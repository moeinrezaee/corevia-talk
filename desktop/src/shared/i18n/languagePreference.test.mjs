import assert from "node:assert/strict";
import test from "node:test";

const values = new Map();
const attributes = new Map();

globalThis.window = { addEventListener: () => {} };
globalThis.localStorage = {
  getItem: (key) => values.get(key) ?? null,
  setItem: (key, value) => values.set(key, String(value)),
};
globalThis.document = {
  documentElement: {
    setAttribute: (name, value) => attributes.set(name, value),
  },
};

const {
  LANGUAGE_STORAGE_KEY,
  getLanguage,
  initializeLanguagePreference,
  isRtlLanguage,
  parseLanguage,
  setLanguage,
} = await import("./languagePreference.ts");
const { MESSAGES } = await import("./messages.ts");
const { translate } = await import("./useTranslation.ts");

test("parseLanguage falls back to English for unknown values", () => {
  assert.equal(parseLanguage("fa"), "fa");
  assert.equal(parseLanguage("en"), "en");
  assert.equal(parseLanguage("de"), "en");
  assert.equal(parseLanguage(null), "en");
});

test("only Persian is right-to-left", () => {
  assert.equal(isRtlLanguage("fa"), true);
  assert.equal(isRtlLanguage("en"), false);
});

test("setLanguage persists the choice and flips lang and dir on the root", () => {
  setLanguage("fa");
  assert.equal(getLanguage(), "fa");
  assert.equal(values.get(LANGUAGE_STORAGE_KEY), "fa");
  assert.equal(attributes.get("lang"), "fa");
  assert.equal(attributes.get("dir"), "rtl");

  setLanguage("en");
  assert.equal(attributes.get("lang"), "en");
  assert.equal(attributes.get("dir"), "ltr");
});

test("initializeLanguagePreference restores the stored language", () => {
  values.set(LANGUAGE_STORAGE_KEY, "fa");
  initializeLanguagePreference();
  assert.equal(getLanguage(), "fa");
  assert.equal(attributes.get("dir"), "rtl");
});

test("every English message has a Persian translation", () => {
  for (const key of Object.keys(MESSAGES.en)) {
    assert.ok(MESSAGES.fa[key]?.length > 0, `missing fa translation: ${key}`);
  }
  assert.equal(
    translate("fa", "settings.profile"),
    MESSAGES.fa["settings.profile"],
  );
});

test("Persian date formatting uses the Jalali calendar and Tehran time", async () => {
  const { installPersianDateFormatting } = await import("./persianDates.ts");
  const instant = new Date(Date.UTC(2026, 9, 6, 8, 30));

  const gregorian = instant.toLocaleString("en-US", { timeZone: "UTC" });
  installPersianDateFormatting();

  // 2026-10-06 is 14 Mehr 1405; 08:30 UTC is 12:00 in Tehran (UTC+3:30).
  const persian = instant.toLocaleString("en-US", {
    year: "numeric",
    month: "numeric",
    day: "numeric",
    hour: "numeric",
    minute: "numeric",
  });
  assert.match(persian, /۱۴۰۵/);
  assert.match(persian, /۱۴/);
  assert.match(persian, /۱۲:۰۰/);
  assert.notEqual(persian, gregorian);

  const utc = new Intl.DateTimeFormat("en-US", {
    hour: "numeric",
    hourCycle: "h23",
    timeZone: "UTC",
  }).format(instant);
  assert.match(utc, /۸/);
});
