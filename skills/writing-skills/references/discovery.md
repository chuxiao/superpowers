# 为可发现性编写 SKILL.md

superpowers:writing-skills 的一部分：SKILL.md 模板，以及如何为技能命名、撰写描述并控制篇幅，让 agent 能找到并阅读它。

## SKILL.md 结构

**Frontmatter（YAML）：**
- 两个必填字段：`name` 与 `description`（全部支持的字段见 [agentskills.io/specification](https://agentskills.io/specification)）
- 总长最多 1024 个字符
- `name`：只使用字母、数字和连字符（不用括号与特殊字符）
- `description`：第三人称，只描述何时使用（而不是它做什么）
  - 以「当……时使用」开头，聚焦触发条件
  - 包含具体的症状、场景与情境
  - **绝不概括技能的流程或工作流**（原因见下文「技能可发现性优化」一节）
  - 如有可能，保持在 500 个字符以内

```markdown
---
name: Skill-Name-With-Hyphens
description: 当[具体触发条件与症状]时使用
---

# 技能名称

## 概述
这是什么？用 1-2 句话给出核心原则。

## 何时使用
[仅当决策并非显而易见时，才放一个小的内联流程图]

用要点列出症状与使用场景
何时不该使用

## 核心模式（针对技巧/模式类技能）
前后代码对比

## 速查参考
用于快速扫读常见操作的表格或要点

## 实现
简单模式直接用内联代码
重量级参考或可复用工具则链接到文件

## 常见错误
会出什么问题 + 修复方法

## 实际效果（可选）
具体成果
```

## 技能可发现性优化（SDO）

**对可发现性至关重要：**未来的 agent 需要能找到你的技能

### 1. 信息丰富的 description 字段

**目的：**你的 agent 会阅读 description 来决定针对给定任务加载哪些技能。要让 description 能回答：「我现在是否就该读这个技能？」

**格式：**以「当……时使用」开头，聚焦触发条件

**关键：description = 何时使用，绝不是技能做什么**

description 只应描述触发条件。绝不要在 description 里概括技能的流程或工作流。

**为什么重要：**测试发现，当 description 概括了技能的工作流时，agent 可能照着 description 行事，而不去阅读完整的技能内容。一条写着「任务之间进行代码审查」的 description 曾导致 agent 仅做了一次审查，尽管技能的流程图明确画了两次审查（先审查设计文档符合性，再审查代码质量）。

后来把 description 改成只有「当执行含独立任务的实施计划时使用」（不含工作流概括），agent 就正确阅读了流程图，并遵循了两阶段审查流程。

**陷阱：**概括工作流的 description 会制造一条 agent 必然去走的捷径。技能正文由此沦为 agent 跳过不读的文档。

```yaml
# ❌ 错误：概括了工作流——agent 可能照此行事，而不去读技能
description: 当执行计划时使用——每个任务派发一个子代理，任务之间进行代码审查

# ❌ 错误：过程细节太多
description: 用于 TDD——先写测试、看它失败、写最少代码、再重构

# ✅ 正确：只有触发条件，无工作流概括
description: 当在当前会话中执行含独立任务的实施计划时使用

# ✅ 正确：只写触发条件
description: 当实现任何功能或修复 bug 时，在编写实现代码之前使用
```

**内容：**
- 使用能表明本技能适用的具体触发条件、症状与情境
- 描述*问题*本身（竞态条件、行为不一致），而不是*语言特定的症状*（setTimeout、sleep）
- 触发条件不要绑定特定技术，除非技能本身就特定于某项技术
- 如果技能特定于某项技术，就在触发条件中明确写出
- 用第三人称书写（会被注入系统提示词）
- **绝不概括技能的流程或工作流**

```yaml
# ❌ 错误：太抽象、含糊，没说明何时使用
description: 用于异步测试

# ❌ 错误：第一人称
description: 当异步测试不稳定时，我可以帮你处理

# ❌ 错误：提到了技术，但技能并不特定于该技术
description: 当测试用到 setTimeout/sleep 且不稳定时使用

# ✅ 正确：以「当……时使用」开头，描述问题，无工作流
description: 当测试存在竞态条件、时序依赖，或通过/失败结果不一致时使用

# ✅ 正确：特定技术的技能，触发条件中明确写出
description: 当使用 React Router 并处理认证重定向时使用
```

### 2. 关键词覆盖

使用 agent 会搜索的词语：
- 错误信息："Hook timed out"（Hook 超时）、"ENOTEMPTY"、"race condition"（竞态条件）
- 症状："flaky"（不稳定）、"hanging"（挂起）、"zombie"（僵尸进程）、"pollution"（污染）
- 同义词："timeout/hang/freeze"（超时/挂起/冻结）、"cleanup/teardown/afterEach"（清理/收尾/afterEach）
- 工具：实际的命令、库名、文件类型

### 3. 描述性命名

**用主动语态，动词在前：**
- ✅ `creating-skills`，而不是 `skill-creation`
- ✅ `condition-based-waiting`，而不是 `async-test-helpers`

### 4. Token 效率（关键）

**问题：**getting-started 和被频繁引用的技能会加载进每一次对话。每个 token 都很重要。

**目标词数：**
- getting-started 工作流：每个 <150 词
- 频繁加载的技能：总共 <200 词
- 其他技能：<500 词（仍要保持简洁）

**技巧：**

**把细节移进工具的帮助信息：**
```bash
# ❌ 错误：在 SKILL.md 里罗列所有 flag
search-conversations 支持 --text、--both、--after DATE、--before DATE、--limit N

# ✅ 正确：指向 --help
search-conversations 支持多种模式与过滤器。详情请运行 --help。
```

**使用交叉引用：**
```markdown
# ❌ 错误：重复工作流细节
搜索时，用模板派发子代理……
[重复的 20 行指令]

# ✅ 正确：引用其他技能
始终使用子代理（可节省 50-100 倍上下文）。REQUIRED：使用 [other-skill-name] 来执行工作流。
```

**压缩示例：**
```markdown
# ❌ 错误：冗长示例（42 词）
your human partner: "How did we handle authentication errors in React Router before?"
You: I'll search past conversations for React Router authentication patterns.
[Dispatch subagent with search query: "React Router authentication error handling 401"]

# ✅ 正确：极简示例（20 词）
Partner: "How did we handle auth errors in React Router?"
You: Searching...
[Dispatch subagent → synthesis]
```

**消除冗余：**
- 不要重复交叉引用的技能里已有的内容
- 不要解释从命令本身就能看出的东西
- 不要为同一个模式给出多个示例

**验证：**
```bash
wc -w skills/path/SKILL.md
# getting-started 工作流：目标为每个 <150 词
# 其他频繁加载的技能：目标为总共 <200 词
```

**用你实际做的事或核心洞见来命名：**
- ✅ `condition-based-waiting` 优于 `async-test-helpers`
- ✅ `using-skills`，而不是 `skill-usage`
- ✅ `flatten-with-flags` 优于 `data-structure-refactoring`
- ✅ `root-cause-tracing` 优于 `debugging-techniques`

**动名词（-ing）适合过程类技能：**
- `creating-skills`、`testing-skills`、`debugging-with-logs`
- 主动语态，描述你正在做的动作

### 5. 交叉引用其他技能

**撰写会引用其他技能的文档时：**

只写技能名，并加上明确的需求标记：
- ✅ 正确：`**REQUIRED SUB-SKILL:** Use superpowers:test-driven-development`
- ✅ 正确：`**REQUIRED BACKGROUND:** You MUST understand superpowers:systematic-debugging`
- ❌ 错误：`See skills/testing/test-driven-development`（不清楚是否必需）
- ❌ 错误：`@skills/testing/test-driven-development/SKILL.md`（强制加载，消耗上下文）

**为什么不用 @ 链接：**`@` 语法会立即强制加载文件，在你需要之前就消耗 200k+ 的上下文。
