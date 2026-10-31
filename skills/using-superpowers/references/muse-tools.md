# Muse 工具对照

技能以动作来表达（「派发一个子代理」「创建一个待办」「读取一个文件」）。在 Muse 上，这些动作对应到下列工具。

| 技能请求的动作 | Muse 中的对应工具 |
|----------------------|----------------|
| 读取一个文件 | `read_file` |
| 读取多个文件 | `read_file`（多次调用）或 `search` |
| 创建新文件 | `write_file` |
| 编辑一个文件 | `edit_file` |
| 运行 shell 命令 | `bash` |
| 搜索文件内容 | `search` |
| 按名称查找文件 | `search` 配合 `glob` |
| 获取 URL | `web_fetch` |
| 搜索网络 | `web_search` |
| 调用一个技能 | 对 `skills/<name>/SKILL.md` 执行 `read_file`，或使用原生技能工具 |
| 派发一个子代理（`Subagent (general-purpose):` 模板） | `subagent_spawn`，并填充提示词 |
| 任务跟踪（「创建一个待办」「标记为完成」） | `write_todos`，或用 `bash` 维护的任务文件 |
| 向需求方提问 | `request_user_input` |

## 指令文件

当技能提到「你的指令文件」时，在 Muse 上指的是项目根目录下的 **`CLAUDE.md`** 或 **`AGENTS.md`**。在配置了分层加载的地方，Muse 会分层加载这些文件。

## 技能调用

Muse 通过 `muse skills` 提供对技能的原生支持。要调用一个 Superpowers 技能，读取它的 `SKILL.md` 并遵循其中的指示。引导技能（`using-superpowers`）会在 `SessionStart` 时通过插件钩子自动注入——你已经在遵循它，不要重新加载。

## 子代理派发

使用 `subagent_spawn` 把工作委派给隔离的子代理。派发之前，先填充提示词模板（例如 `implementer-prompt.md`、`task-reviewer-prompt.md`）。如果没有可用的子代理工具，就在会话内执行这项工作，而不是凭空捏造工具调用。

## 任务跟踪

使用 `write_todos` 跟踪清单。为技能检查清单中的每一项各创建一个待办，随着工作推进，将其标记为 in_progress/completed。如果 `write_todos` 不可用，就通过 `write_file`/`edit_file` 维护一个 markdown 任务文件。
