// Minimal className joiner — swap for clsx + tailwind-merge if class
// conflicts become a real problem (e.g. conditional Tailwind variants).
export function cn(...classes: Array<string | false | null | undefined>): string {
  return classes.filter(Boolean).join(' ');
}
