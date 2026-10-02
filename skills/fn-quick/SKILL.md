---
name: fn-quick
description: Use for lightweight-line work (parameter-level or single-function surgery) or when fn-quick is invoked — since v1.6 the lightweight line is built into fn-grill/fn-analyze, so this entry is a compatibility router that runs the lightweight line and suggests the grill/analyze entries. Also use when the user mentions fn-quick, lightweight, quick fix, or one-line surgery. 当需要轻量线（参数/单函数手术）或收到 fn-quick 调用时使用——轻量线 v1.6 起内置 fn-grill/fn-analyze，本入口为兼容路由：按轻量线执行并提示改用 grill/analyze 入口。用户提到 fn-quick、轻量、快速改一下、单行手术时也用。
license: MIT
---

# fn-quick：轻量线兼容入口（v1.6 起退役为路由）

轻量线已**内置到 fn-grill（小任务分支）与 fn-analyze（参数级提案分流）**，不再单独开线。本入口保留兼容：收到调用时——

1. 报告首行标注**【轻量线】**（线别显式声明是铁律），并提示用户后续从 `/fn-grill`（小任务分支）或 `/fn-analyze`（参数级提案）进入；
2. 按 FN-LADDER.md **轻量线（v1.6）**节执行三步：快问（目的一句话+验收一条，经用户确认）→ 实现+核验（跑验收命令贴输出）→ `fn-commit.sh` 落痕；
3. 超载（牵出多函数/新结构/需求不清）或两轮核验不过 → 停，升【全量线】（`/fn-grill`）或转 `/fn-brainstorm`。

## 出口

三步完成后**停**，显式提示两项：**继续下一个轻量项**，或**升全量线（`/fn-grill`）**——改动比预想大时；用户未显式选择前不推进。

## 红旗（出现即停）

| 念头 | 现实 |
|---|---|
| "改着改着牵出第三个函数了" | 超载即升全量线，轻量线不硬撑 |
| "验收回头补" | 判据先行是唯一不降的纪律 |
| "这么小不用 commit 了吧" | fn-commit 落痕是轻量线的唯一仪式 |
| "兼容入口就是老规矩，照旧独立跑" | 独立线已退役——线别必须声明、路由必须回 grill/analyze |
