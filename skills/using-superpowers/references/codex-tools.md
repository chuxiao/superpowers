## 子代理派发需要 multi-agent 支持

在 Codex 配置（`~/.codex/config.toml`）中添加：

```toml
[features]
multi_agent = true
```

这会启用 `dispatching-parallel-agents` 与 `subagent-driven-development` 等技能所使用的 multi-agent 工具。你能拿到哪些工具，取决于你的模型预设（model preset）所选择的 multi-agent 版本（当前预设运行 V2；较旧的预设运行 V1）。当表格与实际情况不一致时，一律以你实际的工具列表为准——包括本文中的表格在内。

- **派生：** 用 `spawn_agent {fork_turns: "none"}` 给子代理一个干净的上下文；默认值 `"all"` 会把你的会话记录（transcript）复制进子代理。在 Codex 0.145+ 上，`~/.codex/agents/` 下的角色文件会通过 `agent_type` 附加到隔离 fork（即 `fork_turns: "none"` 所建的 fork）上。完整历史 fork 接受 `model` 与 `reasoning_effort` 覆盖（这里唯一会拒绝的是 `agent_type`）——subagent-driven-development（SDD）默认采用隔离 fork 是为了保持上下文干净，而不是因为覆盖参数必须依赖隔离 fork。
- **修复轮：** 用 `followup_task` 恢复实施者——它会送达你的消息、触发一轮对话，并透明地重新载入被 harness 驱逐的子代理。绝不要以「派生出的 agent 无法再次接收消息」为由派发一个全新的实施者；在 V2 上它总是可以。
- **生命周期：** V2 没有 `close_agent`。已完成的子代理会在需要腾出槽位时被自动驱逐；不去关闭它们没有任何代价。只有 V1 会话才有 `close_agent`——在 V1 下，审查者的审查一返回，就关闭该审查者，每个实施者在其任务的审查通过后关闭。
- **模型名称：** 绝不要把来自技能、表格或旧会话的模型名称直接复制进 `spawn_agent`，却不先对照你当前的 spawn 允许列表（allowlist）核对——V2 只接受支持 V2 的预设，对来自其余预设的模型名直接硬报错。

## 等待子代理

`wait_agent` 是事件订阅，不是轮询：长等待会在子代理产生邮箱（mailbox）活动的瞬间醒来，延迟与短等待相同。短超时轮询毫无收益，而且每次轮询都要付出一次工具调用——外加一整份上下文的重新计费。在实测会话中，全部等待调用里约有三分之二是超时的短轮询。

- 只要你还有本地工作可做，就完全不要等待。已完成子代理的最终答案会被推入你的邮箱，并随你的下一轮到来。
- 当你确实空闲、且还有子代理未完成时，以有界的时段进行等待：调用 `wait_agent` 并把 `timeout_ms` 设为 300000-600000（即 5-10 分钟）。每个时段结束后——无论是醒来还是超时——发一条状态行，运行 `list_agents`，并追查任何已完成却未报告的子代理。绝不叠加短于五分钟的轮询；有界时段被事件订阅唤醒的速度，与短时段被唤醒的速度一样快。
- 完成邮件无法唤醒空闲中的控制者（它送达时不会触发新一轮）；覆盖这段空闲窗口正是 `wait_agent` 唯一的职责。一个毫无活动就超时的时段，是在提示你去核对状态，而不是让你缩短下一个时段。

## 派生时的模型路由

你发出的每一个 `spawn_agent`——包括你自己就是被派生的子代理、也在执行扇出（fan-out）的情况——都要按你正在执行的技能的 Model Selection（模型选择）规则，显式设置 `model` 和 `reasoning_effort` 两者。只设置 `model` 是个陷阱：子代理的 effort 会被静默重置为该模型的默认值，而不是沿用你的设置。

请你的需求方在 `~/.codex/config.toml` 中添加一道机器级兜底（backstop），这样任何漏网的派生仍会路由到有意选定的档位，而不是静默继承本会话最昂贵的模型：

```toml
[agents]
default_subagent_model = "<a mid-tier model from your spawn allowlist>"
default_subagent_reasoning_effort = "medium"
```

## 环境检测

会创建工作树或对分支收尾的技能，应在继续之前用只读 git 命令检测自身环境：

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

- `GIT_DIR != GIT_COMMON` → 已处于链接工作树中——先核验该树承载本需求（分支名与主题一致，或需求方确认续作）；否则按「建树纪律」新建专属树，绝不复用他人之树
- `BRANCH` 为空 → 处于 detached HEAD（在沙箱中无法建分支/推送/发 PR）

各技能如何使用这些信号，见 `using-git-worktrees` 的 Step 0 与 `finishing-a-development-branch` 的 Step 1。

## Codex App 收尾

当沙箱阻止分支/推送操作时（外部管理的工作树中处于 detached HEAD），agent 会提交全部工作，并告知需求方使用 App 的原生控件：

- **"Create branch"（创建分支）**——命名分支，然后通过 App 界面完成提交/推送/PR
- **"Hand off to local"（移交到本地）**——把工作转移到需求方的本地检出

agent 仍可运行测试、暂存文件，并输出建议的分支名、提交信息和 PR 描述，供需求方复制。
