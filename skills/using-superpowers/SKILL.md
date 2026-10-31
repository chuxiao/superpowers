---
name: using-superpowers
description: 在开始任何对话时使用——规定如何查找与使用技能，要求在发出任何回应（包括澄清性问题）之前先调用技能
---

<SUBAGENT-STOP>
如果你是作为子代理被派发去执行某个具体任务的，忽略本技能。
</SUBAGENT-STOP>

<EXTREMELY-IMPORTANT>
如果你认为哪怕只有 1% 的可能有一项技能适用于你正在做的事，你也绝对必须调用该技能。

如果一项技能适用于你的任务，你没有选择的余地。你必须使用它。

这不可协商。你无法用合理化借口绕开这条规则。
</EXTREMELY-IMPORTANT>

## 规则

**在任何回应或行动之前，先调用相关技能或请求中点名的技能**——包括提出澄清性问题、探索代码库或查看文件。如果事后发现它不适合当前情况，你就不必使用它。

**在进入 plan mode 之前：**如果你还没有做过头脑风暴，先调用 brainstorming 技能。

然后宣布「Using [skill] to [purpose]」（使用 [技能] 来 [目的]），并严格遵循该技能。如果它有清单，就为每一项各创建一个待办。

## 技能优先级

当多个技能都适用时，流程技能优先——它们确定方法，然后由实现技能（frontend-design 等）来落实。Brainstorming 和 systematic-debugging 是 Superpowers 中最常用的流程技能，但这条优先级规则适用于任何流程技能，不止这两个。

- 「我们来构建 X」→ 先用 superpowers:brainstorming，再用实现技能。
- 「修复这个 bug」→ 先用 superpowers:systematic-debugging，再用领域技能。

## 危险信号

出现这些念头就说明你该停下——你正在找合理化借口：

| 念头 | 现实 |
|---------|---------|
| 「这只是一个简单的问题」 | 问题也是任务。检查是否有技能。 |
| 「我需要先了解更多上下文」 | 技能检查必须先于澄清性问题。 |
| 「让我先探索一下代码库」 | 技能会告诉你如何探索。先检查。 |
| 「我可以快速查一下 git/文件」 | 文件缺少对话上下文。检查是否有技能。 |
| 「让我先收集一些信息」 | 技能会告诉你如何收集信息。 |
| 「这不需要正式的技能」 | 只要有技能存在，就使用它。 |
| 「我记得这个技能」 | 技能会演进。读当前版本。 |
| 「这不算一个任务」 | 行动 = 任务。检查是否有技能。 |
| 「用这个技能是小题大做」 | 简单的事会变得复杂。使用它。 |
| 「我先只做这一件事」 | 做任何事之前，先检查。 |
| 「这感觉很有成效」 | 不守纪律的行动浪费时间。技能能防止这一点。 |
| 「我知道那是什么意思」 | 知道概念 ≠ 使用技能。调用它。 |

## 平台适配

如果你的 harness 出现在下面的列表中，请阅读该 harness 的参考文件以获取特别说明：

- Claude Code: `references/claude-code-tools.md`
- Codex: `references/codex-tools.md`
- Pi: `references/pi-tools.md`
- Antigravity: `references/antigravity-tools.md`
- Hermes Agent: `references/hermes-tools.md`
- Muse: `references/muse-tools.md`

## 用户指令

用户指令（CLAUDE.md、AGENTS.md、GEMINI.md 等，以及直接请求）优先于技能，而技能又覆盖默认行为。只有当你的需求方明确要求你跳过时，才可以跳过技能工作流或技能指令。
