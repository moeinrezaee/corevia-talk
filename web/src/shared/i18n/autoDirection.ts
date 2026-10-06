/**
 * Give message blocks `dir="auto"` so each resolves its own direction.
 *
 * CSS `unicode-bidi: plaintext` already orders text per block, but list markers,
 * blockquote bars and alignment follow the element's own `direction`, so an
 * English bullet inside a Persian UI (or a Persian one in an English UI) would
 * keep its marker on the wrong side.
 * `dir="auto"` resolves the direction of each block from its content instead.
 */
// Top-level blocks only: a `dir="auto"` element ignores descendants that carry
// their own `dir`, so marking a list item or a quoted paragraph as well would
// leave its quote/list container resolving to the UI direction. Nested blocks
// inherit the container's direction instead.
const BLOCKS = "p, h1, h2, h3, h4, h5, h6, table";
// Lists and quotes follow the UI direction (markers and bars stay on the UI
// start side, like the text alignment); only their text runs are ordered per
// item (rtl.css), so they are not marked and nothing inside them is.
const UI_ALIGNED = "li, blockquote";
const SCOPE = ".message-markdown";

function isTopLevel(element: Element): boolean {
  const scope = element.closest(SCOPE);
  if (!scope || element.closest(UI_ALIGNED)) return false;
  const container = element.parentElement?.closest(BLOCKS);
  return !container || !scope.contains(container);
}

function markBlocks(root: ParentNode): void {
  for (const element of root.querySelectorAll<HTMLElement>(BLOCKS)) {
    if (!element.hasAttribute("dir") && isTopLevel(element)) {
      element.setAttribute("dir", "auto");
    }
  }
}

/** Observe the document and tag message blocks as they render. */
export function installAutoDirection(): void {
  const root = globalThis.document?.body;
  if (!root || typeof MutationObserver === "undefined") return;

  let scheduled = false;
  const pending = new Set<Element>();
  const flush = () => {
    scheduled = false;
    for (const node of pending) {
      if (node.isConnected) {
        if (
          node.matches(BLOCKS) &&
          !node.hasAttribute("dir") &&
          isTopLevel(node)
        ) {
          node.setAttribute("dir", "auto");
        }
        markBlocks(node);
      }
    }
    pending.clear();
  };

  new MutationObserver((records) => {
    for (const record of records) {
      for (const node of record.addedNodes) {
        if (node instanceof Element) pending.add(node);
      }
    }
    if (pending.size > 0 && !scheduled) {
      scheduled = true;
      requestAnimationFrame(flush);
    }
  }).observe(root, { childList: true, subtree: true });

  markBlocks(root);
}
