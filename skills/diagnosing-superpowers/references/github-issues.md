# GitHub issues

若 `gh` 已安装且已认证，就使用 `gh`；认证、速率限制和 JSON 都由它处理。否则先回退到用 curl 调公共 API，再回退到交给你的需求方打开的 URL。

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

当报告者缺少 push 权限时，GitHub 会静默丢弃标签，因此标签只对协作者（collaborator）生效；不过模板页脚仍会把该 issue 标记为由技能提交。`gh` 无法附加文件：issue 创建后，把材料包（bundle）路径交给你的需求方，由其通过浏览器附加。

没有 `gh` 时，交给你的需求方一个基于 `bug_report.md` 模板预填好的链接，它会为任何报告者套用 `bug` 标签：

```
https://github.com/obra/superpowers/issues/new?template=bug_report.md&title=<url-encoded title>&body=<url-encoded body>
```

GitHub 会拒绝超过约 8000 个字符的 URL；超过时，只发送带标题的链接，并让你的需求方从文件中粘贴正文。
