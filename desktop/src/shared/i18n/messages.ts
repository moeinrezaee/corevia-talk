import type { Language } from "./languagePreference";

/** English is the source of truth; every other language mirrors its keys. */
const en = {
  "settings.appearance": "Appearance",
  "settings.appearance.description": "Choose how Corevia Talk looks and feels.",
  "settings.profile": "Profile",
  "settings.notifications": "Notifications",
  "settings.voice": "Voice",
  "settings.language.title": "Language",
  "settings.language.description":
    "Choose the interface language. Persian switches the layout to right-to-left.",
  "settings.language.en": "English",
  "settings.language.fa": "فارسی",
  "settings.colorMode": "Color mode",
  "settings.colorMode.description":
    "Follow your system or choose a light or dark appearance.",
  "settings.colorMode.system": "System",
  "settings.colorMode.light": "Light",
  "settings.colorMode.dark": "Dark",
  "settings.themeStyle": "Theme style",
  "settings.themeStyle.description": "Choose the colors used throughout Corevia Talk.",
} as const;

export type MessageKey = keyof typeof en;

const fa: Record<MessageKey, string> = {
  "settings.appearance": "ظاهر",
  "settings.appearance.description": "ظاهر و حس‌وحال Corevia Talk را انتخاب کنید.",
  "settings.profile": "نمایه",
  "settings.notifications": "اعلان‌ها",
  "settings.voice": "صدا",
  "settings.language.title": "زبان",
  "settings.language.description":
    "زبان رابط کاربری را انتخاب کنید. با انتخاب فارسی، چیدمان راست‌به‌چپ می‌شود.",
  "settings.language.en": "English",
  "settings.language.fa": "فارسی",
  "settings.colorMode": "حالت رنگ",
  "settings.colorMode.description":
    "از سیستم پیروی کنید یا ظاهر روشن یا تیره را انتخاب کنید.",
  "settings.colorMode.system": "سیستم",
  "settings.colorMode.light": "روشن",
  "settings.colorMode.dark": "تیره",
  "settings.themeStyle": "سبک تم",
  "settings.themeStyle.description":
    "رنگ‌های مورد استفاده در Corevia Talk را انتخاب کنید.",
};

export const MESSAGES: Record<Language, Record<MessageKey, string>> = {
  en,
  fa,
};
