"""File I/O helpers — kept separate from src/core/ so business logic never
does its own path handling / disk access, see AGENTS.md "Architecture
Rules"."""

from pathlib import Path


def write_text_file(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")
