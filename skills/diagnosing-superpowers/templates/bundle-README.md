# Superpowers 会话诊断材料包（bundle）

会话：<session-id>
harness：<name> <version> (<provenance label>)    Superpowers：<version> (<sha or "not a checkout">; <provenance label>)
脱敏级别：skeleton | evidence | full
构建时间：<ISO timestamp>

标头中的版本字段须标注为以下性质之一：历史证据、未验证快照、当前观察或未知。`environment.json` 对每个环境字段及其佐证位置沿用同样的来源（provenance）区分。

## 这是什么

这是一份脱敏后的记录，对象是一个装有 superpowers 且出了问题的编码 agent 会话。它让当时不在场的 agent 或人能够判断 superpowers 是否在其中起了作用，若是，该改什么。其中的报告以 `path:line` 证据陈述发生了什么。按设计，它不包含对 superpowers 的诊断，也不提出修复方案；这是读者的工作。

## 文件

- `report.md` — 诊断报告（问题陈述、判定、环境、会话、时间线、发现项、参与情况、覆盖范围说明）。
- `case.md` — 分析子代理工作所依据的案件文件。
- `environment.json` — 环境小节的机器可读副本。
- `timeline.md` — 逐轮时间线。
- `findings/<dimension>.md` — 各维度分析子代理的原始发现项。
- `transcripts/<session-id>.md` — 每个受检会话的逐轮精简呈现（绝非原始 JSONL）。工具结果正文按级别处理如下：

  | 级别 | 工具结果正文 |
  |---|---|
  | skeleton | 有意限量；替换为 `[tool result: <tool>, <bytes> bytes, exit <code>]` |
  | evidence | 被引用的事件保留正文，包括支撑发现项所需的命令与结果 |
  | full | 全部保留 |
- `scrub-log.md` — 所用到的每个占位符及其类别（绝不包含原始值）。

## 如何阅读

先读 `report.md` §1–2，再读 §7（参与情况）及其引用的证据行，然后读 `transcripts/` 中对应的轮次。`path:line` 引用指向报告者机器上的原始文件；同样的行号在精简会话记录（transcript）中以 `[L<n>]` 标记保留。

## 脱敏

占位符形如 `<EMAIL-1>`、`<PERSON-2>`、`<SECRET-3>`、`<HOST-4>`、`<REPO-5>`、`<ORG-6>`、`<PROPRIETARY-7>`；家目录路径改写为 `~/…`。在本材料包内，同一占位符始终指代同一原始值。

## 产出者说明

材料包完成后，会用实际结果替换本节说明。

脱敏完成后，仅凭本材料包核查每一条实质性导出的发现项：把它的引用解析到已收录的会话记录/来源标记，读所引用的命令/结果或引文，并核实它确实支撑该论断。仅凭路径与行号存在并不足够。当脱敏级别或必要的隐去使依据缺失时，记录具体局限。

核对报告、案件文件、环境、发现项、README 与任何本地 issue 草稿，确保相互一致。按最终文件刷新 scrub-log 的计数（日志本身不计入）。删除过期的导出声明；区分材料包制备与归档交付。保留历史锚点到已收录证据的映射。

将独立的隐私审计与证据有用性分开记录：
- 隐私审计：CLEAN，或仍有未解决的遗漏。
- 证据依据：有依据（supported）或受限（limited），并附受影响的发现项及原因。

检查之后若内容有变动，重做受影响的检查。将最终日志、文件清单与这两项结论提交给既有的归档审批。归档已审定的文件，并核实交付的归档与这些文件一致。把归档交付情况记录在已审定的材料包之外，而不是在批准后再改动其内容。脱敏不是穷尽的隐私认证。
