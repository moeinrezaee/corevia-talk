import assert from "node:assert/strict";
import test from "node:test";

import {
  DEFAULT_ACP_COMMAND_VALUE,
  acpCommandPickerState,
} from "./acpCommandPicker.ts";

const candidate = {
  command: "corevia-talk-janet-acp",
  binaryPath: "/bin/corevia-talk-janet-acp",
};

test("stock and discovered commands select discovered options", () => {
  const defaultState = acpCommandPickerState("corevia-talk-acp", [candidate]);
  assert.equal(defaultState.selectValue, "corevia-talk-acp");
  assert.deepEqual(defaultState.options, [
    { label: "Corevia Talk ACP (default)", value: "corevia-talk-acp" },
    { label: "corevia-talk-janet-acp", value: "corevia-talk-janet-acp" },
  ]);

  assert.equal(
    acpCommandPickerState("corevia-talk-janet-acp", [candidate]).selectValue,
    "corevia-talk-janet-acp",
  );
});

test("an empty command selects the stock default", () => {
  assert.equal(
    acpCommandPickerState("", [candidate]).selectValue,
    DEFAULT_ACP_COMMAND_VALUE,
  );
});

test("a persisted unknown command is preserved as a read-only current option", () => {
  const state = acpCommandPickerState("my-acp", [candidate]);
  assert.equal(state.selectValue, "my-acp");
  assert.deepEqual(state.options.at(-1), {
    disabled: true,
    label: "my-acp (unavailable)",
    value: "my-acp",
  });
});

test("late discovery replaces the current marker without changing the command", () => {
  const before = acpCommandPickerState("corevia-talk-janet-acp", []);
  assert.deepEqual(before.options.at(-1), {
    disabled: true,
    label: "corevia-talk-janet-acp (unavailable)",
    value: "corevia-talk-janet-acp",
  });

  const after = acpCommandPickerState("corevia-talk-janet-acp", [candidate]);
  assert.equal(after.selectValue, "corevia-talk-janet-acp");
  assert.deepEqual(after.options.at(-1), {
    label: "corevia-talk-janet-acp",
    value: "corevia-talk-janet-acp",
  });
});
