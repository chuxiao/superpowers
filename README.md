# Superpowers

> **注意：** 这是一个修改版。基于 Jesse Vincent 的 [superpowers](https://github.com/obra/superpowers)，MIT 许可证授权。由 chuxiao 修改于 2026 年。

Superpowers 是一套完整的软件开发方法论，面向你的编码 agent，构建在一组可组合的技能与若干初始指令之上——这些初始指令确保你的 agent 真的会去使用这些技能。

## 目录

- [它是如何工作的](#它是如何工作的)
- [商业服务](#商业服务)
- [快速开始](#安装)
  - [Claude Code](#claude-code)
  - [Antigravity](#antigravity)
  - [Codex App](#codex-app)
  - [Codex CLI](#codex-cli)
  - [Cursor](#cursor)
  - [Devin CLI](#devin-cli)
  - [Factory Droid](#factory-droid)
  - [Gemini CLI](#gemini-cli)
  - [GitHub Copilot CLI](#github-copilot-cli)
  - [Grok Build CLI](#grok-build-cli)
  - [Kimi Code](#kimi-code)
  - [OpenCode](#opencode)
  - [Pi](#pi)
  - [Qwen Code](#qwen-code)
  - [Hermes Agent](#hermes-agent)
  - [Muse](#muse)
- [基本工作流](#基本工作流)
- [出了问题怎么办](#出了问题怎么办)
- [社区](#社区)
- [里面有什么](#里面有什么)
- [理念](#理念)
- [参与贡献](#参与贡献)
- [更新](#更新)
- [许可证](#许可证)
- [视觉伴侣遥测](#视觉伴侣遥测)

## 它是如何工作的

一切从你启动编码 agent 的那一刻开始。只要它发现你要构建东西，它*不会*直接扑上去写代码，而是退一步，先问清楚你真正想做的是什么。

等它从对话中梳理出规格，会把规格分成足够短、真能读完并消化的片段，逐段拿给你确认。

在你签核设计之后，agent 会编写一份实施计划，清晰到让一个热情有余却品味欠佳、缺乏判断力、没有项目上下文、还讨厌写测试的初级工程师也能照着执行。计划强调真正的红/绿 TDD、YAGNI（You Aren't Gonna Need It，你不会需要它）和 DRY。

接下来，你一声「开始」，它就会启动*子代理驱动开发*（subagent-driven-development）流程：让各个 agent 逐个完成工程任务，检查并审查它们的产出，然后继续推进。你的 agent 一口气自主工作几个小时而不偏离你定下的计划，并不罕见。

系统还有更多内容，但以上就是核心机制。而且因为技能是自动触发的，你不需要做任何特殊操作。你的编码 agent 就此拥有了 Superpowers。

## 商业服务

如果你在企业环境中使用 Superpowers，需要商业支持、额外工具或费用托管，欢迎随时来信：sales@primeradiant.com。

## 安装

安装方式因 harness 而异。如果你使用多个 harness，需要为每一个分别安装。

### Claude Code

Superpowers 可通过[官方 Claude 插件市场](https://claude.com/plugins/superpowers)获取

#### 官方市场

- 从 Anthropic 官方市场安装插件：

  ```bash
  /plugin install superpowers@claude-plugins-official
  ```

#### Superpowers 市场

Superpowers 市场为 Claude Code 提供 Superpowers 及若干相关插件。

- 注册该市场：

  ```bash
  /plugin marketplace add obra/superpowers-marketplace
  ```

- 从该市场安装插件：

  ```bash
  /plugin install superpowers@superpowers-marketplace
  ```

#### 本 Fork（chuxiao/superpowers）

本仓库是 [obra/superpowers](https://github.com/obra/superpowers) 的个人 fork，带有定制技能与中文文档。要安装本 fork 而非上游版本：

- 将本仓库注册为市场：

  ```bash
  /plugin marketplace add chuxiao/superpowers
  ```

- 从中安装插件：

  ```bash
  /plugin install superpowers@superpowers-dev
  ```

该市场跟踪仓库的默认分支，因此推送到 `main` 的更新会在 Claude Code 下次启动时自动生效。

### Antigravity

以插件形式从本仓库安装 Superpowers：

```bash
agy plugin install https://github.com/obra/superpowers
```

Antigravity 会列出每个已安装技能的 description，而 using-superpowers 技能的 description 会提示模型在对话开始时加载该技能。更新时用同一命令重装即可。

### Codex App

Superpowers 可通过[官方 Codex 插件市场](https://github.com/openai/plugins)获取。

- 在 Codex 应用中，点击侧边栏的 Plugins。
- 你应该在 Coding 分区看到 `Superpowers`。
- 点击 Superpowers 旁边的 `+` 并按提示操作。

### Codex CLI

Superpowers 可通过[官方 Codex 插件市场](https://github.com/openai/plugins)获取。

- 打开插件搜索界面：

  ```bash
  /plugins
  ```

- 搜索 Superpowers：

  ```bash
  superpowers
  ```

- 选择 `Install Plugin`。

### Cursor

- 在 Cursor Agent 聊天中，从市场安装：

  ```text
  /add-plugin superpowers
  ```

- 或者在插件市场里搜索 "superpowers"。

### Devin CLI

- 从本仓库安装插件：

  ```bash
  devin plugins install obra/superpowers
  ```

- 用以下命令更新到最新版本：

  ```bash
  devin plugins update superpowers
  ```

### Factory Droid

- 注册市场：

  ```bash
  droid plugin marketplace add https://github.com/obra/superpowers
  ```

- 安装插件：

  ```bash
  droid plugin install superpowers@superpowers
  ```

### Gemini CLI

- 安装扩展：

  ```bash
  gemini extensions install https://github.com/obra/superpowers
  ```

- 之后更新：

  ```bash
  gemini extensions update superpowers
  ```

### GitHub Copilot CLI

- 注册市场：

  ```bash
  copilot plugin marketplace add obra/superpowers-marketplace
  ```

- 安装插件：

  ```bash
  copilot plugin install superpowers@superpowers-marketplace
  ```

### Grok Build CLI

Superpowers 可通过[官方 Grok 插件市场](https://github.com/xai-org/plugin-marketplace)获取。

- 从 xAI 官方市场安装插件：

  ```bash
  grok plugin install superpowers@xai-official --trust
  ```

- 或在 TUI 中打开市场，搜索 Superpowers 并安装：

  ```text
  /marketplace
  ```

### Kimi Code

Superpowers 已上架 Kimi Code 的插件市场。

- 打开 Kimi Code 的插件管理器：

  ```text
  /plugins
  ```

- 进入 `Marketplace` > `Superpowers` 并安装。

- 或直接从本仓库安装：

  ```text
  /plugins install https://github.com/obra/superpowers
  ```

- 详细文档：[docs/README.kimi.md](docs/README.kimi.md)

### OpenCode

OpenCode 使用自己的插件安装机制；即使你已在其他 harness 用过 Superpowers，也需要在 OpenCode 单独安装。

- 对 OpenCode 说：

  ```
  Fetch and follow instructions from https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/.opencode/INSTALL.md
  ```

- 详细文档：[docs/README.opencode.md](docs/README.opencode.md)

### Pi

以 Pi 包形式从本仓库安装 Superpowers：

```bash
pi install git:github.com/obra/superpowers
```

本地开发时，以临时包形式加载本检出运行 Pi：

```bash
pi -e /path/to/superpowers
```

Pi 包会加载 Superpowers 技能和一个小扩展——它在会话启动时注入 using-superpowers bootstrap，压缩之后会再次注入。Pi 原生支持技能，因此不需要兼容性的 `Skill` 工具。子代理与任务列表工具仍是可选的 Pi 伴生包。

### Qwen Code

Qwen Code 可直接从 Claude Code 市场安装插件。

- 从本仓库安装插件，提示时选择 `superpowers`：

  ```bash
  qwen extensions install obra/superpowers
  ```

- 之后更新：

  ```bash
  qwen extensions update superpowers
  ```

### Hermes Agent

以 Hermes 插件形式从本仓库安装 Superpowers：

```bash
hermes plugins install obra/superpowers --enable
```

安装后重启所有活跃的 Hermes 会话。注意：Hermes 没有压缩后钩子，首轮就触发压缩的超长会话会丢失 bootstrap——如果技能不再触发，请新开会话。

### Muse

Superpowers 作为 Muse 原生插件提供——同一仓库、同一套技能、全 harness 通用。using-superpowers bootstrap 经原生 `SessionStart` 钩子注入，与 Claude Code、Codex、Cursor、Gemini、Pi 等一致——无需每次会话手动启用。

- 从本地检出安装：

  ```bash
  muse plugins install ./
  muse plugins approve superpowers
  ```

  或者克隆后安装：

  ```bash
  git clone https://github.com/obra/superpowers.git
  muse plugins install ./superpowers
  muse plugins approve superpowers
  ```

- 之后更新：

  ```bash
  muse plugins update superpowers
  ```

安装后重启所有活跃的 Muse 会话，让 `SessionStart` 钩子生效——技能立即生效，钩子在首次安装时需要批准。验证方法：新开会话并发送 `Let's make a react todo list`——完好的安装会在写任何代码之前自动触发 `brainstorming`。版本号记录在 `.version-bump.json`，由 `scripts/bump-version.sh` 保持同步。

## 基本工作流

1. **brainstorming** - 在构建任何东西之前激活。通过提问引出你真正想要什么、为什么——让你自己把它描述出来，然后复述它的理解供你纠正。小改动在对话里敲定；项目则会得到一份书面的设计文档，写清楚到执行者能直接据此制定计划。

2. **using-git-worktrees** - 在设计获批后激活。在新分支上创建隔离工作区，执行项目初始化，验证测试基线干净。

3. **writing-plans** - 携获批设计激活。把工作拆成小块任务（每个 2-5 分钟）。每个任务都有确切的文件路径、完整代码与验证步骤。

4. **subagent-driven-development** 或 **executing-plans** - 携计划激活。要么每个任务派发一个全新子代理、每个之后都做审查（最彻底），要么在当前会话内逐任务实现、最后对整分支做一次全新审查（最省）。

5. **test-driven-development** - 在实现期间激活。强制 RED-GREEN-REFACTOR：写失败测试、眼看它失败、写最少量的代码、眼看它通过、提交。删除先于测试写出的代码。

6. **requesting-code-review** - 在请求代码审查、全部计划任务完成之后（整分支终审、安全门与收官把关）、以及收到审查反馈时激活。

7. **integration-verification** - 在审查收官之后、收尾之前激活。先跑全量测试套件，再做分层集成检查（模块组装、API 兼容、构建产物可运行、端到端冒烟路径）；稳定失败集中呈现，交需求方逐项裁定。

8. **finishing-a-development-branch** - 在任务完成时激活。验证测试，呈现选项（合并/创建 PR/保留/丢弃），清理工作区。

9. **regression-sweep** - 仅在显式触发时激活（由需求方或外部调度器触发）。在基线上重跑整个项目的场景登记册，产出留痕报告。

**agent 在做任何任务之前都会检查有无相关技能。**这是强制工作流，不是建议。

### 两个验证技能的依赖

两个验证技能与工作流及被验证项目的耦合关系如下：

**技能之间：**

- **integration-verification** 承接审查收官（`requesting-code-review`）的移交，并向 `finishing-a-development-branch` 移交。也支持单独调用（出口为验证报告，无移交语义）。它的出口凭据（台账行 + HEAD）正是 `finishing-a-development-branch` 判断能否免跑全量套件的依据——连同 HEAD 一致与工作区干净两项一起核对。
- **regression-sweep** 不在任何链路里：仅显式触发，没有任何技能向它移交，它也不向任何技能移交。它读取 `docs/superpowers/verification/` 下的场景登记册，以及 `skills/integration-verification/references/` 中按形态路由的参考文件（backend / web / mobile）。

**在被验证项目上（运行时——由项目自身提供；插件不安装任何东西）：**

- 计划级：含跨任务组装点或外部接口的计划必须带验证方案章节（由 `writing-plans` 生成）；`integration-verification` 依据它执行。计划中缺失的层会被标注「未声明」并呈现，绝不静默跳过。
- 项目级资产位于 `docs/superpowers/verification/`：`environment.md`（各层怎么跑）、`modules/<module>.md` + `cross-module.md`（场景登记册），以及 `docs/superpowers/verification/reports/` 下的报告。登记册行格式被 `integration-verification`、`regression-sweep`、`finishing-a-development-branch` 三者逐字共享——后者在合并时写入条目并初始化登记册。
- 按形态的工具链：backend——pytest/Jest + testcontainers；web——docker-compose + Playwright；mobile——Appium + Android 模拟器。工具由被验证的项目安装，绝不由本插件安装；工具缺失时降级为明确的环境外移交项，而不是自动安装。
- 这些耦合关系由 `tests/integration-verification/test-integration-verification.sh` 的静态断言锁定。

## 出了问题怎么办

有时会话会表现异常：该触发的技能没触发、不该触发的触发了，或者 agent 无视计划、重复干活、token 消耗超出预期。把下面这句原话发给编码 agent，它就会调用 **diagnosing-superpowers** 技能："figure out what went wrong with superpowers in this session"。要检查更早的会话，把会话点名进去："figure out what went wrong with superpowers in session `<id>`"。

该技能会读取会话记录，带行级证据地报告发生了什么，并在你需要时打包一份脱敏材料，供提交 bug 报告使用。

## 社区

Superpowers 由 [Jesse Vincent](https://blog.fsck.com) 与 [Prime Radiant](https://primeradiant.com) 的伙伴们共同构建。

- **Discord**：[加入我们](https://discord.gg/35wsABTejz)，获取社区支持、提问、分享你用 Superpowers 构建的东西
- **Issues**：https://github.com/obra/superpowers/issues
- **发布公告**：[订阅](https://primeradiant.com/superpowers/)以获取新版本通知

## 里面有什么

### 技能库

**测试**
- **test-driven-development** - RED-GREEN-REFACTOR 循环（含测试反模式参考）

**调试**
- **systematic-debugging** - 四阶段根因定位流程（含根因追溯、纵深防御、条件等待技巧）
- **verification-before-completion** - 确保问题真的被修好
- **diagnosing-superpowers** - 查明会话里哪里出了问题，带证据；可导出脱敏材料或提交 issue

**协作**
- **brainstorming** - 构建之前先引出意图
- **writing-plans** - 详尽的实施计划
- **executing-plans** - 会话内执行计划：单一上下文，一次终审
- **dispatching-parallel-agents** - 并发子代理工作流
- **requesting-code-review** - 代码审查：整分支终审、安全门、反馈接收
- **integration-verification** - 分支集成闸门：全量测试套件加分层验证（组装、API 兼容、构建可运行、E2E），位于审查收官与收尾之间
- **using-git-worktrees** - 并行开发分支
- **finishing-a-development-branch** - 合并/PR 决策工作流
- **subagent-driven-development** - 两阶段审查的快速迭代（先规格符合性，后代码质量）
- **regression-sweep** - 显式触发的全项目回归：在基线上重跑场景登记册，落盘留痕报告

**元技能**
- **writing-skills** - 按最佳实践创建新技能（含测试方法论）
- **using-superpowers** - 技能系统入门

## 理念

- **测试驱动开发** - 永远先写测试
- **系统优于即兴** - 用流程代替猜测
- **降低复杂度** - 简洁是首要目标
- **证据优先于声明** - 宣称成功之前先验证

阅读[原始发布公告](https://blog.fsck.com/2025/10/09/superpowers/)。

## 参与贡献

Superpowers 的一般贡献流程如下。请注意：我们通常不接受新技能贡献；对技能的任何更新都必须在我们支持的全部编码 agent 上可用。我们也不接受由 agent 撰写、去修复他人所报 issue 的 PR——除非维护者明确要求，即使你自己遇到了同样的问题；请把你的报告补充到已有 issue 里。

1. 复刻（fork）本仓库
2. 切换到 `dev` 分支
3. 为你的工作创建分支
4. 按 `writing-skills` 技能创建并测试新增与修改的技能
5. 提交 PR，填写 PR 模板的每一个小节——包括由人用自己的话撰写的摘要。

技能行为测试使用 [superpowers-evals](https://github.com/prime-radiant-inc/superpowers-evals/) 的 drill 评测 harness，克隆到 `evals/`——配置见 `evals/README.md`。插件基础设施测试位于 `tests/`，通过相应的 `run-*.sh` 或 `npm test` 运行。

完整指南见 `skills/writing-skills/SKILL.md`。

## 更新

Superpowers 的更新在某种程度上取决于编码 agent，但通常是自动的。

## 许可证

MIT 许可证——详见 LICENSE 文件

## 视觉伴侣遥测

由于技能和插件不会向创作者回传任何反馈，我们无从得知有多少人在使用 Superpowers。默认情况下，brainstorming 可选的视觉伴侣功能会从我们的网站加载 Prime Radiant 标志，其中包含正在使用的 Superpowers 版本号；不包含你的项目、提示词或编码 agent 的任何细节。我们看不到你的点击，也看不到你在构建什么。这帮助我们大致了解有多少人在用 Superpowers、各自用的是哪个版本。此功能完全可选。要停用它，把环境变量 `SUPERPOWERS_DISABLE_TELEMETRY` 设为任意真值即可。Superpowers 同样遵守 Claude Code 的 `DISABLE_TELEMETRY` 与 `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` 关闭项。
