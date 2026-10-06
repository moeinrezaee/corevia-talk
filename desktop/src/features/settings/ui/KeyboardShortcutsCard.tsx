import {
  getShortcutsByCategory,
  getPlatformKeys,
  type KeyboardShortcut,
} from "@/shared/lib/keyboard-shortcuts";
import {
  SettingsOptionGroup,
  SettingsOptionGroupList,
  SettingsOptionRow,
} from "./SettingsOptionGroup";
import { SettingsSectionHeader } from "./SettingsSectionHeader";
import { tl } from "@/shared/i18n/tl";

function KeyCombo({ shortcut }: { shortcut: KeyboardShortcut }) {
  const keys = getPlatformKeys(shortcut);
  // Split on "+" but keep "+" as a standalone key (e.g. for zoom-in "⌘+")
  const parts = keys
    .split(/(?<!\+)\+(?!\s*$)/)
    .map((p) => p.trim())
    .filter(Boolean);

  return (
    <span className="flex items-center gap-1">
      {parts.map((part) => (
        <kbd
          className="inline-flex h-6 min-w-6 items-center justify-center rounded border border-border/70 bg-muted/60 px-1.5 font-mono text-xs text-muted-foreground"
          key={part}
        >
          {part}
        </kbd>
      ))}
    </span>
  );
}

export function KeyboardShortcutsCard() {
  const categories = getShortcutsByCategory();

  return (
    <section className="min-w-0" data-testid="settings-shortcuts">
      <SettingsSectionHeader
        title={tl("Keyboard shortcuts")}
        description={tl(
          "All available keyboard shortcuts. Shortcuts are read-only.",
        )}
      />

      <SettingsOptionGroupList>
        {[...categories.entries()].map(([category, shortcuts]) => (
          <SettingsOptionGroup key={category} title={category}>
            {shortcuts.map((shortcut) => (
              <SettingsOptionRow
                className="min-h-12 px-3 py-2"
                key={shortcut.id}
              >
                <div className="min-w-0 flex-1">
                  <span className="text-sm font-medium text-foreground">
                    {shortcut.label}
                  </span>
                  <span
                    className="ms-2 text-muted-foreground/70"
                    data-settings-subcopy
                  >
                    {shortcut.description}
                  </span>
                </div>
                <KeyCombo shortcut={shortcut} />
              </SettingsOptionRow>
            ))}
          </SettingsOptionGroup>
        ))}
      </SettingsOptionGroupList>
    </section>
  );
}
