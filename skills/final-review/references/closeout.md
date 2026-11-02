# 终审并收尾

本文是 superpowers:final-review 的一部分。计划中的每个任务均已完成。

整分支终审同样有审查包：运行 `bash scripts/review-package PLAN_FILE MERGE_BASE HEAD`（MERGE_BASE = 分支的起始提交，例如 `git merge-base main HEAD`），并把打印出的路径写进终审的派发内容，这样终审审查者读一个文件即可，不必再用 git 命令重新推导分支 diff。派发到可用的最强档模型上（见 SKILL.md 的 Model Selection（模型选择）），使用 [code-reviewer.md](../code-reviewer.md)。向它指出台账中暂缓的 minor 行与搁置行，以便它甄别哪些必须在合并前修复。

**没有子代理工具时：**阅读 [code-reviewer.md](../code-reviewer.md)，亲自对照审查包执行那次审查，把 `Final review: self-review (no subagent tool)` 写入台账，并在最终消息说明这一点：自查弱于全新审查者的审查，由你的需求方在合并前决定这是否足够。

在动手处理任何发现项之前，先按影响重新分级：审查者的严重度标签只是建议，闸门在你手里；一个发现项的级别取决于「若交付，使用这款软件的通情达理的人会得到什么」，而不是设计文档是否点名了触发它的输入——因为设计文档沉默而把某发现项定为 Minor 的审查者，给设计文档评了级，而不是给影响评级。它的「Declined to judge」（不予判定）清单同样归你，每一行都要由你做出裁决并记入台账。

如果整分支终审返回发现项，派发仅一个修复子代理，附上完整的发现项清单——而不是每个发现项各派一个修复者。逐发现项的修复者，每个都要重建上下文并重跑测试套件；某个真实会话中，终审那一轮集中修复（fix wave）的成本超过了该会话全部任务的总和。

**没有子代理工具时：**由你亲自修复全部发现项，每项修复 RED→GREEN + 全绿测试套件，把 `Final: fix self (no subagent tool)` 写入台账，并在最终消息说明这一点：自查修复弱于派发修复者的全新上下文，由你的需求方在合并前决定这是否足够。

然后对这轮集中修复运行恰好一次限定范围的复审（用 `bash scripts/review-package PLAN_FILE FIX_BASE HEAD` 覆盖修复范围，配合 [re-review-prompt.md](../../subagent-driven-development/re-review-prompt.md)）。

**没有子代理工具时：**亲自按 re-review-prompt.md 模板对修复 diff 执行复审，以台账中的修复行及其测试输出作为 [REPORT_FILE] 的等价物，把 `Final: re-review self (no subagent tool)` 写入台账。

**Minor（最好能有）**以 `Final: minor (deferred): <one-liner>` 记入台账，并进入你最终消息的「Deferred minors」一栏——Minor 绝不进入修复轮，也绝不变成裁决。每一项已修复的发现项以 `Final: fixed <finding> — <test name> RED→GREEN, suite <N>/<N>` 记入台账：修复若没有先失败过的测试，就没有得到验证。

对任何残留发现项，按修复循环的熔断（../../subagent-driven-development/references/fix-loop.md）中的做法裁决：附裁决搁置，或对其中承重的发现项做出裁决并把你的决定记入台账。在这里，能让你停下的，只有能让正在运行的计划停下的那四件事（SKILL.md 顶部）。不存在第二轮集中修复——残留的承重发现项会在 finishing-a-development-branch 呈现各选项时呈现给你的需求方。

### 安全门

终审及其后的一切修复/复审工作收尾之后、编制裁决清单与删除工作区之前，执行安全门。它是合并前的最后一道安全把关：所有分支必过；缺子代理工具只降级形态，不免除把关。

用与终审相同的方式生成整分支审查包（`review-package PLAN_FILE MERGE_BASE HEAD`，MERGE_BASE = 分支的起始提交）。

**有子代理工具时：** 把审查者派发到可用的最强档模型上（安全门是判断型任务，与终审同级；按 Model Selection 显式指定模型），使用 `skills/final-review/security-reviewer.md` 模板。随附三样输入：审查包路径；终审发现清单（从台账与修复记录整理——已被修复的项加 `[已修复] ` 前缀，未修复项无标记）；台账中搁置/暂缓行的指引。

**没有子代理工具时：** 阅读 `skills/final-review/security-reviewer.md`，亲自按模板对照审查包执行安全自查，把 `Final: security-gate: self-review (no subagent tool)` 写入台账，并在最终消息说明这一点：自查弱于全新审查者的审查，由你的需求方在合并前决定这是否足够。

按报告处置：

- **Clean-Pass** → 记台账行 `Final: security-gate: clean-pass: <一句依据>`。
- **Critical / Important** → 恰好一轮安全修复：有子代理工具时派单个修复子代理携带完整发现清单，没有时由你亲自修复。每项修复 RED→GREEN + 全绿测试套件；修复报告必须含覆盖测试的命令与输出证据；每项发现项记台账行 `Final: security-gate: finding (<severity>): <one-liner>`。随后恰好一次安全复审：有子代理工具时用 `skills/final-review/security-re-review-prompt.md` 派发最强档子代理（Model Selection 中「限定范围重审用最低档到中档」的规则不适用于安全门复审，依据为设计文档决策 6），没有时由你亲自按模板执行，以台账中的安全修复行及其测试输出作为 `[REPORT_FILE]` 的等价物。
- **复审后的 NOT ADDRESSED 残留与新安全问题** → 记台账裁决行 `Final: security-gate: Ruling: <finding> — <decision> — <cost>`，移交需求方。不存在第二轮安全修复——熔断有界，残留项沿收尾渠道可见。
- **Minor** → 记台账行 `Final: security-gate: minor (deferred): <one-liner>`，绝不进入安全修复轮。
- **非安全观察与范围外安全观察**（门与复审两处）→ 记入台账：非安全观察不阻塞；范围外安全观察按 `Final: security-gate: finding (<severity>): <one-liner>` 记录、进 Security gate 小节，承重者由你做出裁决。

移交：收尾时把台账中全部 `Final: security-gate:` 行收进你最终消息，在 Rulings I made 之下单列 `Security gate` 小节——其中裁决行（含 `Ruling:` 子串）同时进 Rulings I made 本体，clean-pass 与 minor (deferred) 行进 Security gate 小节。

### 收尾

在删除任何东西之前，把台账中每一行包含 `Ruling:` 的内容——预检裁决、搁置的发现项、熔断裁决，全部——收进你最终消息中 "Rulings I made"（我做出的裁决）标题之下，按你做出它们的先后顺序排列，每条都注明：这条裁决如果错了，代价是什么。这份清单必须穷尽：台账里有一条裁决，清单里就有它。你替需求方做出的决定，唯一能传达到他们那里的渠道就是这份清单——他们会读它，并把你做错的地方重做。随工作区一起消亡的裁决，就是一次暗中做出的决定。

当整分支终审干净、且针对终审发现项的修复都已合并后，删除本计划的工作区（`rm -rf <workspace>`）——现在 git 历史就是记录。同级目录属于其他计划；不要动它们。

终审搁置的 Minor（`Final: minor (deferred)` 行）收进你最终消息的「Deferred minors」一栏。

安全门的全部行（clean-pass、裁决、minor deferred、self-review）收进你最终消息的 Security gate 小节，其中裁决行同时进 Rulings I made。

使用 superpowers:finishing-a-development-branch。
