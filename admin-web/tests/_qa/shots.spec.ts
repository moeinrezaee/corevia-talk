import { test } from "@playwright/test";

const OUT = "/tmp/claude-0/-home-user-corevia-talk/a3bad1cb-7dfd-512c-8211-950ac4f580d4/scratchpad/qa";
const reports = [
  { id: "r1", communityId: "c1", communityHost: "design.buzz.xyz", reporterPubkey: "ab".repeat(32), targetKind: "event", target: "cd".repeat(32), reportType: "spam", note: "این پیام تبلیغاتی است / looks like an ad", status: "open", createdAt: "2026-10-05T10:30:00Z" },
  { id: "r2", communityId: "c2", communityHost: "eng.buzz.xyz", reporterPubkey: "12".repeat(32), targetKind: "pubkey", target: "34".repeat(32), reportType: "impersonation", status: "open", createdAt: "2026-10-04T08:00:00Z" },
];
const feedback = [
  { id: "f1", communityId: "c1", communityHost: "design.buzz.xyz", submitterPubkey: "21".repeat(32), category: "bug", bodySummary: "Composer froze on paste. ویرایشگر هنگام چسباندن قفل شد.", status: "new", receivedAt: "2026-10-05T17:30:00Z" },
  { id: "f2", communityId: "c2", communityHost: "eng.buzz.xyz", submitterPubkey: "43".repeat(32), category: "praise", bodySummary: "Love the new sidebar!", status: "reviewed", receivedAt: "2026-10-03T09:10:00Z" },
];
for (const lang of ["fa", "en"]) test(`admin ${lang}`, async ({ page }) => {
  await page.addInitScript((l) => window.localStorage.setItem("buzz.admin.language", l), lang);
  await page.route("**/api/admin/v1/reports*", (r) => r.fulfill({ contentType: "application/json", body: JSON.stringify(reports) }));
  await page.route("**/api/admin/v1/feedback", (r) => r.fulfill({ contentType: "application/json", body: JSON.stringify(feedback) }));
  await page.setViewportSize({ width: 1280, height: 800 });
  await page.goto("/reports");
  await page.waitForTimeout(1500);
  await page.screenshot({ path: `${OUT}/admin-${lang}-reports.png` });
  await page.goto("/feedback");
  await page.waitForTimeout(1500);
  await page.screenshot({ path: `${OUT}/admin-${lang}-feedback.png` });
});
