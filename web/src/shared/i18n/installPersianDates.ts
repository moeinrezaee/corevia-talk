import { getLanguage } from "./languagePreference";
import { installPersianDateFormatting } from "./persianDates";

// Imported first in main.tsx so module-level `Intl.DateTimeFormat` constants
// created by later imports already pick up the Persian calendar.
if (getLanguage() === "fa") {
  installPersianDateFormatting();
}
