#!/usr/bin/env bash
# fn-check —— fn-ladder 代码侧全局核验三件套
# 用法: fn-check.sh [任务工作目录]（默认当前目录；其下应有 fn_work/）
# 覆盖: ① 残留桩 grep  ② 全量测试  ③ tests/ 镜像结构抽查
# 测试命令优先级: FN_TEST_CMD 环境变量 > Makefile(test) > npm test > pytest > go test
set -uo pipefail
ROOT="${1:-$PWD}"
FW="$ROOT/fn_work"
rc=0
say() { printf '%s\n' "$*"; }

say "== ① 残留桩 =="
if [ -d "$FW" ]; then
  n=$(grep -rn "unimplemented:fn:" "$FW" 2>/dev/null | wc -l)
  if [ "$n" -eq 0 ]; then say "PASS 残留桩 0 处"
  else say "FAIL 残留桩 ${n} 处："; grep -rn "unimplemented:fn:" "$FW" 2>/dev/null; rc=1; fi
else
  say "SKIP fn_work/ 不存在：$FW"; rc=1
fi

say "== ② 全量测试 =="
t=2
if   [ -n "${FN_TEST_CMD:-}" ]; then ( cd "$FW" 2>/dev/null || cd "$ROOT"; sh -c "$FN_TEST_CMD" ); t=$?
elif [ -f "$FW/Makefile" ];      then ( cd "$FW" && make test ); t=$?
elif [ -f "$FW/package.json" ];  then ( cd "$FW" && npm test --silent ); t=$?
elif command -v pytest >/dev/null 2>&1 && [ -d "$FW/tests" ]; then ( cd "$FW" && pytest ); t=$?
elif [ -f "$FW/go.mod" ];        then ( cd "$FW" && go test ./... ); t=$?
else say "SKIP 无法识别测试命令（用 FN_TEST_CMD 环境变量指定）"
fi
case $t in
  0) say "PASS 全量测试" ;;
  2) ;;
  *) say "FAIL 全量测试（exit $t）"; rc=1 ;;
esac

say "== ③ tests 镜像结构（警告级） =="
if [ -d "$FW/src" ] && [ -d "$FW/tests" ]; then
  missing=0
  while IFS= read -r f; do
    stem="$(basename "${f%.*}")"
    if ! find "$FW/tests" -type f -name "${stem}.*" 2>/dev/null | grep -q .; then
      say "WARN 源文件无同名测试：$f（若为上游覆盖，须在 responsibility.md 标注）"; missing=1
    fi
  done < <(cd "$FW" && find src -type f ! -name '__init__*' ! -name 'index.*' | sort)
  [ "$missing" -eq 0 ] && say "PASS tests 镜像齐全"
else
  say "SKIP src/ 或 tests/ 不存在"
fi

say "== 汇总 =="
if [ "$rc" -eq 0 ]; then say "全部通过"; exit 0; else say "存在 FAIL 项"; exit 1; fi
