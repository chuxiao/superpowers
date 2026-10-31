# 会话诊断：<session-id>

报告路径：~/.superpowers/diagnosing-superpowers/<session-id>/report.md
写入时间：<ISO timestamp>

## 1. 问题陈述 (REQUIRED)

<从案件文件复制而来。>

## 2. 甄别判定 (REQUIRED)

<写明证据显示所报告问题前后发生了什么：成段文字（而非列表），每条论断后附 `path:line`。给出置信度：high / medium / low，以及什么会使其升高。不得陈述 superpowers 应当做什么。>

## 3. 环境 (REQUIRED)

- 操作系统：
- Harness 与版本：
- 所见模型：
- Superpowers 安装根目录 / 版本 / git sha：
- 已读取或注入的技能文件（来自案件文件的 sha1 表）：
- 其他插件、扩展与 MCP 服务器：
- 存在的指令文件（仅路径）：

将每个环境字段与对技能的观察标注为历史证据（historical evidence）、未验证快照（unverified snapshot）、当前观察（current observation）或未知（unknown），并记录其支撑证据的位置。

## 4. 已检查的会话 (REQUIRED)

| 角色 | 会话 id | 绝对路径 | 行数 | 字节 |
|---|---|---|---|---|

已否决的候选：<id — path — why>，没有则写 "none"。

## 5. 时间线 (REQUIRED)

每条人工输入的提示词占一行。“事件”一栏列出被调用的技能、被派发的子代理、上下文压缩、错误、会话恢复、中止。

| 轮 | 行 | 时间 | 请求（单行） | 事件 |
|---|---|---|---|---|

## 6. 发现项（REQUIRED，每个维度一个小节）

每个发现项：
```
- finding: <one sentence>
  evidence: <path:line> — "<short quote>"
  turns: <first>–<last>
  confidence: high | medium | low
```
无可报告内容的维度写 `none found — checked: <what was checked>`。

### 6.1 Skill timeline
### 6.2 Plan adherence
### 6.3 Repeated work
### 6.4 Stumbles
### 6.5 Quality evidence
### 6.6 Request conflicts
### 6.7 Cost and time
### 6.8 Other plugins and skills used

## 7. Superpowers 参与 (REQUIRED)

not indicated | possible | likely

证据行：<path:line list>。本节仅陈述参与情况，不指出任何缺陷，也不提出任何修改。

## 8. 覆盖范围说明 (REQUIRED)

- 未读取：<ranges, files, and why>
- 不可用的 harness 功能：<list or none>
- 读取时会话仍在进行：yes/no
- 供需求方复核：<list or none>

## 9. 相似会话 (only when requested)

| 会话 id | 路径 | 日期 | Harness | 匹配 | 未匹配 |
|---|---|---|---|---|---|
