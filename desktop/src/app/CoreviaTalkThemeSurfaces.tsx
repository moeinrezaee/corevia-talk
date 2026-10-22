import type { ReactNode } from "react";

export function GradientLayer() {
  return (
    <div
      aria-hidden="true"
      className="corevia-talk-theme-gradient-layer pointer-events-none absolute inset-0 -z-10"
      data-corevia-talk-gradient-layer
    >
      <div className="corevia-talk-theme-gradient-underlay absolute inset-0" />
      <div
        className="corevia-talk-theme-gradient-layer-light absolute inset-0 opacity-0"
        data-corevia-talk-gradient="light"
      />
      <div
        className="corevia-talk-theme-gradient-layer-dark absolute inset-0 opacity-0"
        data-corevia-talk-gradient="dark"
      />
    </div>
  );
}

export function ContentSurface({
  children,
  unframed = false,
  terminal,
}: {
  children: ReactNode;
  terminal?: ReactNode;
  /** Used by dedicated huddle windows, which should not resemble app cards. */
  unframed?: boolean;
}) {
  return (
    <div
      className={
        unframed
          ? "relative z-10 flex min-h-0 flex-1 flex-col overflow-hidden bg-background"
          : "relative z-10 mb-2 ml-px mr-2 mt-px flex min-h-0 flex-1 flex-col overflow-hidden rounded-2xl bg-background shadow-content-edge"
      }
      data-corevia-talk-content-surface
      data-corevia-talk-content-unframed={unframed ? true : undefined}
    >
      <div className="corevia-talk-content-primary flex min-h-0 flex-1 flex-col overflow-hidden">
        {children}
      </div>
      <div className="corevia-talk-terminal-dock-host" data-terminal-dock>
        {terminal}
      </div>
    </div>
  );
}
