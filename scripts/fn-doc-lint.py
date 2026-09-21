#!/usr/bin/env python3
"""fn-doc-lint —— fn-ladder 文档侧机械校验
用法: fn-doc-lint.py [任务工作目录]（默认当前目录；其下应有 fn_docs/）

校验项：
  requirements  八节齐全（警告）、R 编号不重复
  functions     状态词合法、函数与责任文档一致（双向）
  batches       ▶ 至多一个、引用函数存在、与 history 批次不重叠
  responsibility 概览树与函数块一致、函数名唯一、矩阵 R 双向覆盖、
                 调用方存在、调用链可达到入口（死代码拦截）
"""
import os
import re
import sys
from collections import defaultdict

ROOT = sys.argv[1] if len(sys.argv) > 1 else os.getcwd()
D = os.path.join(ROOT, "fn_docs")
errs, warns = [], []


def err(m):
    errs.append(m)


def warn(m):
    warns.append(m)


def read(*parts):
    p = os.path.join(D, *parts)
    if not os.path.isfile(p):
        err(f"缺文件: {os.path.join(*parts)}")
        return ""
    with open(p, encoding="utf-8") as f:
        return f.read()


def cells(line):
    return [x.strip() for x in line.strip().strip("|").split("|")]


req = read("requirements.md")
resp = read("responsibility.md")
funcs = read("implementation", "functions.md")
batches = read("implementation", "batches.md")
hist = read("implementation", "history.md")

# ---- requirements ----
for sec in ["根本目的", "环境与技术栈决策", "术语表", "需求条目", "非功能约束", "外部依赖", "范围外", "变更记录"]:
    if req and f"## {sec}" not in req:
        warn(f"requirements 缺节: {sec}")
rids = re.findall(r"^### R(\d+)", req, re.M)
if len(rids) != len(set(rids)):
    err("requirements R 编号重复")
rset = {f"R{i}" for i in rids}

# ---- responsibility：按节解析 ----
section = ""
tree_names, block_names, callers = [], [], {}
cur = None
matrix = []
for line in resp.splitlines():
    if line.startswith("## "):
        section = re.split("[（(]", line[3:].strip())[0].strip()
        continue
    m = re.match(r"\s*-\s*\*\*(.+?)\*\*(?:（调用方[：:](.+?)）)?", line)
    if m:
        cur = m.group(1).split("[")[0].strip()
        block_names.append(cur)
        if m.group(2):
            callers[cur] = [x.strip() for x in re.split("[,，、]", m.group(2))]
        continue
    if section == "结构概览":
        tm = re.match(r"\s*-\s*([A-Za-z_]\w*)\s*(?:←|$)", line)
        if tm:
            tree_names.append(tm.group(1))
        continue
    cm = re.match(r"\s*[-*]\s*调用方[：:]\s*(.+)", line)
    if cm and cur:
        callers[cur] = [x.strip() for x in re.split("[,，、]", cm.group(1))]
    if section == "需求覆盖矩阵":
        c = cells(line)
        if len(c) == 2 and re.fullmatch(r"R\d+(\s*\[P1\])?", c[0]):
            matrix.append((re.match(r"R\d+", c[0]).group(0), c[1]))

dups = sorted({n for n in block_names if block_names.count(n) > 1})
if dups:
    err(f"responsibility 函数名重复: {dups}")
fnset = set(block_names)
only_tree = set(tree_names) - fnset
only_block = fnset - set(tree_names)
if only_tree:
    err(f"概览树有而函数块无: {sorted(only_tree)}")
if only_block:
    err(f"函数块有而概览树无: {sorted(only_block)}")
for rid, fn in matrix:
    if rid not in rset:
        err(f"矩阵引用不存在的需求: {rid}")
    if fn not in fnset:
        err(f"矩阵顶层函数不在函数树: {fn}")
for r in rset:
    if r not in {x for x, _ in matrix}:
        err(f"需求无顶层函数负责（漏实现）: {r}")

children = defaultdict(list)
tops = []
for fn, ps in callers.items():
    for p in ps:
        if p in ("程序入口", "入口"):
            tops.append(fn)
        elif p in fnset:
            children[p].append(fn)
        else:
            err(f"{fn} 的调用方不存在: {p}")
seen = set(tops)
stack = list(tops)
while stack:
    x = stack.pop()
    for c in children[x]:
        if c not in seen:
            seen.add(c)
            stack.append(c)
for fn in sorted(fnset):
    if fn in callers and fn not in seen:
        err(f"函数无调用链连到入口（死代码）: {fn}")
    elif fn not in callers:
        warn(f"函数缺调用方字段: {fn}")

# ---- functions.md ----
frows = []
for line in funcs.splitlines():
    c = cells(line)
    if len(c) >= 3 and c[0] and c[0] != "函数" and not set(c[0]) <= {"-", ":", " "}:
        frows.append(c)
pat = re.compile(r"^(stub|implemented|tested|wired\s+\S+|blocked:.+)$")
flist = []
for c in frows:
    flist.append(c[0])
    if not pat.match(c[2]):
        err(f"functions 状态词非法: {c[0]} = {c[2]}")
unknown = [f for f in flist if f not in fnset]
if unknown:
    err(f"functions 出现责任文档没有的函数: {unknown}")
if frows:
    notin = sorted(fnset - set(flist))
    if notin:
        err(f"责任文档函数未入实现清单: {notin}")

# ---- batches.md / history.md ----
arrow = 0
bnums = set()
for line in batches.splitlines():
    c = cells(line)
    if len(c) >= 2 and c[0] and c[0] != "批次" and not set(c[0]) <= {"-", ":", " ", "▶"}:
        b = c[0].removeprefix("▶").strip()
        if b.startswith("▶"):
            arrow += 1
            b = b[1:].strip()
        elif "▶" in c[0]:
            arrow += 1
        if re.fullmatch(r"B\d+", b):
            bnums.add(b)
        for f in re.split("[,，、/]+", c[1]):
            f = f.strip()
            if re.fullmatch(r"[A-Za-z_]\w*", f) and f not in flist:
                err(f"批次表引用未知函数: {f}")
if arrow > 1:
    err("批次表 ▶ 多于一个")
hnums = set()
for line in hist.splitlines():
    c = cells(line)
    if len(c) >= 2 and re.fullmatch(r"B\d+", c[1]):
        hnums.add(c[1])
both = sorted(bnums & hnums)
if both:
    err(f"批次同时出现在批次表与历史表: {both}")

print(f"fn-doc-lint @ {D}")
for w in warns:
    print("WARN", w)
for e in errs:
    print("ERR ", e)
print(f"== {len(errs)} 错误, {len(warns)} 警告 ==")
sys.exit(1 if errs else 0)
