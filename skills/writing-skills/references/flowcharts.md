# 技能中的流程图

本文属于 superpowers:writing-skills。

## 流程图用法

```mermaid
flowchart TD
    want_to_show{"需要展示信息吗？"}
    error_prone_decision{"我可能出错的决策？"}
    use_markdown["使用 markdown"]
    small_inline_flowchart["小型内联流程图"]

    want_to_show -->|是| error_prone_decision
    error_prone_decision -->|是| small_inline_flowchart
    error_prone_decision -->|否| use_markdown
```

**仅在以下情况使用流程图：**
- 非显而易见的决策点
- 可能过早停止的流程循环
- “何时该用 A、何时该用 B”的决策

**绝不将流程图用于：**
- 参考资料 → 表格、列表
- 代码示例 → Markdown 块
- 线性指令 → 编号列表
- 没有实际含义的标签（step1、helper2）

## mermaid 风格规则

| 元素 | mermaid 写法 |
|---|---|
| 决策问题 | 菱形 `{"问题？"}` |
| 动作 | 方框 `["做某事"]` |
| 状态、流程入口 | 体育场 `(["某状态"])` |
| 流程终点 | 双圆 `(("完成"))` |
| 警告/禁止 | 方框 + `style id fill:red,color:white` |
| 二元决策的边 | `A -->\|是\| B`、`A -->\|否\| B` |
| 多分支的边 | 每条边标注具体条件 |
| 跨流程触发 | 虚线 `A -.->\|触发\| B` |

- 节点 id 用简短的英文语义词（`can_backtrace`、`fix_root`），全部文字放进双引号
- 命名：问题以？结尾；动作以动词开头；命令原样放进方框；状态描述处境，不用「步骤 N」这类泛化标签
- 多行文字用 `<br/>` 换行

**为需求方做可视化：**mermaid 图在 GitHub、VS Code、Typora、Obsidian 等支持 mermaid 的 markdown 阅读器中直接渲染，无需额外工具；需要导出图片时用 mermaid-cli（`npx @mermaid-js/mermaid-cli -i graph.mmd -o graph.svg`）。
