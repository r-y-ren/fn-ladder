---
name: fn-implement
description: Use when function skeletons (unimplemented:fn stubs) are in place and functions must be implemented one by one — fn-ladder stage 4 (bottom-up batch implementation), tracking the per-function four-state list. Also use when the user mentions fn-implement, start implementing, or continue a fn-ladder task. 当函数骨架（unimplemented:fn 桩）已就位、需要逐函数实现时使用——fn-ladder 流程第四阶段（分批自底向上实现），维护函数级四态实现清单。用户提到 fn-implement、开始实现、继续实现某个 fn-ladder 任务时也用。
license: MIT
---

# fn-implement：分批自底向上实现（fn-ladder 第④阶段）

按批次自底向上逐函数实现。**本阶段文档产出物是 implementation 四文档**（`fn_docs/implementation/` 下 `batches.md` 批次表 / `functions.md` 函数大表 / `history.md` 历史表 / `tracker.md` 步骤账本），本阶段是它们唯一的写入者（tracker 豁免行例外：由 fn-exempt 写入，见豁免协议）；**responsibility.md 与 requirements.md 只读**。**tracker 是步骤级执行账**：每步"预告 → 执行 → 证据+读回"、完成行经插件根 `scripts/fn-step-done.sh`（本技能目录上两级）核验绿才落账；执行以账本**第一个未勾行**为当前步。函数状态只记 functions.md——tracker 不存状态词（双真值边界）。

## 进入：先对账，再干活（五步按序做完才许动手）

**五步逐条执行、每步留证**（前置产物清单 / 对账结论报告 / 批次计划），五步同步进 tracker「进入五步」节逐行勾记；缺任何一步 = 停在原地补做；禁止以"我记得进度"跳过第 2 步对账。

1. 检查前置：`responsibility.md` 在、桩代码在位。缺 → 停，指回前序阶段。
2. **轻量对账（派对账子代理）**（新会话/压缩/中途接手必做）：派子代理运行插件根 `scripts/fn-check.sh`（本技能目录上两级，用法见脚本头）并对照 functions.md 函数大表，主会话只收结论报告（按**子代理结论契约**四段：判据判定表 / 关键读数 / 异常与限界 / 建议——见 fn-analyze）——对账输出不进主上下文，子代理无立场偏见。**对不上先修文档再干活**（重建真值：history.md 留痕 + git log + 核验命令复跑定四态），防止上个会话的谎报传染。**恢复协议**：先读 tracker 首行身份行，与 batches.md / functions.md / git log 三方对账——已勾行 = 已完成不重做，从**第一个未勾行**继续；**账本与 git 压倒记忆**，禁止凭印象重做或跳行。
3. 四文档不存在 → 先做批次计划（见下）；存在 → 走恢复协议从真实位置继续。
4. **中断恢复**：突然中断的批次必仍在批次表（未入历史表）→ 直接按该批次重做；对账中证据可复跑（commit 在、核验命令重跑通过）的函数不必推倒，其余按其标注状态重做。批次不会因中断丢失或被跳过。
5. **功能演进模式**（fn_docs 有 acceptance.md，规则以 FN-LADDER.md 功能演进周期为准）：新一轮批次 **B 编号续号**（不重头编）、历史表保留旧周期记录；上周期之后的手动改动先经轻量对账暴露，漂移重大时建议转 `/fn-review`。

## 批次计划（垂直切片）

- 每个顶层函数的子树一批：自底向上实现完该子树 → 顶层函数 wired = 一个功能口可验收，每批都有可验收增量。
- 单批函数数上限 8，超限则子树内部按层切半。
- 批表门口由用户选执行档位：**主会话连续 / 子代理逐函数**（单批 ≥6 函数建议子代理档——每函数带紧凑提示：职责块 + 桩位置 + 核验命令，派子代理实现；主会话只做调度、贴输出、改状态、把门。**报告不是证据**：子代理回报必附命令输出原文，无原文不予记账）。
- 批次表 + 函数级清单 + tracker 初始账本（进入五步节 + 各批函数五步行——七步的前五步各占一行，第 6/7 步是流程控制步不落行）写盘后呈现，**停在门口等用户批准**。

```markdown
# batches.md —— 批次表（待办导航）
> fn-implement 独占更新。▶ = 下一批要完成的任务；未经批间门批准不得增删批次内容。

| 批次 | 函数/任务清单 | 验收点 | 注 |
|---|---|---|---|
| ▶ B2 | transform_rows, export_report | export_report wired + 实跑 | 含新增改动：修复 parse_and_load 边界 |
| B3 | shared/format_output | format_output wired | |

（每完成一个批次：该批从本表移除、尾部追加进 history.md；四文档同批更新并**读回贴出改后行**——脚本打印成功不算写入证据）

## 变更记录（计划层事件：签名微调、需求变更往返、放弃等）
| 日期 | 事件 | 说明 |
|---|---|---|
```

```markdown
# functions.md —— 函数级实现清单（唯一状态真值）
> fn-implement 独占更新。**代码是真值，本表只是导航。**
> **改任何状态前必须先跑核验命令、在对话中贴出输出，绿了才许改。**
> **改后读回贴出改后行（读回断言）：脚本/命令打印成功不算写入证据，落盘的字节才算。**

| 函数 | 批次 | 状态(日期) | 核验命令+摘要 | commit |
|---|---|---|---|---|
| check_encoding | B1 | wired 09-21 | pytest -k encoding → 2 passed | a1b2c3 |
| validate_header | B1 | tested 09-21 | pytest -k header → 3 passed | — |

（状态：stub / implemented / tested / wired 日期 / blocked: 一句原因；
全函数平铺、按依赖序，不按批分组）
```

```markdown
# history.md —— 历史表（已完成批次队列，只追加不删改）
> fn-implement 独占更新。每批次完成后尾部追加留痕。

| 完成日期 | 批次 | 任务/函数清单（含操作与来源说明） | 验收摘要 |
|---|---|---|---|
| 09-21 | B1 | check_encoding, validate_header | 全绿；parse_and_load 实跑通过 |
```

```markdown
# Implement tracker — fn_docs — 计划: batches.md — 真值: functions.md + git log
> fn-implement 独占更新；**主会话单写者**（子代理只回报证据原文，记账在主会话）。
> **执行以第一个未勾行为当前步**；每步三段式：预告 → 执行 → 证据+读回。
> **完成行经 scripts/fn-step-done.sh 写入**：核验 exit 0 才记账、失败零写入、写完读回。
> 本账本不存函数状态词（状态真值在 functions.md）。

## 进入五步
- [ ] 1 前置检查 — 预告: responsibility.md 在、桩在位
- [ ] 2 轻量对账 — 预告: fn-check + 三方对账（身份行/git/清单）
- [ ] 3 批次计划 — 预告: 四文档初建或恢复协议续走
- [ ] 4 中断恢复检查 — 预告: 批次表无滞留批
- [ ] 5 功能演进判定 — 预告: 有无 acceptance.md

## B1 — check_encoding, validate_header
### check_encoding
- [ ] check_encoding · implemented — 预告: 桩替换为真值，预期 fn-check 桩 grep 无残留
- [ ] check_encoding · tested — 预告: 自有单测绿，预期 pytest → passed
- [ ] check_encoding · wired — 预告: 调用点存在，预期 grep 命中
- [ ] check_encoding · 清单进位 — 预告: functions.md 状态行改后读回
- [ ] check_encoding · commit — 预告: fn(check_encoding): wired 含四文档变更
### validate_header
（同构五行）

## B1 批间门
- [ ] B1 · 评审三轴 — 预告: 规格/标准/档案同步（含 tracker 本批行核对）
- [ ] B1 · 用户裁决 — 预告: 继续 B2 / 修订 / 裁决 blocked

（Ruling 行与豁免行尾部追加、逐行读回：
- Ruling: <偏离内容> — 原因 — 代价 — 落点
- X1: <类型> | 范围: 单门/本批/剩余全部 | 对象: <技能·门> | 原因 | 剩余: N | 状态: active/consumed）
```

## 批内循环（七步是每个函数的强制循环，逐函数走满）

**每个函数都要完整走满这七步，走满才轮到下一个函数**；禁止攒一批函数一起测、禁止跳过 `tested` 直奔 `wired`、禁止"这个函数太简单"压缩任何一步。**七步的前五步各占一行 tracker**（第 6 步是推进规则、第 7 步落 blocked 注记，不占行），每行三段式推进：预告（目标/动作/预期）→ 执行 → 证据+读回；完成行一律经插件根 `scripts/fn-step-done.sh`（本技能目录上两级）写入——核验 exit 0 才记账、失败零写入、写完读回；无 done 行 = 该步未做。每步的证据（测试输出 / grep 结果 / commit）当场贴出。

取**依赖已就绪的最深**未完成函数（自底向上 = 实现某函数时它调用的下层全部就绪，单测可真跑；"当前函数"由 tracker 第一个未勾行指认）：

1. `<函数> · implemented` 行：桩被真实实现替换。
2. `<函数> · tested` 行：叶子函数必须自有单测且绿；中上层可标"上游覆盖"并指向具体测试名。
3. `<函数> · wired` 行：静态调用点存在（grep/ast-grep 可验）；顶层入口函数实跑一次、有可观察输出。
4. `<函数> · 清单进位` 行：**每次改清单状态前，先跑核验命令、把输出贴进证据列，绿了才许改；改完读回贴出改后行（读回断言）——脚本/命令打印成功不算写入证据**。
5. `<函数> · commit` 行：`fn(<函数名>): wired`，同 commit 包含 implementation 四文档的变更——git log 成为第二进度真值。**时序**：前四步行的 done 行与该函数 commit 同批落账；`· commit` 行例外——它的证据就是该 commit，提交完成后勾记。**用户接管 commit 须经 `/fn-exempt` 记账**（豁免类型: 接管 commit），无豁免行照常自动 commit。分支默认不开、在当前分支做；需隔离时由用户在 fn-grill 门口声明，分支名 `fn-<日期>`。
6. 下一个函数：回 tracker 取下一个未勾行。批内连续推进，用户可随时插话。
7. 卡死（同一函数两轮仍无法实现或测试不过）→ 该步不勾行、行下注记 `— blocked: <原因> (<日期>)`，清单标 `blocked` + 原因，跳到下一个不依赖它的函数；批间门集中报告 blocked 项由用户裁决（改需求 / 回 fn-divide 换方案 / 授权绕过）。**禁止静默跳过。**

**与预期不符三态**（防"将就着改到输出像对的"）：核验输出与预告预期不符时只有三条正路——**匹配**继续 / **代码错**（修代码，禁止改症状凑输出）/ **计划错**（tracker 记 Ruling 行：偏离+原因+代价+落点，改计划继续）。禁止静默偏离。

## 批间硬门

每批验收点达成 → 先派**评审子代理**三轴审查本批 diff（规格轴：对照责任文档的职责/签名意图/树外改动；标准轴：桩标记/命名/目录规则；**档案同步轴**：本批完成项与 implementation 四文档（三文档 + tracker 本批行）逐一对照——functions.md 状态已进位、批次已从 batches.md 移入 history.md、tracker 本批各行已勾且证据在，且改后内容已读回贴出；档案没动或无读回证据 = 不过门——防 no-op 静默漂移。**三轴审查无有效豁免行不得跳过**——免审豁免走 `/fn-exempt`；免审时**批间报告仍须报四文档同步情况**），报告（结论契约四段）随汇报附上 → **停，显式提示三项：继续下一批 B<N>（说"继续"即可）/ 修订本批产物 / 裁决 blocked 项**；用户未显式选择前不推进。批间是天然会话边界：可 `/clear` 或压缩后新开会话，靠轻量对账无缝续批。**带病禁行**：存在未裁决 blocked 项或未过核验的步骤行时，不许进下一批。**冲刺例外**：存在 `/fn-exempt` 冲刺豁免行（见 fn-analyze）时批间门降为"门不停人"——过门自动续，核验/证据/读回/记账照跑照贴。
**预授权连做**：仅当存在 `/fn-exempt`"剩余全部"豁免行（用户字面"剩下的批次不用等我"经宣告+记账）才可连做；模糊的"继续"只解锁当前批次；批间报告照发。

## 漂移三则（防静默偏航）

- **签名微调**（参数名、可选参数）：代码即真值，responsibility.md 的签名意图本就是意图级描述，不用改它；在 batches.md 变更记录登记 + tracker 记 Ruling 行（偏离+原因+代价+落点；两处互指不复制）。**未记账的偏离 = 私自决策，审计轴点名。**
- **结构性变化**（函数增/删/拆/并/职责或调用关系变化）：**停**，回 fn-divide 改 responsibility.md（可走一次确认式快速通道），回来更新清单再继续。
- **计划外现有代码（树外）改动：未经批准一律禁止**（含机械清理）。发现 → 作为新任务加入批次表下一批次、注明"新增改动" → 批间门经用户批准后随批实施。每步责任必须分明。

## 需求变更

停下 → 变更经 fn-grill 语义记入 requirements.md 变更记录 → fn-divide 重算受影响子树 → 回本阶段更新清单。

## 红旗（出现即停）

| 念头 | 现实 |
|---|---|
| "这个函数太简单，跳过测试" | 四态无捷径，简单函数的测试最便宜 |
| "先都实现完再一起测" | 攒批测试 = 假完成温床 |
| "新函数顺手直接写了" | 未进责任文档的函数 = 死代码候选，必须回 fn-divide |
| "状态我记得，不用对账" | 对话记忆不可靠，盘上核验才算数 |
| "步骤太多，这行跳了吧" | tracker 第一个未勾行 = 当前步；跳行 = 无证据未做，出门逐行指认必露 |
| "脚本跑了就算记账了吧" | 失败不记账：fn-step-done 绿了才写行，写完还要读回 |
| "免审吧（随口一说）" | 豁免唯一入口 /fn-exempt：先宣告"开始执行 /fn-exempt"、后记账，无豁免行 = 不得跳门 |
| "计划有点不对，我顺手改了" | 计划错走 Ruling 行（偏离+原因+代价+落点）；静默偏离 = 私自决策 |

**出门前自检（逐行指认 tracker 证据，缺一不许出门）**：进入五步节全勾且各行证据在？每函数五步行全勾（七步的前五步）、证据列有命令输出？blocked 项已登记（functions.md + tracker 行下注记）并上报？批间门各行都经用户选择或有豁免行引用？——**逐行报出证据位置**，任一缺 = 回去补做。

全员 wired → **停，显式提示两项：下一步命令 `/fn-close`，或修订**。
