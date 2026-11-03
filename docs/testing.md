# Superpowers 的测试

Superpowers 有两类不同的测试，各自位于独立目录：

- **`tests/`** —— 插件的非 LLM 代码能否正常工作？针对 brainstorm-server JS、OpenCode 插件加载、codex-plugin 同步以及分析工具脚本的 Bash + node + python 集成测试。
- **`evals/`** —— agent 在真实 LLM 会话中的行为是否正确？由 Python harness 驱动 Claude Code / Codex / Gemini CLI 的真实 tmux 会话，并配一个 LLM actor（执行者）与一个 verifier（核验者）评判技能遵循情况。

## 插件测试

位于 `tests/`。目前包括：

- `tests/brainstorm-server/` —— brainstorm server JS 代码的 node 测试套件。
- `tests/opencode/` —— OpenCode 插件加载、bootstrap 缓存与工具注册的 bash 测试。
- `tests/codex-plugin-sync/` —— bash 同步验证。
- `tests/kimi/` —— Kimi 插件清单（manifest）装配的 bash/Python 检查。
- `tests/claude-code/test-helpers.sh`、`analyze-token-usage.py` —— 其余 bash 测试所用的工具脚本。
- `tests/claude-code/test-subagent-driven-development.sh` —— 「agent 能否描述 SDD（subagent-driven-development，子代理驱动开发）」测试（没有对应的 quorum 版本；测的是能否复述技能描述，而非实际行为）。
- `tests/claude-code/test-subagent-driven-development-integration.sh` —— 扩展版 SDD 集成测试，附带 token 分析（quorum 覆盖其中的 YAGNI 子集；bash 则额外增加提交数、Claude Code 任务跟踪与 token 遥测断言）。
- `tests/claude-code/test-worktree-native-preference.sh` —— worktree 技能的 RED-GREEN-REFACTOR 验证（quorum 覆盖 PRESSURE 阶段；bash 还覆盖 RED/GREEN 基线）。
- `tests/explicit-skill-requests/` —— Haiku 专属、多轮对话、以技能名作提示词触发的测试，均不在 quorum 覆盖范围内。
- `tests/diagnosing-superpowers/test-skill-structure.sh` —— diagnosing-superpowers 技能的结构检查（frontmatter、被引用文件、泄漏扫描、字数预算）；行为场景评测的记录由维护者保存在仓库之外。

插件测试通过相应目录里的 `run-*.sh` 或 `npm test` 运行。

## 技能行为评测

位于 `evals/`（[superpowers-evals](https://github.com/prime-radiant-inc/superpowers-evals/) 评测实验室，此前名为 Drill）。Quorum 是其中的 harness CLI——整个系统的一个组成部分：它通过一个 Gauntlet QA agent 驱动真实的编码 agent CLI，并对照每个场景的验收标准与确定性后置检查为其评分。场景位于 `evals/scenarios/<name>/`。环境搭建、容器运行时与安全模型见 `evals/README.md`。快速开始（本地 break-glass 直跑，即绕过常规流程的应急运行）：

```bash
cd evals
bun install
export SUPERPOWERS_ROOT=/path/to/superpowers
bun run quorum run scenarios/triggering-test-driven-development --coding-agent claude
bun run quorum show <run-dir>
```

Quorum 场景很慢（每个场景 3 到 30 多分钟），并以宽松模式运行真实 LLM 会话——请先阅读 `evals/README.md` 的 Live Eval Risk 一节。只有静态闸门（`bun run check`、`bun run quorum check`）可以安全地用于公开 CI；自然的后续方案仍是分层模式（PR 上跑静态闸门，实跑清扫放到夜间与按需触发）。
