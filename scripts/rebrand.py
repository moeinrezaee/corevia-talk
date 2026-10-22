#!/usr/bin/env python3
"""Rebrand Buzz -> Corevia Talk across contents AND paths of a git checkout.

Re-runnable: after every `git merge upstream/main` on the unbranded branch, run
this script on a fresh branch to regenerate the branded tree.

    python3 scripts/rebrand.py            # apply
    python3 scripts/rebrand.py --dry-run  # report only

Naming map (see docs/rebranding.md for the rules and what is left untouched):
    corevia-talk   kebab   (crate/package/dir/CLI/URL scheme names)
    corevia_talk   snake   (Rust/Dart identifiers, Postgres names)
    CoreviaTalk    Pascal  (types, Swift modules)
    coreviaTalk    camel
    COREVIA_TALK   upper   (environment variables, constants)
    coreviatalk    flat    (reverse-DNS bundle / application ids)
    Corevia Talk   display (user-visible product name)
"""
import os
import re
import subprocess
import sys
from collections import Counter

DRY = "--dry-run" in sys.argv

KEBAB, SNAKE, PASCAL, CAMEL = "corevia-talk", "corevia_talk", "CoreviaTalk", "coreviaTalk"
UPPER, FLAT, DISPLAY = "COREVIA_TALK", "coreviatalk", "Corevia Talk"

# Files whose text must not change (history, license, this tooling itself).
SKIP_CONTENT = {
    "CHANGELOG.md", "LICENSE", "NOTICE",
    "scripts/rebrand.py", "docs/rebranding.md",
}

# Spans that refer to the upstream project or to services Block operates.
PROTECT = [
    r"block/buzz[A-Za-z0-9_.\-/]*",                 # upstream repo, links, ghcr
    r"squareup/[A-Za-z0-9_.\-]+",                   # Block-internal repos
    r"[A-Za-z0-9.\-]*buzz\.xyz[A-Za-z0-9_.\-/]*",   # Block-hosted services
    r"buzzdotxyz",
    r"railway\.com/deploy/[A-Za-z0-9_\-]+",
    r"(?i:buzzard)",                                # the bird
]
PROTECT_RE = re.compile("|".join(f"(?:{p})" for p in PROTECT))

RUN = re.compile(r"[A-Za-z0-9_\-]*[Bb][Uu][Zz][Zz][A-Za-z0-9_\-]*")
OCC = re.compile(r"(?i)buzz")
DB_LINE = re.compile(
    r"(?i)postgres|PGUSER|PGDATABASE|PGPASSWORD|psql|pg_isready|createdb|dropdb|"
    r"pg_dump|pg_restore|DATABASE_URL|\bpgschema\b"
)
REVERSE_DNS = re.compile(
    r"\b((?:xyz|com|org|io|dev|app|net)(?:\.[A-Za-z0-9_\-]+)*?\.)buzz\b"
)


def map_run(run, *, mode, snake_ctx=False, flat_ctx=False):
    """Map one identifier-like run containing 'buzz' (any case)."""
    standalone = run.lower() == "buzz"

    def occ(m):
        s, i = m.group(0), m.start()
        before = run[i - 1] if i else ""
        after = run[m.end()] if m.end() < len(run) else ""
        if s == "BUZZ":
            return UPPER
        if s == "Buzz":
            if standalone:
                return DISPLAY if mode == "content" else PASCAL
            return PASCAL
        # lowercase 'buzz'
        if standalone:
            if flat_ctx:
                return FLAT
            return SNAKE if snake_ctx else KEBAB
        if after.isupper() and not before.isalnum():
            return CAMEL
        if before == "_" or after == "_":
            return SNAKE
        if before == "-" or after == "-":
            return KEBAB
        if before.isalnum() or after.isalnum():
            return FLAT
        return KEBAB

    return OCC.sub(occ, run)


def rebrand_text(text, *, path, mode="content"):
    stash = []

    def mask(m):
        stash.append(m.group(0))
        return f"\x00{len(stash) - 1}\x00"

    def mask_val(value):
        stash.append(value)
        return f"\x00{len(stash) - 1}\x00"

    text = PROTECT_RE.sub(mask, text)
    text = REVERSE_DNS.sub(lambda m: m.group(1) + FLAT, text)
    # Bundle / artifact file names are derived from Tauri's productName and are
    # used unquoted by the release scripts, so they must not contain a space.
    text = re.sub(r'("productName"\s*:\s*")Buzz(")', lambda m: m.group(1) + mask_val(PASCAL) + m.group(2), text)
    text = re.sub(
        r"\bBuzz(?=\.(?:app|dmg|AppImage|deb|exe|msi|zip|tar)\b)",
        lambda m: mask_val(PASCAL),
        text,
    )
    sql_file = path.endswith((".sql", ".pgsql"))
    out_lines = []
    for line in text.split("\n"):
        if "buzz" not in line.lower():
            out_lines.append(line)
            continue
        snake_line = sql_file or bool(DB_LINE.search(line))

        def run_sub(m):
            run = m.group(0)
            lo = run.lower()
            start = m.start()
            ctx_before = line[max(0, start - 8):start]
            snake = snake_line
            if lo == "buzz":
                if ctx_before.endswith("package:"):
                    snake = True
                if line[m.end():m.end() + 2] == "::":
                    snake = True
            return map_run(run, mode=mode, snake_ctx=snake)

        out_lines.append(RUN.sub(run_sub, line))
    text = "\n".join(out_lines)
    return re.sub(r"\x00(\d+)\x00", lambda m: stash[int(m.group(1))], text)


def rebrand_path(path):
    parts = path.split("/")
    flat_dirs = any(p in ("kotlin", "java") for p in parts)
    out = []
    for p in parts:
        if re.search(r"(?i)buzz", p) and not re.search(r"(?i)buzzard", p):
            p = RUN.sub(lambda m: map_run(m.group(0), mode="path", flat_ctx=flat_dirs), p)
        out.append(p)
    return "/".join(out)


def main():
    files = [f for f in subprocess.check_output(["git", "ls-files", "-z"], text=True).split("\0") if f]
    changed = Counter()
    for f in files:
        if f in SKIP_CONTENT or not os.path.isfile(f) or os.path.islink(f):
            continue
        try:
            with open(f, encoding="utf-8", newline="") as fh:
                text = fh.read()
        except (UnicodeDecodeError, OSError):
            continue
        if "buzz" not in text.lower():
            continue
        new = rebrand_text(text, path=f)
        if new != text:
            changed["content"] += 1
            if not DRY:
                with open(f, "w", encoding="utf-8", newline="") as fh:
                    fh.write(new)

    renames = []
    for f in files:
        if f in SKIP_CONTENT:
            continue
        new = rebrand_path(f)
        if new != f:
            renames.append((f, new))
    changed["renamed"] = len(renames)
    if not DRY:
        for old, new in renames:
            if not os.path.lexists(old):
                continue
            os.makedirs(os.path.dirname(new) or ".", exist_ok=True)
            os.rename(old, new)
        # drop now-empty directories left behind
        for root, dirs, _ in os.walk(".", topdown=False):
            if ".git" in root.split(os.sep):
                continue
            for d in dirs:
                p = os.path.join(root, d)
                if os.path.isdir(p) and not os.listdir(p):
                    os.rmdir(p)
    print(dict(changed))


if __name__ == "__main__":
    main()
