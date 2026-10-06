import { Languages } from "lucide-react";
import { type Language, setLanguage } from "@/shared/i18n/languagePreference";
import { useTranslation } from "@/shared/i18n/useTranslation";
import { SegmentedControl } from "@/shared/ui/segmented-control";
import { SettingsOptionGroup, SettingsOptionRow } from "./SettingsOptionGroup";

/** Interface language picker; Persian also flips the layout to right-to-left. */
export function LanguageSettingsCard() {
  const { t, language } = useTranslation();

  return (
    <SettingsOptionGroup data-testid="appearance-language-card">
      <SettingsOptionRow data-testid="appearance-language-row">
        <div className="min-w-0">
          <p className="flex items-center gap-2 text-sm font-medium">
            <Languages aria-hidden className="h-4 w-4 text-muted-foreground" />
            {t("settings.language.title")}
          </p>
          <p
            className="text-sm font-normal text-muted-foreground/70"
            data-settings-subcopy
          >
            {t("settings.language.description")}
          </p>
        </div>
        <SegmentedControl<Language>
          indicatorTestId="appearance-language-indicator"
          legend={t("settings.language.title")}
          onValueChange={(next) => {
            setLanguage(next);
            // Strings are resolved when modules and components evaluate, so a
            // reload is the one way to re-render everything in the new language.
            window.location.reload();
          }}
          optionTestIdPrefix="appearance-language"
          options={[
            { value: "en", label: t("settings.language.en") },
            { value: "fa", label: t("settings.language.fa") },
          ]}
          testId="appearance-language-control"
          value={language}
        />
      </SettingsOptionRow>
    </SettingsOptionGroup>
  );
}
