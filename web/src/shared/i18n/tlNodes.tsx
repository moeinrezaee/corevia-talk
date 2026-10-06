import * as React from "react";
import { tl } from "./tl";

/**
 * Translate a sentence that embeds React nodes (links, bold text) at numbered
 * placeholders, e.g. `tlNodes("I agree to the Buzz {0} and {1}.", [a, b])`.
 * The translated template decides where each node lands, so Persian word
 * order can differ from English.
 */
export function tlNodes(
  template: string,
  nodes: readonly React.ReactNode[],
): React.ReactNode[] {
  return tl(template)
    .split(/(\{\d+\})/)
    .map((part, position) => {
      const match = /^\{(\d+)\}$/.exec(part);
      // Parts alternate text / placeholder, so the position is a stable key.
      const key = `${position}`;
      return match ? (
        <React.Fragment key={key}>{nodes[Number(match[1])]}</React.Fragment>
      ) : (
        <React.Fragment key={key}>{part}</React.Fragment>
      );
    });
}
