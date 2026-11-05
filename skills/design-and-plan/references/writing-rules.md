# 写作与排版规范

> 适用于全部五件产物（design.md / implementation.md / plan.md / verification.md / decisions.md）的写作与排版单一权威源。各产物模板只补充本文档没有的专属条目；与本文档重复的条目以本文档为准。

1. 每段只承载一个论点，段首句即结论；句子短，能用列表分点就不用段落。
2. 同类条目用相同句式与相近粒度。
3. 禁止「适当处理」「必要时」「等等」，改为可判真伪的命题；重要规则给 ❌/✅ 对照。
4. 先画图再补充说明：design.md 画用户流程或功能关系图；implementation.md 画模块划分与关键链路图；plan.md 画模块关系或数据流图。mermaid 画法与语法红线见 superpowers:writing-skills 的 `references/flowcharts.md`（语法红线：subgraph 用 `id["标题"]` 形态、文字与特殊字符进引号、换行用 `<br/>`）；提交确认前跑 `scripts/check-mermaid.sh`。
5. 标题层级不超过 3 级，列表嵌套不超过 2 层；单文档超过约 400 行考虑拆分。
6. 交叉引用写「见 §N（内容摘要）」，不写裸引用。
7. 接口配一个调用示例及其对应行为，落点在 implementation.md 接口的「示例」段；其余产物不出现接口签名与调用示例，只引用章节号与名字。
