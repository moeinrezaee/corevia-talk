import * as React from "react";

/** Interface languages the desktop app ships translations for. */
export type Language = "en" | "fa";

export const LANGUAGE_STORAGE_KEY = "corevia-talk.appearance.language";
export const DEFAULT_LANGUAGE: Language = "en";

/** Languages written right to left; the document direction follows these. */
const RTL_LANGUAGES: ReadonlySet<Language> = new Set(["fa"]);

export function isRtlLanguage(language: Language): boolean {
  return RTL_LANGUAGES.has(language);
}

const listeners = new Set<() => void>();
let listeningForStorageChanges = false;

export function parseLanguage(value: string | null | undefined): Language {
  return value === "en" || value === "fa" ? value : DEFAULT_LANGUAGE;
}

function readStoredLanguage(): Language {
  try {
    return parseLanguage(
      globalThis.localStorage?.getItem(LANGUAGE_STORAGE_KEY),
    );
  } catch {
    return DEFAULT_LANGUAGE;
  }
}

let language: Language = readStoredLanguage();

/** Mirror the language onto `<html lang dir>` so CSS and the browser follow it. */
function applyLanguage(next: Language): void {
  const root = globalThis.document?.documentElement;
  if (!root) return;
  root.setAttribute("lang", next);
  root.setAttribute("dir", isRtlLanguage(next) ? "rtl" : "ltr");
}

function notifyListeners(): void {
  for (const listener of listeners) listener();
}

function applyStoredLanguage(): void {
  const next = readStoredLanguage();
  const changed = next !== language;
  language = next;
  applyLanguage(next);
  if (changed) notifyListeners();
}

function listenForStorageChanges(): void {
  if (listeningForStorageChanges || !globalThis.window?.addEventListener)
    return;
  globalThis.window.addEventListener("storage", (event) => {
    if (event.key === LANGUAGE_STORAGE_KEY || event.key === null) {
      applyStoredLanguage();
    }
  });
  listeningForStorageChanges = true;
}

/** Apply the persisted language before React renders to avoid a layout flip. */
export function initializeLanguagePreference(): void {
  applyStoredLanguage();
  listenForStorageChanges();
}

function subscribe(listener: () => void): () => void {
  listeners.add(listener);
  return () => listeners.delete(listener);
}

export function getLanguage(): Language {
  return language;
}

export function setLanguage(next: Language): void {
  language = next;
  applyLanguage(next);
  try {
    globalThis.localStorage?.setItem(LANGUAGE_STORAGE_KEY, next);
  } catch {
    // Persistence is best-effort; the live preference still applies.
  }
  notifyListeners();
}

export function useLanguage(): Language {
  return React.useSyncExternalStore(
    subscribe,
    getLanguage,
    () => DEFAULT_LANGUAGE,
  );
}
