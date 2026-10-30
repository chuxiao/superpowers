# 终审并收尾

本文是 superpowers:subagent-driven-development 的一部分。计划中的每个任务均已完成。

整分支终审同样有审查包：运行 `bash scripts/review-package PLAN_FILE MERGE_BASE HEAD`（MERGE_BASE = 分支的起始提交，例如 `git merge-base main HEAD`），并把打印出的路径写进终审派发，这样终审审查者读一个文件即可，不必再用 git 命令重新推导分支 diff。派发到可用的最强档模型上（见 SKILL.md 的 Model Selection（模型选择）），使用 superpowers:requesting-code-review 的 [code-reviewer.md](../../requesting-code-review/code-reviewer.md)。向它指出台账中暂缓的 minor 行与搁置行，以便它甄别哪些必须在合并前修复。

如果整分支终审返回发现项，派发仅一个修复子代理，附上完整的发现项清单——而不是每个发现项各派一个修复者。逐发现项的修复者每个都要重建上下文并重跑测试套件；某个真实会话的终审修复波成本超过了它全部任务的总和。然后对修复波运行恰好一次范围化复审（用 `bash scripts/review-package PLAN_FILE FIX_BASE HEAD` 覆盖修复范围，配合 [re-review-prompt.md](../re-review-prompt.md)）。对任何残留发现项，按修复循环的熔断（references/fix-loop.md）中的做法裁决：附裁决搁置，或对其中承重的发现项做出裁决并把你的决定记入台账。在这里，能让你停下的只有那四件能让正在运行的计划停下的事（SKILL.md 顶部）。不存在第二个修复波——残留的承重发现项会在 finishing-a-development-branch 呈现各选项时浮现给你的需求方。

### 收尾

在删除任何东西之前，把台账中每一行包含 `Ruling:` 的内容——预检裁决、搁置的发现项、熔断裁决，全部——收进你最终消息中 "Rulings I made"（我做出的裁决）标题之下，按你做出它们的先后顺序排列，每条都注明如果错了代价是什么。这份清单必须穷尽：台账里有一条裁决，清单里就有它。这份清单是你替需求方做出的决定唯一能传达到他们那里的地方——他们会读它，并把你做错的地方返工。随工作区一起消亡的裁决，就是一次暗中做出的决定。

当整分支终审干净且其修复已合并后，删除本计划的工作区（`rm -rf <workspace>`）——现在 git 历史就是记录。同级目录属于其他计划；不要动它们。

使用 superpowers:finishing-a-development-branch。
