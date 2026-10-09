# Spec: code-review 双轴审查修复（tracker + fn-exempt 收尾）

- 日期：2026-10-09
- 来源：code-review 双轴审查（Standards 6 硬违规 + 3 smell；Spec 5 缺失 + 2 相悖 + 2 超范围）
- 上游规格：docs/specs/2026-10-09-tracker-and-fn-exempt.md（本规格是其修订依据，改完后回写该规格）

---

## Problem Statement

v2.2.0 的 tracker + fn-exempt 实现通过了机械检查，但双轴审查发现：规则层存在自相矛盾（tracker 写入权、七步 vs 五行计数、脚本清单漏登、术语漂移），且上游规格承诺的验收接缝（lint 五节/豁免行全字段/git 三方/散句残留检索/行为断言道次）有一半未落地——恰好削弱本次改动要治的"静默漂移"。

## Solution

逐条修复：规则矛盾以"单一真值 + 分口明确"消解；缺口以"补机械校验 + 立验收道次脚本"兑现；超范围项收编进规格；与实作相悖的规格条文按实作回改。验收接缝不变：fn-doc-lint 扩展仍是唯一 lint 接缝，行为断言并入新建的 fn-selftest 验收道次。

## User Stories

1. 作为维护者，我希望 tracker 写入权在所有权表分口明确（步骤行归 fn-implement、豁免行归 fn-exempt、Ruling 随执行记账），以便越界写入判定不自相矛盾。
2. 作为维护者，我希望总纲脚本清单与实际脚本集一致，以便使用者找得到 fn-step-done。
3. 作为执行代理，我希望"七步/五行"口径全文统一（七步前五步各占一行，第 6/7 步不落行），以便照账本执行不再计数错乱。
4. 作为使用者，我希望"四文档"与豁免五类在全部文档里指称一致，以便中英文档互为对照成立。
5. 作为安装代理，我希望 INSTALL 改写锚与技能实文逐字对得上，以便修补可机械执行。
6. 作为维护者，我希望有一条可重跑的验收道次（fn-selftest）覆盖 lint 与 fn-step-done 行为断言，以便"验收接缝"不只是规格里的承诺。
7. 作为审计者，我希望 lint 校验 tracker 五节齐全与豁免行全字段（类型/对象/剩余/范围/状态），以便残缺账本当场报错。
8. 作为审计者，我希望 git 侧三方对账以警告级存在（接管 commit 豁免可改写文案），以便不误伤豁免场景又不漏看。
9. 作为发版者，我希望旧豁免散句进退役术语表，以便回归即被 release.sh 拦截。
10. 作为读者，我希望豁免行 schema 全仓唯一（`- X<n>:`），以便 spec/lint/模板/脚本四方咬合。
11. 作为执行代理，我希望 commit 行时序写清楚（其余四步行与函数 commit 同批落账，commit 行提交后勾记），以便"同刻"不再被误读。
12. 作为用户，我希望豁免撤销/误触停/merge 旧账不搬运被规格正式承认，以便这些行为不再是"无据的善意超纲"。

## Implementation Decisions

- **S1 所有权分口**：所有权表 tracker 行改为——步骤行/清单进位由 fn-implement 记账；**豁免行由 fn-exempt 写入**；Ruling 行随执行记账（豁免协议节背书）。不改"越界写入即违规"总则，只开明确分口。
- **S2 脚本清单**：总纲"检查脚本与子代理"补 fn-step-done.sh 条目；fn-doc-lint 职责句补 tracker 一致性。
- **S3 七步/五行口径**：全文统一为"七步的前五步各占一行（implemented/tested/wired/清单进位/commit）；第 6 步是推进规则、第 7 步落 blocked 注记，不占行"。改 fn-implement（"七步空行"→五步行、"每步=一行"→前五步各占一行、出门自检"七步行全勾"→五步行全勾）与 fn-close（"七步行齐"→五步行齐）。
- **S4 术语统一**：全集指称统一"四文档（三文档 + tracker）"写法（总纲档案同步轴、fn-implement 批间门）；README 双语豁免列表补第五类 analyze 冲刺（横向行 + 技能表）；总纲横向能力行补 fn-exempt。
- **S5 锚语对齐**：fn-implement 的 fn-step-done 引用统一为"插件根 `scripts/fn-step-done.sh`（本技能目录上两级）"，与 INSTALL Class 1 改写锚逐字一致。
- **P1 验收道次 + 散句回归防线**：新建 `fn-selftest.sh`（构造 fn_docs 树：lint 一致态 0 错/漂移态报错/豁免行非法报错/缺节报错 + fn-step-done 失败零写入/成功落账读回/重复记账拒绝，全过 exit 0）；release.sh 退役术语表扩四条旧豁免散句（免审旧句 / 接管 commit 旧句 / 预授权旧称 / 冲刺旧称——均以整句检索，不误伤主题词）。散句检索职责归 release.sh（原规格 Testing Decisions 归位修正）。
- **P2 五节齐全**：fn-doc-lint 补——至少一个批次节（`## B<n>`）、批间门存在、豁免行与 Ruling 行 schema 检查（已有部分）。
- **P3 豁免行全字段**：lint 验类型（五类枚举）/对象非空/剩余整数 + 原有范围档位与状态。
- **P4 git 三方**：lint 在 git 可读时以**警告级**做第三方向对账（wired 函数无对应 `fn(<名>)` 提交 → WARN，注明"接管 commit 豁免可忽略"）——警告级是裁决：commit 文案可被豁免改写，err 级会误伤。
- **P6 schema 唯一**：豁免行 schema 全仓定为 `- X<n>: <类型> | 范围 | 对象 | 原因 | 剩余: N | 状态`（编号 ID 供门行引用与撤销指认）；上游规格按此回改。
- **P7 commit 行时序**：措辞定为"各步行 done 行与该函数 commit 同批落账；`· commit` 行例外——证据即该 commit，提交完成后勾记"。上游规格 US24 同步回改。
- **P8 超范围收编**：撤销机制（consumed + 撤销说明行 = 撤销；consumed 无说明 = 额度用尽）、误触→停、merge 旧账不搬运三条收进上游规格豁免语义/交接语义。

## Testing Decisions

- 好测试 = 只测外部行为：构造树上 lint 的"报错/放行"判定与 fn-step-done 的"写入/零写入"副作用，不测实现细节。
- 接缝不变：fn-doc-lint 仍是唯一 lint 接缝；行为断言并入 **fn-selftest.sh** 验收道次（prior art = 本次会话已手工跑过的三场景断言，固化成脚本）。
- 每条修复至少一条断言覆盖：缺节报错、豁免行非法报错、三方漂移报错、失败零写入、成功读回、重复拒绝。
- 回归防线：release.sh --check（退役术语含新扩四条）。

## Out of Scope

- 不重开设计访谈；不动已通过的硬点（双真值边界、fn-step-done 契约、五类收束、宣告语）。
- 不改 hook 政策、不改 fn-quick。
- spec 发 issue tracker（用户已裁决留本地）。

## Further Notes

- 修复完成后回写上游规格（schema/US24/Testing Decisions/撤销条款 + 修订记录行），CHANGELOG 2.2.0 条目补验收道次与审查修复。
- 退役术语新增四条仅匹配旧散句整句，不误伤"免审""冲刺"等主题词。
