# Spec: v2.2.1 双轴审查修复（单写者/越界依据/INSTALL 同步/冲刺漏洞等）

- 日期：2026-10-13
- 来源：code-review 双轴审查（Standards 3 硬违规 + 5 判断题 + 4 smell；Spec 3 缺失 + 2 提示）
- 上游规格：2026-10-09-reference-material-intake.md、2026-10-13-practice-hardening.md（修完回写）

---

## Problem Statement

v2.2.1 实现硬点全落地，但审查发现规则层三处顶撞（修复子代理写账 vs"子代理不写账本"、走查修复越界无总纲依据、INSTALL 子代理清单失真），以及冲刺模式可绕过 Critical 清零门、若干措辞/同步缺口。

## Solution

单写者条款开**串行执行者显式例外**（保 Q7 定案不动）；走查修复写入总纲"快速修复通道"依据；INSTALL 补子代理清单；冲刺例外明写"对抗 Critical 不放行"；其余按缺失清单逐条补齐。schema/判据重复以"权威定义 + 引用"消解；160 魔数命名。

## User Stories

1. 作为维护者，我希望单写者条款与走查修复环不顶撞（串行执行者=单写链条延伸，禁止的是并行多写），以便 Q7 定案与总纲并存。
2. 作为审计者，我希望走查修复在总纲有"快速修复通道"依据，以便多点修复不算越界写入。
3. 作为安装代理，我希望 INSTALL 子代理清单含新增的对抗审查/走查修复子代理，以便降级措辞不漏。
4. 作为用户，我希望冲刺模式不能放行"对抗 Critical 未清零"，以便 Critical 门不被架空。
5. 作为用户，我希望免审豁免明写不含对抗审查，以便豁免边界无歧义。
6. 作为读者，我希望走查环归属措辞（六道后）与归档惯例（同周期作废 git 留痕、跨周期 acceptance-c<N>）各归其位，以便术语与输出全留原则一致。
7. 作为执行者，我希望环境步明写"记 tracker 证据"、自检覆盖对抗审查行，以便留证与自检无死角。
8. 作为读者，我希望"docs/ 只读登记、不自动扫目录"护栏明示、requirements 概述含参考资料，以便防过度供给有明文。
9. 作为维护者，我希望对抗契约/职责判据权威定义唯一、160 命名常量，以便改一处即可。

## Implementation Decisions

- FN-LADDER 单写者句改："tracker 由主会话单写者维护；**并行子代理不写账本**。例外：走查修复环显式派生的执行子代理是**串行单写链条的延伸**（按 owning 技能纪律记账、逐处留证）"。
- FN-LADDER 越界条款补："fn-close 用户走查环的修复经显式子代理执行 fn-implement（owning 规则）属**快速修复通道**（仅限走查发现的实现问题，逐处留证 + scoped 复走查），不属越界"。
- FN-LADDER fn-doc-lint 描述补长职责点名；环境隔离区括注等价机制按生态惯例（uv/conda/nvm 等）。
- fn-implement：环境步补"记 tracker 证据"；批间门补"对抗审查不在免审豁免范围"；冲刺例外补"**对抗 Critical 未清零不随冲刺放行**"；出门自检"经用户选择或已完成（对抗审查=报告+Critical 清零）或有豁免行引用"。
- fn-close：走查环走查句引用 FN-LADDER 子代理④对抗契约（消三处重复）；第 4 步归档措辞澄清（同周期重写旧版作废 git 留痕；跨周期才归档 acceptance-c<N>）。
- fn-grill：requirements 概述句补"参考资料"。
- README.zh-CN「用户走查环（终检）」→「用户走查环（六道后）」。
- fn-doc-lint：`DUTY_LEN_LIMIT = 160` 命名常量（注释指向 fn-divide 判据）。
- INSTALL：Golden rule 3 / Class 4 派子代理清单补 fn-close（走查/修复）、fn-implement（对抗审查）。
- 走查环清零阈值明写进上游规格（Critical/Important 清零、Minor 留档）。

## Testing Decisions

- 接缝不变；无新机械规则（160 常量为重构非行为变更），fn-selftest 9/9 保持即验证。
- 回归防线：release.sh --check。

## Out of Scope

- 重设计走查修复环（Q7 定案不动）；acceptance 归档惯例改造（沿用既有同周期/跨周期区分）。

## Further Notes

- 修完回写上游两规格的修订记录；CHANGELOG 2.2.1 补变更小节。
