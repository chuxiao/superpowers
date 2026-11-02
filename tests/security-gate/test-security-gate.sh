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
SDD="$REPO_ROOT/skills/requesting-code-review/references/closeout.md"
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
  ck "no-after-requesting-code-review:$(basename "$f")" "! grep -Eq '(还会|之后|后续)[^。]*终审' \"$f\""
done

# 断言 5：单一权威源——安全门规则全文唯一存在于 requesting-code-review 技能的收口规程
# （references 文件无 SKILL.md 的 compaction 字节上限），两执行技能只保留接力句。
# 单一源使两执行方式的措辞漂移在结构上不可能（设计风险 2 的更强解）。
extract() { awk 'f && /^#/{exit} /^### 安全门/{f=1} f' "$1"; }
ck "gate-authoritative-section" "[ -n \"\$(extract \"$SDD\")\" ]"
ck "ep-no-gate-rules"           "! grep -Eq '### 安全门|Final: security-gate:' \"$EP\" && ! grep -qF '收进你最终消息的 Security gate 小节' \"$EP\""
ck "ep-gate-must-pass"          "grep -q '所有分支必过' \"$SDD\""

# 断言 6：台账行格式三条 + [已修复] 前缀（权威源 closeout.md）；收集追加句
# 仅权威源查、且位于 integration-verification 句之前
APPEND='安全门的全部行（clean-pass、裁决、minor deferred、self-review）收进你最终消息的 Security gate 小节，其中裁决行同时进 Rulings I made。'
ck "ledger-clean-pass"     "grep -q 'Final: security-gate: clean-pass:' \"$SDD\""
ck "ledger-minor-deferred" "grep -q 'Final: security-gate: minor (deferred):' \"$SDD\""
ck "ledger-self-review"    "grep -q 'Final: security-gate: self-review (no subagent tool)' \"$SDD\""
ck "fixed-prefix"          "grep -qF '\`[已修复] \` 前缀' \"$SDD\""
for f in "$SDD"; do
  n=$(basename "$f")
  ck "append-sentence:$n"       "grep -qF \"$APPEND\" \"$f\""
  ck "append-before-integration-verification:$n" "[ \"\$(grep -nF \"$APPEND\" \"$f\" | head -1 | cut -d: -f1)\" -lt \"\$(grep -n '使用 superpowers:integration-verification' \"$f\" | tail -1 | cut -d: -f1)\" ]"
done

# 断言 6b：行为承重句持久锁——门模板的四条行为边界、「文件」窄解，
# 收口规程的安全修复轮与发现项台账格式，复审模板的最强档例外声明。
ck "rev-missing-findings-note" "grep -q '未提供' \"$SR\""
ck "rev-non-security-obs"      "grep -q 'Non-Security' \"$SR\""
ck "rev-fixed-prefix-skip"     "grep -qF '\`[已修复] \` 前缀' \"$SR\""
ck "rev-four-element-findings" "grep -q '可被利用' \"$SR\""
ck "rev-file-narrow-source"    "grep -q '不可信来源' \"$SR\""
ck "gate-finding-ledger-line"  "grep -qF 'Final: security-gate: finding (<severity>): <one-liner>' \"$SDD\""
ck "gate-one-round-rule"       "grep -q '不存在第二轮安全修复' \"$SDD\""
ck "rereview-model-exception"  "grep -q '低档规则不适用于安全门复审' \"$RR\""

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
