import { Link } from "@tanstack/react-router";

import buzzAppIcon from "@/assets/app-icon@3x.png";
import { LanguageSwitch } from "@/shared/i18n/LanguageSwitch";
import { ThemeToggle } from "@/shared/theme/ThemeToggle";

/** Top bar: brand on the start side, language and theme controls on the end. */
export function AppHeader() {
  return (
    <header className="flex h-12 shrink-0 items-center justify-between border-b border-black/10 bg-[#F3F3F3] px-4 text-black dark:border-white/10 dark:bg-[#171717] dark:text-white">
      <Link to="/" className="flex items-center gap-2 font-semibold">
        <span
          className="h-6 w-6 overflow-hidden bg-black"
          style={{ borderRadius: "22.37%" }}
        >
          <img alt="" className="h-full w-full" src={buzzAppIcon} />
        </span>
        Buzz
      </Link>
      <div className="flex items-center gap-2">
        <LanguageSwitch />
        <ThemeToggle />
      </div>
    </header>
  );
}
