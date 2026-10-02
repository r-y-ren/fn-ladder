#!/usr/bin/env python3
"""fn-score.py —— 提案登记表（registry.jsonl）打分器

用法:
  fn-score.py [工作目录]
      打分工作台：列出未打分提案（含预期信号）与最新 results/ 快照，供判定
  fn-score.py [工作目录] --set <提案id> <pending|achieved|missed|reversed> [--in <报告名>]
      落打分状态（原子重写 registry.jsonl）

约定：脚本负责取数与登记，判定归人/主会话——预期信号是自然语言，机器只出工作台。
"""
import json
import os
import sys

VALID = {"pending", "achieved", "missed", "reversed"}


def load(path):
    rows = []
    with open(path, encoding="utf-8") as f:
        for i, line in enumerate(f, 1):
            line = line.strip()
            if not line:
                continue
            try:
                rows.append(json.loads(line))
            except json.JSONDecodeError:
                print(f"WARN registry 第 {i} 行 JSON 非法，跳过", file=sys.stderr)
    return rows


def save(path, rows):
    tmp = path + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        for r in rows:
            f.write(json.dumps(r, ensure_ascii=False) + "\n")
    os.replace(tmp, path)


def results_digest(results_dir):
    if not os.path.isdir(results_dir):
        print("（results/ 不存在——尚无快照）")
        return
    files = sorted(os.listdir(results_dir))
    if not files:
        print("（results/ 为空）")
        return
    for name in files[-5:]:
        p = os.path.join(results_dir, name)
        rows = "-"
        if name.endswith((".csv", ".jsonl")):
            try:
                with open(p, encoding="utf-8", errors="replace") as f:
                    rows = str(max(sum(1 for _ in f) - 1, 0))
            except OSError:
                rows = "?"
        mtime = __import__("datetime").datetime.fromtimestamp(os.path.getmtime(p)).strftime("%m-%d %H:%M")
        print(f"  {name}  rows={rows}  mtime={mtime}")


def main():
    args = sys.argv[1:]
    workdir = "."
    if args and not args[0].startswith("-"):
        workdir = args[0]
        args = args[1:]
    reg = os.path.join(workdir, "fn_docs", "analyses", "registry.jsonl")
    if not os.path.isfile(reg):
        print(f"ERR 无登记表: {reg}")
        return 1
    rows = load(reg)

    if args and args[0] == "--set":
        if len(args) < 3:
            print("ERR 用法: --set <id> <status> [--in <报告名>]")
            return 1
        pid, status = args[1], args[2]
        report = None
        if "--in" in args:
            report = args[args.index("--in") + 1]
        if status not in VALID:
            print(f"ERR status 须为 {sorted(VALID)}")
            return 1
        hit = [r for r in rows if r.get("id") == pid]
        if not hit:
            print(f"ERR 无此提案: {pid}")
            return 1
        hit[0]["status"] = status
        if report:
            hit[0]["scored_in"] = report
        save(reg, rows)
        print(f"已落分: {pid} → {status}" + (f"（in {report}）" if report else ""))
        return 0

    # 工作台
    pending = [r for r in rows if r.get("status", "pending") == "pending"]
    done = [r for r in rows if r.get("status", "pending") != "pending"]
    print(f"fn-score 工作台 @ {reg}")
    print(f"== 未打分提案 {len(pending)} 条 ==")
    for r in pending:
        tgt = ",".join(r.get("target", [])) if isinstance(r.get("target"), list) else r.get("target", "-")
        print(f"[{r.get('id')}] {r.get('date', '?')} target={tgt}")
        print(f"  现象: {r.get('phenomenon', '-')}")
        print(f"  预期信号: {r.get('expected_signal', '-')}")
        print(f"  → 裁决: fn-score.py {workdir} --set {r.get('id')} achieved|missed|reversed")
    print(f"== 已打分 {len(done)} 条 ==")
    for r in done:
        print(f"  {r.get('id')} {r.get('status')}" + (f" (in {r['scored_in']})" if r.get("scored_in") else ""))
    print("== results/ 最新快照 ==")
    results_digest(os.path.join(workdir, "fn_docs", "results"))
    return 0


if __name__ == "__main__":
    sys.exit(main())
