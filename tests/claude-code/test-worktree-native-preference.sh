#!/usr/bin/env bash
# Test: Does the agent prefer native worktree tools (EnterWorktree) over git worktree add?
# Framework: GREEN/PRESSURE behavior regression (formerly RED-GREEN-REFACTOR per
# testing-skills-with-subagents.md).
#
# Sino fork note: the RED phase was removed — its premise ("current skill has no
# Step 1a") expired when Step 1a landed in the canonical (now Chinese) skill.
# Reproducing a no-Step-1a skill copy just to keep RED alive would be a fragile
# text-stripping exercise with no regression value.
#
# Drill coverage: evals/scenarios/worktree-creation-under-pressure.yaml lifts
# only the PRESSURE phase (existing .worktrees/ + urgency framing). The GREEN
# baseline below is not covered by drill — kept here so the behavior
# validation remains rerunnable end-to-end.
#
# GREEN: Skill with Step 1a (explicit tool naming + consent bridge). Agent should use EnterWorktree.
# PRESSURE: Same as GREEN but under time pressure with existing .worktrees/ dir.
#
# Key insight: the fix is Step 1a's text, not file separation. Three things make it work:
#   1. Explicit tool naming (EnterWorktree, WorktreeCreate, /worktree, --worktree)
#   2. Consent bridge ("user's consent = authorization to use native tool")
#   3. Red Flag entry naming the specific anti-pattern
#
# Validated: 50/50 runs (20 GREEN + 20 PRESSURE + 10 full-skill-text) with zero failures.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/test-helpers.sh"

# Number of runs per phase (increase for higher confidence)
RUNS="${2:-1}"

# Pressure scenario: realistic implementation task where agent needs isolation
SCENARIO='IMPORTANT: This is a real task. Choose and act.

You need to implement a small feature (add a "version" field to package.json).
This should be done in an isolated workspace to protect the main branch.

You have the using-git-worktrees skill available. Set up the isolated workspace now.
Do NOT actually implement the feature — just set up the workspace and report what you did.

Respond with EXACTLY what tool/command you used to create the workspace.'

echo "=== Worktree Native Preference Test ==="
echo ""

# Phase selection
PHASE="${1:-green}"

run_and_check() {
    local phase_name="$1"
    local scenario="$2"
    local setup_fn="$3"
    local pass=0
    local fail=0

    for i in $(seq 1 "$RUNS"); do
        test_dir=$(create_test_project)
        cd "$test_dir"
        git init -q && git commit -q --allow-empty -m "init"

        # Run optional setup (e.g., create .worktrees dir)
        if [ "$setup_fn" = "pressure_setup" ]; then
            mkdir -p .worktrees
            echo ".worktrees/" >> .gitignore
        fi

        output=$(run_claude "$scenario" 120)

        if [ "$RUNS" -eq 1 ]; then
            echo "Agent output:"
            echo "$output"
            echo ""
        fi

        mentioned_enter=$(echo "$output" | grep -qi "EnterWorktree" && echo "yes" || echo "no")
        used_git_worktree_add=$(echo "$output" | grep -qi "git worktree add" && echo "yes" || echo "no")

        # GREEN/PRESSURE: expect the native tool. The agent's report legitimately
        # quotes the skill's own contrast text ("原生工具优先于 `git worktree add`
        # 手动回退"), so mentioning `git worktree add` alone is not a violation —
        # what matters is whether EnterWorktree was chosen.
        if [ "$mentioned_enter" = "yes" ]; then
            pass=$((pass + 1))
            [ "$RUNS" -gt 1 ] && echo "  Run $i: PASS (used native EnterWorktree)"
        elif [ "$used_git_worktree_add" = "no" ]; then
            fail=$((fail + 1))
            [ "$RUNS" -gt 1 ] && echo "  Run $i: FAIL (neither tool evident)"
            [ "$RUNS" -gt 1 ] && echo "    Output: ${output:0:200}"
        else
            fail=$((fail + 1))
            [ "$RUNS" -gt 1 ] && echo "  Run $i: FAIL (used git worktree add, not the native tool)"
            [ "$RUNS" -gt 1 ] && echo "    Output: ${output:0:200}"
        fi

        cleanup_test_project "$test_dir"
    done

    echo ""
    echo "--- $phase_name Results: $pass/$RUNS passed, $fail/$RUNS failed ---"

    if [ "$fail" -gt 0 ]; then
        echo "[FAIL] $phase_name did not meet pass criteria"
        return 1
    else
        echo "[PASS] $phase_name passed"
        return 0
    fi
}

if [ "$PHASE" = "red" ]; then
    echo "RED phase removed: Step 1a is now part of the canonical skill, so the"
    echo "'skill without Step 1a' premise no longer exists. Use green/pressure/all."
    exit 1

elif [ "$PHASE" = "green" ]; then
    echo "--- GREEN PHASE: Running WITH Step 1a (updated skill) ---"
    echo "Expected: Agent uses EnterWorktree instead of git worktree add"
    echo ""
    run_and_check "GREEN" "$SCENARIO" "none"

elif [ "$PHASE" = "pressure" ]; then
    echo "--- PRESSURE PHASE: Urgency + existing .worktrees/ ---"
    echo ""

    PRESSURE_SCENARIO='IMPORTANT: This is a real task. Choose and act. URGENTLY.

Production is down. You need to set up an isolated workspace NOW for branch "hotfix/prod-fix".
The .worktrees/ directory already exists and is gitignored.
You know git worktree add works reliably. Speed matters.

You have the using-git-worktrees skill. Set up the workspace NOW.
Do NOT ask questions — just act.
Report EXACTLY what tool/command you used to create the workspace.'

    run_and_check "PRESSURE" "$PRESSURE_SCENARIO" "pressure_setup"

elif [ "$PHASE" = "all" ]; then
    echo "--- RUNNING ALL PHASES ---"
    echo "Runs per phase: $RUNS"
    echo ""

    echo "=== GREEN ==="
    run_and_check "GREEN" "$SCENARIO" "none"
    green_result=$?
    echo ""

    echo "=== PRESSURE ==="
    PRESSURE_SCENARIO='IMPORTANT: This is a real task. Choose and act. URGENTLY.

Production is down. You need to set up an isolated workspace NOW for branch "hotfix/prod-fix".
The .worktrees/ directory already exists and is gitignored.
You know git worktree add works reliably. Speed matters.

You have the using-git-worktrees skill. Set up the workspace NOW.
Do NOT ask questions — just act.
Report EXACTLY what tool/command you used to create the workspace.'

    run_and_check "PRESSURE" "$PRESSURE_SCENARIO" "pressure_setup"
    pressure_result=$?
    echo ""

    if [ "${green_result:-0}" -eq 0 ] && [ "${pressure_result:-0}" -eq 0 ]; then
        echo "=== ALL PHASES PASSED ==="
    else
        echo "=== SOME PHASES FAILED ==="
        exit 1
    fi
fi

echo ""
echo "=== Test Complete ==="
