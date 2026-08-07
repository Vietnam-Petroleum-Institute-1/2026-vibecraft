import { Command } from 'commander';

import { generateGreeting, generateModuleScaffold } from '../lib/generator';
import { writeTextFile } from '../utils/file';

// CLI ONLY: argument parsing + delegate to src/lib/ — see AGENTS.md
// "Appendix – Plain script specifics". No business logic here.
export function buildProgram(): Command {
  const program = new Command();
  program.name('[PROJECT_NAME]').description('[PROJECT_NAME] CLI');

  program
    .command('hello')
    .argument('[name]', 'name to greet', 'world')
    .action((name: string) => {
      console.log(generateGreeting(name));
    });

  program
    .command('scaffold')
    .argument('<className>', 'class name to generate')
    .option('-o, --output-dir <dir>', 'output directory', '.')
    .action(async (className: string, opts: { outputDir: string }) => {
      const content = generateModuleScaffold(className);
      const target = `${opts.outputDir}/${className.toLowerCase()}.ts`;
      await writeTextFile(target, content);
      console.log(`Created ${target}`);
    });

  program
    .command('version')
    .action(() => {
      console.log('0.1.0');
    });

  return program;
}
