// @vitest-environment jsdom
import { beforeEach, describe, expect, it } from "vitest";
import { FA_MESSAGES } from "./fa";
import {
  LANGUAGE_STORAGE_KEY,
  getLanguage,
  isRtlLanguage,
  parseLanguage,
  setLanguage,
} from "./languagePreference";
import { installPersianDateFormatting } from "./persianDates";
import { tl, tlt } from "./tl";

describe("admin language preference", () => {
  beforeEach(() => {
    localStorage.clear();
    setLanguage("en");
  });

  it("falls back to English for unknown values", () => {
    expect(parseLanguage("fa")).toBe("fa");
    expect(parseLanguage("de")).toBe("en");
    expect(parseLanguage(null)).toBe("en");
  });

  it("only Persian is right-to-left", () => {
    expect(isRtlLanguage("fa")).toBe(true);
    expect(isRtlLanguage("en")).toBe(false);
  });

  it("persists the choice and flips lang and dir on <html>", () => {
    setLanguage("fa");
    expect(getLanguage()).toBe("fa");
    expect(localStorage.getItem(LANGUAGE_STORAGE_KEY)).toBe("fa");
    expect(document.documentElement.getAttribute("dir")).toBe("rtl");
    setLanguage("en");
    expect(document.documentElement.getAttribute("dir")).toBe("ltr");
  });

  it("translates through tl/tlt and isolates interpolated values", () => {
    expect(tl("Reports")).toBe("Reports");
    setLanguage("fa");
    expect(tl("Reports")).toBe(FA_MESSAGES.Reports);
    expect(tl("Not in the catalogue")).toBe("Not in the catalogue");
    expect(tlt("Request failed ({0})", [500])).toContain("⁨500⁩");
  });

  it("formats dates with the Jalali calendar in Tehran time", () => {
    installPersianDateFormatting();
    const text = new Date(Date.UTC(2026, 9, 6, 8, 30)).toLocaleString("en-US", {
      year: "numeric",
      month: "numeric",
      day: "numeric",
      hour: "numeric",
      minute: "numeric",
    });
    expect(text).toMatch(/۱۴۰۵/);
    expect(text).toMatch(/۱۲:۰۰/);
  });
});
