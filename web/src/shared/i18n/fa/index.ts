import { FA_COMMON } from "./common";
import { FA_INVITE } from "./invite";
import { FA_REPOS } from "./repos";

/** Persian translations for the web client, keyed by the English string. */
export const FA_MESSAGES: Record<string, string> = {
  ...FA_COMMON,
  ...FA_REPOS,
  ...FA_INVITE,
};
