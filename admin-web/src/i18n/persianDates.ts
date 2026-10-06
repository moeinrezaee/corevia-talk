/**
 * Persian dates: Solar Hijri (Jalali) calendar, Persian numerals, Tehran time.
 *
 * Every date in the app is formatted through `Intl.DateTimeFormat` or
 * `Date.prototype.toLocale*String`, many with an explicit `"en-US"` locale. Rather
 * than touch each call site, the Persian language swaps in a wrapper that
 * forces the calendar, locale and default time zone. A time zone passed
 * explicitly (for example `UTC`) is still respected. Other languages never
 * install it, so they keep the browser's Gregorian calendar and time zone.
 */

export const PERSIAN_DATE_LOCALE = "fa-IR-u-ca-persian";
export const TEHRAN_TIME_ZONE = "Asia/Tehran";

type DateFormatter = (
  this: Date,
  locales?: Intl.LocalesArgument,
  options?: Intl.DateTimeFormatOptions,
) => string;

let installed = false;

function withTehranDefaults(
  options: Intl.DateTimeFormatOptions | undefined,
): Intl.DateTimeFormatOptions {
  return { timeZone: TEHRAN_TIME_ZONE, ...options };
}

/** Patch the global date formatters. Safe to call more than once. */
export function installPersianDateFormatting(): void {
  if (installed) return;
  installed = true;

  const NativeDateTimeFormat = Intl.DateTimeFormat;
  Intl.DateTimeFormat = new Proxy(NativeDateTimeFormat, {
    apply: (target, _thisArg, args) =>
      Reflect.apply(target, undefined, [
        PERSIAN_DATE_LOCALE,
        withTehranDefaults(args[1]),
      ]),
    construct: (target, args, newTarget) =>
      Reflect.construct(
        target,
        [PERSIAN_DATE_LOCALE, withTehranDefaults(args[1])],
        newTarget,
      ),
  });

  for (const name of [
    "toLocaleString",
    "toLocaleDateString",
    "toLocaleTimeString",
  ] as const) {
    const native = Date.prototype[name] as DateFormatter;
    Date.prototype[name] = function (_locales, options) {
      return native.call(
        this,
        PERSIAN_DATE_LOCALE,
        withTehranDefaults(options),
      );
    } as DateFormatter;
  }
}
