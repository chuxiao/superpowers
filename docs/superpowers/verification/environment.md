# 集成验证环境与手段

项目形态：技能库（Markdown 技能档案 + shell 测试），非后端、Web 或 App；不走形态路由，按本声明执行机械契约层与会话行为层。

| 层 | 入口命令 | 环境要求 | 预期时长上限 |
|----|---------|---------|-------------|
| 全量测试（Step 1） | `find tests -type f \( -name 'test-*.sh' -o -name 'run-*.sh' \)` 逐一运行 | bash、python3、git | 10 分钟 |
| 机械文本契约（L1 / 兼容） | `bash tests/integration-verification/test-integration-verification.sh`；`bash tests/antigravity/test-plugin-manifest.sh`；`bash tests/skill-size/test-skill-size.sh`；`bash tests/hooks/test-session-start.sh` | bash、python3、git | 每个 2 分钟 |
| 会话行为（L3） | 按各 `docs/superpowers/specs/<date-feature>/verification.md` 的人工场景，在新会话中执行 | Claude Code、技能已安装 | 每个 10 分钟 |

## 环境受限

- `tests/codex/test-package-codex-plugin.sh` 要求 `.git` 为目录；链接工作树中 `.git` 为文件。该测试在普通检出通过、在工作树失败。重跑条件：在普通检出运行，或调整打包脚本接受 `.git` 文件。
- `tests/explicit-skill-requests/` 的 5 个脚本调用 `claude -p --output-format stream-json`；当前 CLI 版本要求同时提供 `--verbose`。重跑条件：CLI 升级或测试脚本补 `--verbose`。

## 工具链

不依赖容器运行时、浏览器或移动模拟器；需要 bash、python3、git 与 Claude Code 会话。
