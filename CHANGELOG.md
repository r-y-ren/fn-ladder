# Changelog

fn-ladder 版本历史（倒序）。自 v2.0.0 起每版对应 git tag `v<x.y.z>`。

## 2.0.0 — 2026-10-02

通用发布（跨客户端），技能本体零改动。

### 新增

- `INSTALL.md`——跨客户端安装适配说明书（中英双语）：交由用户自己的 agent 执行"复制 + 修补"安装（脚本路径内联、FN-LADDER.md 随技能、出口调用语法、子代理能力降级四类修补清单 + 验收步骤），源仓库永不修改
- `LICENSE`（MIT）+ 每技能 frontmatter `license: MIT` 字段
- `README.md`（英文）/ `README.zh-CN.md`（中文）双文件，安装三通道（ZCode 插件 → install.sh 符号链接 → INSTALL.md 其他客户端）
- `CHANGELOG.md`（本文件）与发版 git tag 制度

### 变更

- 技能 description 双语化（英文触发句 + 中文触发句，≤1024 字符），触发覆盖中英文 prompt
- `release.sh` 升级：版本号单一来源（一处输入同步两处 ZCode 清单）、检查扩项（LICENSE、技能 license 字段、CHANGELOG 版本条目）、发版自动打 tag
- 兼容目标扩展：任何支持 Agent Skills 规范的客户端（Claude Code、Codex CLI、Gemini CLI、Cursor、opencode 等）均可经 INSTALL.md 适配使用

### 不变

- ZCode 体验优先：`.zcode-plugin/` 与 `marketplace.json` 双清单、install.sh、全部技能正文（结构/语义/措辞）原样保留

## 1.6.3 — 2026-10-02

审查修复七处：fn-quick 补出口协议、冲刺不可逆动作措辞澄清（对外提交≠git 提交）、粘贴分级补 §6/§7、JOURNAL 线别落痕约定（阶段列=线别）、子代理结论契约上提中枢、fn-quick description 归触发式、README 树形排版。

## 1.6.2 — 2026-10-02

发版机器检查自举：退役术语表 + 技能清单双向一致 + 版本双轨一致（`release.sh --check` 可独立跑）。

## 1.6.1 — 2026-10-02

收官审计修复——17 处漏改清零。

## 1.6.0 — 2026-10-02

冲刺模式（显式授权流水推进，不可逆动作仍需明批）+ 判据再质疑 + 轻量线内置（fn-grill/fn-analyze 各带路由，fn-quick 退役为兼容入口）+ 子代理结论契约（四段）+ 证据强度轴 + 登记即用（数据源当场登记）+ 外发终检（可选第七道）。

## 1.5.0 — 2026-10-02

目录契约：`.scratch/` 暂存区（gitignore、禁系统 /tmp、验收清点升格或删除）+ `vendor/` 拉取物户口（provenance 六字段 + SHA256SUMS + 上游 LICENSE/NOTICE + payload）+ 本地全量保留优先原则。

## 1.4.0 — 2026-10-02

实战复盘三件套：`fn-score.py` 提案登记表打分器 + `registry.jsonl`（哈希定名防撞车）、fn-quick 轻量线入口技能、`fn-commit.sh` 一键落痕（JOURNAL + commit + push）。

## 1.3.2 — 2026-09-22

三个横向技能补标准出口协议：analyze 显式提示 `/fn-grill` 或修订分析；review 显式提示 `/fn-grill` 或到此为止；brainstorm 显式提示分流命令或继续发散。

## 1.3.1 — 2026-09-22

文档全面同步：install.sh 补 fn-review/fn-brainstorm/fn-analyze 三个新技能（修复链接安装漏装 bug）、README 产物树补 analyses/results/归档说明与横向能力行、总览补横向技能行。

## 1.3.0 — 2026-09-22

新增 fn-analyze：结果数据驱动的三轴分析与函数级改进提案，效果闭环打分（防合法假完成）。

## 1.2.4 — 2026-09-22

新增 `release.sh` 发版脚本：一步完成两处版本号 bump + 校验 + 提交推送。

## 1.2.3 — 2026-09-22

fn-brainstorm 补创意接力说明——review(事实)→brainstorm(选项)→grill(定形落盘)，三棒只有 grill 写盘。

## 1.2.2 — 2026-09-22

总览功能演进周期补显式演进链（grill 落盘→divide 增块→scaffold 条件跳过→implement 更新三文档→close 全量归档），消除与散列规则的重复。

## 1.2.1 — 2026-09-22

审查修复：implement 演进判据统一为有 acceptance.md（原"归档"判据会漏识别首个演进周期）；close 澄清归档与原地保留不冲突；brainstorm 绕过记录落点=fn-implement 记 batches.md；grill 定义处置动作；总览清除残词。

## 1.2.0 — 2026-09-22

新增 fn-review（只读双轴审计）与 fn-brainstorm（卡壳发散）技能；五阶段接入功能演进模式（grill 三分支进入检查、文档演化规则、acceptance 周期归档）。

## 1.1.0 — 2026-09-21

新增检查脚本 `fn-check.sh` 与 `fn-doc-lint.py`，技能接入对账/评审/逐函数三类子代理协议，终检脚本化；钩子暂不配置（强制力终点是 workflow 固化）。

## 1.0.0 — 2026-09-21

fn-ladder 首版：七技能 + 总览，五阶段流程与两 on-ramp，八份产物格式闭环。随后改造为 ZCode 插件市场结构（根级 marketplace.json + `.zcode-plugin/plugin.json`，技能移入 `skills/`）。
