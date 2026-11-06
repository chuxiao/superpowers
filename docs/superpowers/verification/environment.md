# 集成验证环境与手段

项目形态：技能库（Markdown 技能档案 + shell 测试），非后端、Web 或 App；不走形态路由，按本声明执行机械契约层与会话行为层。

| 层 | 入口命令 | 环境要求 | 预期时长上限 |
|----|---------|---------|-------------|
| 全量测试（Step 1） | `find tests -type f \( -name 'test-*.sh' -o -name 'run-*.sh' \)` 逐一运行 | bash、python3、git | 10 分钟 |
| 机械文本契约（L1 / 兼容） | `bash tests/integration-verification/test-integration-verification.sh`；`bash tests/antigravity/test-plugin-manifest.sh`；`bash tests/skill-size/test-skill-size.sh`；`bash tests/hooks/test-session-start.sh` | bash、python3、git | 每个 2 分钟 |
| 会话行为（L3） | 按各 `docs/superpowers/specs/<date-feature>/verification.md` 的人工场景，在新会话中执行 | Claude Code、技能已安装 | 每个 10 分钟 |

## 环境受限

- `tests/codex/test-package-codex-plugin.sh` 已随 2026-11-05 design-and-plan 合并改造删除（9fe12e9），本行保留为历史环境记录。
- `tests/explicit-skill-requests/` 五场景为会话层（L3），不在 Step 1 机械口径内，需真实会话执行（另受 CLI --verbose 环境限制）。`tests/claude-code/run-skill-tests.sh` 为机械套件（2026-11-06 修正：此前误归类会话层，实测 v7.1.0 版本同步后 120 秒内可完整跑通）。
- `tests/explicit-skill-requests/` 的 5 个脚本调用 `claude -p --output-format stream-json`；当前 CLI 版本要求同时提供 `--verbose`。重跑条件：CLI 升级或测试脚本补 `--verbose`。

## 工具链

不依赖容器运行时、浏览器或移动模拟器；需要 bash、python3、git 与 Claude Code 会话。
