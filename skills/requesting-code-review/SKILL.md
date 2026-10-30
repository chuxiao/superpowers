---
name: requesting-code-review
description: 完成任务、实现重大功能或合并之前需要验证工作是否满足要求时使用
---

# 请求代码审查

派发代码审查子代理，在问题级联扩散之前将其捕获。审查者拿到的是为评估精确构拟的上下文——绝不是你的会话历史。

**核心原则：** 早审查、常审查。

## 何时请求审查

**强制：**
- 子代理驱动开发中的每个任务之后
- 完成重大功能之后
- 合并到 main 之前

**可选但有价值：**
- 卡住时（新视角）
- 重构之前（基线检查）
- 修复复杂 bug 之后

## 如何请求

**1. 获取 git SHA：**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # 或用: git merge-base origin/main HEAD
HEAD_SHA=$(git rev-parse HEAD)
```

**2. 派发代码审查子代理：**

派发一个 `general-purpose` 子代理，并填写 [code-reviewer.md](code-reviewer.md) 处的模板。

**占位符：**
- `{DESCRIPTION}` - 你所构建内容的简要总结
- `{PLAN_OR_REQUIREMENTS}` - 它应该做什么
- `{BASE_SHA}` - 起始提交
- `{HEAD_SHA}` - 结束提交

**3. 根据反馈采取行动：**
- 立即修复 Critical（必须修复）问题
- 继续之前先修复 Important（应当修复）问题
- 记下 Minor（最好能有）问题，留待以后处理
- 审查者有错时予以反驳（附上理由）

## 示例

```
[刚完成 Task 2: 添加验证函数]

你：让我在继续之前请求代码审查。

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | cut -d' ' -f1)
HEAD_SHA=$(git rev-parse HEAD)

[派发代码审查子代理]
  DESCRIPTION: 添加了带 4 种问题类型的 verifyIndex() 与 repairIndex()
  PLAN_OR_REQUIREMENTS: docs/superpowers/plans/deployment-plan.md 中的 Task 2
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661

[子代理返回]：
  Strengths: 架构干净，测试真实
  Issues:
    Important: 缺少进度指示器
    Minor: 上报间隔使用魔法数字（100）
  Assessment: 可以继续推进

你：[修复进度指示器]
[继续 Task 3]
```

## 常见合理化借口

| 借口 | 现实 |
|--------|---------|
| 「我就自己审查 diff 好了，不必派发审查者」 | 你是控制者——在会话内审查 diff 会烧掉你继续推进这项工作所需的上下文窗口。派发一个审查者子代理：diff 与评估都留在它的上下文里，只有发现项会返回给你。 |
| 「审查者需要我的整个会话历史才能理解这次改动」 | 交给它精确构拟的上下文，绝不是你的会话历史。这能让审查者聚焦于工作产物，而不是你的思考过程。 |

## 危险信号

**绝不：**
- 以「很简单」为由跳过审查
- 无视 Critical 问题
- 带着未修复的 Important 问题继续推进
- 与有效的技术反馈争辩

**如果审查者有错：**
- 用技术理由反驳
- 出示能证明其可正常工作的代码/测试
- 请求澄清

模板见：[code-reviewer.md](code-reviewer.md)
