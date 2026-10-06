import { Moon, Sun, Monitor } from "lucide-react";
import { tl, tlt } from "@/shared/i18n/tl";
import { useTheme } from "@/shared/theme/ThemeProvider";
import { Button } from "@/shared/ui/button";

const icons = {
  light: Sun,
  dark: Moon,
  system: Monitor,
} as const;

const themeNames: Record<string, string> = {
  light: "Light",
  dark: "Dark",
  system: "System",
};

const next: Record<string, "dark" | "system" | "light"> = {
  light: "dark",
  dark: "system",
  system: "light",
};

export function ThemeToggle() {
  const { theme, setTheme } = useTheme();
  const Icon = icons[theme];

  return (
    <Button
      variant="ghost"
      size="icon"
      className="h-8 w-8 text-black hover:bg-black/5 hover:text-black dark:text-white dark:hover:bg-white/10 dark:hover:text-white"
      onClick={() => setTheme(next[theme])}
      aria-label={tlt("Theme: {0}. Click to switch.", [tl(themeNames[theme])])}
    >
      <Icon className="h-4 w-4" />
    </Button>
  );
}
