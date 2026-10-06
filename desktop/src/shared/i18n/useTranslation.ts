import * as React from "react";
import { type Language, useLanguage } from "./languagePreference";
import { MESSAGES, type MessageKey } from "./messages";

export function translate(language: Language, key: MessageKey): string {
  return MESSAGES[language][key] ?? MESSAGES.en[key];
}

/** Translate a message key into the active interface language. */
export function useTranslation() {
  const language = useLanguage();
  const t = React.useCallback(
    (key: MessageKey) => translate(language, key),
    [language],
  );
  return { t, language };
}
