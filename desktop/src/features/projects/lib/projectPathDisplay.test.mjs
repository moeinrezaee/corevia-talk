import assert from "node:assert/strict";
import test from "node:test";

import { shortenProjectPath } from "./projectPathDisplay.ts";

test("keeps short repository paths intact", () => {
  assert.equal(shortenProjectPath("repos/corevia-talk"), "repos/corevia-talk");
});

test("shortens long repository paths to their trailing segments", () => {
  assert.equal(
    shortenProjectPath("/Users/sample-user/sprout/projects/corevia-talk"),
    "…/sprout/projects/corevia-talk",
  );
});

test("normalizes Windows separators for display", () => {
  assert.equal(
    shortenProjectPath("C:\\Users\\sample-user\\repos\\corevia-talk"),
    "…/sample-user/repos/corevia-talk",
  );
});
