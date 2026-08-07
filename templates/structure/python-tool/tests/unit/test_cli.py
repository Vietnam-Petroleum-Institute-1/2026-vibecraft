from typer.testing import CliRunner

from src.cli import app

runner = CliRunner()


def test_hello_command() -> None:
    result = runner.invoke(app, ["hello", "--name", "VibeCraft"])
    assert result.exit_code == 0
    assert "Hello, VibeCraft!" in result.stdout


def test_version_command() -> None:
    result = runner.invoke(app, ["version"])
    assert result.exit_code == 0
