# 验证方案：design-and-plan 合并改造

需求级验证方案。出处约定：`§N` 指 design.md（方案），`Task N` / `D1` 指 plan.md。

## 1. 集成面声明

本改造触及四个集成面：

| # | 集成面 | 内容 |
|---|--------|------|
| I-1 | 引用网络 | 7 个在役文件对新技能名的引用；session-start hook → using-superpowers/SKILL.md 注入链；旧技能名零残留 |
| I-2 | 排版脚本 | `skills/design-and-plan/scripts/` 三脚本可运行且新槽位检查生效（形态声明 / 任务依赖图 / 文首指针） |
| I-3 | 视觉伴侣 | 服务器脚本迁移后可启停；定稿冻结流程文档在位 |
| I-4 | 触发路由 | 新技能 description 承载旧触发词；全新会话按旧场景命中 design-and-plan（路由信号 = description 列表，本项目实证） |
| I-5 | 断言资产 | `tests/integration-verification/test-integration-verification.sh` 既有锚点同步 + 新增 dap- 断言组（S1/S3/S6 固化）；改前改后双轮全绿 |

### 双向映射表

| 集成面 | 承接场景 | 判定 |
|--------|---------|------|
| I-1 | S1、S6 | 覆盖 |
| I-2 | S2、S3 | 覆盖 |
| I-3 | S4 | 覆盖 |
| I-4 | S5、S7 | 覆盖 |
| I-5 | S1、S3、S6、S7（固化后由回归资产持续承接） | 覆盖 |
| — | S5 附带：旧触发词「头脑风暴」单独触发；S5d 呈报分离观察点 | 覆盖（I-4 细分 / I-4 人工观察） |

无「有面无场景」与「有场景无面」缺口。

## 2. 场景清单

### S1（机械，auto）旧名零残留

- 前置状态：Task 6、Task 7 完成（D1 裁决落地）。
- 步骤：`grep -rn "brainstorming\|writing-plans" skills/ hooks/ .claude-plugin/`。
- 期望结果：

| 期望 | 出处 |
|------|------|
| skills/ 下零命中（skills/design-and-plan/** 内亦不得出现两个旧技能名）——**裁决记录（2026-11-05）**：scripts/server.cjs:106 品牌 URL 与 scripts/frame-template.html:5 品牌 title 两行豁免（字节迁移约束优先，原样迁移的必然携带；dap- 断言按行级豁免内置） | plan.md Task 6 验收、Task 7 边界条件 |
| hooks/ 与 .claude-plugin/ 零命中 | plan.md Task 7 边界条件 |
| RELEASE-NOTES.md / archived/ / docs/plans/ 不在扫描口径（历史不改写，plan.md 约束章） | 方案 §7 迁移注意 |

- 清理：无副作用。

### S2（机械，auto）排版脚本对四类文档可运行

- 前置状态：Task 5 完成。
- 步骤：对本需求三件套 + 新技能两份模板（implementation-template.md、reporting-rules.md）运行三脚本。
- 期望结果：

| 期望 | 出处 |
|------|------|
| check-tables.sh、check-mermaid.sh 对全部文档退出码 0 | plan.md Task 5 验收；Task 3 验收（另两份模板的脚本运行） |
| check-doc-structure.sh 对本三件套恰产生 3 份预期差异报告（design.md 缺形态声明、plan.md 缺任务依赖图、plan.md 缺文首指针句；本计划按现行格式写、无新槽位）——记录后按预期差异放行，除这 3 份外零新增报告 | plan.md Task 5 验收 |
| check-doc-structure.sh 对含形态声明的 /tmp 样例零误报 | plan.md Task 5 验收 |

- 清理：/tmp 样例删除。

### S3（机械，auto）新槽位检查红绿演练

- 前置状态：Task 5 完成。
- 步骤：构造两份最小样例——A 含「形态声明」+「任务依赖图」+ 文首指针句；B 缺三者——对 check-doc-structure.sh 运行。
- 期望结果：

| 期望 | 出处 |
|------|------|
| A 全部通过（退出码 0） | plan.md Task 5 Interfaces |
| B 恰好报缺失槽位、不误报其他（红） | plan.md Task 5 改造要点 |
| 对 A 逐项破坏（删形态声明行）→ 对应检查项转红（演练有效） | 登记册惯例（回潮与锚点破坏演练） |

- 清理：样例不入库。

### S4（机械，auto）视觉伴侣服务器启停

- 前置状态：Task 5 完成。
- 步骤：`bash skills/design-and-plan/scripts/start-server.sh` → 断言返回 JSON 含 `screen_dir`/`state_dir`/`url` → `stop-server.sh` → 端口释放。
- 期望结果：

| 期望 | 出处 |
|------|------|
| 启动 JSON 三字段齐备，与旧版返回结构一致 | plan.md Task 5（原样迁移） |
| 停止后无残留进程 | plan.md Task 7 验收 |

- 清理：停服、删临时 screen/state 目录。
- 副作用隔离：启动使用 --project-dir 指向 /tmp 隔离目录，不污染仓库（`.superpowers/` 不入库）。

### S5（会话，L3）全新会话触发测试（需求方动作，合并后执行）

- 前置状态：改造分支已合入 main 或以本地分支加载插件。
- 步骤与期望：

| 场景 | 输入 | 期望 | 出处 |
|------|------|------|------|
| S5a | 全新会话发送「我们来构建 X」（X 为任一真实小需求） | 写任何代码之前自动触发 design-and-plan，进入设计对话而非直接实现 | 方案 §7.6；AGENTS.md 验收测试同型 |
| S5b | 全新会话发送「头脑风暴一下：我要做 Y」 | 同样命中 design-and-plan（旧触发词兼容） | plan.md Task 1 验收（五触发词） |
| S5c | 全新会话给出一份既有设计文档要求写实施计划 | 命中 design-and-plan 并直接进入计划段（不再要求重新设计对话） | 方案 §2.1 触发描述双场景 |

- 通过判据：三场景均以「技能被正确触发且流程可走通」为真；任一场景落空 → 触发词/description 回修，重测。
- **S5d（可选观察点，随 S5a 一并观察）：** S5a 会话进行到呈报环节时，观察代理是否将裁决项回复（如「同意」「按建议」）误读为全套规格确认并开工——方案 §4 呈报分离纪律的行为层检验。只登记观察，不设机械判据；系统性验证归试点复盘（方案 §7.7，plan.md 执行交接已承接）。落空处置：记录会话证据，呈报后回修 reporting-rules/SKILL.md 措辞。

### S6（机械，auto）hook 注入链完整

- 前置状态：Task 6 完成（using-superpowers/SKILL.md 已同步）。
- 步骤：`bash -n hooks/session-start`；模拟 hook 运行提取注入文本（hook 读 `skills/using-superpowers/SKILL.md` 全文注入），对注入产物 grep `design-and-plan`。
- 期望结果：

| 期望 | 出处 |
|------|------|
| `bash -n` 退出码 0（hook 脚本未被本次改动触及，防御性确认） | plan.md Task 7 验收 |
| 注入文本含「design-and-plan」且不含「superpowers:brainstorming」 | plan.md Task 6 验收 + 方案 §2.4（SessionStart 注入文本同步） |

- 清理：无副作用。

### S7（机械，auto）新技能在位且触发词承载

- 前置状态：Task 1 完成。
- 步骤：对新 SKILL.md 断言——frontmatter `name: design-and-plan` 在场；description 含五个旧触发词字样（头脑风暴、设计讨论、我们来构建、实施计划、写计划）且 ≤1024 字符；以「当……时使用」开头。
- 期望结果：

| 期望 | 出处 |
|------|------|
| 三项断言全部成立（grep 与字符计数机械判定） | plan.md Task 1 验收 |

- 清理：无副作用。

### S8（机械，auto）tests/ 套件层——Step 1 全量测试全绿（C-1 修复的承接与防复发）

- 前置状态：终审 C-1 修复完成（tests/ 下五套件对已删除旧路径/旧技能名的依赖同步到 design-and-plan 与新目录）。
- 步骤：按 `docs/superpowers/verification/environment.md` 的 Step 1 口径，`find tests -type f \( -name 'test-*.sh' -o -name 'run-*.sh' \)` 逐一运行。
- 期望结果：

| 期望 | 出处 |
|------|------|
| 全部 test-*.sh / run-*.sh 退出码 0；环境受限条目按 environment.md「环境受限」节口径豁免并逐套件记录 | 本次终审 C-1（tests/brainstorm-server、script-sync、hermes、opencode、explicit-skill-requests 旧路径引用实测红） |

- 清理：无副作用。

## 3. 通过判据

- S1–S4、S6：断言可机械判真伪（命令退出码 / 输出字段）。
- S5：三场景记录（会话 id + 首条响应是否触发技能），由需求方或下一次真实需求确认。
- 修复闭环轮次上限 3：任一场景修复重测超过 3 轮仍红 → 停止迭代，向需求方呈报失败证据与根因分析。

## 4. 验证环境

- macOS + bash；grep/awk 为 BSD 版（脚本现有运行环境即本仓库开发机）。
- node（视觉伴侣服务器依赖，现有版本）。
- Chrome（S5 无关；visual-companion.md 的截图命令仅在真实项目使用时需要）。

## 5. 执行手段

- S1、S3、S6、S7 固化为断言组加入 `tests/integration-verification/test-integration-verification.sh`（随本需求执行期落地；收尾时按登记册惯例并入 `docs/superpowers/verification/cross-module.md`，合组一条「兼容」条目）。
- S2 为一次性执行（脚本对当前文档跑通即证），不做资产化——其断言核心已由 S3 覆盖。
- S4 为一次性执行（启停即证，无持续断言价值）。
- S5 为会话级人工场景，标注人工验证清单——不伪装自动化，不入机械回归。

## 6. 产出物（失败证据采集）

- S1 失败 → grep 命中清单全文。
- S2/S3 失败 → 脚本 stderr 全文 + 触发文档原样。
- S4 失败 → 服务器 stdout/err + 端口占用快照。
- S5 失败 → 会话记录（触发点前后各数条消息）。

## 7. 既有登记册查重

已核对 `docs/superpowers/verification/cross-module.md`：既有条目（REC-L3、UFQ、SDC、WDH、DSC）锚点均为旧需求内容（纪律锚点、SCOPE 位置、十一环节等），本方案 S1/S3/S6 断言对象（design-and-plan 技能名、新槽位检查、hook 注入链）与之零重叠，无重复登记。既有「旧短语缺席」断言（WDH/DSC）若含 brainstorming/writing-plans 正面锚点字样 → S1 执行时需同步核对该资产，命中即触发断言组更新（记录进执行交接）。

## 8. 内容要求六项自查

1. **确定性固定策略：** S1/S2/S3/S6 命令固定、口径固定（grep 词表写死）。
2. **保真度声明：** S5 为真实会话观察，非模拟；S3 样例为构造文档，验检查逻辑不验技能行为——技能行为归 S5。
3. **副作用隔离：** S4 用 /tmp project-dir；样例全走 /tmp。
4. **顺序依赖显式化：** S3 → S2（先证检查逻辑再跑存量文档）；S1 依赖 Task 6/7 完成；S7 依赖 Task 1 完成。
5. **既有登记册查重：** 见 §7。
6. **失败证据采集：** 见 §6。
