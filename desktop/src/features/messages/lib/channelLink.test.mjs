import assert from "node:assert/strict";
import test from "node:test";

import { isChannelLink, parseChannelLink } from "./channelLink.ts";

const CHANNEL_ID = "580ca78b-9dae-46f3-8854-bd671853ba32";
const MESSAGE_ID =
  "8455293f0123456789abcdef0123456789abcdef0123456789abcdef01234567";

test("parseChannelLink accepts the canonical channel path", () => {
  assert.deepEqual(parseChannelLink(`corevia-talk://channel/${CHANNEL_ID}`), {
    ok: true,
    value: { channelId: CHANNEL_ID },
  });
});

test("parseChannelLink accepts a channel message path", () => {
  assert.deepEqual(
    parseChannelLink(`corevia-talk://channel/${CHANNEL_ID}/${MESSAGE_ID}`),
    {
      ok: true,
      value: { channelId: CHANNEL_ID, messageId: MESSAGE_ID },
    },
  );
});

test("parseChannelLink accepts v7 and canonicalizes uppercase UUIDs", () => {
  assert.deepEqual(
    parseChannelLink("corevia-talk://channel/018fdb5d-3a64-7c35-b5f9-4a23e1f9d2d9"),
    {
      ok: true,
      value: { channelId: "018fdb5d-3a64-7c35-b5f9-4a23e1f9d2d9" },
    },
  );
  assert.deepEqual(
    parseChannelLink("corevia-talk://channel/580CA78B-9DAE-46F3-8854-BD671853BA32"),
    {
      ok: true,
      value: { channelId: "580ca78b-9dae-46f3-8854-bd671853ba32" },
    },
  );
});

test("parseChannelLink rejects malformed channel links", () => {
  for (const href of [
    "corevia-talk://channel",
    "corevia-talk://channel/",
    "corevia-talk://channel/one/two",
    `corevia-talk://channel/${CHANNEL_ID}/not-hex`,
    `corevia-talk://channel/${CHANNEL_ID}/${"a".repeat(63)}`,
    `corevia-talk://channel/${CHANNEL_ID}/${MESSAGE_ID}/extra`,
    `corevia-talk://channel/${CHANNEL_ID}/`,
    "corevia-talk://channel/one?extra=true",
    "corevia-talk://channel/one#fragment",
    "https://channel/one",
    "corevia-talk://channel/not-a-uuid",
    "corevia-talk://channel/%",
    "corevia-talk://channel/%ZZ",
    "corevia-talk://channel/%2F",
    "corevia-talk://channel/%00",
  ]) {
    assert.equal(parseChannelLink(href).ok, false, href);
  }
});

test("isChannelLink recognizes only a valid canonical link", () => {
  assert.equal(
    isChannelLink("corevia-talk://channel/580ca78b-9dae-46f3-8854-bd671853ba32"),
    true,
  );
  assert.equal(
    isChannelLink("corevia-talk://message?channel=channel-1&id=message-1"),
    false,
  );
});
