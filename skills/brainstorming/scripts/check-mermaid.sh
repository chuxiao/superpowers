#!/bin/sh
# 校验 Markdown 内 mermaid 代码块的语法红线：
# 1) subgraph 标题必须用 subgraph id["标题"] 形态（裸标题位置不接受 HTML 标记）
# 2) 引号外的文本不得出现 <（HTML 标记只能写在 "…" 引号内的文本里）
# 3) 换行统一用 <br/>，不用 <br>
# 4) 引号外的文本不得出现 ASCII 圆括号（形状语法 [( ( [[ / 的合法对除外）
# 5) mermaid 围栏必须闭合
# 用法：bash scripts/check-mermaid.sh <文件.md> [更多.md...]
# 退出码：0 全部通过；1 发现红线违规；2 用法/文件错误。
# 局限：只做词法红线检查，不渲染图——渲染语义（节点连接、布局）仍需人工查看。
[ $# -ge 1 ] || { echo "用法: $0 <文件.md> [更多.md...]" >&2; exit 2; }
status=0
for f in "$@"; do
  [ -f "$f" ] || { echo "文件不存在: $f" >&2; status=2; continue; }
  awk -v file="$f" '
    /^[ \t]*```mermaid/ { if (inmm) { printf "%s:%d: 嵌套的 mermaid 围栏开始（上一个未闭合）\n", file, FNR; bad = 1 } inmm = 1; next }
    /^[ \t]*```/ { inmm = 0; next }
    inmm {
      if ($0 ~ /(^|[ \t])subgraph[ \t]/ && $0 !~ /subgraph[ \t]+[A-Za-z0-9_]+\["/) {
        printf "%s:%d: subgraph 标题须用 subgraph id[\"标题\"] 形态（裸标题位置不接受 HTML 标记，换行用引号内 <br/>）: %s\n", file, FNR, $0; bad = 1
      }
      nq = $0
      while (match(nq, /"[^"]*"/)) nq = substr(nq, 1, RSTART - 1) substr(nq, RSTART + RLENGTH)
      if (nq ~ /</) {
        printf "%s:%d: 引号外的文本出现 <（HTML 标记只能写在 \"…\" 引号内的文本里）: %s\n", file, FNR, $0; bad = 1
      }
      if ($0 ~ /<br>/) {
        printf "%s:%d: 换行用 <br/>，不要用 <br>: %s\n", file, FNR, $0; bad = 1
      }
      np = nq
      gsub(/\(\(|\)\)|\(\[|\]\)|\[\(|\)\]|\[\[|\]\]|\[\/|\/\]|\[\\|\\\]/, "", np)
      if (np ~ /[()]/) {
        printf "%s:%d: 引号外的文本出现 ASCII 圆括号（未加引号的文本不接受圆括号，文字放进 \"…\" 或改用全角（））: %s\n", file, FNR, $0; bad = 1
      }
    }
    END { if (inmm) { printf "%s: mermaid 代码块未闭合\n", file; bad = 1 } exit bad ? 1 : 0 }
  ' "$f" || status=1
done
exit $status
