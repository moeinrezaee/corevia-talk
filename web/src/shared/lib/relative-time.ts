import { tl, tlt } from "@/shared/i18n/tl";

/** Format a Unix timestamp (seconds) as a human-readable relative time string. */
export function relativeTime(unix: number): string {
  const diff = Date.now() - unix * 1000;
  const seconds = Math.floor(diff / 1000);
  const minutes = Math.floor(seconds / 60);
  const hours = Math.floor(minutes / 60);
  const days = Math.floor(hours / 24);

  if (days > 30) {
    const months = Math.floor(days / 30);
    return months === 1 ? tl("1 month ago") : tlt("{0} months ago", [months]);
  }
  if (days > 0) {
    return days === 1 ? tl("1 day ago") : tlt("{0} days ago", [days]);
  }
  if (hours > 0) {
    return hours === 1 ? tl("1 hour ago") : tlt("{0} hours ago", [hours]);
  }
  if (minutes > 0) {
    return minutes === 1
      ? tl("1 minute ago")
      : tlt("{0} minutes ago", [minutes]);
  }
  return tl("just now");
}

/**
 * Full date and time for a Unix timestamp (seconds), shown as a tooltip next to
 * the relative time. In the Persian UI the Intl proxy makes this Jalali in
 * Tehran time (see shared/i18n/persianDates.ts); English stays Gregorian.
 */
export function formatDateTime(unix: number): string {
  return new Date(unix * 1000).toLocaleString("en-US", {
    dateStyle: "medium",
    timeStyle: "short",
  });
}
