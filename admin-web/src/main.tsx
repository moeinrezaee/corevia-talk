import "./i18n/installPersianDates";
import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { App } from "./App";
import { installAutoDirection } from "./i18n/autoDirection";
import { installContentAlignment } from "./i18n/contentAlignment";
import { installDomTranslator } from "./i18n/domTranslator";
import {
  getLanguage,
  initializeLanguagePreference,
  isRtlLanguage,
} from "./i18n/languagePreference";
import "./styles.css";
import "./fonts-fa.css";
import "./rtl.css";

initializeLanguagePreference();

const root = document.getElementById("root");
if (!root) throw new Error("root element missing");
createRoot(root).render(
  <StrictMode>
    <App />
  </StrictMode>,
);

const language = getLanguage();
if (language === "fa") installDomTranslator();
installAutoDirection();
installContentAlignment(isRtlLanguage(language));
