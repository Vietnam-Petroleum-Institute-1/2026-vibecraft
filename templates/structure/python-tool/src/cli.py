"""CLI ONLY: argument parsing + delegate to src/core/ — see AGENTS.md
"Appendix – Plain script specifics". No business logic here."""

from pathlib import Path

import typer

from src.config import TOOL_NAME, VERSION
from src.core.generator import generate_greeting, generate_module_scaffold
from src.utils.file import write_text_file

app = typer.Typer(name=TOOL_NAME, help=f"{TOOL_NAME} CLI")


@app.command()
def hello(name: str = "world") -> None:
    """Print a greeting."""
    typer.echo(generate_greeting(name))


@app.command()
def scaffold(class_name: str, output_dir: Path = Path(".")) -> None:
    """Generate a minimal Python module file for CLASS_NAME."""
    content = generate_module_scaffold(class_name)
    target = output_dir / f"{class_name.lower()}.py"
    write_text_file(target, content)
    typer.echo(f"Created {target}")


@app.command()
def version() -> None:
    """Print the tool version."""
    typer.echo(VERSION)


if __name__ == "__main__":
    app()
