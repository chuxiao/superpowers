# Antigravity CLI（`agy`）工具对照

技能以动作来表达（「派发子代理」、「创建待办」、「读取文件」）。在 Antigravity CLI（`agy`）上，这些动作对应下列工具。

| 技能请求的动作 | Antigravity CLI 中的对应工具 |
|----------------------|----------------------|
| 派发子代理（`Subagent (general-purpose):` 模板） | `invoke_subagent` 配合内置 `TypeName`——`self` 用于完整能力工作，`research` 用于只读工作 |
| 任务跟踪（「创建待办」、「标记完成」） | **任务工件**（task artifact）——`write_to_file` 并设置 `IsArtifact: true` 与 `ArtifactType: "task"`（见 [任务跟踪](#任务跟踪)）。**不是** `manage_task`——后者管理的是后台进程。 |

## 任务跟踪

Antigravity **没有待办工具**（`manage_task` 管理的是后台进程——`list`/`kill`/`status`/`send_input`——它*不是*清单）。当技能要求创建待办清单或跟踪任务时，维护一个**任务工件**：一份 markdown 清单，用 `write_to_file` 保存（`IsArtifact: true`、`ArtifactMetadata.ArtifactType: "task"`），并随工作进展用 `replace_file_content` / `multi_replace_file_content` 编辑。

在任何多步任务开始时，创建任务工件，列出计划中的每一步。每完成一步，就编辑工件把它标记为已完成（`- [x]`）。如果计划有变，更新清单。始终保持其最新——它是你判断剩余工作的权威依据；一旦对话变长，开始每一步之前先重新读一遍。
