from src.core.generator import generate_greeting, generate_module_scaffold


def test_generate_greeting() -> None:
    assert generate_greeting("VibeCraft") == "Hello, VibeCraft!"


def test_generate_module_scaffold_contains_class_name() -> None:
    result = generate_module_scaffold("Widget")
    assert "class Widget:" in result
