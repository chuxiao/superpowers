#!/usr/bin/env bash
# Integration verification & regression sweep consistency checks — fails when
# either new skill, its form references, or one of the four mounting edits
# drifts from the integration-gate design
# (docs/superpowers/specs/2026-11-01-integration-gate-and-regression-design.md).
#
# Idempotent: no git state, no network, no subagent. Style follows
# tests/security-gate/test-security-gate.sh. Usage:
# tests/integration-verification/test-integration-verification.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
IV="$REPO_ROOT/skills/integration-verification/SKILL.md"
RS="$REPO_ROOT/skills/regression-sweep/SKILL.md"
BK="$REPO_ROOT/skills/integration-verification/references/backend.md"
WB="$REPO_ROOT/skills/integration-verification/references/web.md"
MB="$REPO_ROOT/skills/integration-verification/references/mobile.md"
CR="$REPO_ROOT/skills/requesting-code-review/SKILL.md"
CO="$REPO_ROOT/skills/requesting-code-review/references/closeout.md"
FIN="$REPO_ROOT/skills/finishing-a-development-branch/SKILL.md"
WP="$REPO_ROOT/skills/writing-plans/SKILL.md"
PT="$REPO_ROOT/skills/writing-plans/references/plan-template.md"
MERMAID="$REPO_ROOT/skills/brainstorming/scripts/check-mermaid.sh"
SIZE="$REPO_ROOT/tests/skill-size/test-skill-size.sh"

fail=0
ck() { if eval "$2"; then echo "ok: $1"; else echo "FAIL: $1" >&2; fail=1; fi; }

# 断言 1：两技能 SKILL.md 存在且 frontmatter name 正确
ck "iv-skill-exists" "[ -f \"$IV\" ]"
ck "rs-skill-exists" "[ -f \"$RS\" ]"
ck "iv-frontmatter-name" "grep -q '^name: integration-verification' \"$IV\""
ck "rs-frontmatter-name" "grep -q '^name: regression-sweep' \"$RS\""

# 断言 2：integration-verification 八小节节名齐全（Task 1 口径）+ 文件集约定节
for s in "## 触发" "## Step 1 全量测试套件" "## 快速放行" "## Step 2 分层验证" "## 失败定性裁决" "## 环境受限降级" "## 出口" "## 台账记录" "## 项目级方案文件集与登记册约定"; do
  ck "iv-section:$s" "grep -qF '$s' \"$IV\""
done

# 断言 2b：regression-sweep 相应小节节名齐全
for s in "## 触发" "## 项目级方案文件集" "## 执行（全量重跑）" "## 失败归因与集中呈现" "## 失败定性裁决" "## 首次回归" "## 报告落盘" "## 台账记录" "## 出口"; do
  ck "rs-section:$s" "grep -qF '$s' \"$RS\""
done

# 断言 3：三份形态参考存在且 ≤ 8000 字节
for f in "$BK" "$WB" "$MB"; do
  ck "reference-exists:$(basename "$f")" "[ -f \"$f\" ]"
  ck "reference-size-le-8000:$(basename "$f")" "[ \"\$(wc -c < \"$f\")\" -le 8000 ]"
done

# 断言 4：登记册条目格式行逐字存在（T1 定义、T2 引用、finishing 并入小节逐字引用）
ENTRY='- <场景id> | <层级 L1|L2|L3|兼容> | <资产路径> | <状态 normal|待合并|已知不修> | <期望一句话>'
# 模式以 - 开头，须用 -e 显式指定（同 Task 1 自查记录的坑）
ck "registry-entry-format:SKILL.md(integration-verification)" "grep -qF -e '$ENTRY' \"$IV\""
ck "registry-entry-format:SKILL.md(regression-sweep)" "grep -qF -e '$ENTRY' \"$RS\""
ck "registry-entry-format:SKILL.md(finishing-a-development-branch)" "grep -qF -e '$ENTRY' \"$FIN\""

# 断言 5：两处移交句指向 integration-verification——收官流程图节点与 closeout 末行
# （closeout 末行为「取值句 + 移交链句」复合形式，按分句匹配，不按末行整行精确匹配）
IVNODE='CO --> IV["使用 superpowers:integration-verification"]'
ck "iv-mount-flowchart:requesting-code-review" "grep -qF '$IVNODE' \"$CR\""
ck "iv-mount-in-closeout" "grep -qF '使用 superpowers:integration-verification。' \"$CO\""
ck "iv-handoff-chain-in-closeout" "grep -qF '集成验证完成后再移交 superpowers:finishing-a-development-branch' \"$CO\""
# 反向：closeout 不得回退为直接移交 finishing（移交对象仍是集成验证技能）
ck "no-direct-finishing-handoff" "! grep -qF '使用 superpowers:finishing-a-development-branch。' \"$CO\""

# 断言 6：finishing 免跑三判据词 + 结果过期移交 + 验证方案并入小节
ck "fin-exit-credential" "grep -qF '台账存在集成验证出口凭据' \"$FIN\""
ck "fin-head-match" "grep -qF '与当前 HEAD 一致' \"$FIN\""
ck "fin-worktree-clean" "grep -qF 'git status --porcelain' \"$FIN\""
ck "fin-expired-handoff" "grep -qF '集成验证结果过期' \"$FIN\""
ck "fin-merge-section" "grep -qF '### 验证方案并入（本地合并与推送并创建 PR 执行后）' \"$FIN\""
ck "fin-no-merge-on-keep" "grep -qF '「保持分支原样」不并入' \"$FIN\""

# 断言 7：writing-plans 验证方案要求句 + 自审第十项
ck "wp-plan-requirement" "grep -qF '计划存在跨任务组装点或触及外部接口 → 计划须含「验证方案」内嵌章节' \"$WP\""
ck "wp-self-review-item-10" "grep -qF '**10. 验证方案专项：**' \"$WP\""
ck "wp-no-plan-no-requirement" "grep -qF '纯单模块无接口的计划不加' \"$WP\""

# 断言 8：plan-template 验证方案章——出处标注、双向映射、内容要求句
ck "pt-section" "grep -qF '## 验证方案（可选章）' \"$PT\""
ck "pt-provenance" "grep -qF '每条期望标注设计出处（设计文档章节或需求条目），无出处不得入方案' \"$PT\""
ck "pt-bidirectional-map" "grep -qF '集成面与场景清单的双向映射表' \"$PT\""
ck "pt-content-requirements" "grep -qF '内容要求六项逐项落实——确定性固定策略、保真度声明、副作用隔离、顺序依赖显式化、既有登记册查重、失败证据采集' \"$PT\""

# 断言 9：T1 承重句——免责句、增量重跑、Step 1 失败阻断 Step 2、单独调用、
# 重跑一次/偶发机制、期望修改铁律
ck "iv-no-defect-proof" "grep -qF '不证明无缺陷' \"$IV\""
ck "iv-incremental-rerun" "grep -qF '增量重跑' \"$IV\""
ck "iv-step1-fail-stop" "grep -qF '失败即停' \"$IV\""
ck "iv-step1-blocks-step2" "grep -qF 'Step 2 不执行' \"$IV\""
ck "iv-standalone-invocation" "grep -qF '单独调用' \"$IV\""
ck "iv-rerun-once-flaky" "grep -qF '自动重跑一次' \"$IV\""
ck "iv-expectation-iron-rule" "grep -qF '不得修改方案期望' \"$IV\""
# 断言 9b：⑫ 修复轮增补的模糊授权语条款——integration-verification 与 regression-sweep 两处副本同步锚定
ck "iv-rs-vague-authority-clause" "grep -qF '模糊授权语（「你看着办」「你决定」「随便怎么处理」）不构成定性' \"$IV\" && grep -qF '模糊授权语（「你看着办」「你决定」「随便怎么处理」）不构成定性' \"$RS\""

# 断言 9c：链路内重跑免跑——Step 1 之前的凭据新鲜度检查句（判据与收尾技能免跑同构）
ck "iv-freshness-skip" "grep -qF '凭据记录的 HEAD 与当前 HEAD 一致' \"$IV\" && grep -qF '附一句依据免跑本技能' \"$IV\" && grep -qF '凭据缺失或任一不满足' \"$IV\""

# 断言 10：T1 四层名 + 单测层（分级只覆盖三运行层，单测层由 Step 1 覆盖）
for w in 集成层 接口兼容层 可运行层 端到端层 单测层; do
  ck "iv-layer:$w" "grep -qF '$w' \"$IV\""
done

# 断言 11：T1 方案质量十项引用（四性判据 + 内容要求六项）+ 快速放行判据句
for w in 出处锚定 双向映射 粒度判据 可操作性判据 确定性固定策略 保真度声明 副作用隔离 顺序依赖显式化 既有登记册查重 失败证据采集; do
  ck "iv-quality-term:$w" "grep -qF '$w' \"$IV\""
done
ck "iv-fast-release-source" "grep -qF '真值来源是控制者对分支改动面的推导' \"$IV\""
ck "iv-fast-release-one-sentence" "grep -qF '附一句依据放行' \"$IV\""
ck "iv-fast-release-override" "grep -qF '以推导为准' \"$IV\""

# 断言 12：regression-sweep——显式触发句、报告落盘路径、定性三路句、无场景句
ck "rs-explicit-trigger" "grep -qF '仅显式触发——需求方口头明示或外部调度器显式调用，绝不隐式自动运行' \"$RS\""
ck "rs-report-path" "grep -qF 'docs/superpowers/verification/reports/YYYY-MM-DD-<label>.md' \"$RS\""
ck "rs-three-way-ruling" "grep -qF '定性裁决三路' \"$RS\""
ck "rs-empty-registry-exit" "grep -qF '登记册无场景，无可回归项' \"$RS\""
ck "rs-baseline-check" "grep -qF '执行前先核对工作区处于基线状态' \"$RS\""
ck "rs-no-code-fix" "grep -qF '回归不承担代码修复' \"$RS\""
ck "rs-disclaimer" "grep -qF '不证明无缺陷' \"$RS\""

# 断言 12b：regression-sweep 形态路由三路径全路径引用
for f in backend web mobile; do
  ck "rs-route-reference:$f" "grep -qF 'skills/integration-verification/references/$f.md' \"$RS\""
done

# 断言 12c：反向——不做记录裁决（变更摘要、上次回归）零命中
ck "rs-no-change-summary" "! grep -qF '变更摘要' \"$RS\""
ck "rs-no-last-regression" "! grep -qF '上次回归' \"$RS\""

# 断言 12d：文档目录结构规范化（需求方拍板）——新路径挂载：
# IV/RS/FIN 含 docs/superpowers/verification/；IV 含需求级验证方案定位句；
# FIN 含归档步骤（本地合并当场 git mv、PR 路径推送不归档、条件机械化）
ck "iv-verification-path" "grep -qF 'docs/superpowers/verification/' \"$IV\""
ck "rs-verification-path" "grep -qF 'docs/superpowers/verification/' \"$RS\""
ck "fin-verification-path" "grep -qF 'docs/superpowers/verification/' \"$FIN\""
ck "iv-plan-locating-sentence" "grep -qF '随实施计划存放：\`docs/superpowers/specs/<date-feature>/plan.md\` 的验证方案章' \"$IV\""
ck "fin-archive-git-mv" "grep -qF 'git mv docs/superpowers/specs/<date-feature> docs/superpowers/archived/<date-feature>' \"$FIN\""
ck "fin-archive-pr-not-now" "grep -qF '推送时不归档' \"$FIN\""
ck "fin-archive-condition" "grep -qF '均已到基线（无「待合并」状态）' \"$FIN\""

# 断言 12e：旧路径清零——docs/verification/ 不再出现于两技能、收尾技能、计划技能、
# 计划模板与三份形态参考
for f in "$IV" "$RS" "$FIN" "$WP" "$PT" "$BK" "$WB" "$MB"; do
  ck "no-old-verification-path:$(basename "$(dirname "$f")")/$(basename "$f")" "! grep -qF 'docs/verification/' \"$f\""
done

# 断言 13：既有测试套件——全仓库 SKILL.md 字节上限
ck "suite-skill-size-passes" "bash \"$SIZE\" >/dev/null"

# 断言 14：两新 SKILL.md 的 mermaid 流程骨架过词法红线检查
ck "iv-mermaid-clean" "bash \"$MERMAID\" \"$IV\" >/dev/null"
ck "rs-mermaid-clean" "bash \"$MERMAID\" \"$RS\" >/dev/null"

if [ "$fail" -ne 0 ]; then
  echo "Integration gate or regression sweep drifted from the design. See FAIL lines above." >&2
  exit 1
fi
echo "PASS: integration verification and regression sweep consistent with design and mounts"
