# Installing fn-ladder on non-ZCode clients

> **This document is written for your installing agent.** Give it to the agent and let it execute.
> 本文件是给「你的安装代理（agent）」执行的适配说明书，中文版见文末。

fn-ladder is built for **ZCode first**. Its skill bodies deliberately keep ZCode idioms (hard-gate exit prompts in `/fn-xxx` form, subagent dispatch, plugin-root script paths). **Never modify the source repository to fit another client.** Instead, perform a one-time **copy-and-patch** install: copy the skills into your client's skill directory, then patch the *copies* per the checklist below. The source repo stays pristine; `git pull` there keeps working as the upstream.

## Golden rules

1. **Patch copies only.** Every edit in this guide targets the files inside your client's skill directory. If you find yourself editing the fn-ladder repo, stop.
2. **Names and semantics are frozen.** Keep skill names (`fn-grill` … `fn-quick`) and all workflow semantics (five stages, hard gates, four-state criteria, exit protocol) unchanged. Patches adapt *client-specific syntax and paths* only.
3. **Subagent capability assumed.** fn-implement / fn-analyze / fn-review dispatch subagents (reconciliation, per-function implementation, review, data pull). If your client can dispatch subagents or tasks, apply Class 4 patches as written. If not, apply the Class 4 fallback.

## Step 1 — Place the skills

Clone this repository anywhere, then copy **every `skills/fn-*/` directory** and the file **`FN-LADDER.md`** into your client's skill directory:

| Client | User-level skill dir | Project-level skill dir | Skill invocation syntax |
|---|---|---|---|
| Claude Code | `~/.claude/skills/` | `.claude/skills/` | `/fn-grill` |
| Codex CLI | `~/.agents/skills/` | `.agents/skills/` | `$fn-grill` |
| Gemini CLI | `~/.gemini/skills/` or `~/.agents/skills/` | `.gemini/skills/` or `.agents/skills/` | `/skills` → activate `fn-grill` |
| Cursor | `~/.cursor/skills/` or `~/.agents/skills/` | `.cursor/skills/` or `.agents/skills/` | skill named `fn-grill` |
| opencode | `~/.config/opencode/skills/` or `~/.agents/skills/` | `.opencode/skills/` or `.agents/skills/` | skill named `fn-grill` |
| Any Agent Skills–compliant client | `~/.agents/skills/` | `.agents/skills/` | per client |

Keep the flat layout: `<skill-dir>/fn-grill/SKILL.md`, not nested categories.

## Step 2 — Patch the copies (five classes)

### Class 1 — Script paths

The skill bodies call repo-root scripts with the phrase `插件根 scripts/…（本技能目录上两级）`. The scripts do not travel with a skill-only install, so **vendor them into each skill that references them**:

| Skill | Scripts to copy into `<skill>/scripts/` |
|---|---|
| fn-implement | `fn-check.sh` |
| fn-close | `fn-check.sh`, `fn-doc-lint.py` |
| fn-review | `fn-check.sh`, `fn-doc-lint.py` |
| fn-analyze | `fn-check.sh`, `fn-doc-lint.py`, `fn-score.py`, `fn-commit.sh` |
| fn-grill | `fn-commit.sh` |
| fn-quick | `fn-commit.sh` |

(If unsure, copy all four scripts into every skill — total ~470 lines, harmless.)

Then, in each patched SKILL.md copy, rewrite the path phrase:

- `插件根 \`scripts/fn-check.sh\`（本技能目录上两级）` → `本技能目录 \`scripts/fn-check.sh\``
- same for `fn-doc-lint.py`, `fn-score.py`, `fn-commit.sh`
- bare mentions of `fn-commit.sh`（如「`fn-commit.sh` 落痕」） stay valid once the file sits in `<skill>/scripts/`; optionally clarify to `scripts/fn-commit.sh`.

Run scripts as `bash scripts/fn-check.sh` / `python3 scripts/fn-doc-lint.py` from the skill directory. Note: `fn-doc-lint.py` validates Chinese section names in `fn_docs/` artifacts — its output language is part of the workflow, leave it as is.

### Class 2 — FN-LADDER.md location

Several skills reference `FN-LADDER.md` by bare name (lightweight-line spec, mid-entry protocol, evolution-cycle rules). Copy the repo-root `FN-LADDER.md` **into every skill directory** (next to each SKILL.md). Its body stays Chinese and unchanged — it is the normative hub.

### Class 3 — Exit-protocol invocation syntax

Every skill ends with a hard gate: 「下一步命令 `/fn-xxx`，或修订本步骤」. Rewrite the slash syntax to your client's skill invocation form in the copies:

| Client | Replace `/fn-grill` etc. with |
|---|---|
| Claude Code | `/fn-grill`（personal/project skills — unchanged；若经插件安装为 `/插件名:fn-grill`） |
| Codex CLI | `$fn-grill` |
| Gemini CLI / Cursor / opencode / generic | `fn-grill`（"invoke the skill named fn-grill"） — e.g. 「下一步技能 fn-grill（按当前客户端的技能调用方式调用）」 |

Keep the gate semantics exactly: present results, **stop**, offer the two options (next skill / revise this step), do not proceed without the user's explicit choice.

### Class 4 — Capability wording

If your client **has** subagent/task dispatch: no change needed.

If it **lacks** subagent dispatch, rewrite in the copies:

- 「派子代理」「子代理」→ 「在当前会话内执行同等步骤（只带精制上下文：文档路径、代码路径、上一验收点，不带整段会话史）」
- fn-implement 批间句「可 `/clear` 或压缩后新开会话」→ 「可新开会话（或使用当前客户端的长上下文处理方式）」

The four-part subagent conclusion contract (判据判定表 / 关键读数 / 异常与限界 / 建议) is plain text — keep it regardless.

### Class 5 — Paths you can ignore

`~/.zcode/skills/` and `install.sh` are ZCode-only installation machinery. Do not copy `install.sh`, `.zcode-plugin/`, or `marketplace.json` into your client's skill dir — they are repo-level files and harmless to leave behind.

## Step 3 — Acceptance

1. Your client's skill list shows all 11 `fn-*` skills.
2. Invoke `fn-grill` with a small feature idea: it should start the requirements interview and end by stopping at the hard gate with two explicit options.
3. From any patched skill directory, `bash scripts/fn-check.sh` resolves and runs (exit code may be non-zero on a non-fn-ladder working dir — the point is the script is found).

Done. Use `/fn-grill` for new tasks, `/fn-refactor` for legacy projects, `/fn-merge` for merging fn-ladder projects.

---

# 在非 ZCode 客户端安装 fn-ladder（中文版）

> **本文件交给你的安装代理（agent）执行。** 以下为英文版的完整对照。

fn-ladder 以 **ZCode 体验为先**：技能本体刻意保留 ZCode 惯用法（`/fn-xxx` 出口硬门、子代理调度、插件根脚本路径）。**绝不为其他客户端修改源仓库**，而是做一次性的**复制 + 修补**安装：把技能复制进目标客户端的技能目录，再按下述清单修补**副本**。源仓库保持原样，`git pull` 继续作为上游。

## 铁律

1. **只改副本。** 所有修改都发生在目标客户端技能目录内；发现自己在改 fn-ladder 仓库时立即停手。
2. **名称与语义冻结。** 技能名（`fn-grill` … `fn-quick`）与全部流程语义（五阶段、硬门、四态判据、出口协议）不变；修补只针对**客户端相关的语法与路径**。
3. **子代理能力为默认假设。** fn-implement / fn-analyze / fn-review 会派子代理（对账、逐函数实现、评审、拉数据）。客户端支持派生子任务时，Class 4 无需改动；不支持时按 Class 4 降级。

## 第一步——放置技能

克隆本仓库后，把**全部 `skills/fn-*/` 目录**与 **`FN-LADDER.md`** 复制进目标客户端的技能目录（各客户端路径与调用语法见英文版表格）；保持扁平布局 `<技能目录>/fn-grill/SKILL.md`。

## 第二步——修补副本（五类）

- **Class 1 脚本路径**：按英文版的「技能 → 所需脚本」表把仓库根 `scripts/` 的脚本复制进各技能的 `scripts/`，并把「插件根 `scripts/xxx`（本技能目录上两级）」改写为「本技能目录 `scripts/xxx`」。`fn-doc-lint.py` 的中文输出是流程的一部分，不要翻译。
- **Class 2 FN-LADDER.md**：复制进**每个**技能目录（与 SKILL.md 同级），正文保持中文原样——它是规范中枢。
- **Class 3 出口语法**：把「下一步命令 `/fn-xxx`」的斜杠语法改写为客户端的技能调用形式（Claude Code 不变/插件名为 `/插件名:fn-xxx`；Codex 为 `$fn-xxx`；其余写「下一步技能 fn-xxx」）。硬门语义原样保留：呈现、**停**、二选一、用户未选不推进。
- **Class 4 能力措辞**：客户端无子代理能力时，「派子代理」改为「在当前会话内执行同等步骤（只带精制上下文，不带整段会话史）」；「可 `/clear` 或压缩后新开会话」改为「可新开会话」。子代理结论契约（四段）是纯文本约定，一律保留。
- **Class 5 可忽略**：`install.sh`、`.zcode-plugin/`、`marketplace.json` 是 ZCode 专属安装件，不要复制进技能目录。

## 第三步——验收

1. 客户端技能列表可见 11 个 `fn-*` 技能；
2. 调用 `fn-grill`，应开始需求逼问，并在出口处停下给出两个显式选项；
3. 在任一技能目录内 `bash scripts/fn-check.sh` 能找到并运行脚本（非 fn-ladder 工作目录下退出码非零是正常的，验收点是脚本可解析）。

完成后：新任务 `fn-grill` 起步，存量项目 `fn-refactor`，多项目合并 `fn-merge`。
