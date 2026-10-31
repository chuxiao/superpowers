# GitHub issues

若 `gh` 已安装且已认证，就使用 `gh`；认证、速率限制和 JSON 都交给它处理。否则先用 curl 调公共 API，再退而求其次：把一个 URL 交给你的需求方打开。

## 搜索

```bash
gh search issues --repo obra/superpowers --limit 10 "<terms>" \
  --json number,state,title --jq '.[] | "\(.number)\t\(.state)\t\(.title)"'
```

没有 `gh` 时（未认证，每分钟 10 次请求）：

```bash
curl -s -H "Accept: application/vnd.github+json" \
  "https://api.github.com/search/issues?q=repo:obra/superpowers+is:issue+<url-encoded terms>&per_page=10" \
  | jq -r '.items[] | "\(.number)\t\(.state)\t\(.title)"'
```

没有 curl 时，交给你的需求方 `https://github.com/obra/superpowers/issues?q=<terms>`。

## 提交 issue

把填写好的 `templates/issue.md` 写入工作区，并展示其确切文本。获得批准后：

```bash
gh issue create --repo obra/superpowers --title "<title>" --body-file <path> \
  --label bug --label automated-issue-report
```

当报告者缺少 push 权限时，GitHub 会静默丢弃标签，因此只有报告者本人是协作者（collaborator）时，标签才会生效；不过模板页脚仍会把该 issue 标记为由技能提交。`gh` 无法附加文件：issue 创建后，把材料包（bundle）路径交给你的需求方，由其通过浏览器附加。

没有 `gh` 时，交给你的需求方一个基于 `bug_report.md` 模板预填好的链接，无论报告者是谁，该链接都会带上 `bug` 标签：

```
https://github.com/obra/superpowers/issues/new?template=bug_report.md&title=<url-encoded title>&body=<url-encoded body>
```

GitHub 会拒绝超过约 8000 个字符的 URL；超过时，只发送仅预填标题（不含正文）的链接，并让你的需求方从文件中粘贴正文。
