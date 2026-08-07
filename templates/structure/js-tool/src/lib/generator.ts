// Actual tool logic lives here — no CLI-framework imports, see AGENTS.md
// "Appendix – Plain script specifics".
export function generateGreeting(name: string): string {
  return `Hello, ${name}!`;
}

export function generateModuleScaffold(className: string): string {
  return `export class ${className} {\n  constructor() {}\n}\n`;
}
