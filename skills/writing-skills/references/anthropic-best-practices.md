# 技能编写最佳实践

> 学习如何编写有效的技能，让 agent 能够成功发现并使用。

好的技能简洁、结构清晰，并经过真实使用场景的检验。本指南提供实用的编写决策，帮助你写出 agent 能有效发现和使用的技能。

关于技能如何工作的概念背景，参见[技能概览](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)。

## 核心原则

### 简洁是关键

[上下文窗口](https://platform.claude.com/docs/en/build-with-claude/context-windows)是公共资源。你的技能要与 agent 需要了解的其他一切共享上下文窗口，包括：

* 系统提示词
* 对话历史
* 其他技能的元数据
* 你的实际请求

技能里的 token 并非每个都有即时成本。启动时，只有所有技能的元数据（name 和 description）被预加载。agent 只在技能变得相关时才读取 SKILL.md，其他文件也只在需要时才读。不过 SKILL.md 的简洁仍然重要：一旦 agent 加载了它，其中每个 token 都要与对话历史和其他上下文竞争。

**默认假设**：agent 本身已经非常聪明

只添加 agent 尚不具备的上下文。对每一条信息都要追问：

* 「agent 真的需要这段解释吗？」
* 「我可以假设 agent 已经知道这一点吗？」
* 「这段文字配得上它的 token 成本吗？」

**好示例：简洁**（约 50 个 token）：

````markdown  theme={null}
## 提取 PDF 文本

用 pdfplumber 做文本提取：

```python
import pdfplumber

with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```
````

**坏示例：过于冗长**（约 150 个 token）：

```markdown  theme={null}
## 提取 PDF 文本

PDF（Portable Document Format）是一种常见文件格式，包含文本、图片和其他内容。要从 PDF 中提取文本，你需要使用一个库。可用于处理 PDF 的库有很多，但我们推荐 pdfplumber，因为它易用，且能妥善处理大多数情况。首先你需要用 pip 安装它。然后你可以使用下面的代码……
```

简洁版假定 agent 知道 PDF 是什么、库如何工作。

### 设定合适的自由度

让具体程度与任务的脆弱性和可变性相匹配。

**高自由度**（纯文字说明）：

适用场景：

* 多种做法都可行
* 决策取决于上下文
* 由启发式规则指引方法

示例：

```markdown  theme={null}
## 代码审查流程

1. 分析代码结构与组织方式
2. 检查潜在 bug 或边界情况
3. 就可读性与可维护性提出改进建议
4. 核对是否符合项目约定
```

**中自由度**（带参数的伪代码或脚本）：

适用场景：

* 存在偏好的模式
* 允许一定变化
* 配置会影响行为

示例：

````markdown  theme={null}
## 生成报告

使用此模板并按需自定义：

```python
def generate_report(data, format="markdown", include_charts=True):
    # 处理数据
    # 以指定格式生成输出
    # 可选：包含可视化
```
````

**低自由度**（具体脚本，参数极少或没有）：

适用场景：

* 操作脆弱且容易出错
* 一致性至关重要
* 必须遵循特定顺序

示例：

````markdown  theme={null}
## 数据库迁移

精确运行这个脚本：

```bash
python scripts/migrate.py --verify --backup
```

不得修改命令或添加额外标志。
````

**类比**：把 agent 想象成一个探索路径的机器人：

* **两侧都是悬崖的窄桥**：只有一条安全的路。提供具体的护栏和精确的指令（低自由度）。示例：必须按精确顺序运行的数据库迁移。
* **没有危险的开阔场地**：多条路都能走向成功。给出大致方向，相信 agent 能找到最佳路线（高自由度）。示例：代码审查，由上下文决定最佳做法。

### 用计划使用的所有模型测试

技能是对模型的增补，因此效果取决于底层模型。用你计划使用技能的全部模型来测试它。

**按模型考虑测试要点**：

* **Claude Haiku**（快速、经济）：技能是否提供了足够的指引？
* **Claude Sonnet**（均衡）：技能是否清晰高效？
* **Claude Opus**（推理能力强）：技能是否避免了过度解释？

对 Opus 完美有效的内容，换成 Haiku 可能需要更多细节。如果你计划跨多个模型使用技能，就要以对所有模型都好用的说明为目标。

## 技能结构

<Note>
  **YAML frontmatter**：SKILL.md 的 frontmatter 需要两个字段：

  * `name` - 技能的人类可读名称（最多 64 个字符）
  * `description` - 一行描述，说明技能做什么以及何时使用（最多 1024 个字符）

  完整的技能结构细节参见[技能概览](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview#skill-structure)。
</Note>

### 命名规范

使用一致的命名模式，让技能更容易被引用和讨论。我们建议技能名采用**动名词形式**（动词 + -ing），因为它清楚地描述了技能提供的活动或能力。

**好的命名示例（动名词形式）**：

* "Processing PDFs"
* "Analyzing spreadsheets"
* "Managing databases"
* "Testing code"
* "Writing documentation"

**可接受的替代形式**：

* 名词短语："PDF Processing"、"Spreadsheet Analysis"
* 动作导向："Process PDFs"、"Analyze Spreadsheets"

**避免**：

* 含糊的名称："Helper"、"Utils"、"Tools"
* 过于宽泛："Documents"、"Data"、"Files"
* 技能集合内部命名模式不一致

一致的命名让以下事情更容易：

* 在文档和对话中引用技能
* 一眼看出技能的用途
* 组织和检索多个技能
* 维护专业、连贯的技能库

### 编写有效的 description

`description` 字段决定技能能否被发现，应当同时包含技能做什么以及何时使用。

<Warning>
  **始终用第三人称书写**。description 会被注入系统提示词，人称不一致可能导致可发现性问题。

  * **好：**「处理 Excel 文件并生成报告」
  * **避免：**「我可以帮你处理 Excel 文件」
  * **避免：**「你可以用这个来处理 Excel 文件」
</Warning>

**要具体并包含关键词**。既要写技能做什么，也要写明使用它的具体触发条件/场景。

每个技能有且仅有一个 description 字段。description 对技能选择至关重要：agent 要靠它从可能多达 100 多个可用技能中选出正确的一个。你的 description 必须提供足够细节，让 agent 知道何时选择这个技能；SKILL.md 的其余部分则提供实现细节。

有效示例：

**PDF Processing 技能：**

```yaml  theme={null}
description: 从 PDF 文件中提取文本和表格，填写表单，合并文档。当处理 PDF 文件，或用户提到 PDF、表单或文档提取时使用。
```

**Excel Analysis 技能：**

```yaml  theme={null}
description: 分析 Excel 电子表格，创建数据透视表，生成图表。当分析 Excel 文件、电子表格、表格数据或 .xlsx 文件时使用。
```

**Git Commit Helper 技能：**

```yaml  theme={null}
description: 通过分析 git diff 生成描述性的提交信息。当用户请求协助编写提交信息或审查暂存更改时使用。
```

避免这样的模糊描述：

```yaml  theme={null}
description: 帮助处理文档
```

```yaml  theme={null}
description: 处理数据
```

```yaml  theme={null}
description: 对文件做各种操作
```

### 渐进式披露模式

SKILL.md 充当总览，按需把 agent 指向详细材料，就像入职指南中的目录。关于渐进式披露如何运作的说明，参见概览中的[技能如何工作](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview#how-skills-work)。

**实用建议：**

* SKILL.md 正文保持在 500 行以内以获得最佳效果
* 接近该上限时把内容拆分到单独的文件
* 使用下面的模式有效组织说明、代码和资源

#### 可视化总览：从简单到复杂

一个基础技能一开始只有一个包含元数据和说明的 SKILL.md 文件：

<img src="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=87782ff239b297d9a9e8e1b72ed72db9" alt="Simple SKILL.md file showing YAML frontmatter and markdown body" data-og-width="2048" width="2048" data-og-height="1153" height="1153" data-path="images/agent-skills-simple-file.png" data-optimize="true" data-opv="3" srcset="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=280&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=c61cc33b6f5855809907f7fda94cd80e 280w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=560&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=90d2c0c1c76b36e8d485f49e0810dbfd 560w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=840&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=ad17d231ac7b0bea7e5b4d58fb4aeabb 840w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=1100&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=f5d0a7a3c668435bb0aee9a3a8f8c329 1100w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=1650&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=0e927c1af9de5799cfe557d12249f6e6 1650w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-simple-file.png?w=2500&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=46bbb1a51dd4c8202a470ac8c80a893d 2500w" />

随着技能变大，你可以捆绑更多内容，agent 只在需要时才加载：

<img src="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=a5e0aa41e3d53985a7e3e43668a33ea3" alt="Bundling additional reference files like reference.md and forms.md." data-og-width="2048" width="2048" data-og-height="1327" height="1327" data-path="images/agent-skills-bundling-content.png" data-optimize="true" data-opv="3" srcset="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=280&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=f8a0e73783e99b4a643d79eac86b70a2 280w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=560&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=dc510a2a9d3f14359416b706f067904a 560w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=840&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=82cd6286c966303f7dd914c28170e385 840w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=1100&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=56f3be36c77e4fe4b523df209a6824c6 1100w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=1650&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=d22b5161b2075656417d56f41a74f3dd 1650w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-bundling-content.png?w=2500&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=3dd4bdd6850ffcc96c6c45fcb0acd6eb 2500w" />

完整的技能目录结构可能如下：

```
pdf/
├── SKILL.md              # 主指令（触发时加载）
├── FORMS.md              # 表单填写指南（按需加载）
├── reference.md          # API 参考（按需加载）
├── examples.md           # 使用示例（按需加载）
└── scripts/
    ├── analyze_form.py   # 工具脚本（执行而非加载）
    ├── fill_form.py      # 表单填写脚本
    └── validate.py       # 校验脚本
```

#### 模式 1：带参考文件的高层指南

````markdown  theme={null}
---
name: PDF Processing
description: 从 PDF 文件中提取文本和表格，填写表单，合并文档。当处理 PDF 文件，或用户提到 PDF、表单或文档提取时使用。
---

# PDF Processing

## 快速开始

用 pdfplumber 提取文本：
```python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```

## 高级功能

**表单填写**：完整指南参见 [FORMS.md](FORMS.md)
**API 参考**：全部方法参见 [REFERENCE.md](REFERENCE.md)
**示例**：常见模式参见 [EXAMPLES.md](EXAMPLES.md)
````

agent 只在需要时才加载 FORMS.md、REFERENCE.md 或 EXAMPLES.md。

#### 模式 2：按领域组织

对包含多个领域的技能，按领域组织内容以避免加载无关上下文。当用户询问销售指标时，agent 只需要读销售相关的 schema，不需要读财务或营销数据。这样能把 token 用量保持在低位，让上下文保持聚焦。

```
bigquery-skill/
├── SKILL.md （总览与导航）
└── reference/
    ├── finance.md （营收、计费指标）
    ├── sales.md （商机、销售管线）
    ├── product.md （API 用量、功能）
    └── marketing.md （营销活动、归因）
```

````markdown SKILL.md theme={null}
# BigQuery Data Analysis

## 可用数据集

**Finance**：营收、ARR、计费 → 参见 [reference/finance.md](reference/finance.md)
**Sales**：商机、销售管线、客户 → 参见 [reference/sales.md](reference/sales.md)
**Product**：API 用量、功能、采用情况 → 参见 [reference/product.md](reference/product.md)
**Marketing**：营销活动、归因、邮件 → 参见 [reference/marketing.md](reference/marketing.md)

## 快速检索

用 grep 查找具体指标：

```bash
grep -i "revenue" reference/finance.md
grep -i "pipeline" reference/sales.md
grep -i "api usage" reference/product.md
```
````

#### 模式 3：条件式细节

展示基础内容，链接到高级内容：

```markdown  theme={null}
# DOCX Processing

## 创建文档

新建文档用 docx-js。参见 [DOCX-JS.md](DOCX-JS.md)。

## 编辑文档

简单修改直接改 XML。

**涉及修订（tracked changes）**：参见 [REDLINING.md](REDLINING.md)
**OOXML 细节**：参见 [OOXML.md](OOXML.md)
```

只有当用户需要那些功能时，agent 才会读 REDLINING.md 或 OOXML.md。

### 避免深层嵌套的引用

当文件被其他被引用文件引用时，agent 可能只部分读取文件。遇到嵌套引用时，agent 可能用 `head -100` 之类的命令预览内容而不是读完整文件，导致信息不完整。

**引用保持在距 SKILL.md 一层以内**。所有参考文件都应直接从 SKILL.md 链接，确保 agent 在需要时读到完整文件。

**坏示例：层级过深**：

```markdown  theme={null}
# SKILL.md
参见 [advanced.md](advanced.md)...

# advanced.md
参见 [details.md](details.md)...

# details.md
真正的信息在这里...
```

**好示例：只深一层**：

```markdown  theme={null}
# SKILL.md

**基本用法**：[说明在 SKILL.md 中]
**高级功能**：参见 [advanced.md](advanced.md)
**API 参考**：参见 [reference.md](reference.md)
**示例**：参见 [examples.md](examples.md)
```

### 用目录组织较长的参考文件

超过 100 行的参考文件，在顶部加一个目录。这样即使 agent 用部分读取做预览，也能看到可用信息的完整范围。

**示例**：

```markdown  theme={null}
# API Reference

## 目录
- 认证与设置
- 核心方法（创建、读取、更新、删除）
- 高级功能（批量操作、webhook）
- 错误处理模式
- 代码示例

## 认证与设置
...

## 核心方法
...
```

然后 agent 可以按需读取完整文件或跳到特定小节。

关于这套基于文件系统的架构如何实现渐进式披露的细节，参见下方高级部分中的[运行环境](#运行环境)小节。

## 工作流与反馈循环

### 对复杂任务使用工作流

把复杂操作拆成清晰的顺序步骤。对特别复杂的工作流，提供一份清单，让 agent 可以复制到自己的回复里并随进度逐项勾选。

**示例 1：研究综合工作流**（适用于不含代码的技能）：

````markdown  theme={null}
## 研究综合工作流

复制这份清单并跟踪你的进度：

```
研究进度：
- [ ] Step 1: 读取所有源文档
- [ ] Step 2: 识别关键主题
- [ ] Step 3: 交叉核对论断
- [ ] Step 4: 创建结构化摘要
- [ ] Step 5: 核验引用
```

**Step 1: 读取所有源文档**

审阅 `sources/` 目录中的每个文档。记录主要论点和支撑证据。

**Step 2: 识别关键主题**

寻找各来源之间的模式。哪些主题反复出现？各来源在哪里一致、在哪里分歧？

**Step 3: 交叉核对论断**

对每条主要论断，核实它确实出现在源材料中。记录每一点由哪个来源支撑。

**Step 4: 创建结构化摘要**

按主题组织发现。包括：
- 主要论断
- 来自来源的支撑证据
- 相互冲突的观点（如有）

**Step 5: 核验引用**

检查每条论断都引用了正确的源文档。如果引用不完整，回到 Step 3。
````

这个示例展示工作流如何应用于不需要代码的分析任务。清单模式适用于任何复杂的多步骤流程。

**示例 2：PDF 表单填写工作流**（适用于含代码的技能）：

````markdown  theme={null}
## PDF 表单填写工作流

复制这份清单，完成一项就勾掉一项：

```
任务进度：
- [ ] Step 1: 分析表单（运行 analyze_form.py）
- [ ] Step 2: 创建字段映射（编辑 fields.json）
- [ ] Step 3: 校验映射（运行 validate_fields.py）
- [ ] Step 4: 填写表单（运行 fill_form.py）
- [ ] Step 5: 核验输出（运行 verify_output.py）
```

**Step 1: 分析表单**

Run: `python scripts/analyze_form.py input.pdf`

这一步提取表单字段及其位置，保存到 `fields.json`。

**Step 2: 创建字段映射**

编辑 `fields.json`，为每个字段填入值。

**Step 3: 校验映射**

Run: `python scripts/validate_fields.py fields.json`

继续之前先修复所有校验错误。

**Step 4: 填写表单**

Run: `python scripts/fill_form.py input.pdf fields.json output.pdf`

**Step 5: 核验输出**

Run: `python scripts/verify_output.py output.pdf`

如果核验失败，回到 Step 2。
````

清晰的步骤能防止 agent 跳过关键校验。清单能帮你和 agent 共同跟踪多步骤工作流的进度。

### 实现反馈循环

**常见模式**：运行校验器 → 修复错误 → 重复

这个模式能大幅提升输出质量。

**示例 1：风格指南合规**（适用于不含代码的技能）：

```markdown  theme={null}
## 内容审查流程

1. 按照 STYLE_GUIDE.md 中的指引起草内容
2. 对照清单审查：
   - 检查术语一致性
   - 核对示例是否符合标准格式
   - 确认所有必需小节齐全
3. 如果发现问题：
   - 记录每个问题并注明具体小节
   - 修订内容
   - 再次对照清单审查
4. 只有全部要求都满足才能继续
5. 定稿并保存文档
```

这里展示的是用参考文档代替脚本的校验循环模式。「校验器」就是 STYLE\_GUIDE.md，agent 通过阅读和比对来执行检查。

**示例 2：文档编辑流程**（适用于含代码的技能）：

```markdown  theme={null}
## 文档编辑流程

1. 对 `word/document.xml` 做你的修改
2. **立即校验**：`python ooxml/scripts/validate.py unpacked_dir/`
3. 如果校验失败：
   - 仔细阅读错误信息
   - 修复 XML 中的问题
   - 再次运行校验
4. **只有校验通过才能继续**
5. 重新打包：`python ooxml/scripts/pack.py unpacked_dir/ output.docx`
6. 测试输出的文档
```

校验循环能尽早抓住错误。

## 内容指引

### 避免时效性信息

不要包含将来会过时的信息：

**坏示例：有时效性**（将来会变错）：

```markdown  theme={null}
如果你在 2025 年 8 月之前做这件事，用旧 API。
2025 年 8 月之后，用新 API。
```

**好示例**（使用「旧模式」小节）：

```markdown  theme={null}
## 当前方法

使用 v2 API 端点：`api.example.com/v2/messages`

## 旧模式

<details>
<summary>旧版 v1 API（2025-08 已弃用）</summary>

v1 API 使用的端点：`api.example.com/v1/messages`

该端点已不再受支持。
</details>
```

「旧模式」小节提供历史背景，同时不把主内容搞乱。

### 使用一致的术语

选定一个术语，在整个技能中贯彻使用：

**好 - 一致**：

* 始终用 "API endpoint"
* 始终用 "field"
* 始终用 "extract"

**坏 - 不一致**：

* 混用 "API endpoint"、"URL"、"API route"、"path"
* 混用 "field"、"box"、"element"、"control"
* 混用 "extract"、"pull"、"get"、"retrieve"

一致性帮助 agent 理解并遵循指令。

## 常见模式

### 模板模式

为输出格式提供模板。让严格程度匹配你的需求。

**对严格要求**（如 API 响应或数据格式）：

````markdown  theme={null}
## 报告结构

必须始终使用这个模板结构：

```markdown
# [分析标题]

## 执行摘要
[关键发现的一段式概述]

## 关键发现
- 发现项 1 及支撑数据
- 发现项 2 及支撑数据
- 发现项 3 及支撑数据

## 建议
1. 具体可执行的建议
2. 具体可执行的建议
```
````

**对灵活指引**（当适配有用时）：

````markdown  theme={null}
## 报告结构

下面是一个合理的默认格式，但请根据分析自行判断取舍：

```markdown
# [分析标题]

## 执行摘要
[概述]

## 关键发现
[根据发现调整小节]

## 建议
[按具体情境裁剪]
```

针对具体分析类型按需调整小节。
````

### 示例模式

对输出质量取决于看到示例的技能，像常规提示词工程一样提供输入/输出对：

````markdown  theme={null}
## 提交信息格式

参照以下示例生成提交信息：

**示例 1：**
输入：用 JWT token 添加了用户认证
输出：
```
feat(auth): implement JWT-based authentication

Add login endpoint and token validation middleware
```

**示例 2：**
输入：修复了报告中日期显示错误的 bug
输出：
```
fix(reports): correct date formatting in timezone conversion

Use UTC timestamps consistently across report generation
```

**示例 3：**
输入：更新了依赖并重构了错误处理
输出：
```
chore: update dependencies and refactor error handling

- Upgrade lodash to 4.17.21
- Standardize error response format across endpoints
```

遵循这种风格：type(scope)：简短描述，然后是详细说明。
````

示例比单纯的描述更能帮助 agent 清楚理解目标风格和详细程度。

### 条件式工作流模式

引导 agent 通过决策点：

```markdown  theme={null}
## 文档修改工作流

1. 判断修改类型：

   **创建新内容？** → 走下面的「创建工作流」
   **编辑现有内容？** → 走下面的「编辑工作流」

2. 创建工作流：
   - 使用 docx-js 库
   - 从零构建文档
   - 导出为 .docx 格式

3. 编辑工作流：
   - 解包现有文档
   - 直接修改 XML
   - 每次修改后都校验
   - 完成后重新打包
```

<Tip>
  如果工作流变得庞大或步骤繁多，考虑把它们推到单独的文件里，并告诉 agent 根据手头任务读取相应文件。
</Tip>

## 评估与迭代

### 先构建评估

**在编写大量文档之前先创建评估。**这能确保你的技能解决真实问题，而不是记录想象出来的问题。

**评估驱动开发：**

1. **识别差距**：在没有技能的情况下，让你的 agent 跑有代表性的任务。记录具体的失败或缺失的上下文
2. **创建评估**：构建三个测试这些差距的场景
3. **建立基线**：测量没有技能时 agent 的表现
4. **编写最小说明**：只创建刚好够弥补差距并通过评估的内容
5. **迭代**：执行评估，与基线对比，然后改进

这种做法确保你解决的是真实存在的问题，而不是在预判可能永远不会出现的需求。

**评估结构**：

```json  theme={null}
{
  "skills": ["pdf-processing"],
  "query": "Extract all text from this PDF file and save it to output.txt",
  "files": ["test-files/document.pdf"],
  "expected_behavior": [
    "Successfully reads the PDF file using an appropriate PDF processing library or command-line tool",
    "Extracts text content from all pages in the document without missing any pages",
    "Saves the extracted text to a file named output.txt in a clear, readable format"
  ]
}
```

<Note>
  这个示例演示的是带简单测试评分规则的数据驱动评估。我们目前没有提供运行这些评估的内置方式，用户可以自建评估系统。评估是衡量技能效果的权威依据。
</Note>

### 与 agent 一起迭代开发技能

最有效的技能开发流程要让 agent 自身参与。与一个实例（「Agent A」）协作，创建将由其他实例（「Agent B」）使用的技能。Agent A 帮你设计和打磨说明，Agent B 在真实任务中测试它们。这之所以有效，是因为底层模型既懂得如何编写有效的 agent 指令，也了解 agent 需要什么信息。

**创建新技能：**

1. **不用技能完成一个任务**：用常规提示词与 Agent A 一起解决一个问题。工作过程中你会自然地提供上下文、解释偏好、分享流程性知识。注意你反复提供了哪些信息。

2. **识别可复用模式**：任务完成后，找出你提供的上下文中哪些对未来类似任务有用。

   **示例**：如果你完成了一次 BigQuery 分析，你可能提供过表名、字段定义、过滤规则（比如「始终排除测试账号」）和常见查询模式。

3. **让 Agent A 创建技能**：「创建一个技能，把这套 BigQuery 分析模式沉淀下来。包括表 schema、命名规范和过滤测试账号的规则。」

   <Tip>
     现代 agent 天然理解技能的格式与结构。创建技能不需要特殊的系统提示词，也不需要一个「技能编写」技能来帮忙。直接让 agent 创建技能，它就会生成结构正确的 SKILL.md 内容，带上合适的 frontmatter 和正文。
   </Tip>

4. **审查是否简洁**：检查 Agent A 有没有添加不必要的解释。可以说：「把解释胜率含义的内容删掉——agent 已经知道胜率是什么。」

5. **改进信息架构**：让 Agent A 把内容组织得更有效。例如：「把表 schema 放到单独的参考文件里。以后我们可能还会加更多表。」

6. **在类似任务上测试**：让加载了技能的 Agent B（一个全新实例）处理相关用例。观察 Agent B 是否找到正确的信息、正确应用规则、顺利完成任务。

7. **根据观察迭代**：如果 Agent B 遇到困难或遗漏了什么，带着具体细节回到 Agent A：「agent 用这个技能时，忘了按 Q4 的日期过滤。要不要加一节讲日期过滤模式？」

**迭代已有技能：**

改进技能时延续同样的分层模式。你在以下角色之间交替：

* **与 Agent A 协作**（帮忙打磨技能的专家）
* **用 Agent B 测试**（使用技能执行真实工作的那个 agent）
* **观察 Agent B 的行为**并把洞见带回给 Agent A

1. **在真实工作流中使用技能**：给 Agent B（加载了技能）真实任务，而不是测试场景

2. **观察 Agent B 的行为**：记录它在哪里遇到困难、哪里成功、哪里做出出人意料的选择

   **观察示例**：「我让 Agent B 出一份区域销售报告，它写出了查询，却忘了过滤测试账号，尽管技能里提到了这条规则。」

3. **回到 Agent A 寻求改进**：把当前的 SKILL.md 分享给它，描述你的观察。可以说：「我注意到让 Agent B 出区域报告时它忘了过滤测试账号。技能里提到了过滤，但可能不够醒目？」

4. **审视 Agent A 的建议**：Agent A 可能会建议重新组织内容让规则更醒目、改用更强的措辞（如用 "MUST filter" 代替 "always filter"），或重构工作流小节。

5. **应用并测试更改**：把 Agent A 的打磨更新进技能，再用 Agent B 在类似请求上测试

6. **按使用情况重复**：遇到新场景就继续这个观察-打磨-测试循环。每次迭代都基于 agent 的真实行为而非假设来改进技能。

**收集团队反馈：**

1. 与队友分享技能并观察他们的使用
2. 询问：技能是否在预期时激活？指令清晰吗？缺了什么？
3. 吸收反馈，弥补你自己使用模式中的盲区

**这个方法为什么有效**：Agent A 懂 agent 的需求，你提供领域专业知识，Agent B 通过真实使用暴露差距，迭代打磨让技能基于观察到的行为而非假设得到改进。

### 观察 agent 如何导航技能

迭代技能时，留意 agent 在实践中究竟怎么使用它们。注意以下信号：

* **出人意料的探索路径**：agent 读文件的顺序是否出乎你的预料？这可能说明你的结构不如你以为的那么直观
* **漏掉的关联**：agent 是否没有跟随指向重要文件的引用？你的链接可能需要更明确或更醒目
* **过度依赖某些小节**：如果 agent 反复读同一个文件，考虑是不是该把那部分内容放进主 SKILL.md
* **被忽略的内容**：如果 agent 从不访问某个捆绑文件，它可能不必要，或者在主说明中信号太弱

基于这些观察而非假设来迭代。技能元数据中的「name」和「description」尤其关键。agent 在决定是否针对当前任务触发技能时用的就是它们。确保它们清楚描述技能做什么、何时应使用。

## 需要避免的反模式

### 避免 Windows 风格路径

文件路径始终用正斜杠，即使在 Windows 上：

* ✓ **好**：`scripts/helper.py`、`reference/guide.md`
* ✗ **避免**：`scripts\helper.py`、`reference\guide.md`

Unix 风格路径在所有平台都可用，而 Windows 风格路径在 Unix 系统上会报错。

### 避免提供过多选项

除非必要，不要给出多种做法：

````markdown  theme={null}
**坏示例：选项太多**（令人困惑）：
"你可以用 pypdf，或者 pdfplumber，或者 PyMuPDF，或者 pdf2image，或者..."

**好示例：给出默认项**（留有退路）：
"文本提取用 pdfplumber：
```python
import pdfplumber
```

对需要 OCR 的扫描版 PDF，改用 pdf2image 加 pytesseract。"
````

## 高级：含可执行代码的技能

下面几节聚焦于包含可执行脚本的技能。如果你的技能只用 markdown 说明，直接跳到[高效技能清单](#高效技能清单)。

### 解决问题，而不是推给 agent

为技能编写脚本时，要处理错误情况，而不是把问题丢回给 agent。

**好示例：显式处理错误**：

```python  theme={null}
def process_file(path):
    """Process a file, creating it if it doesn't exist."""
    try:
        with open(path) as f:
            return f.read()
    except FileNotFoundError:
        # 不失败退出，而是以默认内容创建文件
        print(f"File {path} not found, creating default")
        with open(path, 'w') as f:
            f.write('')
        return ''
    except PermissionError:
        # 不失败退出，而是提供替代方案
        print(f"Cannot access {path}, using default")
        return ''
```

**坏示例：把问题丢给 agent**：

```python  theme={null}
def process_file(path):
    # 直接失败，让 agent 自己想办法
    return open(path).read()
```

配置参数也应当有依据并有文档，避免「巫毒常量」（Ousterhout 定律）。如果你都不知道正确的值是什么，agent 怎么可能确定？

**好示例：自解释**：

```python  theme={null}
# HTTP 请求通常在 30 秒内完成
# 更长的超时是为慢连接留余量
REQUEST_TIMEOUT = 30

# 三次重试在可靠性与速度之间取得平衡
# 多数间歇性失败到第二次重试就能恢复
MAX_RETRIES = 3
```

**坏示例：魔法数字**：

```python  theme={null}
TIMEOUT = 47  # 为什么是 47？
RETRIES = 5   # 为什么是 5？
```

### 提供工具脚本

即使你的 agent 自己也能写脚本，预制脚本仍有优势：

**工具脚本的好处**：

* 比临时生成的代码更可靠
* 节省 token（无需把代码放进上下文）
* 节省时间（无需生成代码）
* 保证多次使用之间的一致性

<img src="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=4bbc45f2c2e0bee9f2f0d5da669bad00" alt="Bundling executable scripts alongside instruction files" data-og-width="2048" width="2048" data-og-height="1154" height="1154" data-path="images/agent-skills-executable-scripts.png" data-optimize="true" data-opv="3" srcset="https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=280&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=9a04e6535a8467bfeea492e517de389f 280w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=560&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=e49333ad90141af17c0d7651cca7216b 560w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=840&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=954265a5df52223d6572b6214168c428 840w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=1100&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=2ff7a2d8f2a83ee8af132b29f10150fd 1100w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=1650&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=48ab96245e04077f4d15e9170e081cfb 1650w, https://mintcdn.com/anthropic-claude-docs/4Bny2bjzuGBK7o00/images/agent-skills-executable-scripts.png?w=2500&fit=max&auto=format&n=4Bny2bjzuGBK7o00&q=85&s=0301a6c8b3ee879497cc5b5483177c90 2500w" />

上面的图展示了可执行脚本如何与说明文件配合。说明文件（forms.md）引用脚本，agent 可以执行脚本而不用把脚本内容加载进上下文。

**重要区分**：在说明中写清楚 agent 应该：

* **执行脚本**（最常见）：「运行 `analyze_form.py` 来提取字段」
* **当作参考来读**（针对复杂逻辑）：「字段提取算法参见 `analyze_form.py`」

多数工具脚本更适合执行，因为这样更可靠、更高效。脚本执行如何运作的细节参见下文的[运行环境](#运行环境)小节。

**示例**：

````markdown  theme={null}
## 工具脚本

**analyze_form.py**：从 PDF 提取全部表单字段

```bash
python scripts/analyze_form.py input.pdf > fields.json
```

输出格式：
```json
{
  "field_name": {"type": "text", "x": 100, "y": 200},
  "signature": {"type": "sig", "x": 150, "y": 500}
}
```

**validate_boxes.py**：检查边界框是否重叠

```bash
python scripts/validate_boxes.py fields.json
# 返回 "OK" 或列出冲突
```

**fill_form.py**：把字段值应用到 PDF

```bash
python scripts/fill_form.py input.pdf fields.json output.pdf
```
````

### 使用视觉分析

当输入可以渲染成图像时，让 agent 分析它们：

````markdown  theme={null}
## 表单布局分析

1. 把 PDF 转成图片：
   ```bash
   python scripts/pdf_to_images.py form.pdf
   ```

2. 分析每一页的图片以识别表单字段
3. agent 可以直观地看到字段的位置和类型
````

<Note>
  在这个示例中，你需要自己编写 `pdf_to_images.py` 脚本。
</Note>

agent 的视觉能力有助于理解布局和结构。

### 创建可核验的中间产物

agent 执行复杂、开放式的任务时会犯错。「计划-校验-执行」模式能尽早抓住错误：先让 agent 以结构化格式创建计划，执行前再用脚本校验该计划。

**示例**：设想让 agent 根据一张电子表格更新 PDF 中的 50 个表单字段。没有校验的话，它可能引用不存在的字段、制造相互冲突的值、漏掉必填字段，或者更新应用出错。

**解法**：使用上文展示的工作流模式（PDF 表单填写），但增加一个中间 `changes.json` 文件，在应用更改之前先校验它。工作流变成：分析 → **创建计划文件** → **校验计划** → 执行 → 核验。

**这个模式为什么有效：**

* **尽早抓住错误**：校验在更改应用之前就发现问题
* **机器可核验**：脚本提供客观验证
* **计划可回退**：agent 可以反复迭代计划而不碰原件
* **调试清晰**：错误信息直接指向具体问题

**何时使用**：批量操作、破坏性更改、复杂校验规则、高风险操作。

**实现提示**：让校验脚本输出详细、具体的错误信息，比如 "Field 'signature\_date' not found. Available fields: customer\_name, order\_total, signature\_date\_signed"，帮助 agent 修复问题。

### 包依赖

技能运行在代码执行环境中，不同平台有不同限制：

* **claude.ai**：可以从 npm 和 PyPI 安装包，并从 GitHub 仓库拉取
* **Anthropic API**：没有网络访问，也无法在运行时安装包

在 SKILL.md 中列出所需的包，并对照[代码执行工具文档](https://platform.claude.com/docs/en/agents-and-tools/tool-use/code-execution-tool)确认它们可用。

### 运行环境

技能运行在具备文件系统访问、bash 命令和代码执行能力的代码执行环境中。这一架构的概念性说明参见概览中的[技能架构](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview#the-skills-architecture)。

**这对你的编写意味着什么：**

**agent 如何访问技能：**

1. **元数据预加载**：启动时，所有技能 YAML frontmatter 中的 name 和 description 被加载进系统提示词
2. **文件按需读取**：agent 用自己的文件读取工具按需访问文件系统中的 SKILL.md 和其他文件
3. **脚本高效执行**：工具脚本可以通过 bash 执行而无需把完整内容加载进上下文，只有脚本输出消耗 token
4. **大文件无上下文代价**：参考文件、数据或文档在被真正读取之前不消耗上下文 token

* **文件路径很重要**：agent 像浏览文件系统一样浏览你的技能目录。用正斜杠（`reference/guide.md`），不要用反斜杠
* **文件名要有描述性**：名字要能表明内容：用 `form_validation_rules.md`，不要用 `doc2.md`
* **为发现而组织**：按领域或功能组织目录
  * 好：`reference/finance.md`、`reference/sales.md`
  * 坏：`docs/file1.md`、`docs/file2.md`
* **捆绑全面的资源**：收录完整的 API 文档、大量示例、大型数据集；在被访问之前不产生上下文代价
* **确定性操作优先用脚本**：写一个 `validate_form.py`，而不是让 agent 生成校验代码
* **写明执行意图**：
  * 「运行 `analyze_form.py` 来提取字段」（执行）
  * 「提取算法参见 `analyze_form.py`」（当作参考来读）
* **测试文件访问模式**：用真实请求测试，验证 agent 能在你的目录结构中导航

**示例：**

```
bigquery-skill/
├── SKILL.md （总览，指向参考文件）
└── reference/
    ├── finance.md （营收指标）
    ├── sales.md （销售管线数据）
    └── product.md （使用分析）
```

当用户询问营收时，agent 读 SKILL.md，看到对 `reference/finance.md` 的引用，然后调用 bash 只读那一个文件。sales.md 和 product.md 留在文件系统上，在被需要之前消耗零个上下文 token。这套基于文件系统的模型正是渐进式披露得以实现的基础。agent 可以导航并按每个任务的需要选择性加载。

技术架构的完整细节参见技能概览中的[技能如何工作](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview#how-skills-work)。

### MCP 工具引用

如果你的技能使用 MCP（Model Context Protocol）工具，始终使用全限定工具名，避免「找不到工具」错误。

**格式**：`ServerName:tool_name`

**示例**：

```markdown  theme={null}
用 BigQuery:bigquery_schema 工具检索表 schema。
用 GitHub:create_issue 工具创建 issue。
```

其中：

* `BigQuery` 和 `GitHub` 是 MCP 服务器名
* `bigquery_schema` 和 `create_issue` 是这些服务器内的工具名

没有服务器前缀，agent 可能找不到工具，在有多个 MCP 服务器可用时尤其如此。

### 避免假定工具已安装

不要假定包已经可用：

````markdown  theme={null}
**坏示例：假定已安装**：
"用 pdf 库处理这个文件。"

**好示例：明确依赖**：
"先安装所需的包：`pip install pypdf`

然后使用：
```python
from pypdf import PdfReader
reader = PdfReader("file.pdf")
```"
````

## 技术说明

### YAML frontmatter 要求

SKILL.md 的 frontmatter 需要 `name`（最多 64 个字符）和 `description`（最多 1024 个字符）两个字段。完整结构细节参见[技能概览](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview#skill-structure)。

### token 预算

为获得最佳效果，SKILL.md 正文保持在 500 行以内。如果内容超过这个数，用前文介绍的渐进式披露模式拆分到单独文件。架构细节参见[技能概览](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview#how-skills-work)。

## 高效技能清单

分享技能之前，核对以下各项：

### 核心质量

* [ ] description 具体并包含关键词
* [ ] description 同时写明技能做什么和何时使用
* [ ] SKILL.md 正文在 500 行以内
* [ ] 补充细节放在单独文件中（如有需要）
* [ ] 没有时效性信息（或已放进「旧模式」小节）
* [ ] 全文术语一致
* [ ] 示例具体而非抽象
* [ ] 文件引用只深一层
* [ ] 恰当使用渐进式披露
* [ ] 工作流步骤清晰

### 代码与脚本

* [ ] 脚本自己解决问题，而不是把问题丢给 agent
* [ ] 错误处理显式且有帮助
* [ ] 没有「巫毒常量」（所有取值都有依据）
* [ ] 所需的包已在说明中列出并确认可用
* [ ] 脚本有清晰的文档
* [ ] 没有 Windows 风格路径（全部用正斜杠）
* [ ] 关键操作有校验/核验步骤
* [ ] 质量关键任务带反馈循环

### 测试

* [ ] 至少创建了三个评估
* [ ] 用 Haiku、Sonnet、Opus 测试过
* [ ] 用真实使用场景测试过
* [ ] 已吸收团队反馈（如适用）

## 后续步骤

<CardGroup cols={2}>
  <Card title="开始使用 Agent Skills" icon="rocket" href="https://platform.claude.com/docs/en/agents-and-tools/agent-skills/quickstart">
    创建你的第一个技能
  </Card>

  <Card title="在 Claude Code 中使用技能" icon="terminal" href="https://code.claude.com/docs/en/skills">
    在 Claude Code 中创建和管理技能
  </Card>

  <Card title="通过 API 使用技能" icon="code" href="https://platform.claude.com/docs/en/build-with-claude/skills-guide">
    以编程方式上传和使用技能
  </Card>
</CardGroup>
