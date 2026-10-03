# fn-ladder — the function-ladder skill suite

**English** · [中文](README.zh-CN.md)

An AI coding workflow of **function-granular** skills that prevents "AI fake completion" — the model claims the task is done while functions are missing or never wired up.

Built for **ZCode first** (plugin marketplace / `~/.zcode/skills/`). Other Agent Skills–compliant clients (Claude Code, Codex CLI, Gemini CLI, Cursor, opencode, …) are supported through a one-time copy-and-patch install — hand [INSTALL.md](INSTALL.md) to your agent. The skill bodies keep ZCode idioms on purpose; adaptation happens in your own environment, never in this repo.

## Workflow

```
fn-refactor (legacy project) ─┐
                               ├──> fn-grill ──> fn-divide ──> fn-scaffold ──> fn-implement ──> fn-close
fn-merge (multi-project merge) ┘    requirements   function decomp.  structure    bottom-up batches   close-out
```

Each stage boundary is a **hard gate**: the skill presents its output and **stops**, offering exactly two options — the next command (`/fn-xxx`) or revising this step — and never proceeds without the user's explicit choice. On-ramps (fn-refactor / fn-merge) do only their own stage and hand over to the normal chain. After acceptance you can start an **evolution cycle**: add features to the same project and run the five stages again on the same `fn_docs/` (see [FN-LADDER.md](FN-LADDER.md)).

Lateral skills are available any time, outside the stage chain: `fn-review` (read-only audit) · `fn-brainstorm` (ideation when stuck + criterion re-questioning) · `fn-analyze` (data-driven analysis and function-level improvement proposals, incl. **sprint mode**). Parameter-level / single-function surgery goes through the **lightweight line** (built into `fn-grill`/`fn-analyze`; `fn-quick` remains as a compatibility router).

> **Release discipline** — the version number has a single source: run `scripts/release.sh <version> [note]` to do everything (preflight machine checks → bump both ZCode manifests → JSON validation → CHANGELOG check → commit → tag → push). ZCode displays the version from `plugin.json` and checks updates against `marketplace.json`, so both must stay equal. **Machine checks** (`release.sh --check` runs standalone): retired-terminology zero-residue (retirements registered in release.sh's table), skill list `skills/` ↔ `install.sh` two-way consistency, dual-manifest version consistency, LICENSE + per-skill `license` fields present, CHANGELOG contains the version — any hit aborts the release.

## Five invariants (see [FN-LADDER.md](FN-LADDER.md))

1. **Code is the truth, docs are the navigation** — before changing any status marker, run the verification command and paste its output.
2. **Stage hard gates** — stop and offer "next command or revise"; never advance without an explicit user choice.
3. **Document ownership** — each document has exactly one writing stage; all other stages are read-only.
4. **Mid-entry by reconciliation** — never rely on conversation memory; on resuming, re-run global checks and reconcile against the documents.
5. **Step discipline** — every numbered step list, must-ask checklist, stage sequence and final-check pass is a mandatory sequence: execute each item in order and leave visible evidence, never skip, merge, reorder or claim completion without evidence; before exiting, self-check the list item by item and redo anything lacking evidence.

## Anti-fake-completion mechanisms

- Four-state function criteria: `stub → implemented → tested → wired` (leaf functions need their own green unit test; wired = call sites exist and the top entry actually runs);
- Requirement-coverage matrix blocks both ways: a requirement with no owning function = missed implementation; a function unreachable from any entry = dead code;
- Skeleton-first: unified stub marker `unimplemented:fn:<name>`, so remaining work is reported by the code itself;
- Acceptance reports paste facts and raw outputs only; the final verdict belongs to the user;
- **Effect closed-loop**: acceptance extends to run results — fn-analyze scores each historical proposal's "expected signal" (achieved / missed / reversed), catching the "tests pass but the score didn't move" form of legal fake completion;
- **Check scripts** (`scripts/`): `fn-check.sh` (code-side trio), `fn-doc-lint.py` (mechanical doc validation), `fn-score.py` (proposal-registry scoring), `fn-commit.sh` (JOURNAL entry + commit + push) — mechanical checks go to scripts, not the model's eyes;
- **Subagents**: reconciliation subagent (isolates reconciliation output), per-batch review subagent (tri-axis diff review: spec / standards / doc-sync, waivable), per-function implementation subagent (optional tier for large batches).

## Task artifacts

```
fn_docs/                          # process docs (committed with git by default)
├── README.md                     # user-facing: workflow + features (jargon-free)
├── requirements.md               # eight sections: requirements, terms, acceptance, external deps (incl. result data sources)…
├── responsibility.md             # overview tree + coverage matrix + recursive function blocks
├── implementation/               # batches.md (batch table) / functions.md (status truth) / history.md (log)
├── inventory.md                  # merge only: implemented inventory (code-reality snapshot)
├── analyses/                     # analyze only: analysis reports (hash-named) + registry.jsonl proposal ledger
├── results/                      # analyze only: run-result snapshots (keep all — the AI's error-correction evidence)
├── vendor/                       # third-party pull provenance: six fields + SHA + upstream LICENSE/NOTICE + payload
├── JOURNAL.md                    # running log (appended via fn-commit; any executor may write)
└── acceptance.md                 # six final checks' facts + raw output (old cycles archived as acceptance-c<N>.md)
fn_work/                          # source: src/ (one folder per top-level function + shared/) + mirrored tests/ + env deps
│   └── <lab>/evidence/           # code-adjacent run results (same rule as results/: keep all)
.scratch/                         # staging (gitignored): pulls / big corpora / agent workdirs; no system /tmp; settled at acceptance
```

## Installation

**Option 1 (recommended) — ZCode plugin**: Settings → Plugin Management → Discover → `+` add marketplace
`https://github.com/r-y-ren/fn-ladder.git`, then install the **fn-ladder** plugin.

**Option 2 — symlink (for developing against the repo directly)**:

```bash
git clone https://github.com/r-y-ren/fn-ladder.git ~/Code/fn-ladder
bash ~/Code/fn-ladder/install.sh
```

`install.sh` symlinks the eleven skills and the hub doc into `~/.zcode/skills/` — one source of truth, edits to the repo take effect immediately. **Pick one per machine**: plugin and symlink together duplicate the skills.

**Option 3 — other Agent Skills clients** (Claude Code, Codex CLI, Gemini CLI, Cursor, opencode, …):

- Quick install: `npx skills add r-y-ren/fn-ladder` — installs the skills onto every detected client on your machine. Note that per-skill installs do not carry the repo-root check scripts (`scripts/fn-check.sh` …) or the `FN-LADDER.md` hub; for the full experience run the adaptation below.
- Full adaptation: hand [INSTALL.md](INSTALL.md) to your agent — it copies the skills into your client's skill directory and patches the copies (script paths, invocation syntax, capability wording). The source repo is never modified.

Start a fresh session with `/fn-grill` (legacy project: `/fn-refactor`; merging projects: `/fn-merge`).

## Skills

| Skill | Stage | Exit |
|---|---|---|
| fn-grill | ① requirements capture (rounds / frontier interrogation, eight must-asks) | `/fn-divide` |
| fn-divide | ② function decomposition (responsibility document) | `/fn-scaffold` |
| fn-scaffold | ③ structure + skeleton (fn_work/, unified stubs) | `/fn-implement` |
| fn-implement | ④ vertical-slice batches, bottom-up four states | batch gate (3 options) / `/fn-close` |
| fn-close | ⑤ six final checks + acceptance report (delivery tasks get optional external triple-check) | verdict to the user |
| fn-refactor | on-ramp: legacy project (two grill rounds + snapshot safety net) | `/fn-divide` |
| fn-merge | on-ramp: multi-project merge (inventory → merged requirements → merged responsibility) | `/fn-scaffold` |
| fn-review | audit (on demand, read-only): mechanical + spec axes over code and docs | back to the matching loop |
| fn-brainstorm | ideation when stuck (blocked / plan rework / can't see clearly): ≥3 options incl. a radical one | back to the matching loop |
| fn-analyze | data-driven improvement (pull results → three-axis analysis → function-level proposals → effect scoring) | proposals to `/fn-grill` |
| fn-quick | compatibility router (retired in v1.6): lightweight line now lives in fn-grill/fn-analyze; always declare the line | next lightweight item or upgrade |

## License

[MIT](LICENSE) © r-y-ren
