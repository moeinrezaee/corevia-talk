// @vitest-environment jsdom
import { beforeEach, describe, expect, it } from "vitest";
import { relativeTime } from "../lib/relative-time";
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
import { translateRendered } from "./domTranslator";

describe("web language preference", () => {
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

  it("persists the choice under buzz.web.language and flips lang/dir", () => {
    setLanguage("fa");
    expect(getLanguage()).toBe("fa");
    expect(LANGUAGE_STORAGE_KEY).toBe("buzz.web.language");
    expect(localStorage.getItem(LANGUAGE_STORAGE_KEY)).toBe("fa");
    expect(document.documentElement.getAttribute("lang")).toBe("fa");
    expect(document.documentElement.getAttribute("dir")).toBe("rtl");
    setLanguage("en");
    expect(document.documentElement.getAttribute("dir")).toBe("ltr");
  });
});

describe("tl / tlt", () => {
  beforeEach(() => setLanguage("en"));

  it("leaves English untouched", () => {
    expect(tl("Repositories")).toBe("Repositories");
    expect(tlt("{0} branches", [3])).toBe("3 branches");
  });

  it("translates in Persian, falls back to the key, isolates arguments", () => {
    setLanguage("fa");
    expect(tl("Repositories")).toBe(FA_MESSAGES.Repositories);
    expect(tl("Not in the catalogue")).toBe("Not in the catalogue");
    expect(tlt("{0} branches", [3])).toBe("⁨3⁩ شاخه");
  });

  it("safety-net translator handles catalogue strings and templates", () => {
    expect(translateRendered("Repositories")).toBe(FA_MESSAGES.Repositories);
    expect(translateRendered("5 minutes ago")).toBe("5 دقیقه پیش");
    expect(translateRendered("خانه")).toBeNull();
  });
});

describe("relative time", () => {
  const ago = (seconds: number) => Math.floor(Date.now() / 1000) - seconds;

  beforeEach(() => setLanguage("en"));

  it("is English by default", () => {
    expect(relativeTime(ago(5))).toBe("just now");
    expect(relativeTime(ago(60 * 5))).toBe("5 minutes ago");
    expect(relativeTime(ago(3600))).toBe("1 hour ago");
    expect(relativeTime(ago(86400 * 3))).toBe("3 days ago");
  });

  it("is Persian in the Persian UI", () => {
    setLanguage("fa");
    expect(relativeTime(ago(5))).toBe("همین الان");
    expect(relativeTime(ago(3600))).toBe("۱ ساعت پیش");
    expect(relativeTime(ago(86400 * 3))).toContain("روز پیش");
  });
});

describe("Persian dates", () => {
  it("formats with the Jalali calendar in Tehran time once installed", () => {
    const instant = new Date(Date.UTC(2026, 9, 6, 8, 30));
    const english = instant.toLocaleString("en-US", {
      dateStyle: "medium",
      timeStyle: "short",
      timeZone: "UTC",
    });
    expect(english).toContain("2026");
    installPersianDateFormatting();
    const text = instant.toLocaleString("en-US", {
      dateStyle: "medium",
      timeStyle: "short",
    });
    expect(text).toContain("۱۴۰۵");
    // 08:30 UTC is 12:00 in Tehran (UTC+3:30).
    expect(text).toContain("۱۲:۰۰");
  });
});

const SOURCES = import.meta.glob<string>("/src/**/*.{ts,tsx}", {
  query: "?raw",
  import: "default",
  eager: true,
});

describe("Persian catalogue coverage", () => {
  it("has an entry for every literal passed to tl(), tlt() and tlNodes()", () => {
    const missing: string[] = [];
    for (const [file, text] of Object.entries(SOURCES)) {
      if (file.includes("/shared/i18n/") || file.endsWith(".test.ts")) continue;
      for (const match of text.matchAll(
        /\b(?:tl|tlt|tlNodes)\(\s*("(?:[^"\\]|\\.)*")/g,
      )) {
        const key = JSON.parse(match[1]) as string;
        if (!(key in FA_MESSAGES)) missing.push(`${file}: ${key}`);
      }
    }
    expect(missing).toEqual([]);
  });

  it("keeps placeholders consistent between English and Persian", () => {
    const holes = (text: string) =>
      (text.match(/\{\d+\}/g) ?? []).sort().join(",");
    for (const [key, value] of Object.entries(FA_MESSAGES)) {
      expect(holes(value), key).toBe(holes(key));
    }
  });
});
