#!/usr/bin/env bash
# Fails when any skill's SKILL.md reaches Claude Code's compaction cut.
#
# After a compaction, Claude Code re-attaches each invoked skill truncated to
# 20,000 characters (#2481). Anything past the cut is gone from the agent's
# context for the rest of the session unless it re-reads the file. Content a
# skill only needs sometimes belongs in references/, where the agent reads it
# fresh from disk at the step that needs it.
#
# Measures bytes, which is stricter than characters for files with non-ASCII
# text. Usage: tests/skill-size/test-skill-size.sh
#
# 门值依据：design-and-plan 为三合一合并技能（对话纪律 + 计划原则 + 实现设计规则），
# 2026-11-06 经需求方确认上调至 24000；references 外置纪律不变。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LIMIT=24000

failed=0
for skill in "$REPO_ROOT"/skills/*/SKILL.md; do
  size=$(wc -c <"$skill" | tr -d ' ')
  if ((size >= LIMIT)); then
    echo "FAIL: ${skill#"$REPO_ROOT"/} is $size bytes (limit: under $LIMIT)" >&2
    failed=1
  fi
done

if ((failed)); then
  echo "Move content the skill only needs sometimes into its references/ directory." >&2
  exit 1
fi
echo "PASS: every SKILL.md is under $LIMIT bytes"
