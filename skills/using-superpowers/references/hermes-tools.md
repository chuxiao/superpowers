# Hermes Agent 工具对照

技能以动作来表达（「派发子代理」「创建待办」「读取文件」）。在 Hermes Agent 上，这些动作对应到下列工具。

## 工具

| 技能请求的动作 | Hermes 工具 |
|---|---|
| 读取文件 | `read_file` |
| 创建新文件 | `write_file` |
| 编辑文件（针对性补丁） | `patch` |
| 运行 shell 命令 | `terminal` |
| 搜索文件内容 | `search_files` |
| 按名称查找文件 | `terminal` 配合 `find` |
| 获取 URL / 读取网页 | `web_extract(urls=[...])` |
| 搜索网络 | `web_search(query=...)` |
| 派发子代理 | `delegate_task(goal=..., context=..., toolsets=[...], role="leaf")` |
| 任务跟踪 | `todo` 工具 |
| 调用技能 | `skill_view("skill-name")` |

## 指令文件

当技能提到「你的指令文件」时，在 Hermes Agent 上指的是项目目录中的 **`AGENTS.md`**，或全局位置 `~/.hermes/SOUL.md` 处的 **`SOUL.md`**。

## 调用技能

Hermes Agent 提供一个 `skills` 工具集，内含 `skill_view` 与 `skills_list` 工具。要调用 superpowers 技能，使用：

```
skill_view("brainstorming")
skill_view("test-driven-development")
```

如果 `skill_view` 找不到某个 superpowers 技能（在插件完全注册之前，它可能不会出现在目录中），退回为直接读取 SKILL.md：

```
read_file(path="~/.hermes/plugins/superpowers/skills/<skill-name>/SKILL.md")
```

这一回退机制与其他不具备原生技能加载能力的 harness 所用机制相同。

## 子代理派发

使用 `delegate_task` 派生隔离的子代理，用于并行或顺序的各项工作：

```
delegate_task(goal="...", context="...", toolsets=[...], role="leaf")
```

如果 `delegate_task` 不可用，请在会话内直接完成该工作，而不是编造工具调用。

## 任务跟踪

在会话内使用 `todo` 工具进行任务跟踪。对于多 agent 任务看板，若可用则使用 `hermes kanban` CLI。将旧有的 `TodoWrite` 引用视为任务跟踪动作。
