/**
 * Give message blocks `dir="auto"` so each resolves its own direction.
 *
 * CSS `unicode-bidi: plaintext` already orders text per block, but list markers,
 * blockquote bars and alignment follow the element's own `direction`, so an
 * English bullet inside a Persian UI (or a Persian one in an English UI) would
 * keep its marker on the wrong side.
 * `dir="auto"` resolves the direction of each block from its content instead.
 */
const BLOCKS = "p, li, blockquote, h1, h2, h3, h4, h5, h6, td, th";
const SCOPE = ".message-markdown";

function markBlocks(root: ParentNode): void {
  for (const element of root.querySelectorAll<HTMLElement>(BLOCKS)) {
    if (!element.hasAttribute("dir") && element.closest(SCOPE)) {
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
        if (node.matches(BLOCKS) && node.closest(SCOPE)) {
          if (!node.hasAttribute("dir")) node.setAttribute("dir", "auto");
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
