"""Actual tool logic lives here — no CLI-framework imports, see AGENTS.md
"Appendix – Plain script specifics"."""


def generate_greeting(name: str) -> str:
    return f"Hello, {name}!"


def generate_module_scaffold(class_name: str) -> str:
    return f'''"""{class_name} module."""


class {class_name}:
    def __init__(self) -> None:
        pass
'''
