# 视觉伴侣指南

基于浏览器的视觉头脑风暴伴侣，用于展示视觉稿、图示与选项。

## 何时使用

逐个问题做判断，而不是按整个会话判断。判断标准：**用户看到它，是否比读到它理解得更好？**

**内容本身是视觉性的，就用浏览器**：

- **UI 视觉稿** — 线框图、布局、导航结构、组件设计
- **架构图** — 系统组件、数据流、关系图
- **并排视觉对比** — 比较两种布局、两种配色方案、两种设计方向
- **设计打磨** — 当问题关乎观感、间距、视觉层级时
- **空间关系** — 以图示形式呈现的状态机、流程图与实体关系

**内容是文字或表格性的，就用终端**：

- **需求与范围问题** — “X 是什么意思？”“哪些功能在范围内？”
- **概念性 A/B/C 选择** — 在用文字描述的方案之间挑选
- **权衡清单** — 优缺点、对比表
- **技术决策** — API 设计、数据建模、架构方案选择
- **澄清性问题** — 凡答案为文字而非视觉偏好的问题

一个*关于* UI 主题的问题并不会自动成为视觉问题。“你想要什么样的向导？”是概念性的 — 用终端。“这几种向导布局哪个感觉对？”是视觉性的 — 用浏览器。

## 工作原理

服务器会监视一个目录中的 HTML 文件，并向浏览器提供最新的一个。你把 HTML 内容写入 `screen_dir`，用户在浏览器中看到它，并可以点击选择选项。选择结果会记录到 `state_dir/events`，你在下一轮读取。

**内容片段与完整文档的区别：** 如果你的 HTML 文件以 `<!DOCTYPE` 或 `<html` 开头，服务器会原样提供它（只注入 helper 脚本）。否则，服务器会自动把你的内容包进 frame 模板 — 加上页头、CSS 主题、连接状态以及全部交互基础设施。**默认写内容片段。** 只有当你需要对页面完全控制时才写完整文档。

## 启动会话

```bash
# 在用户批准使用视觉伴侣之后再启动。--open 会在推送第一块屏幕时自动打开
# 用户的浏览器；--project-dir 让视觉稿持久保存，并支持同端口重启。
bash scripts/start-server.sh --project-dir /path/to/project --open

# 返回：{"type":"server-started","port":52341,
#        "url":"http://localhost:52341/?key=ab12…",
#        "screen_dir":"/path/to/project/.superpowers/brainstorm/12345-1706000000/content",
#        "state_dir":"/path/to/project/.superpowers/brainstorm/12345-1706000000/state"}
```

从返回结果中保存 `screen_dir` 和 `state_dir`。使用 `--open` 时，浏览器会在你推送第一块屏幕时自行打开 — 无需请用户手动打开，但仍应分享 URL 作为兜底（headless/远程环境不会自动打开）。

**URL 中包含会话密钥（`?key=…`）。** 服务器会拒绝任何不带密钥的请求，所以务必把 `url` 字段中的**完整** URL 交给用户 — 绝不裁掉查询字符串，也绝不交出裸的 `http://host:port`。这个密钥把守着 HTTP 与 WebSocket 访问，这样无关的浏览器标签页或同一网络中的其他机器就无法读取屏幕内容或注入事件。首次加载后，浏览器会通过 cookie 记住密钥，因此刷新页面和加载 `/files/*` 资源时无需重复携带。

**查找连接信息：** 服务器会把启动 JSON 写入 `$STATE_DIR/server-info`。如果你在后台启动了服务器且没有捕获 stdout，读取该文件即可获得 URL 和端口。使用 `--project-dir` 时，可在 `<project>/.superpowers/brainstorm/` 下查找会话目录。

**注意：** 请把项目根目录作为 `--project-dir` 传入，这样视觉稿才会持久保存在 `.superpowers/brainstorm/` 中，并在服务器重启后保留。不传的话，文件会进入 `/tmp` 并被清理。如果 `.gitignore` 里还没有 `.superpowers/`，请提醒用户加上。

**各平台启动服务器的方式：**

**Claude Code:**
```bash
# 默认模式即可工作 — 脚本自己会把服务器放到后台。
bash scripts/start-server.sh --project-dir /path/to/project --open
```

在 Windows 上，脚本会自动检测并切换到前台模式（这会阻塞工具调用）。在 Bash 工具调用上使用 `run_in_background: true`，让服务器跨越多轮对话持续运行，然后在下一轮读取 `$STATE_DIR/server-info` 获取 URL 和端口。

**Codex:**
```bash
# Codex 会回收后台进程。脚本会自动检测 CODEX_CI 并切换到前台模式。
# 正常运行即可 — 无需额外标志。
bash scripts/start-server.sh --project-dir /path/to/project --open
```

**Gemini CLI:**
```bash
# 使用 --foreground，并在 shell 工具调用上设置 is_background: true，
# 让进程跨越多轮持续运行
bash scripts/start-server.sh --project-dir /path/to/project --open --foreground
```

**Copilot CLI:**
```bash
# 用 Copilot CLI 的非阻塞/后台 shell 机制来启动，让服务器跨越多轮持续
# 运行。保留 --foreground，让后台化由 harness 而不是脚本负责。启动器是
# 一个 .sh 文件，因此要通过 bash 调用（Windows 上从 PowerShell 工具调用
# Git Bash 的 bash.exe）。
bash scripts/start-server.sh --project-dir /path/to/project --open --foreground
```

**其他环境：** 服务器必须跨越多轮对话持续在后台运行。如果你的环境会回收已脱离的进程，使用 `--foreground` 并用你所在平台的后台执行机制来启动命令。

如果你的浏览器无法访问该 URL（远程/容器化环境中很常见），绑定一个非环回主机：

```bash
bash scripts/start-server.sh \
  --project-dir /path/to/project \
  --host 0.0.0.0 \
  --url-host localhost
```

用 `--url-host` 控制返回 JSON 中打印的 URL 主机名。

## 循环流程

1. **确认服务器存活**，然后**把 HTML 写入** `screen_dir` 中的新文件：
   - **必须做到：在引用 URL 或推送屏幕之前，先确认服务器存活。** 检查 `$STATE_DIR/server-info` 存在，且 `$STATE_DIR/server-stopped` 不存在。如果服务器已关闭，用 `start-server.sh` 以**相同的 `--project-dir`** 重启 — 它会复用同一端口，用户已打开的标签页会自行重连（服务器停机期间标签页显示“paused”遮罩），你也无需发送新 URL。服务器空闲 4 小时后自动退出（可用 `--idle-timeout-minutes` 配置）。
   - 使用语义化文件名：`platform.html`、`visual-style.html`、`layout.html`
   - **绝不复用文件名** — 每块屏幕都用全新文件
   - 使用你的文件创建工具 — **绝不使用 cat/heredoc**（会把噪音倾倒进终端）
   - 服务器会自动提供最新的文件

2. **告诉用户将会看到什么，然后结束你的轮次：**
   - 提醒他们 URL（每一步都要，不只是第一次）
   - 用文字简要概述屏幕上的内容（例如：“正在展示主页的 3 个布局选项”）
   - 请他们在终端回复：“去看一下，然后告诉我你的想法。愿意的话可以点击选择一个选项。”

3. **在你的下一轮** — 用户在终端回复之后：
   - 如果 `$STATE_DIR/events` 存在，读取它 — 里面以 JSON 行记录了用户在浏览器中的交互（点击、选择）
   - 与用户的终端文字合并，得到完整图景
   - 终端消息是主要反馈；`state_dir/events` 提供结构化的交互数据

4. **迭代或推进** — 如果反馈需要修改当前屏幕，写一个新文件（例如 `layout-v2.html`）。只有当前步骤得到验证后，才进入下一个问题。

5. **回到终端时清空屏幕** — 当下一步不需要浏览器时（例如澄清性问题、权衡讨论），推送一个等待屏幕来清除过时内容：

   ```html
   <!-- 文件名：waiting.html（或 waiting-2.html 等） -->
   <div style="display:flex;align-items:center;justify-content:center;min-height:60vh">
     <p class="subtitle">在终端中继续……</p>
   </div>
   ```

   这样可以避免用户盯着一个已经定下的选择，而对话早已向前推进。当下一个视觉问题出现时，照常推送新的内容文件。

6. 重复以上步骤直到完成。

## 编写内容片段

只写将放进页面内部的内容。服务器会自动把它包进 frame 模板（页头、主题 CSS、连接状态以及全部交互基础设施）。

**最小示例：**

```html
<h2>哪种布局更好？</h2>
<p class="subtitle">考虑可读性与视觉层级</p>

<div class="options">
  <div class="option" data-choice="a" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div class="content">
      <h3>单栏</h3>
      <p>干净、专注的阅读体验</p>
    </div>
  </div>
  <div class="option" data-choice="b" onclick="toggleSelect(this)">
    <div class="letter">B</div>
    <div class="content">
      <h3>双栏</h3>
      <p>侧边栏导航加主内容区</p>
    </div>
  </div>
</div>
```

就这些。不需要 `<html>`，不需要 CSS，也不需要 `<script>` 标签。这些都由服务器提供。

## 可用的 CSS 类

frame 模板为你的内容提供以下 CSS 类：

### Options（A/B/C 选项）

```html
<div class="options">
  <div class="option" data-choice="a" onclick="toggleSelect(this)">
    <div class="letter">A</div>
    <div class="content">
      <h3>标题</h3>
      <p>描述</p>
    </div>
  </div>
</div>
```

**多选：** 在容器上添加 `data-multiselect`，让用户可以选中多个选项。每次点击都会切换该项的选中样式。

```html
<div class="options" data-multiselect>
  <!-- 与上面相同的 option 标记 — 用户可以多选/取消多选 -->
</div>
```

### Cards（视觉设计）

```html
<div class="cards">
  <div class="card" data-choice="design1" onclick="toggleSelect(this)">
    <div class="card-image"><!-- mockup 内容 --></div>
    <div class="card-body">
      <h3>名称</h3>
      <p>描述</p>
    </div>
  </div>
</div>
```

### 视觉稿容器

```html
<div class="mockup">
  <div class="mockup-header">预览：仪表盘布局</div>
  <div class="mockup-body"><!-- 你的 mockup HTML --></div>
</div>
```

### Split view（并排）

```html
<div class="split">
  <div class="mockup"><!-- 左侧 --></div>
  <div class="mockup"><!-- 右侧 --></div>
</div>
```

### Pros/Cons

```html
<div class="pros-cons">
  <div class="pros"><h4>优点</h4><ul><li>好处</li></ul></div>
  <div class="cons"><h4>缺点</h4><ul><li>不足</li></ul></div>
</div>
```

### Mock 元素（线框构件）

```html
<div class="mock-nav">Logo | 首页 | 关于 | 联系</div>
<div style="display: flex;">
  <div class="mock-sidebar">导航</div>
  <div class="mock-content">主内容区</div>
</div>
<button class="mock-button">操作按钮</button>
<input class="mock-input" placeholder="输入框">
<div class="placeholder">占位区域</div>
```

### 排版与区块

- `h2` — 页面标题
- `h3` — 小节标题
- `.subtitle` — 标题下方的次级文字
- `.section` — 带下边距的内容块
- `.label` — 小号大写字母的标签文字

## 浏览器事件格式

用户在浏览器中点击选项时，其交互会被记录到 `$STATE_DIR/events`（每行一个 JSON 对象）。当你推送新屏幕时，该文件会自动清空。

```jsonl
{"type":"click","choice":"a","text":"Option A - Simple Layout","timestamp":1706000101}
{"type":"click","choice":"c","text":"Option C - Complex Grid","timestamp":1706000108}
{"type":"click","choice":"b","text":"Option B - Hybrid","timestamp":1706000115}
```

完整的事件流展示了用户的探索路径 — 他们可能在定下来之前点击多个选项。最后一个 `choice` 事件通常是最终选择，但点击的模式能透露出值得追问的犹豫或偏好。

如果 `$STATE_DIR/events` 不存在，说明用户没有与浏览器交互 — 只依据他们的终端文字。

## 设计要点

- **按问题调整保真度** — 布局问题用线框图，观感打磨问题才做精细打磨
- **在每页解释问题** — 写“哪种布局显得更专业？”，而不是只写“选一个”
- **推进前先迭代** — 如果反馈需要修改当前屏幕，就写一个新版本
- 每块屏幕**最多 2-4 个选项**
- **内容本身重要时使用真实内容** — 例如摄影作品集，就用真实图片（Unsplash）。占位内容会掩盖设计问题。
- **保持视觉稿简单** — 聚焦布局与结构，而非像素级完美的设计

## 文件命名

- 使用语义化命名：`platform.html`、`visual-style.html`、`layout.html`
- 绝不复用文件名 — 每块屏幕都必须是新文件
- 迭代时追加版本后缀，如 `layout-v2.html`、`layout-v3.html`
- 服务器按修改时间提供最新的文件

## 清理

```bash
bash scripts/stop-server.sh $SESSION_DIR
```

如果会话使用了 `--project-dir`，视觉稿文件会持久保存在 `.superpowers/brainstorm/` 中以供日后参考。只有 `/tmp` 会话在停止时会被删除。

## 参考

- frame 模板（CSS 参考）：`scripts/frame-template.html`
- helper 脚本（客户端）：`scripts/helper.js`
