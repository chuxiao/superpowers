# 案件：<session-id>

工作区：~/.superpowers/diagnosing-superpowers/<session-id>/
创建时间：<ISO timestamp>

## 问题陈述（与需求方达成一致）

<一段话。写明是哪个（哪些）会话、轮次范围（如已知）、期望是什么、实际发生了什么，以及要紧的可观测指标：实际耗时（wall-clock）、token、重复动作、某个具体的意外动作。>

本次目标是否为 superpowers 提交 bug 报告：yes | no

## 会话

| 角色 | 会话 id | 绝对路径 | 行数 | 字节数 | 最长行（字节） | 首条提示词（前 120 字符） | 首个时间戳 |
|---|---|---|---|---|---|---|---|
| main | | | | | | | |
| subagent | | | | | | | |

已否决的候选：<id — 路径 — 否决原因>，或 "none"。

读取时，会话仍在运行：yes | no（mtime <ISO>，行数 <N>）

## 环境

- OS：<名称与版本>
- Harness：<名称> <版本>
- 所见模型：<模型 id — 位置（main / 子代理 id）>
- Superpowers 安装根目录：<path>；版本 <x.y.z>；git sha <sha 或 "not a checkout">
- 会话期间读取或注入的技能文件：

| 技能 / 来源路径 | sha1 或 unavailable | 出处（provenance） | 支撑位置 |
|---|---|---|---|

将环境与技能观察标注为历史证据（historical evidence）、未验证快照（unverified snapshot）、当前观察（current observation）或未知（unknown）。在宣布历史信息不可用（unavailable）之前，先核查已提供的出处说明、归档，以及已捕获的技能正文。原始路径缺失并不会抹除已保留的副本。当前的版本/mtime 并不能确立历史版本；一份已捕获的技能正文并不能证实整个安装。

- 已配置的其他插件 / 扩展 / MCP 服务器：<列表，或 "none found">
- 存在的指令文件（仅路径）：<列表>

## 面向这些文件所有读者的上下文安全规则

- 读取此处列出的任何文件之前，先遵循 `references/context-safety.md`。
- 在子代理的会话记录（transcript）中，"user" 指父 agent。

## 已探明的来源与记录含义

- 已查阅的来源：<绝对路径、工具、帮助或文档来源>
- 提取所用的命令或查询：<对每个来源所用的限量（bounded）命令或工具查询>
- 目标身份证据：<session id、工作目录、时间戳、相匹配的内容，以及支撑性的记录位置>
- 关联会话：<session id、关系，以及支撑性的记录位置，或 "none found">
- 人类消息：<记录形态及其含义的证据>
- 注入消息与父 agent 的派发：<记录形态及其含义的证据>
- 助手消息：<记录形态及其含义的证据>
- 工具调用及其结果：<记录形态、二者如何对应，以及这些含义的证据>
- 用量计数器（usage counter）：<字段、增量或累计语义、单位与证据，或 "unavailable">
- 时间信息：<字段、单位、事件边界与证据，或 "unavailable">
- 其他相关记录：<模型、版本、上下文压缩（compaction）或其他含义与证据>
- 尚未解决的信息：<缺失、无法访问、含糊或不存在的信息，或 "none">
