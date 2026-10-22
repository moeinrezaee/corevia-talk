import { isMacPlatform } from "@/shared/lib/platform";
import { tl } from "@/shared/i18n/tl";

export const HUDDLE_SHORTCUT_EVENT = "corevia-talk:huddle-shortcut";

export type HuddleShortcutDetail = {
  channelId: string;
};

export type ShortcutCategory =
  | "Navigation"
  | "Messages"
  | "Formatting"
  | "Zoom";

export type KeyboardShortcut = {
  id: string;
  label: string;
  description: string;
  keys: string;
  keysWindows: string;
  category: ShortcutCategory;
};

export const KEYBOARD_SHORTCUTS: KeyboardShortcut[] = [
  // Navigation
  {
    id: "quick-search",
    label: tl("Quick search"),
    description: tl("Open the search dialog"),
    keys: "⌘K",
    keysWindows: "Ctrl+K",
    category: "Navigation",
  },
  {
    id: "browse-channels",
    label: tl("Browse channels"),
    description: tl("Open the channel browser"),
    keys: "⇧⌘O",
    keysWindows: "Shift+Ctrl+O",
    category: "Navigation",
  },
  {
    id: "browse-dms",
    label: tl("New direct message"),
    description: tl("Open the new message composer"),
    keys: "⇧⌘K",
    keysWindows: "Shift+Ctrl+K",
    category: "Navigation",
  },
  {
    id: "new-channel",
    label: tl("New channel"),
    description: tl("Open the create channel dialog"),
    keys: "⇧⌘N",
    keysWindows: "Shift+Ctrl+N",
    category: "Navigation",
  },
  {
    id: "open-settings",
    label: tl("Settings"),
    description: tl("Open or close settings"),
    keys: "⌘,",
    keysWindows: "Ctrl+,",
    category: "Navigation",
  },
  {
    id: "go-back",
    label: tl("Go back"),
    description: tl("Navigate to the previous page"),
    keys: "⌘[",
    keysWindows: "Alt+←",
    category: "Navigation",
  },
  {
    id: "go-forward",
    label: tl("Go forward"),
    description: tl("Navigate to the next page"),
    keys: "⌘]",
    keysWindows: "Alt+→",
    category: "Navigation",
  },
  {
    id: "find-in-channel",
    label: tl("Find in channel"),
    description: tl("Search messages in current channel"),
    keys: "⌘F",
    keysWindows: "Ctrl+F",
    category: "Navigation",
  },
  {
    id: "go-home",
    label: tl("Home"),
    description: tl("Navigate to the home feed"),
    keys: "⇧⌘A",
    keysWindows: "Shift+Ctrl+A",
    category: "Navigation",
  },
  {
    id: "toggle-sidebar",
    label: tl("Toggle sidebar"),
    description: tl("Show or hide the sidebar"),
    keys: "⌘S",
    keysWindows: "Ctrl+S",
    category: "Navigation",
  },
  {
    id: "mark-current-read",
    label: tl("Mark as read"),
    description: tl("Mark the current conversation as read"),
    keys: "Escape",
    keysWindows: "Escape",
    category: "Navigation",
  },
  {
    id: "mark-all-read",
    label: tl("Mark all as read"),
    description: tl("Mark all conversations as read"),
    keys: "⇧Escape",
    keysWindows: "Shift+Escape",
    category: "Navigation",
  },

  // Zoom
  {
    id: "zoom-in",
    label: tl("Zoom in"),
    description: tl("Increase the zoom level"),
    keys: "⌘+",
    keysWindows: "Ctrl+=",
    category: "Zoom",
  },
  {
    id: "zoom-out",
    label: tl("Zoom out"),
    description: tl("Decrease the zoom level"),
    keys: "⌘-",
    keysWindows: "Ctrl+-",
    category: "Zoom",
  },
  {
    id: "zoom-reset",
    label: tl("Reset zoom"),
    description: tl("Reset zoom to default level"),
    keys: "⌘0",
    keysWindows: "Ctrl+0",
    category: "Zoom",
  },

  // Messages
  {
    id: "send-message",
    label: tl("Send message"),
    description: tl("Send the current message"),
    keys: "Enter",
    keysWindows: "Enter",
    category: "Messages",
  },
  {
    id: "new-line",
    label: tl("New line"),
    description: tl("Insert a line break in the composer"),
    keys: "Shift+Enter",
    keysWindows: "Shift+Enter",
    category: "Messages",
  },
  {
    id: "always-address-agent",
    label: tl("Always address agent"),
    description: tl(
      "Address the default agent, or toggle the highlighted agent",
    ),
    keys: "⇧⌘M",
    keysWindows: "Ctrl+Shift+M",
    category: "Messages",
  },
  {
    id: "publish-note",
    label: tl("Publish note"),
    description: tl("Publish a Pulse note"),
    keys: "⌘Enter",
    keysWindows: "Ctrl+Enter",
    category: "Messages",
  },
  {
    id: "close-dialog",
    label: tl("Close dialog"),
    description: tl("Close the current dialog or settings"),
    keys: "Escape",
    keysWindows: "Escape",
    category: "Messages",
  },
  {
    id: "toggle-huddle",
    label: tl("Start or leave huddle"),
    description: tl(
      "Start or join a huddle in the current channel; leave when connected",
    ),
    keys: "Ctrl+Shift+Space",
    keysWindows: "Ctrl+Shift+Space",
    category: "Messages",
  },
  {
    id: "push-to-talk",
    label: tl("Push to talk"),
    description: tl("Hold to unmute in a huddle"),
    keys: "Ctrl+Space",
    keysWindows: "Ctrl+Space",
    category: "Messages",
  },

  // Formatting
  {
    id: "format-bold",
    label: tl("Bold"),
    description: tl("Toggle bold formatting"),
    keys: "⌘B",
    keysWindows: "Ctrl+B",
    category: "Formatting",
  },
  {
    id: "format-italic",
    label: tl("Italic"),
    description: tl("Toggle italic formatting"),
    keys: "⌘I",
    keysWindows: "Ctrl+I",
    category: "Formatting",
  },
  {
    id: "format-strikethrough",
    label: tl("Strikethrough"),
    description: tl("Toggle strikethrough formatting"),
    keys: "⌘⇧X",
    keysWindows: "Ctrl+Shift+X",
    category: "Formatting",
  },
  {
    id: "format-code",
    label: tl("Inline code"),
    description: tl("Toggle inline code formatting"),
    keys: "⌘E",
    keysWindows: "Ctrl+E",
    category: "Formatting",
  },
  {
    id: "format-link",
    label: tl("Insert link"),
    description: tl(
      "Link the selected composer text, or edit the link under the caret",
    ),
    keys: "⌘K",
    keysWindows: "Ctrl+K",
    category: "Formatting",
  },
];

const CATEGORY_ORDER: ShortcutCategory[] = [
  "Navigation",
  "Messages",
  "Formatting",
  "Zoom",
];

export function getShortcutsByCategory(): Map<
  ShortcutCategory,
  KeyboardShortcut[]
> {
  const map = new Map<ShortcutCategory, KeyboardShortcut[]>();
  for (const cat of CATEGORY_ORDER) {
    map.set(
      cat,
      KEYBOARD_SHORTCUTS.filter((s) => s.category === cat),
    );
  }
  return map;
}

export function getPlatformKeys(shortcut: KeyboardShortcut): string {
  return isMacPlatform() ? shortcut.keys : shortcut.keysWindows;
}

/**
 * Platform-appropriate key hint for a shortcut in {@link KEYBOARD_SHORTCUTS},
 * or null when the id is unknown. Use this for inline hints (menus, tooltips)
 * so they stay in sync with the canonical shortcut registry.
 */
export function getPlatformKeysById(id: string): string | null {
  const shortcut = KEYBOARD_SHORTCUTS.find((s) => s.id === id);
  return shortcut ? getPlatformKeys(shortcut) : null;
}
