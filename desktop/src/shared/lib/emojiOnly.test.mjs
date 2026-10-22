import assert from "node:assert/strict";
import test from "node:test";

import { isEmojiOnlyMessage } from "./emojiOnly.ts";

const CUSTOM_EMOJI = [
  { shortcode: "corevia-talk", url: "https://relay/corevia-talk.png" },
  { shortcode: "party_parrot", url: "https://relay/parrot.gif" },
];

test("detects unicode emoji-only messages", () => {
  assert.equal(isEmojiOnlyMessage("😀", CUSTOM_EMOJI), true);
  assert.equal(isEmojiOnlyMessage("😀 👍🏽\n❤️", CUSTOM_EMOJI), true);
  assert.equal(isEmojiOnlyMessage("🏳️‍🌈 👨‍👩‍👧‍👦", CUSTOM_EMOJI), true);
});

test("detects known custom emoji-only shortcode messages", () => {
  assert.equal(isEmojiOnlyMessage(":corevia-talk:", CUSTOM_EMOJI), true);
  assert.equal(isEmojiOnlyMessage(":corevia-talk: :party_parrot:", CUSTOM_EMOJI), true);
  assert.equal(isEmojiOnlyMessage(":Corevia Talk:", CUSTOM_EMOJI), true);
});

test("allows mixed unicode and custom emoji", () => {
  assert.equal(isEmojiOnlyMessage("😀 :corevia-talk: ❤️", CUSTOM_EMOJI), true);
});

test("rejects prose, markdown, and unknown shortcodes", () => {
  assert.equal(isEmojiOnlyMessage("hello 😀", CUSTOM_EMOJI), false);
  assert.equal(isEmojiOnlyMessage("😀!", CUSTOM_EMOJI), false);
  assert.equal(isEmojiOnlyMessage("**😀**", CUSTOM_EMOJI), false);
  assert.equal(isEmojiOnlyMessage(":unknown:", CUSTOM_EMOJI), false);
  assert.equal(isEmojiOnlyMessage("", CUSTOM_EMOJI), false);
});
