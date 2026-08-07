import { generateGreeting, generateModuleScaffold } from '../src/lib/generator';

describe('generateGreeting', () => {
  it('returns a greeting for the given name', () => {
    expect(generateGreeting('VibeCraft')).toBe('Hello, VibeCraft!');
  });
});

describe('generateModuleScaffold', () => {
  it('contains the class declaration', () => {
    expect(generateModuleScaffold('Widget')).toContain('export class Widget {');
  });
});
