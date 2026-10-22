import { expect, test } from "@playwright/test";

import { installMockBridge } from "../helpers/bridge";

test("Persian font resolves each weight to a shipped Peyda file", async ({
  page,
}) => {
  await page.addInitScript(() =>
    window.localStorage.setItem("corevia-talk.appearance.language", "fa"),
  );
  await installMockBridge(page);
  await page.goto("/", { waitUntil: "domcontentloaded" });
  const loaded = await page.evaluate(async () => {
    const out: Record<string, boolean> = {};
    for (const w of [200, 300, 400, 500, 600, 700, 800, 900, 950]) {
      const faces = await document.fonts.load(
        `${w} 16px "Peyda FaNum"`,
        "۱۲۳ ا",
      );
      out[String(w)] = faces.length > 0;
    }
    return out;
  });
  for (const ok of Object.values(loaded)) expect(ok).toBe(true);
  await expect(
    page.evaluate(() => getComputedStyle(document.body).fontFamily),
  ).resolves.toContain("Peyda FaNum");
});
