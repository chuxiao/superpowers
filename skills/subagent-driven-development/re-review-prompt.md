# 范围化复审提示词模板

在修复轮之后派发复审时使用此模板。复审者验证各发现项是否已得到解决，并检查修复 diff 有无新的破坏。这不是一次全新的审查——完整审查已经发生过。

**目的：** 验证上一次审查的每项发现项均已解决，且修复本身未破坏任何东西。

```
Subagent (general-purpose):
  description: "复审 Task N 修复轮 R"
  model: [MODEL — REQUIRED: choose per SKILL.md Model Selection; an omitted
         model silently inherits the session's most expensive one]
  prompt: |
    你正在复审单个任务的修复轮。此前的一次审查产出了发现项；一名实施者已尝试修复它们。你的工作是对每项发现项给出判定，并检查修复 diff——除此之外别无其他。

    ## 任务

    阅读任务简报：[BRIEF_FILE]

    ## 待验证的发现项

    [FINDINGS]

    ## 修复

    阅读实施者的报告（修复报告追加在末尾）：
    [REPORT_FILE]

    **修复基点：** [FIX_BASE_SHA]（即上一次审查所见到的 head）
    **Head:** [HEAD_SHA]
    **Diff 文件：** [DIFF_FILE]

    只读一遍 diff 文件——它包含修复提交、一份 stat 摘要，以及带周围上下文的修复 diff。不要重新运行 git 命令。
    如果 diff 文件缺失，自行获取 diff：
    `git diff --stat [FIX_BASE_SHA]..[HEAD_SHA]` 和
    `git diff [FIX_BASE_SHA]..[HEAD_SHA]`。

    你在本次检出上的审查是只读的。不得以任何方式改动工作树、暂存区（index）、HEAD 或分支状态。

    ## 你不得派发子代理

    这场审查的全部工作都由你亲自完成。绝不派生子代理去审查 diff 的一部分，也绝不派生另一名审查者来提供第二意见。该流程已经为这项工作配齐了它应得的全部审查席位；你派生的审查者只会以全额成本重复其中一个席位，且其判定不作数。如果 diff 大到让你觉得无法一遍完成，就自行分多遍审查，并在报告中说明。

    ## 范围

    你的范围是发现项列表和修复 diff。对每一项发现项给出判定。检查修复 diff 中有无修复本身引入的新问题。绝不重新审查修复未触及的代码：如果你注意到某个问题完全位于修复 diff 之外，将其报告在 Out-of-Scope Observations 之下——它不阻塞本任务，也不会延长修复循环。所有任务完成后还会进行一次全面的整分支终审。

    ## 测试

    实施者已重新运行覆盖被修改代码的测试，并将结果追加到报告文件中。将该报告视为未经证实的声明：确认修复报告写明了覆盖这些代码的测试并展示了其输出，并对照 diff 核验这些声明。不要为了确认其报告而重新运行测试套件。仅当阅读代码引发某个现有运行无法回答的具体疑点时才运行测试——且届时只运行聚焦测试，绝不运行包级测试套件。

    ## 输出格式

    你的最终消息就是报告本身：直接以第一项发现项的判定开头。每一行要么是一个判定、要么是带 file:line 的发现项、要么是你运行过的一项检查——不要开场白，也不要过程叙述。

    ### Finding Verdicts

    针对「待验证的发现项」一节中的每一项发现项，按顺序给出：
    - **[finding one-liner]** — ADDRESSED | NOT ADDRESSED，并附 file:line 证据。「已尝试」不算 ADDRESSED：该具体缺陷必须已不复存在。

    ### New Breakage in the Fix Diff

    修复本身破坏或引入的任何内容，标注严重度（Critical/Important/Minor）并附 file:line。若干净，写 "None"。

    ### Out-of-Scope Observations

    你注意到的完全位于修复 diff 之外的问题。不构成阻塞；控制者会将它们记入台账，供终审使用。若无，写 "None"。

    ### Verdict

    **Fix round:** [All findings addressed, no new Critical/Important breakage | Findings remain open]——列出仍未解决的发现项。
```

**占位符：**
- `[MODEL]` — 必填：审查者模型按 SKILL.md Model Selection（模型选择）选择；针对小型修复 diff 的范围化复审采用最低档到中档的模型
- `[BRIEF_FILE]` — 任务简报文件（实施者所依据的正是这份文件）
- `[FINDINGS]` — 上一次审查的全部 Critical/Important 发现项与设计文档缺口，逐字复制，每条占一个列表项
- `[REPORT_FILE]` — 实施者的报告文件（修复报告追加在末尾）
- `[FIX_BASE_SHA]` — 上一次审查所见到的 head
- `[HEAD_SHA]` — 当前提交
- `[DIFF_FILE]` — `bash scripts/review-package PLAN_FILE FIX_BASE HEAD` 所打印的路径

**复审者返回：** 逐项发现项的判定（ADDRESSED / NOT ADDRESSED）、修复 diff 中的新破坏、范围外的观察项，以及针对该轮的判定。
