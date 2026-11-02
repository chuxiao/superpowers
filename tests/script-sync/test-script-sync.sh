#!/usr/bin/env bash
# Script sync checks — fails when a duplicated helper script drifts between
# the skills that each carry their own copy. Duplication is deliberate: every
# skill stays self-contained so per-skill harness installs keep working. The
# failure mode this test pins is drift between copies, not the duplication.
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

check_pair check-tables.sh skills/brainstorming/scripts/check-tables.sh skills/writing-plans/scripts/check-tables.sh
check_pair check-mermaid.sh skills/brainstorming/scripts/check-mermaid.sh skills/writing-plans/scripts/check-mermaid.sh
check_pair review-package skills/subagent-driven-development/scripts/review-package skills/final-review/scripts/review-package
check_pair sdd-workspace skills/subagent-driven-development/scripts/sdd-workspace skills/final-review/scripts/sdd-workspace

if [ "$fail" -eq 0 ]; then echo "=== script sync: all green ==="; fi
exit "$fail"
