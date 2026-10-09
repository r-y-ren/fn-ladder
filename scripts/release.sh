#!/usr/bin/env bash
# release.sh —— fn-ladder 发版一步到位
# 作用：发版前机器检查（防"改 A 忘 B"同步债）→ 以命令行版本号为**单一版本源**，同步
#       bump marketplace.json 与 .zcode-plugin/plugin.json 两处版本号（ZCode 在线更新依赖
#       版本号变化：显示版本取 plugin.json，更新检测对比 marketplace.json，两处必须一致）
#       → 校验 JSON、版本双轨一致与 CHANGELOG 版本条目 → 连同当前全部改动一起提交、
#       打 tag v<版本号> 并推送。
# 用法：scripts/release.sh <版本号> [说明]
#       scripts/release.sh --check        # 只跑发版前检查，不 bump 不提交
# 例：  scripts/release.sh 1.3.0 "新增 fn-x 技能"
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

# —— 发版前机器检查（命中即中止，未提交任何改动）——
preflight() {
  local fail=0

  # ① 退役术语表：改术语时在此登记（旧词|新词）；旧词任何残留=中止。
  #    注意模式精度：如"五道+目录清点"是合法组成说明，不命中"五道终检/过五道"。
  local retired=(
    "轻量臂|轻量线"
    "五道终检|六道终检"
    "过五道|过六道"
    "转常规流程|走轻量线"
    "小任务豁免|小任务→轻量线"
    "用户说“免审”可跳过|无有效豁免行不得跳过（/fn-exempt）"
    "用户接管 commit 则跳过|接管 commit 须经 /fn-exempt 记账"
    "预授权例外|预授权连做"
    "冲刺模式例外|冲刺例外"
  )
  local pair old new hits
  for pair in "${retired[@]}"; do
    old="${pair%%|*}"; new="${pair##*|}"
    hits=$(grep -rn "$old" --include="*.md" --include="*.sh" --include="*.json" \
      --exclude="release.sh" . 2>/dev/null | grep -v "^\./\.git/" || true)
    if [ -n "$hits" ]; then
      echo "ERR 退役术语「$old」残留（应改用「$new」）："
      echo "$hits"
      fail=1
    fi
  done

  # ② 技能清单双向一致：skills/ 目录 ↔ install.sh 安装环
  local d s
  for d in skills/*/; do
    s=$(basename "$d")
    grep -q "\b$s\b" install.sh || { echo "ERR 新技能 $s 未登记 install.sh"; fail=1; }
  done
  for s in $(grep -o 'for s in [^;]*' install.sh | sed 's/for s in //' | tr ' ' '\n' | grep '^fn-' || true); do
    [ -d "skills/$s" ] || { echo "ERR install.sh 登记的 $s 无 skills/ 目录"; fail=1; }
  done

  # ③ 合规文件：LICENSE 存在 + 每技能 frontmatter license 字段齐备 + CHANGELOG 存在
  [ -f LICENSE ] || { echo "ERR 缺 LICENSE"; fail=1; }
  [ -f CHANGELOG.md ] || { echo "ERR 缺 CHANGELOG.md"; fail=1; }
  for d in skills/*/; do
    grep -q "^license:" "$d/SKILL.md" || { echo "ERR $d SKILL.md 缺 license 字段"; fail=1; }
  done

  [ "$fail" = 0 ] || { echo "—— 发版前检查未过，中止（未提交任何改动）——"; return 1; }
  echo "发版前检查过：退役术语 0 残留、技能清单双向一致、合规文件齐备"
}

if [ "${1:-}" = "--check" ]; then
  preflight
  exit 0
fi

VER="${1:?用法: release.sh <x.y.z> [说明] | release.sh --check}"
MSG="${2:-例行发版}"
[[ "$VER" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "ERR 版本号须为 x.y.z"; exit 1; }

preflight

for f in marketplace.json .zcode-plugin/plugin.json; do
  sed -i "s/\"version\": \"[^\"]*\"/\"version\": \"$VER\"/" "$f"
  python3 -m json.tool "$f" >/dev/null || { echo "ERR $f JSON 非法，已中止（未提交）"; exit 1; }
done

# ④ 版本双轨一致：两处都须等于目标版本（防 sed 单处失效——README 警告的事故形态）
MV=$(grep -o '"version": "[^"]*"' marketplace.json | cut -d'"' -f4)
PV=$(grep -o '"version": "[^"]*"' .zcode-plugin/plugin.json | cut -d'"' -f4)
[ "$MV" = "$VER" ] && [ "$PV" = "$VER" ] || {
  echo "ERR 版本双轨不一致：marketplace=$MV plugin=$PV 目标=$VER（未提交）"; exit 1; }

# ⑤ CHANGELOG 版本条目：发版前须已在 CHANGELOG.md 写好「## <版本号>」条目
grep -q "^## $VER " CHANGELOG.md || {
  echo "ERR CHANGELOG.md 无「## $VER」条目（未提交）"; exit 1; }

if git diff --quiet && git diff --cached --quiet && [ -z "$(git status --porcelain --untracked-files=all)" ]; then
  echo "除版本号外无其他改动，仍发版（纯版本提交）"
fi

git add -A
git commit -m "release: v$VER $MSG"
git tag -a "v$VER" -m "release v$VER"
git push --follow-tags
echo "已发版 v$VER（tag v$VER）—— ZCode 刷新插件市场后即可见更新"
