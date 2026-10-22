import { ThemeGrainientBackground } from "@/app/ThemeGrainientBackground";
import { FlappingBee } from "@/shared/ui/corevia-talk-logo/FlappingBee";
import { tl } from "@/shared/i18n/tl";

/** Immediate feedback shown while the native huddle session is being prepared. */
export function HuddleStartingView() {
  return (
    <div
      aria-label={tl("Starting huddle")}
      className="corevia-talk-setup-loading-shell flex min-h-0 flex-1 items-center justify-center overflow-hidden px-6 text-foreground"
      data-testid="huddle-starting-view"
      role="status"
    >
      <ThemeGrainientBackground />
      <span className="sr-only">{tl("Starting huddle")}</span>
      <FlappingBee className="relative z-10 h-auto w-28" />
    </div>
  );
}
