import { expect, test } from "@playwright/test";

import { waitForAnimations } from "../helpers/animations";
import { installMockBridge } from "../helpers/bridge";

const SHOTS = "test-results/language-rtl";

test("switching to Persian flips the interface to right-to-left", async ({
  page,
}) => {
  await installMockBridge(page);
  await page.setViewportSize({ width: 1280, height: 720 });
  await page.goto("/", { waitUntil: "domcontentloaded" });
  await page.getByTestId("open-settings").click();
  await page.getByTestId("profile-popover-settings").click();
  await page.getByTestId("settings-nav-appearance").click();

  await expect(page.locator("html")).toHaveAttribute("dir", "ltr");
  await waitForAnimations(page);
  await page.screenshot({ path: `${SHOTS}/appearance-en.png` });

  await page.getByTestId("appearance-language-fa").click();
  await expect(page.locator("html")).toHaveAttribute("lang", "fa");
  await expect(page.locator("html")).toHaveAttribute("dir", "rtl");
  await expect(page.getByTestId("settings-nav-appearance")).toContainText(
    "ظاهر",
  );
  await waitForAnimations(page);
  await page.screenshot({ path: `${SHOTS}/appearance-fa.png` });

  await page.reload({ waitUntil: "domcontentloaded" });
  await expect(page.locator("html")).toHaveAttribute("dir", "rtl");

  await page.getByTestId("appearance-language-en").click();
  await expect(page.locator("html")).toHaveAttribute("dir", "ltr");
});
