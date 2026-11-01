#!/usr/bin/env bash
# Security gate consistency checks — fails when the mounted gate drifts
# between the two execution modes, or when a template loses a section,
# a criteria face, a forbidden sentence guard, or its size bound.
#
# Idempotent: no git state, no network, no subagent. Style follows
# tests/skill-size/test-skill-size.sh. Usage: tests/security-gate/test-security-gate.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SR="$REPO_ROOT/skills/requesting-code-review/security-reviewer.md"
RR="$REPO_ROOT/skills/requesting-code-review/security-re-review-prompt.md"
SDD="$REPO_ROOT/skills/subagent-driven-development/references/final-review.md"
EP="$REPO_ROOT/skills/executing-plans/SKILL.md"

fail=0
ck() { if eval "$2"; then echo "ok: $1"; else echo "FAIL: $1" >&2; fail=1; fi; }

# 断言 1：两模板文件存在
ck "reviewer-template-exists" "[ -f \"$SR\" ]"
ck "rereview-template-exists" "[ -f \"$RR\" ]"

# 断言 2：审查者模板五个节名、源清单五项、汇清单六项
for s in "## 输入" "## 检查结构" "## 快速放行" "## 输出格式"; do
  ck "reviewer-section:$s" "grep -q '$s' \"$SR\""
done
for w in 用户输入 网络 环境变量 "LLM/工具输出" 命令执行 SQL 路径拼接 "URL 请求" 反序列化 "HTML 渲染"; do
  ck "structure-word:$w" "grep -q '$w' \"$SR\""
done

# 断言 3：判据五面，每面词 3 行窗口内有其映射源词（机械判定：行号差 ≤ 3）
SEC=$(awk '/## 快速放行/{f=1;next}/## /{f=0}f' "$SR")
FACE_LINES=$(echo "$SEC" | grep -n '外部输入处理\|认证授权\|密钥/依赖\|外部通信\|LLM 输入/输出处理' | cut -d: -f1)
[ "$(echo "$FACE_LINES" | grep -c .)" = 5 ] || { echo "FAIL: gate-five-faces" >&2; fail=1; }
MAP_OK=1
for ln in $FACE_LINES; do
  echo "$SEC" | sed -n "${ln},$((ln+3))p" | grep -q '用户输入\|文件\|网络\|环境变量\|LLM/工具输出\|认证授权边界\|密钥与依赖\|URL 请求' || MAP_OK=0
done
ck "gate-face-source-mapping" "[ \"$MAP_OK\" = 1 ]"

# 断言 4：禁句正则（两模板）
for f in "$SR" "$RR"; do
  ck "no-after-final-review:$(basename "$f")" "! grep -Eq '(还会|之后|后续)[^。]*终审' \"$f\""
done

# 断言 5：两文件安全门段逐行 diff ≤ 2 行（提取：标题行起，至下一个以 # 开头的标题行止）
extract() { awk 'f && /^#/{exit} /^### 安全门/{f=1} f' "$1"; }
DIFFN=$(diff <(extract "$SDD") <(extract "$EP") | grep -c '^[<>]' || true)
ck "gate-section-diff-le2" "[ \"\${DIFFN:-99}\" -le 2 ]"

# 断言 6：台账行格式三条 + [已修复] 前缀（两文件各查）；收集追加句存在且位于 finishing 句之前
APPEND='安全门的全部行（clean-pass、裁决、minor deferred、self-review）收进你最终消息的 Security gate 小节，其中裁决行同时进 Rulings I made。'
for f in "$SDD" "$EP"; do
  n=$(basename "$f")
  ck "ledger-clean-pass:$n"     "grep -q 'Final: security-gate: clean-pass:' \"$f\""
  ck "ledger-minor-deferred:$n" "grep -q 'Final: security-gate: minor (deferred):' \"$f\""
  ck "ledger-self-review:$n"    "grep -q 'Final: security-gate: self-review (no subagent tool)' \"$f\""
  ck "fixed-prefix:$n"          "grep -qF '\`[已修复] \` 前缀' \"$f\""
  ck "append-sentence:$n"       "grep -qF \"$APPEND\" \"$f\""
  ck "append-before-finishing:$n" "[ \"\$(grep -nF \"$APPEND\" \"$f\" | head -1 | cut -d: -f1)\" -lt \"\$(grep -n '使用 superpowers:finishing-a-development-branch。' \"$f\" | tail -1 | cut -d: -f1)\" ]"
done

# 断言 7：复审模板六占位符、四输出节名、「## 测试」节
for p in '\[MODEL\]' '\[FINDINGS\]' '\[REPORT_FILE\]' '\[FIX_BASE_SHA\]' '\[HEAD_SHA\]' '\[DIFF_FILE\]'; do
  ck "rereview-placeholder:$p" "grep -q '$p' \"$RR\""
done
for s in '### Finding Verdicts' '### New Security Issues in the Fix Diff' '### Out-of-Scope Observations' '### Verdict' '## 测试'; do
  ck "rereview-section:$s" "grep -qF '$s' \"$RR\""
done

# 断言 8：字节上限
ck "reviewer-size-le-12000" "[ \"\$(wc -c < \"$SR\")\" -le 12000 ]"
ck "rereview-size-le-8000"  "[ \"\$(wc -c < \"$RR\")\" -le 8000 ]"

if [ "$fail" -ne 0 ]; then
  echo "Two execution modes disagree, or a template lost required structure. See FAIL lines above." >&2
  exit 1
fi
echo "PASS: security gate consistent across both execution modes"
