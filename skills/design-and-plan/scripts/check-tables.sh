#!/bin/sh
# 校验 Markdown 表格列一致性：对每张表检查分隔行、数据行的列数是否与表头一致。
# 用法：bash scripts/check-tables.sh <文件.md> [更多.md...]
# 退出码：0 全部一致；1 发现列错位或分隔行格式问题；2 用法/文件错误。
# 局限：不解析表格单元格内的转义竖线（\|）与嵌套围栏中的表格样例。
[ $# -ge 1 ] || { echo "用法: $0 <文件.md> [更多.md...]" >&2; exit 2; }
status=0
for f in "$@"; do
  [ -f "$f" ] || { echo "文件不存在: $f" >&2; status=2; continue; }
  awk -v file="$f" '
    function cols(s,  n, a) { n = split(s, a, "|") - 2; return n < 0 ? 0 : n }
    FNR == 1 { intable = 0; sepseen = 0; fence = 0; refcols = -1; start = 0 }
    /^[ \t]*```/ { fence = !fence; intable = 0; sepseen = 0; next }
    fence { next }
    /^[ \t]*\|/ {
      if (!intable) { intable = 1; start = FNR; refcols = cols($0); sepseen = 0; next }
      if (!sepseen) {
        sepseen = 1
        if ($0 !~ /^[ \t]*\|[-: \t|]+$/) { printf "%s:%d: 分隔行格式非法（应为 |---|---| 形式）: %s\n", file, FNR, $0; bad = 1 }
        c = cols($0)
        if (c != refcols) { printf "%s:%d: 列错位——表头（第 %d 行）%d 列，分隔行 %d 列\n", file, start, start, refcols, c; bad = 1 }
        next
      }
      c = cols($0)
      if (c != refcols) { printf "%s:%d: 列错位——表头 %d 列，本行 %d 列: %s\n", file, FNR, refcols, c, $0; bad = 1 }
      next
    }
    { intable = 0; sepseen = 0 }
    END { exit bad ? 1 : 0 }
  ' "$f" || status=1
done
exit $status
