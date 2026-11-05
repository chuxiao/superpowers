#!/usr/bin/env bash
# Script sync checks — fails when a duplicated helper script drifts between
# the skills that each carry their own copy. Duplication is deliberate: every
# skill stays self-contained so per-skill harness installs keep working. The
# failure mode this test pins is drift between copies, not the duplication.
#
# 2026-11-05 design-and-plan 合并收尾：brainstorming 与 writing-plans 两目录已删除，
# 其各自携带的 check-tables.sh / check-mermaid.sh 双份副本不复存在（合并后归一到
# skills/design-and-plan/scripts/ 单份），原两对同步对象消亡，对应检查移除。
# 仍在位的双份脚本仅剩 subagent-driven-development 与 requesting-code-review 的
# review-package 与 sdd-workspace 两对（本套件改为只检查这两对）。
#
# Idempotent: no git state, no network, no subagent. Style follows
# tests/security-gate/test-security-gate.sh. Usage: tests/script-sync/test-script-sync.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

fail=0
ck() { if eval "$2"; then echo "ok: $1"; else echo "FAIL: $1" >&2; fail=1; fi; }

check_pair() {
  local name="$1" a="$2" b="$3"
  ck "pair-exists:$name" "[ -f \"$REPO_ROOT/$a\" ] && [ -f \"$REPO_ROOT/$b\" ]"
  ck "pair-identical:$name" "cmp -s \"$REPO_ROOT/$a\" \"$REPO_ROOT/$b\""
}

check_pair review-package skills/subagent-driven-development/scripts/review-package skills/requesting-code-review/scripts/review-package
check_pair sdd-workspace skills/subagent-driven-development/scripts/sdd-workspace skills/requesting-code-review/scripts/sdd-workspace

if [ "$fail" -eq 0 ]; then echo "=== script sync: all green ==="; fi
exit "$fail"
