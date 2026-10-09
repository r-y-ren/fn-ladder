#!/usr/bin/env bash
# fn-step-done.sh —— 核验绿才记账硬门：跑核验命令，exit 0 才把 tracker 步骤行勾为完成（失败零写入）
# 用法（在任务工作目录下运行）:
#   fn-step-done.sh <tracker.md> "<步骤标识>" -- <核验命令...>
# 步骤标识 = tracker 中该行「- [ ] 」后的唯一文本（如 "parse_config · tested"）
# 例: fn-step-done.sh fn_docs/implementation/tracker.md "parse_config · tested" -- pytest -q tests/test_parse_config.py
# 约定（FN-LADDER 不变式 1/5 的脚本承载）：核验失败什么也不写；成功只改一行（勾选+证据+日期）；
#       写完从盘上重读贴出改后行——读回不到 = 按写入未落地报错（no-op 防线）。
set -euo pipefail

TRACKER="${1:?用法: fn-step-done.sh <tracker.md> '<步骤标识>' -- <核验命令...>}"
IDENT="${2:?缺步骤标识}"
shift 2
if [ "${1:-}" != "--" ]; then
  echo "ERR 参数须为 '<tracker.md>' '<步骤标识>' -- <核验命令...>"
  exit 1
fi
shift
[ "$#" -gt 0 ] || { echo "ERR 缺核验命令"; exit 1; }
[ -f "$TRACKER" ] || { echo "ERR tracker 不存在: $TRACKER"; exit 1; }

MATCHES="$(grep -nF -- "- [ ] $IDENT" "$TRACKER" || true)"
N="$(printf '%s\n' "$MATCHES" | grep -c '.' || true)"
if [ "$N" != "1" ]; then
  echo "ERR 未勾步骤行命中 $N 处（须恰好 1 处）: $IDENT"
  exit 1
fi
LN="${MATCHES%%:*}"

echo "—— 核验: $*"
set +e
OUTPUT="$("$@" 2>&1)"
RC=$?
set -e
printf '%s\n' "$OUTPUT"
if [ "$RC" -ne 0 ]; then
  echo "核验未过（exit $RC）——未记账（失败零写入，该步仍未做）"
  exit "$RC"
fi

CMD="$*"
SUMMARY="$(printf '%s\n' "$OUTPUT" | grep -v '^[[:space:]]*$' | tail -n 1 | cut -c1-60)"
[ -n "$SUMMARY" ] || SUMMARY="exit 0"
TS="$(date '+%m-%d')"
DONE="- [x] $IDENT — 证据: $CMD → $SUMMARY ($TS)"
TMP="$(mktemp)"
awk -v ln="$LN" -v rep="$DONE" 'NR==ln{print rep; next}{print}' "$TRACKER" > "$TMP"
mv "$TMP" "$TRACKER"

echo "读回（落盘字节才算写入证据）:"
if grep -qF -- "$DONE" "$TRACKER"; then
  grep -nF -- "- [x] $IDENT" "$TRACKER" | head -n 1
else
  echo "ERR 读回失败：写入未落地（no-op 防线），该步按未做处理"
  exit 1
fi
