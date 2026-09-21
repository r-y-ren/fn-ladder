# fn-ladder 函数阶梯

以**函数为颗粒度**的 AI 编程开发流技能套件，用来防"AI 假完成"——AI 自称做完，实际漏实现、或函数存在但没接线。

为 ZCode 的 Agent Skills 机制设计（`~/.zcode/skills/`），符号链接方式同样适用于其他兼容技能目录的运行时。

## 流程

```
fn-refactor（存量项目）─┐
                        ├──> fn-grill ──> fn-divide ──> fn-scaffold ──> fn-implement ──> fn-close
fn-merge（多项目合并）──┘    需求打磨      函数划分      结构+骨架       分批自底向上实现    收尾核验
```

每阶段之间是**硬门**：阶段完毕必须显式提示"下一步命令（`/fn-xxx`）或修订本步骤"，用户不点头不推进；on-ramp 只做自身阶段，出口交给正常流程的单个技能。

> **发版纪律**：每次发布提交必须**同步 bump 两处版本号**——`marketplace.json` 的 `plugins[].version` 与 `.zcode-plugin/plugin.json` 的 `version`。只改其一会导致：插件显示旧版本号、或永远提示"可更新"（ZCode 显示的版本取自 plugin.json，更新检测对比 marketplace.json 的版本）。

## 四条不变式（详见 [FN-LADDER.md](FN-LADDER.md)）

1. **代码是真值，文档是导航**——改任何状态标注前必须先跑核验命令、贴出输出。
2. **阶段硬门**——显式提示下一步命令或修订，未选择不推进。
3. **文档所有权分离**——每份文档只有一个写入阶段，其他阶段只读。
4. **中途进入靠对账**——不靠对话记忆，接手时先跑全局核验与文档对账。

## 防假完成机制

- 函数四态判据：`stub → implemented → tested → wired`（叶子必自有单测；wired = 调用点存在、顶层实跑）；
- 需求覆盖矩阵双向拦截：没函数负责的需求 = 漏实现；连不到入口的函数 = 死代码；
- 骨架优先：统一桩标记 `unimplemented:fn:<名>`，剩余工作由代码自己报告；
- 验收报告只贴事实与原始输出，终审归用户；
- **检查脚本**（`scripts/`）：`fn-check.sh`（代码侧三件套）与 `fn-doc-lint.py`（文档侧机械校验：矩阵双向、死代码、状态词、批次一致性）——机械检查交给脚本，不靠模型肉眼；
- **子代理**：对账子代理（隔离对账输出）、批间评审子代理（双轴审查批 diff，可免审）、逐函数实现子代理（可选档，大批发）。

## 任务产物

```
fn_docs/                          # 流程文档（默认随 git 提交）
├── README.md                     # 用户向：工作流程 + 功能（零术语）
├── requirements.md               # 八节：需求、环境决策、术语、验收方式…
├── responsibility.md             # 概览树 + 覆盖矩阵 + 功能块递归分块
├── implementation/               # batches.md（批次表）/ functions.md（状态真值）/ history.md（留痕）
├── inventory.md                  # 仅 merge：已实施清单（代码现状快照）
└── acceptance.md                 # 五道终检事实 + 原始输出
fn_work/                          # 源码：src/（每顶层函数一文件夹 + shared/）+ tests/ 镜像 + 环境依赖
```

## 安装

**方式一（推荐，ZCode 插件）**：Settings → Plugin Management → Discover → `+` 添加市场
`https://github.com/r-y-ren/fn-ladder.git`，安装 **fn-ladder** 插件。

**方式二（符号链接，适合直接改仓库开发）**：

```bash
git clone https://github.com/r-y-ren/fn-ladder.git ~/Code/fn-ladder
bash ~/Code/fn-ladder/install.sh
```

`install.sh` 在 `~/.zcode/skills/` 下为七个技能与总览创建指向仓库的符号链接——源头只有仓库一份，改仓库即生效。**同一台机器二选一**：插件与符号链接并存会导致技能重复。新开会话后 `/fn-grill` 起步（存量项目 `/fn-refactor`，多项目合并 `/fn-merge`）。

## 技能清单

| 技能 | 阶段 | 出口 |
|---|---|---|
| fn-grill | ① 需求打磨（轮次/前沿逼问，必问八条） | `/fn-divide` |
| fn-divide | ② 函数划分（责任文档） | `/fn-scaffold` |
| fn-scaffold | ③ 结构 + 骨架（fn_work/、统一桩） | `/fn-implement` |
| fn-implement | ④ 垂直切片分批、自底向上四态 | 批间门三项 / `/fn-close` |
| fn-close | ⑤ 五道终检 + 验收报告 | 终审归用户 |
| fn-refactor | on-ramp：存量项目（两轮 grill + 快照安全网） | `/fn-divide` |
| fn-merge | on-ramp：多项目合并（inventory → 合并需求 → 汇总责任） | `/fn-scaffold` |
