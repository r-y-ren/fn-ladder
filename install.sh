#!/usr/bin/env bash
# fn-ladder 符号链接安装（适用于不支持插件机制的运行时；ZCode 用户推荐直接添加本仓库为插件市场）
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS="${HOME}/.zcode/skills"
mkdir -p "$SKILLS"

link() {  # link <仓库内相对路径> <链接名>
  local src="$REPO/$1" target="$SKILLS/$2"
  if [ -e "$target" ] || [ -L "$target" ]; then
    if [ "$(readlink -f "$target" 2>/dev/null || true)" = "$(readlink -f "$src")" ]; then
      echo "已链接，跳过：$2"
    else
      echo "已存在且非本仓库链接，请手动处理：$target"
    fi
    return
  fi
  ln -s "$src" "$target"
  echo "已链接：$2"
}

for s in fn-grill fn-divide fn-scaffold fn-implement fn-close fn-refactor fn-merge; do
  link "skills/$s" "$s"
done
link "FN-LADDER.md" "FN-LADDER.md"

echo "完成。新开会话后 /fn-grill 即可用。"
