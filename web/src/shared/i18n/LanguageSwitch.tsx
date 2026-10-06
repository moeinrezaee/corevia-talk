import { cn } from "@/shared/lib/cn";
import {
  type Language,
  getLanguage,
  setLanguage,
  useLanguage,
} from "./languagePreference";

const OPTIONS: ReadonlyArray<{ value: Language; label: string }> = [
  { value: "en", label: "English" },
  { value: "fa", label: "فارسی" },
];

/**
 * Visible English | فارسی switch. Strings are read when each module call
 * evaluates, so a change reloads the page instead of showing a half-translated
 * screen.
 */
export function LanguageSwitch({ className }: { className?: string }) {
  const language = useLanguage();

  const choose = (next: Language) => {
    if (next === getLanguage()) return;
    setLanguage(next);
    window.location.reload();
  };

  return (
    <fieldset
      className={cn(
        "m-0 inline-flex items-center gap-0.5 rounded-full border-0 bg-black/5 p-0.5 dark:bg-white/10",
        className,
      )}
      aria-label="Language / زبان"
      data-no-translate
      dir="ltr"
    >
      {OPTIONS.map((option) => {
        const active = option.value === language;
        return (
          <button
            key={option.value}
            type="button"
            lang={option.value}
            aria-pressed={active}
            onClick={() => choose(option.value)}
            className={cn(
              "rounded-full px-3 py-1 text-xs font-medium leading-5 transition-colors focus-visible:outline-2 focus-visible:outline-offset-1 focus-visible:outline-black dark:focus-visible:outline-white",
              active
                ? "bg-black text-white dark:bg-white dark:text-black"
                : "text-black/60 hover:text-black dark:text-white/60 dark:hover:text-white",
            )}
          >
            {option.label}
          </button>
        );
      })}
    </fieldset>
  );
}
