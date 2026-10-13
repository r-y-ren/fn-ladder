# Spec: v2.2.2 双轴审查修复（六要素残留 / 轻量线同步 / 白名单对齐 / 模板冻结）

- 日期：2026-10-13
- 来源：code-review 双轴（Standards 4 硬违规 + 3 判断题；Spec 2 缺失 + 2 未逐字）
- 上游：2026-10-13-adversarial-prompt-governance.md（修完回写）

---

## Problem Statement

提示词治理落地后，审查发现：术语更新漏改活文档（fn-close 使用手册头注残留旧清理措辞）且未登记退役表；轻量线改中枢后路由文档（fn-grill/fn-analyze/fn-quick/README.zh-CN）仍旧三步（fn-quick 自相矛盾）；INSTALL 的机械替换会改坏冻结模板且无子代理降级方案；模板槽位白名单与实槽不对齐、claims 固定措辞 fn-close 未逐字。

## Solution

活文档术语对齐 + 退役表按精度惯例登记精确残句；轻量线四文档同步为"实现+核验+对抗审查"；模板题源槽位化（轻量线可用同一模板）+ 白名单与实槽一一对齐（含 claims/输出补充）；fn-close claims 恢复逐字固定句；INSTALL Class 4 增"模板冻结豁免 + 无子代理降级（独立上下文扮演审查者，报告注明独立性弱化）"。

## User Stories

1. 作为维护者，我希望旧清理措辞在活文档零残留并进退役表（历史条目按精度惯例豁免），以便术语回不了头。
2. 作为使用者，我希望 fn-grill/fn-analyze/fn-quick/README 的轻量线描述与中枢一致（含对抗审查），以便 fn-quick 不再自相矛盾。
3. 作为轻量线执行者，我希望模板题源是槽位（默认 requirements/responsibility，轻量线填快问两件），以便同一模板两类场景照抄可用。
4. 作为安装代理，我希望 Class 4 明文"冻结模板不参与机械替换"，以便修补不改坏模板。
5. 作为无子代理客户端用户，我希望有明文降级方案（独立上下文扮演审查者 + 报告注明独立性弱化），以便不至于静默丢失对抗审查。
6. 作为读者，我希望白名单与模板实槽一一对齐（对象/路径/运行方式/题源/claims/输出补充），以便治理约束自身无歧义。
7. 作为审计者，我希望 claims 固定降级句在两份模板逐字一致，以便降级措辞不可各写各的。

## Implementation Decisions

- fn-close user-guide 模板头注旧清理措辞（尾词为"临时物"的那句）改为"临时件落 /tmp、无需清理"；release.sh 退役表登记该旧句的精确形态防回归（历史条目 CHANGELOG 2.2.1 已发布档案不改写——按该表精度惯例处理，勿在新文档引用旧句原文）。
- fn-grill 小任务分支、fn-analyze 轻量线分支、fn-quick 步骤 2 与描述、README.zh-CN 轻量线句：三步枚举统一补"对抗审查"；fn-quick 补"派发词照 fn-implement《对抗审查派发模板》原文照抄、对象收窄本轻量项"。
- 模板改造（两份同构）：功能要求出处**槽位化**（默认 requirements 验收方式 + responsibility 职责块；轻量线填"快问的一句话目的+一条验收"；走查填"user-guide 承诺的功能目标"）；输出节加【输出契约补充项（可选）】槽；头注白名单列全六槽（审查对象/工作目录/测试运行方式/功能要求出处/claims/输出补充）；fn-close 模板补"临时件非证据载体"。
- fn-close claims 节恢复逐字固定句"以下均为未经验证的主张，逐条独立复算后对比，不一致先怀疑主张本身"。
- FN-LADDER ④ 禁令恢复全词"夹带假设清单/期望值/结论倾向"；轻量线②补取模板说明（fn-implement SKILL.md 同级可查）。
- INSTALL Class 4：冻结模板豁免（机械替换不得改写派发模板正文块）+ 无子代理降级方案（新开独立上下文扮演审查者执行同套步骤，保留输出契约，报告注明"审查独立性弱化"）。
- README 术语轻微漂移（unverified statements vs 被审主张）判定接受不改（互为译文）。

## Testing Decisions

- 回归防线：release.sh --check（新退役条目生效即验证）+ fn-selftest 9/9 保持；无新机械规则。

## Out of Scope

- 改写已发布 CHANGELOG 历史条目；模板引擎化；分类学清单。

## Further Notes

- 修完回写上游规格（白名单六槽定稿、六要素清理条款措辞）；CHANGELOG 2.2.2 补变更行。
