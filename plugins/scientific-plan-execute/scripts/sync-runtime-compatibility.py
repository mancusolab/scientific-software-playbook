#!/usr/bin/env python3
"""Sync Runtime Compatibility sections from docs/runtime-compatibility.md.

Updates all markdown files under plugins/scientific-* that contain a Runtime
Compatibility section. The managed section is wrapped with markers so future
sync operations are deterministic.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

BLOCK_BEGIN = "<!-- BEGIN:RUNTIME_COMPATIBILITY_BLOCK -->"
BLOCK_END = "<!-- END:RUNTIME_COMPATIBILITY_BLOCK -->"
SYNC_BEGIN = "<!-- SYNC:BEGIN runtime-compatibility -->"
SYNC_END = "<!-- SYNC:END runtime-compatibility -->"

# Replace legacy section text from heading to the standard closing sentence.
LEGACY_SECTION_RE = re.compile(
    r"## Runtime Compatibility\n"
    r"(?:.*?\n)*?"
    r"Apply this translation before following the remaining steps\.\n",
    re.DOTALL,
)


def _repo_root() -> Path:
    # .../plugins/scientific-plan-execute/scripts/sync-runtime-compatibility.py
    return Path(__file__).resolve().parents[3]


def _extract_block(source_text: str) -> str:
    pattern = re.compile(
        rf"{re.escape(BLOCK_BEGIN)}\n(.*?)\n{re.escape(BLOCK_END)}",
        re.DOTALL,
    )
    match = pattern.search(source_text)
    if not match:
        raise ValueError("canonical block markers not found in docs/runtime-compatibility.md")
    return match.group(1).rstrip() + "\n"


def _managed_section(block_text: str) -> str:
    return f"{SYNC_BEGIN}\n{block_text}{SYNC_END}\n"


def _target_files(repo_root: Path) -> list[Path]:
    targets: list[Path] = []
    for path in sorted((repo_root / "plugins").glob("scientific-*/**/*.md")):
        if not path.is_file():
            continue
        text = path.read_text(encoding="utf-8")
        if "## Runtime Compatibility" in text or SYNC_BEGIN in text:
            targets.append(path)
    return targets


def _sync_text(text: str, managed: str) -> tuple[str, bool, str | None]:
    if SYNC_BEGIN in text or SYNC_END in text:
        marker_re = re.compile(
            rf"{re.escape(SYNC_BEGIN)}\n.*?\n{re.escape(SYNC_END)}\n?",
            re.DOTALL,
        )
        if not marker_re.search(text):
            return text, False, "found sync marker but could not parse managed block"
        new_text = marker_re.sub(managed, text, count=1)
        return new_text, (new_text != text), None

    legacy_match = LEGACY_SECTION_RE.search(text)
    if not legacy_match:
        return text, False, "contains runtime heading but legacy block pattern did not match"

    new_text = LEGACY_SECTION_RE.sub(managed, text, count=1)
    return new_text, (new_text != text), None


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--check",
        action="store_true",
        help="Check for drift without writing files.",
    )
    args = parser.parse_args()

    repo_root = _repo_root()
    source_path = repo_root / "docs" / "runtime-compatibility.md"
    source_text = source_path.read_text(encoding="utf-8")
    block_text = _extract_block(source_text)
    managed = _managed_section(block_text)

    errors: list[str] = []
    changed: list[Path] = []

    for path in _target_files(repo_root):
        text = path.read_text(encoding="utf-8")
        new_text, did_change, error = _sync_text(text, managed)
        if error is not None:
            errors.append(f"{path}: {error}")
            continue
        if did_change:
            changed.append(path)
            if not args.check:
                path.write_text(new_text, encoding="utf-8")

    if errors:
        for message in errors:
            print(f"error: {message}", file=sys.stderr)
        return 1

    if changed:
        mode = "would update" if args.check else "updated"
        for path in changed:
            rel = path.relative_to(repo_root)
            print(f"{mode}: {rel}")
        return 1 if args.check else 0

    print("runtime_compatibility_sync_ok")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
