import crypto from "node:crypto";
import fs from "node:fs";
import fsp from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import process from "node:process";
import { spawn } from "node:child_process";

const scriptPath = fileURLToPath(import.meta.url);
const scriptDir = path.dirname(scriptPath);
const repoRoot = path.resolve(scriptDir, "..");
const casesPath = path.join(repoRoot, "evals", "codebase-orient-behavioral-cases.json");
const canonicalSkillDir = path.join(repoRoot, "skills", "codebase-orient");
const canonicalSkillPath = path.join(canonicalSkillDir, "SKILL.md");
const defaultOutputRoot = path.join(path.dirname(repoRoot), "codebase-orient-behavioral-eval-artifacts");
const caseArgKeys = new Set(["case-id", "codex-path", "model", "output-root", "inspect-artifact-root", "grade-artifact-root", "timeout-ms"]);

main().catch((error) => {
  const message = error instanceof Error ? error.stack || error.message : String(error);
  console.error(message);
  process.exitCode = 1;
});

async function main() {
  const args = parseArgs(process.argv.slice(2));

  if (args.help) {
    console.log(getUsage());
    return;
  }

  if (args.listCases) {
    const cases = await loadCases();
    console.log(JSON.stringify({
      mode: "list-cases",
      case_ids: cases.map((entry) => entry.id),
    }, null, 2));
    return;
  }

  if (args.inspectArtifactRoot) {
    const diagnostic = await inspectHistoricalArtifact({
      artifactRoot: args.inspectArtifactRoot,
      caseId: args.caseId || "explicit-dry-run-unfamiliar",
    });
    console.log(JSON.stringify(diagnostic, null, 2));
    if (!diagnostic.success) {
      process.exitCode = 1;
    }
    return;
  }

  if (args.gradeArtifactRoot) {
    const replayResult = await gradeArtifactRoot({
      artifactRoot: args.gradeArtifactRoot,
      caseId: args.caseId || "explicit-dry-run-unfamiliar",
    });
    console.log(JSON.stringify(replayResult, null, 2));
    process.exitCode = replayResult.success ? 0 : 1;
    return;
  }

  if (!args.caseId) {
    throw new Error("Missing required --case-id for live execution.");
  }

  const liveResult = await runLiveCase(args);
  console.log(JSON.stringify(liveResult, null, 2));
  process.exitCode = liveResult.success ? 0 : 1;
}

function parseArgs(argv) {
  const args = {
    listCases: false,
    help: false,
    caseId: null,
    codexPath: null,
    model: null,
    outputRoot: defaultOutputRoot,
    inspectArtifactRoot: null,
    gradeArtifactRoot: null,
    timeoutMs: 180000,
  };

  for (let index = 0; index < argv.length; index += 1) {
    const token = argv[index];
    switch (token) {
      case "--help":
      case "-h":
        args.help = true;
        break;
      case "--list-cases":
        args.listCases = true;
        break;
      case "--case-id":
        args.caseId = requireValue(argv, ++index, token);
        break;
      case "--codex-path":
        args.codexPath = requireValue(argv, ++index, token);
        break;
      case "--model":
        args.model = requireValue(argv, ++index, token);
        break;
      case "--output-root":
        args.outputRoot = requireValue(argv, ++index, token);
        break;
      case "--inspect-artifact-root":
        args.inspectArtifactRoot = requireValue(argv, ++index, token);
        break;
      case "--grade-artifact-root":
        args.gradeArtifactRoot = requireValue(argv, ++index, token);
        break;
      case "--timeout-ms":
        args.timeoutMs = Number(requireValue(argv, ++index, token));
        if (!Number.isFinite(args.timeoutMs) || args.timeoutMs <= 0) {
          throw new Error(`Invalid --timeout-ms value: ${args.timeoutMs}`);
        }
        break;
      default:
        if (token.startsWith("--")) {
          const key = token.slice(2);
          if (caseArgKeys.has(key)) {
            throw new Error(`Missing value for ${token}`);
          }
        }
        throw new Error(`Unknown argument: ${token}`);
    }
  }

  return args;
}

function requireValue(argv, index, flag) {
  if (index >= argv.length) {
    throw new Error(`Missing value for ${flag}`);
  }
  return argv[index];
}

function getUsage() {
  return [
    "Usage:",
    "  node scripts/run-behavioral-evals.mjs --list-cases",
    "  node scripts/run-behavioral-evals.mjs --inspect-artifact-root <path> [--case-id <id>]",
    "  node scripts/run-behavioral-evals.mjs --grade-artifact-root <path> [--case-id <id>]",
    "  node scripts/run-behavioral-evals.mjs --case-id <id> [--codex-path <path>] [--model <model>] [--output-root <path>] [--timeout-ms <ms>]",
  ].join(os.EOL);
}

async function loadCases() {
  const raw = await fsp.readFile(casesPath, "utf8");
  const parsed = JSON.parse(raw);
  if (!Array.isArray(parsed)) {
    throw new Error(`Expected case corpus array in ${casesPath}`);
  }
  return parsed;
}

async function inspectHistoricalArtifact({ artifactRoot, caseId }) {
  const caseRoot = path.join(path.resolve(artifactRoot), caseId);
  const passRoot = path.join(caseRoot, "pass-1");
  const tracePath = path.join(passRoot, "trace.jsonl");
  const stderrPath = path.join(passRoot, "stderr.txt");
  const finalMessagePath = path.join(passRoot, "final-message.txt");

  const exists = {
    case_root: await pathExists(caseRoot),
    pass_root: await pathExists(passRoot),
    trace_jsonl: await pathExists(tracePath),
    stderr_txt: await pathExists(stderrPath),
    final_message_txt: await pathExists(finalMessagePath),
  };

  if (!exists.pass_root || !exists.trace_jsonl) {
    return {
      mode: "historical-diagnostic",
      success: false,
      case_id: caseId,
      artifact_root: path.resolve(artifactRoot),
      located_paths: exists,
      reason: "Historical pass artifacts were not found in the expected case/pass layout.",
    };
  }

  const trace = await parseJsonlTrace(tracePath);
  const reachesTurnCompleted = trace.events.some((event) => event?.type === "turn.completed");

  return {
    mode: "historical-diagnostic",
    success: true,
    case_id: caseId,
    artifact_root: path.resolve(artifactRoot),
    located_paths: {
      case_root: caseRoot,
      pass_root: passRoot,
      trace_jsonl: tracePath,
      stderr_txt: exists.stderr_txt ? stderrPath : null,
      final_message_txt: exists.final_message_txt ? finalMessagePath : null,
    },
    observations: {
      trace_event_count: trace.events.length,
      invalid_jsonl_line_count: trace.invalidLines.length,
      reaches_turn_completed: reachesTurnCompleted,
      stderr_present: exists.stderr_txt,
      final_message_present: exists.final_message_txt,
    },
    replay_limitations: {
      full_replay_supported: false,
      rationale: [
        "Historical artifact can be inspected as partial diagnostic evidence only.",
        "The older artifact contract did not persist the child exit code.",
        "The older artifact contract did not persist initial grading snapshots.",
      ],
    },
  };
}

async function runLiveCase(args) {
  const cases = await loadCases();
  const selectedCase = cases.find((entry) => entry.id === args.caseId);
  if (!selectedCase) {
    throw new Error(`Unknown case id: ${args.caseId}`);
  }
  if (selectedCase.execution !== "single") {
    if (selectedCase.execution === "two-pass-rerun" || selectedCase.execution === "two-pass-source-drift") {
      return runTwoPassLiveCase(args, selectedCase);
    }
    throw new Error(`Unsupported case execution type: ${selectedCase.execution}`);
  }

  const codexPath = await findCodexPath(args.codexPath);
  const outputRoot = path.resolve(args.outputRoot);
  await fsp.mkdir(outputRoot, { recursive: true });

  const timestamp = formatTimestamp(new Date());
  const runRoot = path.join(outputRoot, timestamp);
  const caseRoot = path.join(runRoot, selectedCase.id);
  const fixtureRoot = path.join(caseRoot, "fixture");
  const isolatedHomeRoot = path.join(caseRoot, "home");
  const passRoot = path.join(caseRoot, "pass-1");

  await fsp.mkdir(passRoot, { recursive: true });
  await createFixtureRepo(selectedCase.fixture, fixtureRoot);
  const testedSkill = await prepareIsolatedSkillHome(isolatedHomeRoot, fixtureRoot);

  if (!testedSkill.hashes_match) {
    throw new Error("Isolated skill copy hash does not match canonical SKILL.md hash.");
  }

  const initialSnapshots = {
    head_sha: await getHeadShaOrNull(fixtureRoot),
    git_status: await getGitStatus(fixtureRoot),
    non_docs_ai_surface: await snapshotSurface(fixtureRoot),
    docs_ai: await snapshotDocsAi(fixtureRoot),
  };

  const artifactMetadata = {
    case_id: selectedCase.id,
    category: selectedCase.category,
    execution: selectedCase.execution,
    sandbox: selectedCase.sandbox,
    prompt: selectedCase.prompt,
    notes: selectedCase.notes,
    artifact_root: runRoot,
    case_root: caseRoot,
    fixture_root: fixtureRoot,
    runtime: {
      node_version: process.version,
      platform: process.platform,
      codex_path: codexPath,
      timeout_ms: args.timeoutMs,
      output_root: outputRoot,
    },
    tested_skill: testedSkill,
    isolation: {
      env_overrides: {
        USERPROFILE: isolatedHomeRoot,
        HOME: isolatedHomeRoot,
        CODEX_HOME: path.join(isolatedHomeRoot, ".codex"),
      },
      fallback_prevention: "The runner sets USERPROFILE, HOME, and CODEX_HOME to a disposable home containing only the copied codebase-orient skill, and passes --ignore-user-config to codex exec. The disposable CODEX_HOME is seeded with a copy of the real auth.json only, so live cases can authenticate without inheriting any other real Codex state such as registered skills or session history.",
    },
    snapshots: {
      initial: initialSnapshots,
    },
  };

  const metadataPath = path.join(caseRoot, "artifact-metadata.json");
  await writeJson(metadataPath, artifactMetadata);

  const runStartedAt = new Date();
  let executionResult;
  try {
    executionResult = await invokeCodexExec({
      codexPath,
      fixtureRoot,
      prompt: selectedCase.prompt,
      sandbox: selectedCase.sandbox,
      isolatedHomeRoot,
      passRoot,
      timeoutMs: args.timeoutMs,
      model: args.model,
    });
  } catch (error) {
    const runnerFailure = {
      step: "invoke-codex-exec",
      message: error instanceof Error ? error.message : String(error),
      stack: error instanceof Error ? error.stack || null : null,
    };
    await writeJson(path.join(caseRoot, "runner-failure.json"), runnerFailure);
    throw error;
  }

  const runCompletedAt = new Date();
  const finalSnapshots = {
    head_sha: await getHeadShaOrNull(fixtureRoot),
    git_status: await getGitStatus(fixtureRoot),
    non_docs_ai_surface: await snapshotSurface(fixtureRoot),
    docs_ai: await snapshotDocsAi(fixtureRoot),
  };

  artifactMetadata.runtime.started_at = runStartedAt.toISOString();
  artifactMetadata.runtime.completed_at = runCompletedAt.toISOString();
  artifactMetadata.runtime.duration_ms = runCompletedAt.getTime() - runStartedAt.getTime();
  artifactMetadata.runtime.command = {
    executable: codexPath,
    args: executionResult.commandArgs,
  };
  artifactMetadata.runtime.child_exit_code = executionResult.exitCode;
  artifactMetadata.runtime.completion = executionResult.completion;
  artifactMetadata.runtime.timed_out = executionResult.completion === "timeout";
  artifactMetadata.snapshots.final = finalSnapshots;
  artifactMetadata.paths = {
    trace_jsonl: executionResult.tracePath,
    stderr_txt: executionResult.stderrPath,
    final_message_txt: executionResult.finalMessagePath,
  };
  await writeJson(metadataPath, artifactMetadata);

  let summary;
  try {
    summary = await buildSingleRunSummary({
      caseData: selectedCase,
      caseRoot,
      tracePath: executionResult.tracePath,
      stderrPath: executionResult.stderrPath,
      finalMessagePath: executionResult.finalMessagePath,
      executionResult,
      artifactMetadata,
      liveCodexInvokedDuringThisCommand: true,
    });
    await writeJson(path.join(caseRoot, "summary.json"), summary);
  } catch (error) {
    await writeRunnerFailure({
      caseRoot,
      stage: "grade-or-write-summary",
      caseId: selectedCase.id,
      error,
      artifactMetadataPath: metadataPath,
      tracePath: executionResult.tracePath,
      stderrPath: executionResult.stderrPath,
      finalMessagePath: executionResult.finalMessagePath,
    });
    throw error;
  }

  return {
    success: true,
    mode: "live-case",
    case_id: selectedCase.id,
    run_root: runRoot,
    case_root: caseRoot,
    summary_path: path.join(caseRoot, "summary.json"),
    artifact_metadata_path: metadataPath,
    completion: executionResult.completion,
    child_exit_code: executionResult.exitCode,
  };
}

async function runTwoPassLiveCase(args, selectedCase) {
  const codexPath = await findCodexPath(args.codexPath);
  const outputRoot = path.resolve(args.outputRoot);
  await fsp.mkdir(outputRoot, { recursive: true });

  const runRoot = path.join(outputRoot, formatTimestamp(new Date()));
  const caseRoot = path.join(runRoot, selectedCase.id);
  const fixtureRoot = path.join(caseRoot, "fixture");
  const isolatedHomeRoot = path.join(caseRoot, "home");
  await createFixtureRepo(selectedCase.fixture, fixtureRoot);
  const testedSkill = await prepareIsolatedSkillHome(isolatedHomeRoot, fixtureRoot);
  if (!testedSkill.hashes_match) {
    throw new Error("Isolated skill copy hash does not match canonical SKILL.md hash.");
  }

  const initialSnapshots = {
    head_sha: await getHeadShaOrNull(fixtureRoot),
    git_status: await getGitStatus(fixtureRoot),
    non_docs_ai_surface: await snapshotSurface(fixtureRoot),
    docs_ai: await snapshotDocsAi(fixtureRoot),
  };

  const passResults = [];
  for (let passNumber = 1; passNumber <= 2; passNumber += 1) {
    if (passNumber === 2 && selectedCase.execution === "two-pass-source-drift") {
      await fsp.appendFile(path.join(fixtureRoot, "README.md"), "\nSource drift added by the evaluation harness.\n", "utf8");
    }

    const before = {
      head_sha: await getHeadShaOrNull(fixtureRoot),
      git_status: await getGitStatus(fixtureRoot),
      non_docs_ai_surface: await snapshotSurface(fixtureRoot),
      docs_ai: await snapshotDocsAi(fixtureRoot),
    };
    const passRoot = path.join(caseRoot, `pass-${passNumber}`);
    await fsp.mkdir(passRoot, { recursive: true });
    const startedAt = new Date();
    const executionResult = await invokeCodexExec({
      codexPath,
      fixtureRoot,
      prompt: selectedCase.prompt,
      sandbox: selectedCase.sandbox,
      isolatedHomeRoot,
      passRoot,
      timeoutMs: args.timeoutMs,
      model: args.model,
    });
    const completedAt = new Date();
    const after = {
      head_sha: await getHeadShaOrNull(fixtureRoot),
      git_status: await getGitStatus(fixtureRoot),
      non_docs_ai_surface: await snapshotSurface(fixtureRoot),
      docs_ai: await snapshotDocsAi(fixtureRoot),
    };
    const trace = await parseJsonlTrace(executionResult.tracePath);
    passResults.push({
      name: `pass-${passNumber}`,
      started_at: startedAt.toISOString(),
      completed_at: completedAt.toISOString(),
      duration_ms: completedAt.getTime() - startedAt.getTime(),
      child_exit_code: executionResult.exitCode,
      completion: executionResult.completion,
      paths: {
        trace_jsonl: executionResult.tracePath,
        stderr_txt: executionResult.stderrPath,
        final_message_txt: executionResult.finalMessagePath,
      },
      trace: {
        invalid_jsonl_lines: trace.invalidLines,
        evidence: extractTraceEvidence(trace.events),
      },
      snapshots: { before, after },
    });
  }

  const firstDocs = passResults[0].snapshots.after.docs_ai;
  const secondDocs = passResults[1].snapshots.after.docs_ai;
  const docsChangesOnSecondPass = compareSnapshotKeys(firstDocs, secondDocs);
  const secondPassSurfaceChanges = compareSnapshotKeys(
    passResults[1].snapshots.before.non_docs_ai_surface,
    passResults[1].snapshots.after.non_docs_ai_surface,
  );
  const requiredArtifacts = [
    "docs/ai/ORIENTATION_STATE.json",
    "docs/ai/CODEBASE_MAP.md",
    "docs/ai/CHANGE_SURFACES.md",
    "docs/ai/OPEN_QUESTIONS.md",
  ];
  const firstPassCreatedFullPackage = requiredArtifacts.every((file) => file in firstDocs);
  const behaviorSatisfied = selectedCase.execution === "two-pass-rerun"
    ? docsChangesOnSecondPass.length === 0
    : docsChangesOnSecondPass.length > 0;
  const processesCompleted = passResults.every((pass) => pass.child_exit_code === 0 && pass.completion === "completed");
  const success = processesCompleted && firstPassCreatedFullPackage && behaviorSatisfied && secondPassSurfaceChanges.length === 0;

  const metadata = {
    case_id: selectedCase.id,
    category: selectedCase.category,
    execution: selectedCase.execution,
    sandbox: selectedCase.sandbox,
    prompt: selectedCase.prompt,
    notes: selectedCase.notes,
    artifact_root: runRoot,
    case_root: caseRoot,
    fixture_root: fixtureRoot,
    tested_skill: testedSkill,
    snapshots: { initial: initialSnapshots },
    runs: passResults,
  };
  await writeJson(path.join(caseRoot, "artifact-metadata.json"), metadata);

  const summary = {
    success,
    mode: "live-two-pass-case",
    case_id: selectedCase.id,
    execution: selectedCase.execution,
    deterministic_checks: {
      processes_completed: processesCompleted,
      first_pass_created_full_package: firstPassCreatedFullPackage,
      docs_changes_on_second_pass: docsChangesOnSecondPass,
      expected_second_pass_docs_change: selectedCase.execution === "two-pass-source-drift",
      second_pass_non_docs_ai_changes: secondPassSurfaceChanges,
    },
    runs: passResults.map((pass) => ({
      name: pass.name,
      child_exit_code: pass.child_exit_code,
      completion: pass.completion,
      trace_path: pass.paths.trace_jsonl,
      stderr_path: pass.paths.stderr_txt,
      final_message_path: pass.paths.final_message_txt,
      proxy_evidence: pass.trace.evidence,
    })),
  };
  await writeJson(path.join(caseRoot, "summary.json"), summary);

  return {
    success,
    mode: "live-two-pass-case",
    case_id: selectedCase.id,
    run_root: runRoot,
    case_root: caseRoot,
    summary_path: path.join(caseRoot, "summary.json"),
    artifact_metadata_path: path.join(caseRoot, "artifact-metadata.json"),
  };
}

async function gradeArtifactRoot({ artifactRoot, caseId }) {
  const caseRoot = path.join(path.resolve(artifactRoot), caseId);
  const metadataPath = path.join(caseRoot, "artifact-metadata.json");
  const replaySummaryPath = path.join(caseRoot, "replay-summary.json");

  if (!(await pathExists(metadataPath))) {
    return {
      mode: "grade-artifact-root",
      success: false,
      case_id: caseId,
      artifact_root: path.resolve(artifactRoot),
      reason: "Missing artifact-metadata.json; artifact does not support full offline grading.",
    };
  }

  const artifactMetadata = JSON.parse(await readTextFileAuto(metadataPath));
  const initialSnapshots = artifactMetadata?.snapshots?.initial;
  const finalSnapshots = artifactMetadata?.snapshots?.final;
  const childExitCode = artifactMetadata?.runtime?.child_exit_code;
  const completion = artifactMetadata?.runtime?.completion;
  const tracePath = artifactMetadata?.paths?.trace_jsonl;
  const stderrPath = artifactMetadata?.paths?.stderr_txt;
  const finalMessagePath = artifactMetadata?.paths?.final_message_txt;

  if (!initialSnapshots || !finalSnapshots || typeof childExitCode !== "number" || typeof completion !== "string") {
    return {
      mode: "grade-artifact-root",
      success: false,
      case_id: caseId,
      artifact_root: path.resolve(artifactRoot),
      reason: "Artifact metadata is missing persisted exit code, completion, or grading snapshots needed for full offline grading.",
    };
  }

  const cases = await loadCases();
  const caseData = cases.find((entry) => entry.id === caseId) ?? {
    id: artifactMetadata.case_id || caseId,
    category: artifactMetadata.category || "unknown",
    execution: artifactMetadata.execution || "single",
    sandbox: artifactMetadata.sandbox || "unknown",
    prompt: artifactMetadata.prompt || "",
    notes: artifactMetadata.notes || "",
  };

  try {
    const summary = await buildSingleRunSummary({
      caseData,
      caseRoot,
      tracePath,
      stderrPath,
      finalMessagePath,
      executionResult: {
        exitCode: childExitCode,
        completion,
      },
      artifactMetadata,
      liveCodexInvokedDuringThisCommand: false,
    });
    await writeJson(replaySummaryPath, summary);
    return {
      mode: "grade-artifact-root",
      success: true,
      case_id: caseId,
      artifact_root: path.resolve(artifactRoot),
      replay_summary_path: replaySummaryPath,
      trace_path: tracePath,
      stderr_path: stderrPath,
      final_message_path: finalMessagePath,
      live_codex_invoked: false,
    };
  } catch (error) {
    await writeRunnerFailure({
      caseRoot,
      stage: "grade-or-write-summary",
      caseId,
      error,
      failureFileName: "replay-runner-failure.json",
      artifactMetadataPath: metadataPath,
      tracePath,
      stderrPath,
      finalMessagePath,
    });
    throw error;
  }
}

async function buildSingleRunSummary({
  caseData,
  caseRoot,
  tracePath,
  stderrPath,
  finalMessagePath,
  executionResult,
  artifactMetadata,
  liveCodexInvokedDuringThisCommand,
}) {
  const initialSnapshots = requireSnapshots(artifactMetadata.snapshots?.initial, "initial");
  const finalSnapshots = requireSnapshots(artifactMetadata.snapshots?.final, "final");
  const testedSkill = artifactMetadata.tested_skill || {};
  const trace = await parseJsonlTrace(tracePath);
  const evidence = extractTraceEvidence(trace.events);
  const finalMessage = await safeReadFile(finalMessagePath);
  const docsChanged = compareSnapshotKeys(initialSnapshots.docs_ai, finalSnapshots.docs_ai);
  const surfaceChanged = compareSnapshotKeys(initialSnapshots.non_docs_ai_surface, finalSnapshots.non_docs_ai_surface);
  const docsRootExists = Object.keys(finalSnapshots.docs_ai).length > 0;

  return {
    case_id: caseData.id,
    category: caseData.category,
    execution: caseData.execution,
    sandbox: caseData.sandbox,
    prompt: caseData.prompt,
    notes: caseData.notes,
    observability: {
      direct_skill_event_available: evidence.direct_skill_event_available,
      rationale: evidence.direct_skill_event_available
        ? "A dedicated trace event explicitly identified skill invocation."
        : "No dedicated skill-selected or skill-invoked event was observed. Invocation evidence remains proxy evidence based on messages and outcomes.",
    },
    checks: {
      no_commits: initialSnapshots.head_sha === finalSnapshots.head_sha,
      no_docs_written: !docsRootExists,
      docs_exist_after_run: docsRootExists,
      docs_changed: docsChanged.length > 0,
      non_docs_ai_surface_changed: surfaceChanged.length > 0,
      trace_reaches_turn_completed: evidence.reaches_turn_completed,
      proxy_skill_mention_observed: evidence.proxy_skill_mention_observed,
      tested_skill_hashes_match: Boolean(testedSkill.hashes_match),
      tested_skill_isolated: Boolean(testedSkill.isolated_target_path),
    },
    docs_changed: docsChanged,
    surface_changed: surfaceChanged,
    runs: [
      {
        name: "pass-1",
        exit_code: executionResult.exitCode,
        completion: executionResult.completion,
        trace_path: tracePath,
        stderr_path: stderrPath,
        final_message_path: finalMessagePath,
        invalid_jsonl_lines: trace.invalidLines,
        event_types: uniqueSorted(trace.events.map((event) => event?.type).filter(Boolean)),
        proxy_evidence: {
          agent_mentions_skill: evidence.proxy_skill_mention_observed,
          command_count: evidence.command_count,
          command_declines: evidence.command_declines,
          command_failures: evidence.command_failures,
        },
        final_message_excerpt: finalMessage.length > 400 ? finalMessage.slice(0, 400) : finalMessage,
      },
    ],
    tested_skill: {
      canonical_source_path: testedSkill.canonical_source_path || null,
      canonical_sha256: testedSkill.canonical_sha256 || null,
      isolated_target_path: testedSkill.isolated_target_path || null,
      isolated_sha256: testedSkill.isolated_sha256 || null,
      hashes_match: Boolean(testedSkill.hashes_match),
      fallback_prevention: artifactMetadata.isolation?.fallback_prevention || null,
    },
    artifact_context: {
      case_root: caseRoot,
      artifact_metadata_path: path.join(caseRoot, "artifact-metadata.json"),
      live_codex_invoked_during_this_command: liveCodexInvokedDuringThisCommand,
    },
  };
}

function requireSnapshots(snapshotData, label) {
  if (!snapshotData || typeof snapshotData !== "object") {
    throw new Error(`Missing ${label} snapshots in artifact metadata.`);
  }
  if (!("docs_ai" in snapshotData) || !("non_docs_ai_surface" in snapshotData)) {
    throw new Error(`Incomplete ${label} snapshots in artifact metadata.`);
  }
  return snapshotData;
}

async function writeRunnerFailure({
  caseRoot,
  stage,
  caseId,
  error,
  failureFileName = "runner-failure.json",
  artifactMetadataPath,
  tracePath,
  stderrPath,
  finalMessagePath,
}) {
  const runnerFailure = {
    stage,
    case_id: caseId,
    timestamp: new Date().toISOString(),
    message: error instanceof Error ? error.message : String(error),
    stack: error instanceof Error ? error.stack || null : null,
    paths: {
      artifact_metadata_path: artifactMetadataPath || null,
      trace_jsonl: tracePath || null,
      stderr_txt: stderrPath || null,
      final_message_txt: finalMessagePath || null,
    },
  };
  await writeJson(path.join(caseRoot, failureFileName), runnerFailure);
}

async function prepareIsolatedSkillHome(homeRoot, fixtureRoot) {
  await resetDirectory(homeRoot);
  await seedIsolatedCodexHome(homeRoot);
  const isolatedSkillDir = path.join(homeRoot, ".agents", "skills", "codebase-orient");
  await copyDirectory(canonicalSkillDir, isolatedSkillDir);
  const fixtureSkillDir = path.join(fixtureRoot, ".agents", "skills", "codebase-orient");
  await copyDirectory(canonicalSkillDir, fixtureSkillDir);

  const canonicalHash = await sha256File(canonicalSkillPath);
  const isolatedSkillPath = path.join(isolatedSkillDir, "SKILL.md");
  const isolatedHash = await sha256File(isolatedSkillPath);
  const fixtureSkillPath = path.join(fixtureSkillDir, "SKILL.md");
  const fixtureHash = await sha256File(fixtureSkillPath);

  return {
    canonical_source_path: canonicalSkillPath,
    canonical_sha256: canonicalHash,
    isolated_target_path: isolatedSkillPath,
    isolated_sha256: isolatedHash,
    fixture_target_path: fixtureSkillPath,
    fixture_sha256: fixtureHash,
    hashes_match: canonicalHash === isolatedHash && canonicalHash === fixtureHash,
  };
}

async function seedIsolatedCodexHome(homeRoot) {
  const isolatedCodexHome = path.join(homeRoot, ".codex");
  await fsp.mkdir(isolatedCodexHome, { recursive: true });
  const realCodexHome = path.join(process.env.USERPROFILE || os.homedir(), ".codex");
  const realAuthPath = path.join(realCodexHome, "auth.json");
  try {
    await fsp.copyFile(realAuthPath, path.join(isolatedCodexHome, "auth.json"));
  } catch (error) {
    throw new Error(
      `Unable to seed isolated Codex auth from ${realAuthPath}: ${error.message}. ` +
        "Live cases require an authenticated local Codex install; only auth.json is copied, no other real Codex state.",
    );
  }
}

async function createFixtureRepo(fixtureType, fixtureRoot) {
  await resetDirectory(fixtureRoot);
  await runGit(["init"], fixtureRoot);

  switch (fixtureType) {
    case "basic-readme":
      await fsp.writeFile(path.join(fixtureRoot, "README.md"), "# Fixture Repo\n\nSmall disposable repo for codebase-orient behavioral evaluation.\n", "utf8");
      break;
    case "readme-typo":
      await fsp.writeFile(path.join(fixtureRoot, "README.md"), "# Fixture Repo\n\nThis repo has teh one-line typo used for a negative invocation case.\n", "utf8");
      break;
    case "one-file-fix":
      await fsp.writeFile(path.join(fixtureRoot, "README.md"), "# Fixture Repo\n\nSmall repo for a narrow one-file fix.\n", "utf8");
      await fsp.mkdir(path.join(fixtureRoot, "src"), { recursive: true });
      await fsp.writeFile(path.join(fixtureRoot, "src", "app.js"), 'const userNmae = "demo";\nconsole.log(userNmae);\n', "utf8");
      break;
    default:
      throw new Error(`Unknown fixture type: ${fixtureType}`);
  }
}

async function invokeCodexExec({
  codexPath,
  fixtureRoot,
  prompt,
  sandbox,
  isolatedHomeRoot,
  passRoot,
  timeoutMs,
  model,
}) {
  const tracePath = path.join(passRoot, "trace.jsonl");
  const stderrPath = path.join(passRoot, "stderr.txt");
  const finalMessagePath = path.join(passRoot, "final-message.txt");
  const traceStream = fs.createWriteStream(tracePath, { encoding: "utf8" });
  const stderrStream = fs.createWriteStream(stderrPath, { encoding: "utf8" });
  const env = {
    ...process.env,
    USERPROFILE: isolatedHomeRoot,
    HOME: isolatedHomeRoot,
    CODEX_HOME: path.join(isolatedHomeRoot, ".codex"),
  };
  const commandArgs = [
    "exec",
    "--json",
    "--ignore-user-config",
    "--skip-git-repo-check",
    "--sandbox",
    sandbox,
    "--cd",
    fixtureRoot,
    "--output-last-message",
    finalMessagePath,
  ];
  if (model) {
    commandArgs.push("--model", model);
  }
  commandArgs.push(prompt);

  const child = spawn(codexPath, commandArgs, {
    cwd: repoRoot,
    env,
    stdio: ["ignore", "pipe", "pipe"],
    windowsHide: true,
  });

  child.stdout.pipe(traceStream);
  child.stderr.pipe(stderrStream);

  let timedOut = false;
  const timeoutHandle = setTimeout(() => {
    timedOut = true;
    child.kill("SIGTERM");
    setTimeout(() => {
      if (!child.killed) {
        child.kill("SIGKILL");
      }
    }, 5000).unref();
  }, timeoutMs);

  const result = await new Promise((resolve, reject) => {
    child.once("error", reject);
    child.once("close", (code, signal) => {
      clearTimeout(timeoutHandle);
      resolve({
        code,
        signal,
      });
    });
  }).finally(async () => {
    traceStream.end();
    stderrStream.end();
    await Promise.all([
      onceFinished(traceStream),
      onceFinished(stderrStream),
    ]);
  });

  return {
    commandArgs,
    exitCode: result.code,
    signal: result.signal,
    completion: timedOut ? "timeout" : "completed",
    tracePath,
    stderrPath,
    finalMessagePath,
  };
}

function extractTraceEvidence(events) {
  const agentMessages = [];
  const commandEvents = [];
  let directSkillEvent = false;

  for (const event of events) {
    if (!event || typeof event !== "object") {
      continue;
    }

    if (typeof event.type === "string" && event.type.toLowerCase().includes("skill")) {
      directSkillEvent = true;
    }

    const item = event.item;
    if (item?.type === "agent_message") {
      if (typeof item.text === "string") {
        agentMessages.push(item.text);
      }
      if (Array.isArray(item.content)) {
        for (const part of item.content) {
          if (typeof part?.text === "string") {
            agentMessages.push(part.text);
          }
        }
      }
    }

    if (item?.type === "command_execution") {
      commandEvents.push(item);
    }
  }

  const proxySkillMentionObserved = agentMessages.some((text) => text.includes("codebase-orient"));

  return {
    direct_skill_event_available: directSkillEvent,
    proxy_skill_mention_observed: proxySkillMentionObserved,
    command_count: commandEvents.length,
    command_declines: commandEvents.filter((item) => item.status === "declined").length,
    command_failures: commandEvents.filter((item) => item.status === "failed").length,
    reaches_turn_completed: events.some((event) => event?.type === "turn.completed"),
  };
}

async function parseJsonlTrace(filePath) {
  if (!(await pathExists(filePath))) {
    return { events: [], invalidLines: [] };
  }

  const raw = await readTextFileAuto(filePath);
  const lines = raw.split(/\r?\n/).filter((line) => line.trim() !== "");
  const events = [];
  const invalidLines = [];

  for (const line of lines) {
    try {
      events.push(JSON.parse(line));
    } catch {
      invalidLines.push(line);
    }
  }

  return { events, invalidLines };
}

async function snapshotSurface(repoPath) {
  const files = await collectFiles(repoPath, (fullPath) => {
    return !fullPath.includes(`${path.sep}.git${path.sep}`)
      && !fullPath.includes(`${path.sep}.agents${path.sep}`)
      && !fullPath.includes(`${path.sep}docs${path.sep}ai${path.sep}`);
  });
  return snapshotFiles(repoPath, files);
}

async function snapshotDocsAi(repoPath) {
  const docsRoot = path.join(repoPath, "docs", "ai");
  if (!(await pathExists(docsRoot))) {
    return {};
  }
  const files = await collectFiles(docsRoot, () => true);
  return snapshotFiles(repoPath, files);
}

async function collectFiles(rootPath, predicate) {
  const files = [];
  const entries = await fsp.readdir(rootPath, { withFileTypes: true });
  for (const entry of entries) {
    const fullPath = path.join(rootPath, entry.name);
    if (entry.isDirectory()) {
      files.push(...await collectFiles(fullPath, predicate));
    } else if (entry.isFile() && predicate(fullPath)) {
      files.push(fullPath);
    }
  }
  return files.sort();
}

async function snapshotFiles(repoPath, files) {
  const snapshot = {};
  for (const fullPath of files) {
    const relative = path.relative(repoPath, fullPath).split(path.sep).join("/");
    snapshot[relative] = await sha256File(fullPath);
  }
  return snapshot;
}

function compareSnapshotKeys(before, after) {
  const keys = new Set([...Object.keys(before), ...Object.keys(after)]);
  return Array.from(keys).filter((key) => before[key] !== after[key]).sort();
}

async function getHeadShaOrNull(repoPath) {
  try {
    const result = await runGit(["rev-parse", "HEAD"], repoPath);
    return result.stdout.trim() || null;
  } catch {
    return null;
  }
}

async function getGitStatus(repoPath) {
  const result = await runGit(["status", "--short", "--branch", "--untracked-files=all"], repoPath);
  return result.stdout.split(/\r?\n/).filter(Boolean);
}

async function runGit(args, cwd) {
  return new Promise((resolve, reject) => {
    const child = spawn("git", args, {
      cwd,
      stdio: ["ignore", "pipe", "pipe"],
      windowsHide: true,
    });
    let stdout = "";
    let stderr = "";
    child.stdout.on("data", (chunk) => {
      stdout += chunk;
    });
    child.stderr.on("data", (chunk) => {
      stderr += chunk;
    });
    child.once("error", reject);
    child.once("close", (code) => {
      if (code === 0) {
        resolve({ stdout, stderr });
      } else {
        reject(new Error(`git ${args.join(" ")} failed in ${cwd}: ${stderr || stdout}`));
      }
    });
  });
}

async function findCodexPath(requestedPath) {
  if (requestedPath) {
    return path.resolve(requestedPath);
  }

  const candidates = [
    process.env.LOCALAPPDATA ? path.join(process.env.LOCALAPPDATA, "OpenAI", "Codex", "bin", "codex.exe") : null,
    process.env.USERPROFILE ? path.join(process.env.USERPROFILE, ".codex", ".sandbox-bin", "codex.exe") : null,
  ].filter(Boolean);

  for (const candidate of candidates) {
    if (await pathExists(candidate)) {
      return candidate;
    }
  }

  const lookup = process.env.PATHEXT ? process.env.PATHEXT.split(";") : [""];
  for (const directory of (process.env.PATH || "").split(path.delimiter)) {
    if (!directory) {
      continue;
    }
    for (const extension of lookup) {
      const candidate = path.join(directory, extension ? `codex${extension.toLowerCase()}` : "codex");
      if (await pathExists(candidate)) {
        return candidate;
      }
    }
    const plainCandidate = path.join(directory, "codex.exe");
    if (await pathExists(plainCandidate)) {
      return plainCandidate;
    }
  }

  throw new Error("Unable to find a runnable Codex CLI. Pass --codex-path explicitly.");
}

async function writeJson(filePath, value) {
  await fsp.writeFile(filePath, `${JSON.stringify(value, null, 2)}\n`, "utf8");
}

async function safeReadFile(filePath) {
  try {
    return await readTextFileAuto(filePath);
  } catch {
    return "";
  }
}

async function readTextFileAuto(filePath) {
  const buffer = await fsp.readFile(filePath);
  if (buffer.length >= 2 && buffer[0] === 0xff && buffer[1] === 0xfe) {
    return buffer.toString("utf16le");
  }
  if (buffer.length >= 4 && buffer[1] === 0x00 && buffer[3] === 0x00) {
    return buffer.toString("utf16le");
  }
  return buffer.toString("utf8");
}

async function sha256File(filePath) {
  const hash = crypto.createHash("sha256");
  const buffer = await fsp.readFile(filePath);
  hash.update(buffer);
  return hash.digest("hex");
}

async function resetDirectory(dirPath) {
  await fsp.rm(dirPath, { recursive: true, force: true });
  await fsp.mkdir(dirPath, { recursive: true });
}

async function copyDirectory(sourceDir, targetDir) {
  await fsp.mkdir(targetDir, { recursive: true });
  const entries = await fsp.readdir(sourceDir, { withFileTypes: true });
  for (const entry of entries) {
    const sourcePath = path.join(sourceDir, entry.name);
    const targetPath = path.join(targetDir, entry.name);
    if (entry.isDirectory()) {
      await copyDirectory(sourcePath, targetPath);
    } else if (entry.isFile()) {
      await fsp.copyFile(sourcePath, targetPath);
    }
  }
}

function uniqueSorted(values) {
  return Array.from(new Set(values)).sort();
}

function formatTimestamp(date) {
  const parts = [
    date.getFullYear(),
    pad(date.getMonth() + 1),
    pad(date.getDate()),
  ];
  const time = [
    pad(date.getHours()),
    pad(date.getMinutes()),
    pad(date.getSeconds()),
  ];
  return `${parts.join("")}-${time.join("")}`;
}

function pad(value) {
  return String(value).padStart(2, "0");
}

async function pathExists(targetPath) {
  try {
    await fsp.access(targetPath);
    return true;
  } catch {
    return false;
  }
}

function onceFinished(stream) {
  if (stream.writableFinished) {
    return Promise.resolve();
  }
  return new Promise((resolve, reject) => {
    stream.once("finish", resolve);
    stream.once("error", reject);
  });
}

function fileURLToPath(fileUrl) {
  return new URL(fileUrl).pathname.replace(/^\/([A-Za-z]:)/, "$1").replace(/\//g, path.sep);
}
