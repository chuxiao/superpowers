Title: <skill or symptom>: <one-line observable> (<harness>)

- [x] 我已搜索现有 issue，本条并非重复（已搜索：<query terms>；最接近的：<#n title, or "none">）

## 谁在提交这份报告？ (REQUIRED)

<model and harness of this session>，代表 <how your partner wants to be named, or "my human partner"> 提交；其要求为："<their request from this session that led to the diagnosis or the issue, scrubbed>"

## 需求方亲自撰写的摘要 (REQUIRED, 200 词以内)

<Your partner's own words on what went wrong and what should have happened, pasted as written. Ask for them; a placeholder here means the issue is not ready to file. If they run long, ask them to trim rather than editing their words.>

## 环境 (REQUIRED)

| Field | Value | Provenance / supporting evidence |
|-------|-------|-------------------------------|
| Superpowers version | <version> (<sha or "not a checkout">) | <historical evidence / unverified snapshot / current observation / unknown>; <location> |
| Harness (Claude Code, Cursor, etc.) | <harness> | <label>; <location> |
| Harness version | <version> | <label>; <location> |
| Your model + version | <model ids seen> | <label>; <location> |
| All plugins installed | <list> | <label>; <location> |
| OS + shell | <os version>, <shell> | <label>; <location> |

## 这是 Superpowers 的问题，还是平台的问题？

- [ ] 我已确认在未安装 Superpowers 的情况下该问题不会出现

我如何验证该问题在无 Superpowers 时不复现：

<"Not tried", or what your partner ran without superpowers and what happened, with the transcript path if there is one. Tick the box above only when a transcript shows the problem did not recur.>

参与的证据见下文；它并不确立成因。

## 发生了什么？

<Problem statement, then the triage verdict, with `path:line` citations rewritten as `transcript line <n>`.>

## 复现步骤

1. <first human prompt, scrubbed>
2. <the turns leading to the problem, one line each>
3. <the observable>

## 预期行为

<from the problem statement>

## 实际行为

<from the triage verdict>

## 调试日志或会话记录（transcript）

会话 id：<ids>. Delivered local archive: <path, redaction level <level> | none built>. Attached bundle: <no claim; attach only after approval>。按诊断报告，Superpowers 的参与情况：<possible | likely>，证据见 <transcript lines>。本报告不提出修复方案。

---
本报告由 `diagnosing-superpowers` 技能提交。提交方的模型与 harness 见「谁在提交这份报告」小节；被诊断会话的模型、harness、版本与插件见「环境」表格。
