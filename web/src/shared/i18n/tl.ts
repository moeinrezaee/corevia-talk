import { FA_MESSAGES } from "./fa";
import { getLanguage } from "./languagePreference";

const FIRST_STRONG_ISOLATE = "⁨";
const POP_ISOLATE = "⁩";

/**
 * Translate an English UI string into the active language. The English text is
 * the lookup key, so untranslated strings fall back to English unchanged.
 * The language is read when each call evaluates, so changing it reloads the
 * window (see `LanguageSettingsCard`).
 */
export function tl(text: string): string {
  return getLanguage() === "fa" ? (FA_MESSAGES[text] ?? text) : text;
}

/**
 * Translate a template whose dynamic parts are numbered placeholders, e.g.
 * `tlt("Search in {0}", [scope])`. The English template is the lookup key.
 */
export function tlt(template: string, args: readonly unknown[]): string {
  const rtl = getLanguage() === "fa";
  return tl(template).replace(/\{(\d+)\}/g, (_match, index) => {
    const value = String(args[Number(index)] ?? "");
    // Isolate the dynamic part so a Latin name or #channel inside a Persian
    // sentence keeps its own direction instead of reordering its neighbours.
    return rtl && value
      ? `${FIRST_STRONG_ISOLATE}${value}${POP_ISOLATE}`
      : value;
  });
}
