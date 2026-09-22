#!/usr/bin/env bash
# release.sh —— fn-ladder 发版一步到位
# 作用：同步 bump marketplace.json 与 .zcode-plugin/plugin.json 两处版本号（ZCode 在线更新
#       依赖版本号变化：显示版本取 plugin.json，更新检测对比 marketplace.json，两处必须一致），
#       校验 JSON 合法性，然后连同当前全部改动一起提交推送。
# 用法：scripts/release.sh <版本号> [说明]
# 例：  scripts/release.sh 1.3.0 "新增 fn-x 技能"
set -euo pipefail

VER="${1:?用法: release.sh <x.y.z> [说明]}"
MSG="${2:-例行发版}"
[[ "$VER" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "ERR 版本号须为 x.y.z"; exit 1; }

cd "$(dirname "${BASH_SOURCE[0]}")/.."

for f in marketplace.json .zcode-plugin/plugin.json; do
  sed -i "s/\"version\": \"[^\"]*\"/\"version\": \"$VER\"/" "$f"
  python3 -m json.tool "$f" >/dev/null || { echo "ERR $f JSON 非法，已中止（未提交）"; exit 1; }
done

CUR=$(grep -o '"version": "[^"]*"' .zcode-plugin/plugin.json | cut -d'"' -f4)
[ "$CUR" = "$VER" ] || { echo "ERR 版本写入失败"; exit 1; }

if git diff --quiet && git diff --cached --quiet && [ -z "$(git status --porcelain --untracked-files=all)" ]; then
  echo "除版本号外无其他改动，仍发版（纯版本提交）"
fi

git add -A
git commit -m "release: v$VER $MSG"
git push
echo "已发版 v$VER —— ZCode 刷新插件市场后即可见更新"
