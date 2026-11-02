# Gemini CLI 工具对照

技能以动作来表述需求（「派发子代理」「创建待办」「读取文件」）。在 Gemini CLI 上，这些动作对应到下列工具。

| 技能请求的动作 | Gemini CLI 中的对应工具 |
|----------------------|----------------------|
| 读取文件 | `read_file` |
| 一次读取多个文件 | `read_many_files` |
| 创建新文件 | `write_file` |
| 编辑文件 | `replace` |
| 运行 shell 命令 | `run_shell_command` |
| 搜索文件内容 | `grep_search` |
| 按名称查找文件 | `glob` |
| 列出文件与子目录 | `list_directory` |
| 获取 URL | `web_fetch` |
| 搜索网络 | `google_web_search` |
| 调用技能 | `activate_skill` |
| 派发子代理（`Subagent (general-purpose):` 模板） | 调用 `invoke_agent` 并指定 `agent_name: "generalist"`（可通过 `@generalist` 聊天语法调用——见[子代理支持](#子代理支持)） |
| 多个并行派发 | 在同一响应中发起多次 `invoke_agent` 调用 |
| 任务跟踪（「创建待办」「标记完成」） | `write_todos`（状态值：pending、in_progress、completed、cancelled、blocked） |

## 指令文件

当技能提到「你的指令文件」时，在 Gemini CLI 上指的是 **`GEMINI.md`**。Gemini CLI 按层级加载 `GEMINI.md`：全局的在 `~/.gemini/GEMINI.md`，项目级的文件位于工作区目录及其上级目录中，而子目录的 `GEMINI.md` 文件则在工具访问该子目录内的文件时加载。

## 个人技能目录

用户级技能位于 **`~/.gemini/skills/`**，**`~/.agents/skills/`** 是它的跨运行时别名（与 Codex 和 Copilot CLI 共享）。当同一层级下两个目录都存在时，以 `.agents/skills/` 为准。每个技能是一个子目录，内含一份 `SKILL.md`（带有 `name` 与 `description` frontmatter）。

## 子代理支持

Gemini CLI 通过 `invoke_agent` 工具派发子代理，该工具接受 `agent_name` 与 `prompt` 参数。同一派发操作也有聊天语法快捷方式：输入 `@generalist <prompt>` 等价于以 `agent_name: "generalist"` 调用 `invoke_agent`。内置 agent 名称包括 `generalist`、`cli_help`、`codebase_investigator`，以及（在启用浏览器工具的情况下）`browser_agent`。

技能以 `Subagent (general-purpose):` 模板派发子代理，要么引用一份提示词模板文件（如 `superpowers:subagent-driven-development` 的 `./implementer-prompt.md`），要么直接给出内联提示词。在 Gemini CLI 上：

| 技能派发形式 | Gemini CLI 中的对应工具 |
|---------------------|----------------------|
| 引用 `*-prompt.md` 模板（implementer、task-reviewer、code-reviewer 等） | 先填充模板，然后以 `agent_name: "generalist"` 与填充后的提示词调用 `invoke_agent` |
| 引用 `superpowers:final-review` 的 `./code-reviewer.md` | 以 `agent_name: "generalist"` 与填充后的审查模板调用 `invoke_agent` |
| 内联提示词（未引用模板） | 以 `agent_name: "generalist"` 与你的内联提示词调用 `invoke_agent` |

### 提示词填充

技能提供的提示词模板带有占位符，如 `{WHAT_WAS_IMPLEMENTED}` 或 `[FULL TEXT of task]`。在把完整提示词传给 `invoke_agent` 之前，先填充所有占位符。提示词模板本身就包含 agent 的角色、审查标准与预期输出格式——子代理会遵循整份模板。

### 并行派发

Gemini CLI 支持并行派发子代理。在同一响应中发起多次 `invoke_agent` 调用（或在一个提示词中多次调用 `@generalist`），即可让相互独立的子代理并行工作。有依赖的任务保持串行，但不要仅仅为了保留一份更简单的历史记录，就把相互独立的子代理任务串行化。

## 其他 Gemini CLI 工具

以下是 Gemini CLI 独有的工具：

| 工具 | 用途 |
|------|---------|
| `save_memory`（旧版） | 当 `experimental.memoryV2 = false` 时跨会话持久化事实 |
| `get_internal_docs` | 查阅 Gemini CLI 自带的文档 |
| `ask_user` | 向用户提出结构化问题（文本 / 单选 / 多选） |
| `enter_plan_mode` / `exit_plan_mode` | 进入与退出只读的计划模式 |
| `update_topic` | 更新当前对话的「主题」「战略意图」两类元数据 |
| `complete_task` | 供 Gemini 子代理声明自身已完成，并将其结果返回给父 agent |
| `tracker_create_task`、`tracker_update_task`、`tracker_get_task`、`tracker_list_tasks`、`tracker_add_dependency`、`tracker_visualize` | 功能丰富、支持依赖关系与可视化的任务追踪器 |
| `read_mcp_resource`、`list_mcp_resources` | MCP 资源访问 |
