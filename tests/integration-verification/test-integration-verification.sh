#!/usr/bin/env bash
# Integration verification & regression sweep consistency checks — fails when
# either new skill, its form references, or one of the four mounting edits
# drifts from the integration-gate design
# (docs/superpowers/archived/2026-11-01-integration-gate-and-regression/design.md).
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
BS="$REPO_ROOT/skills/design-and-plan/SKILL.md"
WP="$REPO_ROOT/skills/design-and-plan/SKILL.md"
PT="$REPO_ROOT/skills/design-and-plan/references/plan-template.md"
PSR="$REPO_ROOT/skills/design-and-plan/references/plan-self-review.md"
MERMAID="$REPO_ROOT/skills/design-and-plan/scripts/check-mermaid.sh"
VT="$REPO_ROOT/skills/design-and-plan/references/verification-template.md"
DD="$REPO_ROOT/skills/design-and-plan/references/dialogue-discipline.md"
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

# 断言 6：finishing 免跑三判据词 + 结果过期移交 + 验证方案并入小节（原子化时序 + main/master 目标限定）
ck "fin-exit-credential" "grep -qF '台账存在集成验证出口凭据' \"$FIN\""
ck "fin-head-match" "grep -qF '与当前 HEAD 一致' \"$FIN\""
ck "fin-worktree-clean" "grep -qF 'git status --porcelain' \"$FIN\""
ck "fin-expired-handoff" "grep -qF '集成验证结果过期' \"$FIN\""
ck "fin-merge-section" "grep -qF '### 验证方案并入（基准分支为 main/master 且选「本地合并」或「推送并创建 PR」时）' \"$FIN\""
ck "fin-merge-precondition" "grep -qF '前置条件：基准分支为 main/master' \"$FIN\""
ck "fin-atomic-order" "grep -qF '合并/推送之前' \"$FIN\" && grep -qF '「功能代码 + 登记册更新」原子到达' \"$FIN\""
ck "fin-no-merge-non-main" "grep -qF '基准分支不是 main/master' \"$FIN\""
ck "fin-verification-source" "grep -qF 'docs/superpowers/specs/<date-feature>/verification.md' \"$FIN\""
ck "fin-no-merge-on-keep" "grep -qF '「保持分支原样」不并入' \"$FIN\""

# 断言 7：计划侧验证方案指针句 + 触发判据句 + 三件套保存句 + 自审第十项（核查对象 verification.md）
ck "wp-plan-requirement" "grep -qF '计划存在跨任务组装点或触及外部接口时产出（触发判据见 \`references/plan-template.md\`「验证方案文件」段）' \"$WP\""
ck "wp-verification-pointer" "grep -qF '模板见 \`references/verification-template.md\`' \"$WP\""
ck "wp-saves-verification" "grep -qF '计划存在跨任务组装点或触及外部接口 → 同目录另产出 verification.md' \"$PT\""
ck "wp-self-review-item-10" "grep -qF '**10. 验证方案专项：**' \"$PSR\""
ck "wp-self-review-target" "grep -qF '计划产出 verification.md 时逐项核对' \"$PSR\""
ck "wp-no-plan-no-requirement" "grep -qF '纯单模块无接口时不产出该文件' \"$WP\""

# 断言 8：plan-template「验证方案文件」说明段——存在性、指向 verification.md、出处标注、双向映射、内容要求句
ck "pt-verification-file-section" "grep -qF '## 验证方案文件' \"$PT\""
ck "pt-points-to-verification" "grep -qF 'docs/superpowers/specs/<date-feature>/verification.md' \"$PT\""
ck "pt-provenance" "grep -qF '期望以表格呈现并附出处标注列——无出处不得入方案' \"$VT\""
ck "pt-bidirectional-map" "grep -qF '集成面与场景清单的双向映射表' \"$VT\""
ck "pt-content-requirements" "grep -qF '内容要求六项逐项落实——确定性固定策略、保真度声明、副作用隔离、场景自包含、既有登记册查重、失败证据采集' \"$VT\""

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
for w in 出处锚定 双向映射 粒度判据 可操作性判据 确定性固定策略 保真度声明 副作用隔离 场景自包含 既有登记册查重 失败证据采集; do
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
# IV/RS/FIN 含 docs/superpowers/verification/；IV 含需求级验证方案定位句
ck "iv-verification-path" "grep -qF 'docs/superpowers/verification/' \"$IV\""
ck "rs-verification-path" "grep -qF 'docs/superpowers/verification/' \"$RS\""
ck "fin-verification-path" "grep -qF 'docs/superpowers/verification/' \"$FIN\""
ck "iv-source-locating-sentence" "grep -qF 'specs 下各 \`docs/superpowers/specs/<date-feature>/verification.md\`' \"$IV\""
ck "iv-sweep-all-cases" "grep -qF '执行 specs 下能找到的所有验证用例' \"$IV\""
ck "iv-traverse-verification-files" "grep -qF '遍历各 \`<date-feature>/verification.md\`' \"$IV\""
ck "iv-no-cases-exit" "grep -qF 'specs 下无验证用例' \"$IV\""
ck "iv-registry-source-flow" "grep -qF '验证用例的源头在' \"$IV\""

# 断言 12f：回归双模式（需求方裁决 2026-11-03，决策 6 子决策 a / 附录补充之十三）——
# 模式判定句、双源用例集句、失败分类两路句、机械判据句
ck "rs-dual-mode-judgment" "grep -qF '工作区 HEAD ≠ 基线最新 → feature 分支模式' \"$RS\""
ck "rs-dual-source-cases" "grep -qF 'docs/superpowers/specs/*/verification.md' \"$RS\" && grep -qF '双源' \"$RS\""
ck "rs-covered-change" "grep -qF '已覆盖行为变更' \"$RS\""
ck "rs-suspected-regression" "grep -qF '疑似回归' \"$RS\""
ck "rs-covered-mechanical-criterion" "grep -qF '同资产路径' \"$RS\""

# 断言 12g：归档全量化（需求方裁决 2026-11-03，决策 10 子决策 d 再修订 / 附录补充之十四）——
# 合并后 specs 全部内容原样移入 archived、specs 清空、PR 推送不归档下次合并顺带；
# 旧断言 fin-archive-git-mv（按 date-feature 逐目录归档）与 fin-archive-condition
# （均已到基线条件）随语义废止移除
ck "fin-archive-full-volume" "grep -qF '下全部内容原样移入 \`docs/superpowers/archived/\`' \"$FIN\""
ck "fin-archive-specs-empty" "grep -qF 'specs/ 清空，下次需求从空目录开始' \"$FIN\""
ck "fin-archive-pr-not-now" "grep -qF '推送时不归档' \"$FIN\""
ck "fin-archive-next-merge" "grep -qF '下次 feature 分支合并到 main 时全量归档顺带完成' \"$FIN\""

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

# 断言 15：干净工作区执行前置（需求方裁决 2026-11-03，决策 5 执行前置条目 +
# 决策 6 子决策 b + 附录第五轮补充之十五）——IV 执行前置小节与 porcelain 停下句、
# 回修先提交句、方案修改先提交句、统一重跑前置句；RS 双模式共用的脏工作区门句
ck "iv-precondition-section" "grep -qF '## 执行前置' \"$IV\""
ck "iv-precondition-porcelain-stop" "grep -qF '\`git status --porcelain\` 非空（工作区不干净）→ 停下移交需求方——先提交（或自行处置未提交改动）后再跑集成验证' \"$IV\""
ck "iv-precondition-committed-target" "grep -qF '验证对象统一为**已提交状态**' \"$IV\""
ck "iv-precondition-no-dirty-run" "grep -qF '❌「工作区脏也照跑，把未提交改动当验证对象」' \"$IV\" && grep -qF '✅「porcelain 非空即停下，要求先提交」' \"$IV\""
ck "iv-bug-fix-commit-before-rerun" "grep -qF '回修完成后先提交（修复作为一次提交），再全量重跑本技能' \"$IV\""
ck "iv-non-bug-plan-commit-before-rerun" "grep -qF '方案修改先提交（verification.md 修改作为一次提交）' \"$IV\""
ck "iv-every-rerun-clean-worktree" "grep -qF '每次重跑前工作区必须干净' \"$IV\""
ck "rs-dirty-worktree-gate" "grep -qF '## 执行前置' \"$RS\" && grep -qF '停下移交需求方，不执行重跑——先提交或自行处置后再触发' \"$RS\""
ck "rs-gate-covers-both-modes" "grep -qF '基线模式与 feature 分支模式均受此门约束' \"$RS\""
ck "rs-gate-before-mode-judgment" "awk '/## 执行前置/{p=NR} /## 双模式判定/{m=NR} END{if (p && m && p < m) exit 0; exit 1}' \"$RS\""

# 断言 16：分支纪律三条规则——archived 冻结与设计决策走向、main/master 集成动作限定、
# 改动二分（新 feature 完整工作流 / bugfix 过收官把关与集成验证门槛）
ck "fin-discipline-archived-frozen" "grep -qF '归档后冻结，零改动' \"$FIN\" && grep -qF '随新 feature 的 \`docs/superpowers/specs/<date-feature>/design.md\` 走完整工作流' \"$FIN\""
ck "fin-discipline-main-integration-only" "grep -qF 'main/master 只承载集成动作，不直接开发' \"$FIN\" && grep -qF '分支合并、验证方案并入登记册、合并事件文件落盘、基线分支快进、规格目录归档移动' \"$FIN\" && grep -qF '任何开发性改动不得直接在 main/master 上提交' \"$FIN\""
ck "fin-discipline-binary-classification" "grep -qF '改动二分' \"$FIN\" && grep -qF '走 design-and-plan → 收官把关 → 集成验证 → 收尾完整工作流' \"$FIN\" && grep -qF '无新需求文档，合并前同样过收官把关与集成验证门槛' \"$FIN\""

# 断言 17：分支纪律上移（需求方裁决 2026-11-03）——design-and-plan 含 archived 冻结句与
# 改动分类句；FIN 分支纪律小节段尾含上位载体指向句
ck "bs-archived-frozen" "grep -qF '归档后冻结零改动' \"$BS\" && grep -qF '不回写已归档文档' \"$BS\""
ck "bs-change-classification" "grep -qF '收到新问题时先分类' \"$BS\" && grep -qF 'bugfix 路径' \"$BS\""
ck "fin-discipline-upstream-pointer" "grep -qF '三规则的上位载体' \"$FIN\" && grep -qF '实施只能在本需求分支上' \"$FIN\" && grep -qF '设计决策（存放位置与改动分类）归 design-and-plan' \"$FIN\""

# 断言 18：分支治理纪律——路由与冻结的上位落点（需求方拍板：三规则各归其位）
USK="$REPO_ROOT/skills/using-superpowers/SKILL.md"
BRS="$REPO_ROOT/skills/design-and-plan/SKILL.md"
TPL="$REPO_ROOT/skills/design-and-plan/references/design-doc-template.md"
ck "us-routing-feature-workflow" "grep -qF 'design.md + implementation.md + plan.md + verification.md + decisions.md' \"$USK\""
ck "us-routing-feature-closeout-relay" "grep -qF 'requesting-code-review 收官把关' \"$USK\""
ck "us-routing-fix-branch-gate" "grep -qF 'bugfix 分支上进行，合并前过收官把关与集成验证门槛' \"$USK\""
ck "us-main-no-direct-dev" "grep -qF 'main/master 上不直接开发' \"$USK\""
ck "brs-archived-frozen" "grep -qF '归档后冻结零改动' \"$BRS\""
ck "brs-bugfix-closeout-gate" "grep -qF '合并前过收官把关与集成验证门槛' \"$BRS\""
ck "fin-discipline-pointer" "grep -qF '上位载体' \"$FIN\""

# 断言 19：豁免清零与纪律句在场（需求方裁决 2026-11-03）——工作流技能正文六条豁免短语缺席、
# 三条纪律句在场；设计文档模板「小改动」「简短版」词级缺席
ck "brs-no-exemption-phrases" "! grep -qF '简短版' \"$BRS\" && ! grep -qF '不做独立审读' \"$BRS\" && ! grep -qF '不进入完整计划流程' \"$BRS\" && ! grep -qF '判错则升级' \"$BRS\" && ! grep -qF '这项技能即告完成' \"$BRS\" && ! grep -qF '也随之解除' \"$BRS\""
ck "brs-discipline-sentences" "grep -qF '跳过的是对话，不是流程' \"$DD\" && grep -qF '不解除闸门' \"$BRS\" && grep -qF '所有改动统一完整版' \"$BRS\""
ck "tpl-no-small-change" "! grep -qF '小改动' \"$TPL\" && ! grep -qF '简短版' \"$TPL\""

# 断言 20：产物目录唯一约定（需求方裁决 2026-11-03，spec-dir-convention）——
# 正向：两技能固定句锚点在场；反向：两旧偏好句整句缺席、泛化短语缺席
# （泛化短语「偏好优先」「偏好覆盖」经全仓核实 2026-11-04 零命中后纳入）
ck "spec-dir-fixed-convention" "grep -qF '设计文档一律落此处' \"$BS\" && grep -qF '全部居住在 \`docs/superpowers/specs/<date-feature>/\`' \"$WP\""
ck "spec-dir-no-preference" "! grep -qF '需求方的偏好优先于以上两者' \"$BS\" && ! grep -qF '需求方对计划存放位置的偏好覆盖此默认值' \"$WP\" && ! grep -qF '偏好优先' \"$BS\" && ! grep -qF '偏好覆盖' \"$WP\" && ! grep -qF '偏好优先' \"$WP\" && ! grep -qF '偏好覆盖' \"$BS\""

# 断言 21：流程纪律加固（workflow-discipline-hardening，2026-11-04）——
# 正向：Task 1-4 提交信息登记的全部锚点子串（35 个）按承载文件逐字在场；
# 反向：被删除/被替换的旧表述按真实字面拦截、按承载文件限定
# （spec 三份文档引用旧句原文属合法自引用，故不做全仓 grep）
UGW="$REPO_ROOT/skills/using-git-worktrees/SKILL.md"
SDG="$REPO_ROOT/skills/systematic-debugging/SKILL.md"
EP="$REPO_ROOT/skills/executing-plans/SKILL.md"
SDD="$REPO_ROOT/skills/subagent-driven-development/SKILL.md"
# using-superpowers——流程闸门与定性（Task 1）
ck "wdh-us-routing-conditional" "grep -qF 'design.md + implementation.md + plan.md + verification.md + decisions.md' \"$USK\""
ck "wdh-us-scope-software" "grep -qF '只适用于软件开发类工作' \"$USK\""
ck "wdh-us-announce-type" "grep -qF '用一句话宣布类型与依据' \"$USK\""
ck "wdh-us-no-downgrade" "grep -qF '不构成降级理由' \"$USK\""
ck "wdh-us-eleven-gates" "grep -qF '流程闸门的全部十个环节' \"$USK\""
ck "wdh-us-exempt-impl-only" "grep -qF '可豁免的只有实现层的做法' \"$USK\""
# 计划模板——无集成面的推导依据（Task 1）
ck "wdh-wp-derivation" "grep -qF '把推导依据写进计划' \"$PT\""
# using-git-worktrees——建树纪律（Task 2）
ck "wdh-ugw-mandatory-tree" "grep -qF '一律建立专属工作树' \"$UGW\""
ck "wdh-ugw-branch-prefix" "grep -qF '分支名带类型前缀' \"$UGW\""
ck "wdh-ugw-reclassify-rename" "grep -qF '重定性时树保留改名' \"$UGW\""
ck "wdh-ugw-synced-base" "grep -qF '同步后的基线分支顶端' \"$UGW\""
ck "wdh-ugw-single-writer" "grep -qF '只允许一个会话开发写入' \"$UGW\""
ck "wdh-ugw-post-create-verify" "grep -qF '建树后核验合并基' \"$UGW\""
ck "wdh-ugw-refuse-in-place" "grep -qF '说明隔离工作区与流程闸门的必要性' \"$UGW\""
ck "wdh-ugw-env-failure-gate" "grep -qF '环境故障不解开闸门' \"$UGW\""
ck "wdh-ugw-never-reuse" "grep -qF '绝不复用他人之树' \"$UGW\""
# design-and-plan——定性即建树（Task 2）
ck "wdh-brs-no-bypass" "grep -qF '来绕开五件套' \"$BS\""
ck "wdh-brs-reclassify-defect" "grep -qF '设计期发现实为缺陷修复' \"$BS\""
# systematic-debugging——修复链入口四态（Task 3）
ck "wdh-sdg-tree-default" "grep -qF '定性即建默认工作树' \"$SDG\""
ck "wdh-sdg-state-baseline" "grep -qF '缺陷在基线已交付代码' \"$SDG\""
ck "wdh-sdg-state-current" "grep -qF '缺陷由当前需求引入' \"$SDG\""
ck "wdh-sdg-state-other" "grep -qF '缺陷由其他进行中需求引入' \"$SDG\""
ck "wdh-sdg-state-rejudged" "grep -qF '修复提交后宿主改判' \"$SDG\""
ck "wdh-sdg-need-new-behavior" "grep -qF '需要新行为或新能力' \"$SDG\""
# executing-plans——停止条件与分支前置（Task 3）
ck "wdh-ep-branch-only" "grep -qF '实施只能在本需求分支上进行' \"$EP\""
ck "wdh-ep-missing-spec-stop" "grep -qF '停止实施并回到设计确认门' \"$EP\""
# subagent-driven-development——停止条件与分支前置（Task 3）
ck "wdh-sdd-branch-only" "grep -qF '实施地点只能在本需求分支上' \"$SDD\""
ck "wdh-sdd-missing-spec-stop" "grep -qF '没有可获取设计文档的计划不得开始执行' \"$SDD\""
# finishing-a-development-branch——收尾链（Task 4）
ck "wdh-fin-base-tree-merge" "grep -qF '合并一律在基准分支所在工作树内执行' \"$FIN\""
ck "wdh-fin-merge-event" "grep -qF '合并事件记录' \"$FIN\""
ck "wdh-fin-four-states" "grep -qF '影响分析四态判定' \"$FIN\""
ck "wdh-fin-source-zero-change" "grep -qF '源与目标的原方案文件零字节改动' \"$FIN\""
ck "wdh-fin-net-result" "grep -qF '规格目录下全部方案的净结果集' \"$FIN\""
ck "wdh-fin-dirty-stop" "grep -qF '吸收分支工作树脏' \"$FIN\""
ck "wdh-fin-pr-backfill" "grep -qF '外来规格目录无对应合并事件文件' \"$FIN\""
# 终审修复项新增断言（Critical-1、Important-2/3/5/10/11）
# Critical-1：建后校验改为严格相等（合并基 = 同步后的基线顶端），字面整串在场
ck "wdh-ugw-post-create-strict" "grep -qF '\"\$(git rev-parse HEAD)\" = \"\$(git rev-parse <同步后的基线分支顶端>)\"' \"$UGW\""
# Important-2：沙箱回退正文两串缺席（原「在原地工作」不覆盖该正文）
ck "wdh-no-sandbox-inplace" "! grep -qF '在当前目录中工作' \"$UGW\" && ! grep -qF '在原地完成环境配置' \"$UGW\""
# Important-3：bugfix 定性改为症状口径，宿主由归因判定
ck "wdh-us-bugfix-symptom" "grep -qF '报告为缺陷且需要修改既有代码' \"$USK\" && grep -qF '宿主（基线/当前需求/他需求）由归因判定' \"$USK\""
ck "wdh-no-bugfix-delivered-only" "! grep -qF '修复基线分支上已交付内容的缺陷' \"$USK\""
# Important-5：入口技能集成动作枚举与 FIN/UGW/术语表对齐为五项
ck "wdh-us-integration-actions" "grep -qF '分支合并、验证方案并入登记册、合并事件文件落盘、基线分支快进、规格目录归档移动' \"$USK\""
# Important-10：FIN 本地合并前先定位基准分支所在工作树
ck "wdh-fin-locate-base-tree" "grep -qF 'git worktree list' \"$FIN\" && grep -qF 'cd <基准分支所在工作树路径>' \"$FIN\""
# Important-11：合并事件目录与验证方案文件写明作为一次提交落在吸收分支
ck "wdh-fin-merge-event-committed" "grep -qF '作为一次提交落在吸收分支上' \"$FIN\""
# 复审核得的新破坏：FIN 改动二分仍用旧定义，与 design §2.1「与收尾技能同口径」冲突
ck "wdh-fin-bugfix-symptom" "grep -qF '报告为缺陷且需修改既有代码——宿主由归因判定' \"$FIN\" && ! grep -qF '修复 main/master 上已交付内容的缺陷' \"$FIN\""
# 反向拦截：旧表述按真实字面缺席（UGW 偏好行与回退表行由「在原地工作」覆盖；
# 沙箱回退正文不含该串，由 wdh-no-sandbox-inplace 的两串单独覆盖；
# 「裁决只是暂定的」为 EP/SDD 两文件各自旧句的共有子串；「非软件项目到此停止」在 BRS 原为两处）
ck "wdh-no-inplace-work" "! grep -qF '在原地工作' \"$UGW\""
ck "wdh-no-tentative-ruling-ep" "! grep -qF '裁决只是暂定的' \"$EP\""
ck "wdh-no-tentative-ruling-sdd" "! grep -qF '裁决只是暂定的' \"$SDD\""
ck "wdh-no-never-create-another-tree" "! grep -qF '绝不要再创建另一个工作树' \"$UGW\""
ck "wdh-no-skip-create-row" "! grep -qF '已处于链接工作树中 | 跳过创建' \"$UGW\""
ck "wdh-no-software-anywhere-phrase" "! grep -qF '软件内外皆然' \"$BS\""
ck "wdh-no-nonsoftware-stop-brs" "! grep -qF '非软件项目到此停止' \"$BS\""
ck "wdh-no-nonsoftware-stop-wp" "! grep -qF '非软件项目止于设计文档' \"$WP\""
ck "wdh-no-nonsoftware-stop-template" "! grep -qF '非软件项目止于设计文档' \"$PT\""
ck "wdh-no-nonsoftware-reject" "! grep -qF '收到非软件项目时，拒绝并返回设计阶段' \"$WP\""
# 泛化短语（入断言前全仓 grep 核实计数）：「非软件项目」2026-11-04 全仓 skills/ 零命中；
# 「跳过创建」同日全仓零命中（codex 参考已改述）——故可作词级缺席断言
ck "wdh-no-nonsoftware-term-brs" "! grep -qF '非软件项目' \"$BS\""
ck "wdh-no-nonsoftware-term-wp" "! grep -qF '非软件项目' \"$WP\" && ! grep -qF '非软件项目' \"$PT\""
ck "wdh-no-skip-create-term" "! grep -qF '跳过创建' \"$UGW\""

# 断言组 22（sdr-）：已裁决事项不重复请求确认 + 设计/计划状态标注随裁决同步
# 缺陷：计划已裁决接受的弱验证残余在收尾被再次请求裁决；文档保留待裁决标注
ck "sdr-us-no-reask" "grep -qF '不得再次请求确认' \"$USK\" && grep -qF '已裁决（日期 + 结论）' \"$USK\""
ck "sdr-us-status-sync" "grep -qF '不得保留「待裁决」「待追认」等与事实不符的标记' \"$USK\""
ck "sdr-brs-status-sync" "grep -qF '文档必须同步更新状态标注为已裁决' \"$BRS\""
ck "sdr-wp-status-sync" "grep -qF '文档只留「待需求方裁决」占位' \"$WP\""

# 断言组 23（dsc-）：技能库适用范围收敛（dev-scope-convergence，2026-11-04）
MAP="$REPO_ROOT/docs/skills-map.md"
README="$REPO_ROOT/README.md"
DPA="$REPO_ROOT/skills/dispatching-parallel-agents/SKILL.md"
SDB="$REPO_ROOT/skills/systematic-debugging/SKILL.md"

# 结构：SCOPE 位置、标题骨架与唯一范围句
ck "dsc-us-scope-first" "awk 'f && NF{print; exit} /<\\/SUBAGENT-STOP>/{f=1}' \"$USK\" | grep -qxF '<SCOPE>'"
ck "dsc-us-scope-before-imp" "s=\$(grep -nF '</SCOPE>' \"$USK\" | head -1 | cut -d: -f1); i=\$(grep -nF '<EXTREMELY-IMPORTANT>' \"$USK\" | head -1 | cut -d: -f1); [ -n \"\$s\" ] && [ -n \"\$i\" ] && [ \"\$s\" -lt \"\$i\" ]"
ck "dsc-us-headings" "h1=\$(grep -cE '^# ' \"$USK\"); h2=\$(grep -cE '^## ' \"$USK\"); [ \"\$h1\" = 3 ] && [ \"\$h2\" = 7 ]"
ck "dsc-us-only-scope-phrase" "[ \"\$(grep -cF '只适用于' \"$USK\")\" = 1 ]"
ck "dsc-us-heading-order" "grep -nE '^#{1,2} ' \"$USK\" | cut -d: -f2- | paste -sd '|' - | grep -qxF '# 技能调用纪律|## 规则|## 技能优先级|## 平台适配|## 用户指令|# 开发工作流|## 工作流总览|## 流程闸门与定性|## 已裁决事项|# 附录：危险信号'"
ck "dsc-us-scope-inside" "s=\$(grep -nF '<SCOPE>' \"$USK\" | cut -d: -f1); e=\$(grep -nF '</SCOPE>' \"$USK\" | cut -d: -f1); l=\$(grep -nF '只适用于' \"$USK\" | cut -d: -f1); [ -n \"\$s\" ] && [ -n \"\$e\" ] && [ -n \"\$l\" ] && [ \"\$l\" -gt \"\$s\" ] && [ \"\$l\" -lt \"\$e\" ]"
ck "dsc-us-scope-text" "grep -qF '本技能只适用于软件开发类工作——包括代码、测试与项目文档。' \"$USK\" && grep -qF '按描述加载本技能的 harness：非软件开发类任务不触发加载。' \"$USK\" && grep -qF '无条件注入本技能的 harness：技能已加载，但其工作流不适用于非软件开发类任务——按用户指令正常应答。' \"$USK\""
ck "dsc-us-part2" "grep -qF '# 开发工作流' \"$USK\""
ck "dsc-us-1pct-text" "grep -qF '如果你认为哪怕只有 1% 的可能有一项技能适用于你正在做的事' \"$USK\""
ck "dsc-us-eleven-gates" "grep -qF '流程闸门的全部十个环节' \"$USK\""
ck "dsc-us-new-desc" "grep -qF '在开始任何软件开发类任务时使用' \"$USK\""
ck "dsc-us-no-old-scope" "! grep -qF '只适用于软件开发项目' \"$USK\""
ck "dsc-us-no-old-desc" "! grep -qF '在开始任何对话时使用' \"$USK\""
ck "dsc-us-no-old-request" "! grep -qF '收到开发类请求时' \"$USK\""
ck "dsc-us-no-old-category" "! grep -qF '非开发任务' \"$USK\""

# 正向：计划、头脑风暴、分派、调试、技能地图、项目说明、分支收尾
ck "dsc-wp-new-scope" "grep -qF '当你即将开始任何软件开发类的创造性工作' \"$WP\" && grep -qF '计划只适用于软件开发类工作（含代码与项目文档）' \"$PT\""
ck "dsc-wp-no-old-scope" "! grep -qF '计划只适用于软件项目' \"$WP\" && ! grep -qF '计划只适用于软件项目' \"$PT\""
ck "dsc-bs-new-desc" "grep -qF '软件开发类的创造性工作' \"$BS\""
ck "dsc-bs-no-old-desc" "! grep -qF '在做任何创造性工作之前' \"$BS\""
ck "dsc-bs-new-l8" "grep -qF '在任何软件开发产物被构建出来之前' \"$BS\""
ck "dsc-bs-no-old-l8" "! grep -qF '在任何东西被构建出来之前' \"$BS\""
ck "dsc-bs-no-art" "! grep -qF '一件艺术品的媒介' \"$BS\""
ck "dsc-bs-no-software-project" "! grep -qF '软件项目' \"$BS\""
ck "dsc-bs-new-visual1" "grep -qF '一个屏幕、一个页面、一个弹窗、一份报表' \"$DD\""
ck "dsc-bs-old-visual1" "! grep -qF '一个屏幕、一个页面、一份打印件、一块标牌' \"$BS\""
ck "dsc-bs-new-visual2" "grep -qF '页面的、面板的、流程的' \"$DD\""
ck "dsc-bs-old-visual2" "! grep -qF '屏幕的、房间的、日程的' \"$BS\""
ck "dsc-bs-new-visual3" "grep -qF '一张架构图、一条时间线、一张关系图' \"$DD\""
ck "dsc-bs-old-visual3" "! grep -qF '一张图、一条时间线、一幅地图' \"$BS\""
ck "dsc-bs-new-visual4" "grep -qF '比如一个页面、一个屏幕、一份报表或一个弹窗？' \"$DD\""
ck "dsc-bs-old-visual4" "! grep -qF '比如一个页面、一个屏幕、一份日程或一份打印件？' \"$BS\""
ck "dsc-bs-retained-artifact" "grep -qF '一个应用的平台、编程语言和库。' \"$DD\""
ck "dsc-bs-ref-flow-gate" "grep -qF '流程闸门与定性' \"$BS\" && grep -qF '## 流程闸门与定性' \"$USK\""
ck "dsc-dpa-new" "grep -qF '处理的软件开发任务时使用' \"$DPA\""
ck "dsc-dpa-old" "! grep -qF '当面对 2 个以上相互独立、可在没有共享状态或顺序依赖的情况下处理的任务时使用' \"$DPA\""
ck "dsc-sd-new" "grep -qF '适用于任何软件开发技术问题：' \"$SDB\""
ck "dsc-sd-old" "! grep -qF '适用于任何技术问题：' \"$SDB\""
ck "dsc-map-new" "grep -qF '任何软件开发类创造性工作开始之前——功能、组件、计划。' \"$MAP\""
ck "dsc-map-old" "! grep -qF '任何创造性工作开始之前——功能、组件、计划，软件内外都算。' \"$MAP\" && ! grep -qF '软件内外' \"$MAP\" && ! grep -qF '非软件项目' \"$MAP\""
ck "dsc-map-retained" "grep -qF '五件套' \"$MAP\" && grep -qF 'bugfix 路径' \"$MAP\""
ck "dsc-readme-new" "grep -qF '在开始软件开发类构建之前激活' \"$README\" && grep -qF 'agent 在做任何软件开发任务之前都会检查有无相关技能。' \"$README\""
ck "dsc-readme-old" "! grep -qF '在做任何任务之前' \"$README\" && ! grep -qF '在构建任何东西之前激活' \"$README\""
ck "dsc-fin-new" "grep -qF '开发工作流' \"$FIN\" && grep -qF 'archived 冻结的存放策略' \"$FIN\" && grep -qF '# 开发工作流' \"$USK\""
ck "dsc-fin-old" "! grep -qF '技能优先级' \"$FIN\""

# 断言组 24（场景自包含，2026-11-05）：验证场景自包含判据与并行安全/容量池语义锚——
# 正向：判据名与新语义锚在场（Task 2 改 WP/PT、Task 3 改 IV/RS、Task 4 改 BK/WB/MB 后转绿）；
# 落点级：容量池引导须落在 IV 初始化描述句内（文件级 grep 无法区分初始化句与执行规则句两处落点）；
# 回潮：三条旧串对技能文档全库反向断言（反向模式同断言 12e，全库口径不排除任何 skills/ 子路径；
# 匹配模式为精确串，除递归 -r 与固定串 -F 外不加其他参数）
for f in "$VT" "$PSR" "$BK" "$WB" "$MB"; do
  ck "scene-self-contained:$(basename "$(dirname "$f")")/$(basename "$f")" "grep -qF '场景自包含' \"$f\""
done
for f in "$VT" "$BK" "$WB" "$MB"; do
  ck "anchor-parallel-safety:$(basename "$(dirname "$f")")/$(basename "$f")" "grep -qF '并行安全' \"$f\""
done
ck "iv-default-capacity" "grep -qF '默认容量 1' \"$IV\""
ck "rs-default-capacity" "grep -qF '默认容量 1' \"$RS\""
ck "iv-capacity-pool" "grep -qF '容量池' \"$IV\""
ck "rs-capacity-pool" "grep -qF '容量池' \"$RS\""
ck "iv-init-line-capacity-pool" "grep '各层一行怎么跑' \"$IV\" | grep -qF '容量池'"
# 无并行能力降级语义锚（2026-11-05 修复轮）：执行规则句须含串行降级与串行原因标注
ck "iv-serial-reason-annotation" "grep -qF '标注串行原因' \"$IV\""
ck "rs-serial-reason-annotation" "grep -qF '标注串行原因' \"$RS\""
for s in '顺序依赖显式化' '标注可并行' '顺序依赖链'; do
  ck "no-resurgence:$s" "! grep -rqF '$s' \"$REPO_ROOT/skills/\""
done

# 断言组 25（dap-，design-and-plan 合并收尾，2026-11-05 Task 7）——旧技能目录删除后的
# 收尾机械验证（对应 verification.md S1/S3/S6/S7）。
# S1：旧名零残留（-i 口径）；豁免 scripts/server.cjs 品牌 URL 行与 frame-template.html
# 品牌标题行（字节一致约束，Task 7 裁决 2），豁免在断言实现中内置（排除模式）
ck "dap-no-legacy-refs" "! { grep -rniE 'brainstorming|writing-plans' \"$REPO_ROOT/skills/\" \"$REPO_ROOT/hooks/\" \"$REPO_ROOT/.claude-plugin/\" || true; } | grep -vE 'superpowers-visual-brainstorming-logo\\.png|<title>Superpowers Brainstorming</title>'"
# S7：新技能在位——frontmatter name、五触发词（头脑风暴/设计讨论/我们来构建/实施计划/写计划）
# 锚定在 description 行、以「当……时使用」开头、长度 ≤1024 字符（字节口径从严）
ck "dap-frontmatter-name" "grep -q '^name: design-and-plan' \"$BS\""
for w in 头脑风暴 设计讨论 我们来构建 实施计划 写计划; do
  ck "dap-trigger-word:$w" "grep '^description: ' \"$BS\" | grep -qF '$w'"
done
ck "dap-desc-opens-when-use" "grep -q '^description: 当' \"$BS\" && grep '^description: ' \"$BS\" | grep -qF '时使用'"
ck "dap-desc-length-le-1024" "[ \"\$(sed -n 's/^description: //p' \"$BS\" | wc -c)\" -le 1024 ]"
# S6：hook 注入链——session-start 语法检查 + 真实运行注入产物含 design-and-plan、不含旧名
ck "dap-hook-bash-n" "bash -n \"$REPO_ROOT/hooks/session-start\""
ck "dap-hook-inject-contains-dap" "CLAUDE_PLUGIN_ROOT=\"$REPO_ROOT\" bash \"$REPO_ROOT/hooks/session-start\" | grep -qF 'design-and-plan'"
ck "dap-hook-inject-no-legacy" "! CLAUDE_PLUGIN_ROOT=\"$REPO_ROOT\" bash \"$REPO_ROOT/hooks/session-start\" | grep -qiF 'superpowers:brainstorming'"
# S3：新槽位检查红绿演练——样例内联构造于临时目录（缺形态声明样例报红且报在形态声明项、
# 含槽位样例通过）；演练毕清理临时目录
DAPS="$REPO_ROOT/skills/design-and-plan/scripts/check-doc-structure.sh"
DAPTMP="$(mktemp -d)"
cat > "$DAPTMP/design-slot-good.md" <<'EOF'
# 设计文档样例

## 0. 形态声明

新建 `docs/superpowers/specs/<date-feature>/` 五件套。

## 背景

样例背景。
EOF
cat > "$DAPTMP/design-slot-missing.md" <<'EOF'
# 设计文档样例

## 背景

样例背景。
EOF
cat > "$DAPTMP/plan-slot-good.md" <<'EOF'
# 实施计划样例

实现设计见同目录 implementation.md。

## 任务依赖图

Task 1 → Task 2（顺序依赖）。

### Task 1: 样例任务

职责：完成样例改动。
EOF
cat > "$DAPTMP/plan-slot-depgraph-missing.md" <<'EOF'
# 实施计划样例

实现设计见同目录 implementation.md。

### Task 1: 样例任务

职责：完成样例改动。
EOF
cat > "$DAPTMP/plan-slot-ptr-missing.md" <<'EOF'
# 实施计划样例

## 任务依赖图

Task 1（单任务，无依赖）。

### Task 1: 样例任务

职责：完成样例改动。
EOF
ck "dap-slot-good-sample-passes" "bash \"$DAPS\" \"$DAPTMP/design-slot-good.md\" >/dev/null"
ck "dap-slot-missing-sample-fails" "! bash \"$DAPS\" \"$DAPTMP/design-slot-missing.md\" >/dev/null"
ck "dap-slot-missing-reports-form-decl" "{ bash \"$DAPS\" \"$DAPTMP/design-slot-missing.md\" || true; } 2>&1 | grep -qF '缺形态声明槽位'"
# 任务依赖图槽位红绿（plan 文档含 Task 小节必须有含该字样的标题行）
ck "dap-slot-plan-good-sample-passes" "bash \"$DAPS\" \"$DAPTMP/plan-slot-good.md\" >/dev/null"
ck "dap-slot-depgraph-missing-fails" "! bash \"$DAPS\" \"$DAPTMP/plan-slot-depgraph-missing.md\" >/dev/null"
ck "dap-slot-depgraph-missing-reports-depgraph" "{ bash \"$DAPS\" \"$DAPTMP/plan-slot-depgraph-missing.md\" || true; } 2>&1 | grep -qF '「任务依赖图」槽位'"
# 文首指针句槽位红绿（plan 文档指针句须出现在首个 Task 小节之前）
ck "dap-slot-ptr-missing-fails" "! bash \"$DAPS\" \"$DAPTMP/plan-slot-ptr-missing.md\" >/dev/null"
ck "dap-slot-ptr-missing-reports-ptr" "{ bash \"$DAPS\" \"$DAPTMP/plan-slot-ptr-missing.md\" || true; } 2>&1 | grep -qF '缺文首指针句'"
rm -rf "$DAPTMP"

if [ "$fail" -ne 0 ]; then
  echo "Integration gate or regression sweep drifted from the design. See FAIL lines above." >&2
  exit 1
fi
echo "PASS: integration verification and regression sweep consistent with design and mounts"
