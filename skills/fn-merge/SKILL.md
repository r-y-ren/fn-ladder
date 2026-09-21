---
name: fn-merge
description: 当需要把多个用 fn-ladder 结构实现的项目合并成一个大项目时使用——fn-ladder 的合并入口（on-ramp）。用户提到 fn-merge、项目合并、合并几个 fn 项目时也用。
---

# fn-merge：多项目合并入口（fn-ladder on-ramp）

把多个 fn-ladder 项目合并进目标工作目录的一个新任务，然后进入正常流程。全程自底向上、**以代码现实现为准**；每一阶段完成后向用户确认并给出建议。

## 前置检查

- 各源项目必须是 fn-ladder 项目（有自己的 `fn_docs/responsibility.md`）；不是 → 先对它走 fn-refactor。
- 目标工作目录由用户指定（新建或选主项目）；**源项目全程只读，一个字节都不改**。

## 阶段一：已实施清单（inventory.md）

**两步生成，顺序不可颠倒**：

1. **代码普查**（此步**禁止参考任何 responsibility.md**）：按源项目分节，扫描代码统计全部实际存在的函数——防止"照抄文档清单"代替真实扫码。
2. **对照原文档**（普查完毕后才开始）：逐函数对照**各自的** responsibility.md（不是汇总版——防漏读），填职责摘要与登记情况，产出 `fn_docs/inventory.md`：

```markdown
# 已实施清单
> fn-merge 独占产出；进入正常流程后只读。
> 以代码现实现为准，禁止照抄任何 implementation 文档——本清单是代码现状快照，不是进度文档。
> 已实现的函数不得无理由删除。

## 统计
| 项目 | 函数数 | 源文档未登记 |
|---|---|---|

## <项目A>
| 函数 | 所属项目 | 位置(路径) | 直接调用方 | 职责摘要 | 源文档登记 | 测试 | 注 |
|---|---|---|---|---|---|---|---|
| format_output | projA | src/export/format_output.py | export_report | 格式化输出行（详见 projA responsibility.md） | 有 | 有 | |
| mystery_fn | projA | src/legacy/x.py | 无调用方 | 职责不明（源文档未登记） | 无 | 无 | |

## <项目B>
（同构）
```

- 节内按该项目源 responsibility 的结构概览序排列；源文档未登记的函数排在该节末尾。
- 职责摘要 = ≤20 字首句摘要 + 指向源文档；重复函数、职责不明的函数**直接在职责摘要列标注**（如"疑似重复：与 projB:foo 同职责"），由实施阶段处理，不设独立差异区。
- 跨项目同名函数的引用键统一为 `项目名:函数名`（如 `projA:format_output`）；行内函数名保持裸名，靠所属项目列区分。
- 测试列 = `tests/` 下存在同名测试文件即"有"。
- 本文件进入正常流程后为只读参考。

## 阶段二：合并需求文档（README.md + requirements.md）

- 新 README.md 与 requirements.md **只参考各源项目对应的 README.md / requirements.md 生成；禁止参考任何代码实现，禁止面向结果生成需求**。
- 汇总版两份文档**末尾附原始项目文件内容原文**：README 附各源 README 原文、requirements 附各源 requirements 原文，逐段标注来源项目、照录不改。
- grill 用户：确认汇总 README 的程序执行流程与功能符合预期；对 requirements 合并中的冲突与缺口逐条提问（机制同 fn-grill：轮次/前沿/推荐答案/通俗解释）。

## 阶段三：汇总责任文档（responsibility.md）

- 汇总各源 responsibility.md 为一份；**记录已实现函数必须对照各自的 responsibility.md，禁止只看汇总版**（防漏读）。
- 同名函数 / 需求重叠 / 接口不一致：全部列入 grill 由用户逐项裁决（保留哪个 / 如何融合 / 丢弃哪个），裁决结果直接体现在汇总后的函数树形态上。
- **函数级操作（修改/重命名等）：不在本文档登记、不在本阶段动手——只记录和安排在新的 implementation.md 里**（由实施阶段对照 inventory.md 与本汇总文档生成）。
- 汇总 responsibility.md **不附原文，只指向原文**：列出各源责任文档的路径引用，不照录内容（与 README/requirements 的附原文规则不同）。

## 出口：本技能到汇总责任文档为止

- inventory → 合并需求 → 汇总责任即本技能的**全部职责**；此后由用户显式逐步调用正常流程的单个技能，本技能不代跑：`/fn-scaffold` → `/fn-implement` → `/fn-close`（责任文档已由本技能产出，跳过 fn-grill/fn-divide；要加全新功能先走需求变更）。
- 汇总 responsibility.md 经用户确认后**停**，显式提示两项：**下一步命令 `/fn-scaffold`**，或**修订本步骤**；用户未显式选择前不推进。

## 交接铁律（执行者为后续 fn-implement）

- 新 implementation 三文档（batches/functions/history）生成时必须对照 inventory.md 与新 responsibility.md，**禁止参考任何旧 implementation 文档**——旧进度文档不是真值，代码与清单才是。
- 对函数的每一次修改/重命名：**实施前作为任务排入新批次表（batches.md）**（注明操作与来源，如"重命名：项目A foo → bar"），完成后进历史表（history.md）留痕。

## 红旗（出现即停）

| 念头 | 现实 |
|---|---|
| "implementation.md 写着都做完了，直接抄" | 进度文档可过期；代码与 inventory 才是真值 |
| "合并需求时看下代码更准" | 禁止面向结果生成需求——需求只来自源需求文档与用户裁决 |
| "小冲突我自己定就行" | 所有冲突裁决归用户 |
| "顺手把源项目也改了" | 源项目只读 |
