import { getIcon } from '@/utils/icon-registry';

export type AppIconProps = {
  name?: string | null;
  className?: string;
};

// Reusable UI ONLY — no business logic, no API calls. See AGENTS.md
// "Frontend specifics". Renders an icon by (kebab-case) key from a
// statically-imported, curated set (utils/icon-registry.ts) — falls back
// to a fixed default for an unknown/missing key.
export function AppIcon({ name, className }: AppIconProps) {
  const Icon = getIcon(name);
  return <Icon className={className} />;
}
