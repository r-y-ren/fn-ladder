#!/usr/bin/env bash
# fn-selftest.sh —— 验收道次：构造 fn_docs 树，跑 fn-doc-lint 与 fn-step-done 行为断言
# 用法: bash scripts/fn-selftest.sh   （全过 exit 0；任一断言失败立即 exit 1）
# 覆盖（对应 docs/specs/2026-10-09-review-fixes.md Testing Decisions）：
#   lint：一致态放行 / wired 三方漂移报错 / 缺批次节报错 / 豁免行类型非法报错
#   fn-step-done：核验失败零写入 / 成功落账+读回 / 重复记账拒绝
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

FIX="$(mktemp -d)"
trap 'rm -rf "$FIX"' EXIT
PASS=0
ok()   { PASS=$((PASS + 1)); echo "  ✓ $1"; }
fail() { echo "  ✗ $1"; exit 1; }

build_fixture() {
  rm -rf "$FIX/fn_docs" "$FIX/fn_work"
  mkdir -p "$FIX/fn_docs/implementation" "$FIX/fn_work/src"
  cat > "$FIX/fn_docs/requirements.md" <<'EOF'
# requirements
## 根本目的
x
## 环境与技术栈决策
x
## 术语表
x
## 需求条目
### R1
验收方式: 测试: test_foo
## 非功能约束
x
## 外部依赖
x
## 范围外
x
## 变更记录
EOF
  cat > "$FIX/fn_docs/responsibility.md" <<'EOF'
# responsibility
## 结构概览
- foo ← 程序入口
## 需求覆盖矩阵
| 需求 | 顶层函数 |
|---|---|
| R1 | foo |
## 功能块
- **foo**（调用方：程序入口）
  - 职责：干一件事
EOF
  cat > "$FIX/fn_work/src/foo.py" <<'EOF'
def foo():
    return 42
EOF
  cat > "$FIX/fn_docs/implementation/functions.md" <<'EOF'
| 函数 | 批次 | 状态(日期) | 核验命令+摘要 | commit |
|---|---|---|---|---|
| foo | B1 | wired 09-21 | 测试: test_foo → 1 passed | abc123 |
EOF
  cat > "$FIX/fn_docs/implementation/batches.md" <<'EOF'
| 批次 | 函数/任务清单 | 验收点 | 注 |
|---|---|---|---|
| ▶ B2 | foo | x | |
EOF
  cat > "$FIX/fn_docs/implementation/history.md" <<'EOF'
| 完成日期 | 批次 | 任务/函数清单（含操作与来源说明） | 验收摘要 |
|---|---|---|---|
| 09-21 | B1 | foo | 全绿 |
EOF
  cat > "$FIX/fn_docs/implementation/tracker.md" <<'EOF'
# Implement tracker — fn_docs — 计划: batches.md — 真值: functions.md + git log

## 进入五步
- [x] 1 前置检查 — 证据: ls → ok (09-21)

## B1 — foo
### foo
- [x] foo · implemented — 证据: diff → done (09-21)
- [x] foo · tested — 证据: pytest → 1 passed (09-21)
- [x] foo · wired — 证据: grep → 1 hit (09-21)

## B1 批间门
- [x] B1 · 评审三轴 — 证据: review → clean (09-21)

- Ruling: 签名加 opts — 原因: 桩缺参数 — 代价: 调用方补一处 — 落点: batches.md 变更记录
- X1: 免审 | 范围: 单门 | 对象: fn-implement·批间门 | 原因: 用户口头 | 剩余: 0 | 状态: consumed
EOF
}

lint() {
  RC=0
  OUT="$(python3 scripts/fn-doc-lint.py "$FIX" 2>&1)" || RC=$?
}

echo "== fn-selftest：lint 断言 =="
build_fixture
lint
[ "$RC" = 0 ] || fail "一致态应放行，实际：$OUT"
ok "一致态 0 错误放行"

sed -i 's/^- \[x\] foo · wired.*/- [ ] foo · wired — 预告: 调用点 grep 命中/' "$FIX/fn_docs/implementation/tracker.md"
lint
[ "$RC" != 0 ] && grep -q "三方漂移" <<<"$OUT" || fail "三方漂移应报错，实际：$OUT"
ok "wired 三方漂移报错"

build_fixture
sed -i 's/^## B1 — foo/## 批次/' "$FIX/fn_docs/implementation/tracker.md"
lint
[ "$RC" != 0 ] && grep -q "缺批次节" <<<"$OUT" || fail "缺批次节应报错，实际：$OUT"
ok "缺批次节报错"

build_fixture
sed -i 's/^- X1: 免审 |/- X1: 免测 |/' "$FIX/fn_docs/implementation/tracker.md"
lint
[ "$RC" != 0 ] && grep -q "豁免行类型非法" <<<"$OUT" || fail "豁免行类型非法应报错，实际：$OUT"
ok "豁免行类型非法报错"

echo "== fn-selftest：fn-step-done 行为断言 =="
T="$FIX/step.md"
cat > "$T" <<'EOF'
# Implement tracker — fn_docs

## B1 — foo
### foo
- [ ] foo · tested — 预告: 单测绿，预期 pytest → passed
EOF
BEFORE="$(md5sum "$T")"
RC=0
bash scripts/fn-step-done.sh "$T" "foo · tested" -- false >/dev/null 2>&1 || RC=$?
[ "$RC" != 0 ] || fail "核验失败应返回非 0"
[ "$BEFORE" = "$(md5sum "$T")" ] || fail "核验失败却写入了账本（失败零写入被破坏）"
ok "核验失败零写入"

bash scripts/fn-step-done.sh "$T" "foo · tested" -- bash -c 'echo "1 passed"' >/dev/null 2>&1 || fail "核验通过应记账"
grep -qF -- "- [x] foo · tested — 证据:" "$T" || fail "成功后步骤行未落账"
ok "成功落账 + 读回"

RC=0
bash scripts/fn-step-done.sh "$T" "foo · tested" -- true >/dev/null 2>&1 || RC=$?
[ "$RC" != 0 ] || fail "重复记账应被拒绝"
ok "重复记账拒绝"

echo "== fn-selftest：$PASS/$PASS 断言全过 =="
