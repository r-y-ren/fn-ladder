#!/usr/bin/env bash
# fn-ladder 安装：在 ~/.zcode/skills/ 下为技能与总览创建符号链接
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS="${HOME}/.zcode/skills"
mkdir -p "$SKILLS"

for name in fn-grill fn-divide fn-scaffold fn-implement fn-close fn-refactor fn-merge FN-LADDER.md; do
  target="$SKILLS/$name"
  if [ -e "$target" ] || [ -L "$target" ]; then
    if [ "$(readlink -f "$target" 2>/dev/null || true)" = "$(readlink -f "$REPO/$name")" ]; then
      echo "已链接，跳过：$name"
    else
      echo "已存在且非本仓库链接，请手动处理：$target"
    fi
    continue
  fi
  ln -s "$REPO/$name" "$target"
  echo "已链接：$name"
done

echo "完成。新开会话后 /fn-grill 即可用。"
