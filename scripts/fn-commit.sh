#!/usr/bin/env bash
# fn-commit.sh —— 一键落痕：JOURNAL 行 + git commit + push（轻量臂与冲刺的收尾仪式）
# 用法（在任务工作目录下运行）:
#   fn-commit.sh "<阶段> <一行摘要>" ["<核验结果>"]
# 例: fn-commit.sh "quick 把 temperature 参数 0.8→0.6" "对战脚本 → 胜率 52%（-k 100 局）"
set -euo pipefail

ENTRY="${1:?用法: fn-commit.sh '<阶段> <一行摘要>' ['<核验结果>']（在任务工作目录下运行）}"
VERIFY="${2:-—}"
STAGE="${ENTRY%% *}"
SUMMARY="${ENTRY#* }"
if [ "$STAGE" = "$ENTRY" ]; then
  echo "ERR 摘要须为 '<阶段> <一行摘要>' 形式（首词为阶段，如 quick/implement/analyze）"
  exit 1
fi

TS="$(date '+%Y-%m-%d %H:%M')"
mkdir -p fn_docs
J="fn_docs/JOURNAL.md"
if [ ! -f "$J" ]; then
  printf '# JOURNAL —— 过程流水（fn-commit 追加；任何执行者可写，与结构化文档互补）\n\n| 日期时间 | 阶段 | 摘要 | 核验 |\n|---|---|---|---|\n' > "$J"
fi
printf '| %s | %s | %s | %s |\n' "$TS" "$STAGE" "$SUMMARY" "$VERIFY" >> "$J"

if git rev-parse --git-dir >/dev/null 2>&1; then
  git add -A
  git commit -m "fn($STAGE): $SUMMARY" || echo "WARN 无新内容可提交（JOURNAL 行已落盘）"
  git push || echo "WARN push 失败（远端未配置/网络问题），本地 commit 与 JOURNAL 已落盘"
else
  echo "WARN 非 git 仓库，仅落 JOURNAL 行"
fi
echo "已落痕: $TS | $STAGE | $SUMMARY"
