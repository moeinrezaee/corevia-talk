import { expect, test } from "@playwright/test";

import { waitForAnimations } from "../helpers/animations";
import { installMockBridge } from "../helpers/bridge";

const SHOTS = "test-results/language-fa-tour";

test("Persian tour of the main surfaces", async ({ page }) => {
  test.setTimeout(120_000);
  await page.addInitScript(() =>
    window.localStorage.setItem("corevia-talk.appearance.language", "fa"),
  );
  await installMockBridge(page);
  await page.setViewportSize({ width: 1280, height: 720 });
  await page.goto("/", { waitUntil: "domcontentloaded" });
  await expect(page.locator("html")).toHaveAttribute("dir", "rtl");
  await page.waitForTimeout(1500);
  await waitForAnimations(page);
  await page.screenshot({ path: `${SHOTS}/01-home.png` });

  await page.getByTestId("channel-general").click();
  await page.waitForTimeout(1200);
  await page.screenshot({ path: `${SHOTS}/02-channel.png` });

  for (const [name, label] of [
    ["03-pulse", "پالس"],
    ["04-projects", "پروژه‌ها"],
    ["05-agents", "ایجنت‌ها"],
    ["06-workflows", "گردش‌کارها"],
  ] as const) {
    await page.getByRole("button", { name: label }).first().click();
    await page.waitForTimeout(1200);
    await page.screenshot({ path: `${SHOTS}/${name}.png` });
  }

  await page.getByTestId("open-settings").click();
  await page.getByTestId("profile-popover-settings").click();
  for (const section of [
    "profile",
    "appearance",
    "notifications",
    "shortcuts",
  ]) {
    const nav = page.getByTestId(`settings-nav-${section}`);
    if (await nav.count()) {
      await nav.click();
      await page.waitForTimeout(1000);
      await page.screenshot({ path: `${SHOTS}/07-settings-${section}.png` });
    }
  }
});
