import { mkdir, writeFile } from 'node:fs/promises';
import { dirname } from 'node:path';

// File I/O helpers — kept separate from src/lib/ so business logic never
// does its own path handling / disk access, see AGENTS.md "Architecture
// Rules".
export async function writeTextFile(path: string, content: string): Promise<void> {
  await mkdir(dirname(path), { recursive: true });
  await writeFile(path, content, 'utf-8');
}
