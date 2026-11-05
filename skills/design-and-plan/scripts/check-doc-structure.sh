#!/bin/sh
# 校验设计与计划文档的结构槽位（模板：skills/design-and-plan/references/ 下的 design-doc-template.md 与 plan-template.md）：
# 功能卡片必含字段、决策速览表、Task 职责句、风险清单四列表格（仅 plan 文档启用）、mermaid 节点文本预算，以及三个新槽位——
# 形态声明（design/implementation 文档）、任务依赖图（含 Task 小节的 plan 文档）、文首指针句（plan 文档）。
# 用法：bash scripts/check-doc-structure.sh <文件.md> [更多.md...]
# 退出码：0 全部通过；1 发现结构缺损；2 用法/文件错误。
# 判定只查存在性、不判语义；条件槽位（出口表/流程图/边界条件分组）依赖判断，归独立审读检查。
# 豁免已废除（2026-11-03 裁决）：所有设计文档一律五章、所有计划含 Task 结构，卡片与职责断言对全部文档生效。
# 新槽位检查按文件名启用（verification 文档只查既有通用槽位；风险清单表格检查仅 plan 文档），并一律跳过代码围栏——
# 围栏内的模板示例与引用文字不构成槽位在场。
[ $# -ge 1 ] || { echo "用法: $0 <文件.md> [更多.md...]" >&2; exit 2; }
status=0
for f in "$@"; do
  [ -f "$f" ] || { echo "文件不存在: $f" >&2; status=2; continue; }
  awk -v file="$f" '
    function has(s, k) { return index(s, k) > 0 }
    function base(p,  n, a) { n = split(p, a, "/"); return a[n] }   # 槽位检查按文件名（非路径）启用——路径可含技能目录名字样
    BEGIN { isplan = index(base(file), "plan") > 0 }
    function flushcard(  where, t) {
      t = cardtext
      gsub(/\*/, "", t)   # 归一化加粗标记：「**定位：**」与「**定位**：」视为同形
      where = sprintf("%s（卡片起始于第 %d 行）", file, cardstart)
      if (has(t, "定位：") == 0) { printf "%s: 功能卡片缺「定位：」字段 %s\n", where, ""; bad = 1 }
      if (has(t, "触发与输入") == 0) { printf "%s: 功能卡片缺「触发与输入」字段 %s\n", where, ""; bad = 1 }
      if (has(t, "执行要点") == 0) { printf "%s: 功能卡片缺「执行要点」字段 %s\n", where, ""; bad = 1 }
      if (has(t, "本次不做") == 0) { printf "%s: 功能卡片缺「本次不做」字段 %s\n", where, ""; bad = 1 }
    }
    function fluashtask() {
      if (has(tasktext, "职责：") == 0) { printf "%s:%d: Task 小节缺「职责：」句\n", file, taskstart; bad = 1 }
    }
    /^[ \t]*```/ {
      if (fence) { fence = 0; inmermaid = 0 }
      else { fence = 1; inmermaid = ($0 ~ /^[ \t]*```mermaid/) }
      next
    }
    fence && inmermaid {
      line = $0
      gsub(/\|[ \t]*"[^"]*"[ \t]*\|/, "||", line)   # 剥离边标签，只查节点文本
      n = split(line, seg, "\"")
      for (i = 2; i <= n; i += 2) {
        depth = 1 + gsub(/<br\/>/, "", seg[i])
        if (depth > 3) { printf "%s:%d: mermaid 节点文本超 3 行（%d 行）: %s\n", file, FNR, depth, seg[i]; bad = 1 }
      }
      next
    }
    fence { next }
    /^[ \t]*#{1,3} / {
      if (incard) flushcard()
      if (intask) fluashtask()
      if (isplan && inrisk && !risktable) { printf "%s: 「风险清单」章节缺四列表格（表头应含「触发条件」「缓解」）\n", file; bad = 1 }
      incard = 0; intask = 0; cardtext = ""; tasktext = ""
      if ($0 ~ /^[ \t]*### 功能/) { incard = 1; cardstart = FNR; cardtext = $0 }
      else if ($0 ~ /^[ \t]*### Task/) { intask = 1; taskstart = FNR; tasktext = $0; sawtask = 1; if (firsttask == 0) firsttask = FNR }
      if ($0 ~ /^[ \t]*### 决策/) decisions++
      if ($0 ~ /^[ \t]*## .*风险清单/) { inrisk = 1; risktable = 0 } else if ($0 ~ /^[ \t]*## /) inrisk = 0
      if ($0 ~ /^[ \t]*#+[ \t]*(0\.[ \t]*)?形态声明/) decl = 1
      if ($0 ~ /^[ \t]*#+[ \t]*.*任务依赖图/) deptask = 1
      next
    }
    {
      if (incard) cardtext = cardtext "\n" $0
      if (intask) tasktext = tasktext "\n" $0
      if (inrisk && $0 ~ /^[ \t]*\|/ && has($0, "触发条件") && has($0, "缓解")) risktable = 1
      if (has($0, "一句话结论") && $0 ~ /^[ \t]*\|/) overview = 1
      if ($0 ~ /^[ \t]*形态声明/) decl = 1
      if (firsttask == 0 && has($0, "实现设计见同目录 implementation.md")) ptrline = 1
    }
    END {
      if (incard) flushcard()
      if (intask) fluashtask()
      if (decisions >= 2 && !overview) { printf "%s: 决策小节共 %d 个，但缺决策速览表（表头应含「一句话结论」）\n", file, decisions; bad = 1 }
      if (isplan && inrisk && !risktable) { printf "%s: 「风险清单」章节缺四列表格（表头应含「触发条件」「缓解」）\n", file; bad = 1 }
      b = base(file)
      if (index(b, "design") > 0 || index(b, "implementation") > 0) {
        if (!decl) { printf "%s: 缺形态声明槽位（应含「## 0. 形态声明」级标题或行首「形态声明」行）\n", file; bad = 1 }
      }
      if (index(b, "plan") > 0 && sawtask && !deptask) { printf "%s: 含 Task 小节但缺「任务依赖图」槽位（应有含该字样的标题行）\n", file; bad = 1 }
      if (index(b, "plan") > 0 && !ptrline) { printf "%s: 缺文首指针句「实现设计见同目录 implementation.md」（须出现在首个 Task 小节之前）\n", file; bad = 1 }
      exit bad ? 1 : 0
    }
  ' "$f" || status=1
done
exit $status
