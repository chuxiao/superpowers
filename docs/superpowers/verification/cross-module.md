# 跨模块场景登记册

跨技能联动的端到端行为场景（integration-verification 与 regression-sweep 及收尾链路）。场景规格与执行证据见 `tests/integration-verification/drills.md`（13 场景，2026-11-02 执行全部通过）；层级 L3 = 真实会话端到端行为场景。并入来源：`docs/superpowers/specs/2026-11-01-integration-gate-and-regression/plan.md`（Task 6）。

- REC-L3-001 | L3 | tests/integration-verification/drills.md | normal | 跨任务组装失败：一遍跑完后按层分组集中呈现，不移交收尾技能
- REC-L3-002 | L3 | tests/integration-verification/drills.md | normal | 接口破坏性变更被兼容层拦下，兼容层不随运行层降级
- REC-L3-003 | L3 | tests/integration-verification/drills.md | normal | 无集成面分支附一句依据快速放行，不产生出口凭据
- REC-L3-004 | L3 | tests/integration-verification/drills.md | normal | 回归仅显式触发，基线核对后全量重跑并落盘报告，待合并条目单列
- REC-L3-005 | L3 | tests/integration-verification/drills.md | normal | 三形态路由走通；模拟器不可达走环境外降级逐项移交
- REC-L3-006 | L3 | tests/integration-verification/drills.md | normal | 并入仅在选合并或 PR 后三态登记；保持原样零改动
- REC-L3-007 | L3 | tests/integration-verification/drills.md | normal | 免跑三判据成立时收尾 Step 1 免跑（带残留凭据同样免跑）
- REC-L3-008 | L3 | tests/integration-verification/drills.md | normal | 非 bug 定性后仅增量重跑被定性条目；bug 回修全量重跑
- REC-L3-009 | L3 | tests/integration-verification/drills.md | normal | 偶发失败重跑通过记稳定性信号，不进入定性裁决
- REC-L3-010 | L3 | tests/integration-verification/drills.md | normal | 有集成面却判无时以改动面推导为准不放行
- REC-L3-011 | L3 | tests/integration-verification/drills.md | normal | HEAD 变化或工作区脏时结果过期，照跑套件并移交
- REC-L3-012 | L3 | tests/integration-verification/drills.md | normal | 未定性（含模糊授权语）不得修改方案期望
- REC-L3-013 | L3 | tests/integration-verification/drills.md | normal | 偶发重跑通过不被误拉进定性裁决

并入来源：`docs/superpowers/specs/2026-11-03-uniform-full-workflow/verification.md`（2026-11-04 并入；机械场景 S-01~S-07/S-09 同一资产一次执行故合组一条，会话场景 S-08 证据性资产单列）。

- UFQ-001 | 兼容 | tests/integration-verification/test-integration-verification.sh | normal | 机械场景（S-01~S-07/S-09）：断言电池全绿——小改动豁免清零三断言、存活锚点在场、正文与全仓旧短语零命中
- UFQ-002 | L3 | docs/superpowers/specs/2026-11-03-uniform-full-workflow/eval-record.md | normal | 会话场景（S-08）：施压下不跳设计文档/审读/计划，坚持完整流程（GREEN 6/6 在案，证据性资产）

并入来源：`docs/superpowers/specs/2026-11-03-spec-dir-convention/verification.md`（2026-11-04 并入；机械场景 S1-S4 同一资产一次执行合组一条；S5 为合并后首个真实需求会话的人工观察项，不可回归执行，不入册，观察义务见该需求台账）。

- SDC-001 | 兼容 | tests/integration-verification/test-integration-verification.sh | normal | 机械场景（S1-S4）：断言 20 正反向全绿——两锚点全仓唯一在场、两旧偏好句与泛化短语全仓缺席；回潮与锚点破坏演练红绿有效

并入来源：`docs/superpowers/specs/2026-11-04-workflow-discipline-hardening/verification.md`（2026-11-04 并入；机械场景 S1-S4 同一资产一次执行合组一条，S6 会话场景单列）。

- WDH-001 | 兼容 | tests/integration-verification/test-integration-verification.sh | normal | 机械场景（S1-S4）：断言组 21 正反向全绿——35 条纪律锚点按承载文件唯一在场、13 条旧表述与泛化短语缺席；回潮与锚点破坏演练红绿有效
- WDH-002 | L3 | docs/superpowers/specs/2026-11-04-workflow-discipline-hardening/verification.md | normal | 会话场景（S6）：施压下先定性并基于基线顶端建树、拒绝跳过闸门并说明（单次演练记录见该方案 §7）
