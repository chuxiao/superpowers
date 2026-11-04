# eval 探测与行为场景记录

- **日期：** 2026-11-04
- **依据：** 设计 §4 决策 7，选择 A（先探测 eval 覆盖，再决定是否跑 before/after）
- **探测对象：** `https://github.com/prime-radiant-inc/superpowers-evals.git`，克隆至 `evals/`（gitignored）

## 结论

**S6、S8 无覆盖场景；S7 有覆盖但未运行（授权/凭证受限）。** 未运行 before/after；不新增自研 eval 场景。S6–S8 转需求方手动验证。

## 证据

- 克隆提交：`e64684cd1fa270c464ac797747e45bbe8d127e8b`
- 场景总数：94 个（`evals/scenarios` 下目录数）。
- 覆盖判据：场景必须涉及「适用范围判定」「非软件开发任务是否触发工作流」「文档类交付物是否进入工作流」「描述触发语」之一；仅有通用编码场景不算覆盖。
- 检索命令与结果：
  - `grep -rli "non-software|non software|not a software|unrelated request|documentation-only|doc-only|non-coding|noncoding" evals/scenarios` → 无匹配文件。
  - `grep -rin "scope" evals/scenarios/*/story.md` → 命中均指任务范围或对话范围（如 `that scope is ok`、`wait_tool_scope`），不是技能适用范围判定。
  - 现有 `triggering-*` 场景覆盖的是软件开发任务的技能触发（writing-plans、executing-plans、requesting-code-review 等），不含「非软件开发请求不进入工作流」或「文档类交付物进入工作流」。
  - `superpowers-bootstrap` 覆盖 S7：原样发送 `Let's make a react todo list`，期望写代码前触发 brainstorming。属于有覆盖。但 live eval 需要 trusted-maintainer 凭证，并以 `--dangerously-skip-permissions` 启动编码代理，属安全敏感操作；本次未运行，移交需求方决定。
- S6、S8 无覆盖；S7 有覆盖但未运行。未创建基线 worktree，未调用任何编码代理，未使用任何 API key。

## S6–S8 行为场景（待需求方手动验证）

执行者无法在自身会话中开新交互式会话并观察，以下三条由需求方在实施完成后执行，结果填入本节。

| 场景 | 环境与步骤 | 期望 | 结果 |
|------|-----------|------|------|
| S6 非软件开发请求 | 需求方在本机 Claude Code 新会话，工作目录为 `mktemp -d` 空目录；发送「帮我策划一场婚礼」 | 正常应答；不创建 `docs/superpowers/specs/`；不进入工作流 | 待需求方手动验证 |
| S7 软件开发请求 | 需求方在本机 Claude Code 新会话，工作目录为 `mktemp -d` 空目录；原样发送 `Let's make a react todo list` | 写代码前自动触发 `brainstorming` | 有覆盖（`superpowers-bootstrap`）但未运行；待需求方决定是否跑 live eval 或手动验证 |
| S8 文档类请求 | 需求方在本机 Claude Code 新会话，工作目录为软件仓库临时副本；发送「帮我为这个项目写一份部署文档」 | 写文档前触发 `brainstorming`；不被范围标签排除 | 待需求方手动验证 |

## 产物与副作用

- `evals/` 已克隆但被 `.gitignore` 忽略；`git ls-files evals/` 为空。
- 未创建 `/tmp/dsc-baseline-*`；未提交任何 eval 输出或运行日志。
- 未修改 `evals/` 下任何文件。

## 未执行理由

S6、S8 覆盖判据不成立；S7 有覆盖但 live eval 属安全敏感操作，未运行。按计划转入人工场景；不把「未运行」伪装成「已运行」，也不把 S7 的有覆盖误记为无覆盖。
