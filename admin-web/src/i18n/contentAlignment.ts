/**
 * Keep the right-to-left layout an exact mirror of the left-to-right one.
 *
 * `unicode-bidi: plaintext` (rtl.css) orders each text block by its own first
 * strong character, which is right for punctuation, but it also makes the
 * browser resolve the block's direction from its content, so `text-align:
 * start` follows the content instead of the UI. An English line in the Persian
 * UI would hug the left edge, and a Persian message in the English UI would hug
 * the right one.
 *
 * Blocks whose content direction differs from the UI direction and that use the
 * default alignment are marked, and rtl.css aligns them with the UI:
 *   - `data-ltr-text`: English-first text in the Persian UI -> right edge.
 *   - `data-rtl-text`: Persian-first text in the English UI -> left edge.
 * Chat content is the exception: each message block (and the composer) keeps
 * the direction of its own text, Persian right and English left, in either UI
 * language (see autoDirection.ts and rtl.css). Centered, explicitly aligned,
 * code and form-control content is left alone too.
 */
const SKIP =
  "pre, code, .xterm, input, textarea, [contenteditable], .ProseMirror, .message-markdown :is(p, li, blockquote, h1, h2, h3, h4, h5, h6, td, th), [data-no-align]";
const LATIN_FIRST = /^[^\p{L}]*[A-Za-z]/u;
const PERSIAN_FIRST = /^[^\p{L}]*[؀-ۿ]/u;

function blockOf(node: Node): HTMLElement | null {
  let element = node.parentElement;
  while (element && getComputedStyle(element).display.startsWith("inline")) {
    element = element.parentElement;
  }
  return element && element !== document.body ? element : null;
}

function markText(node: Node, uiIsRtl: boolean): void {
  const text = node.nodeValue?.trim();
  if (!text) return;
  const contentFirst = uiIsRtl ? LATIN_FIRST : PERSIAN_FIRST;
  if (!contentFirst.test(text)) return;
  const parent = node.parentElement;
  if (!parent || parent.closest(SKIP)) return;
  const block = blockOf(node);
  const attribute = uiIsRtl ? "data-ltr-text" : "data-rtl-text";
  if (!block || block.hasAttribute(attribute)) return;
  if (!contentFirst.test((block.textContent ?? "").trim())) return;
  if (getComputedStyle(block).textAlign === "start") {
    block.setAttribute(attribute, "");
  }
}

function markTree(root: Node, uiIsRtl: boolean): void {
  if (root.nodeType === Node.TEXT_NODE) {
    markText(root, uiIsRtl);
    return;
  }
  if (!(root instanceof Element)) return;
  const walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT);
  for (let node = walker.nextNode(); node; node = walker.nextNode()) {
    markText(node, uiIsRtl);
  }
}

/** Mark mismatched-direction blocks now and as the UI renders more of them. */
export function installContentAlignment(uiIsRtl: boolean): void {
  const body = globalThis.document?.body;
  if (!body || typeof MutationObserver === "undefined") return;

  const pending = new Set<Node>();
  let scheduled = false;
  const flush = () => {
    scheduled = false;
    for (const node of pending) {
      if (node.isConnected) markTree(node, uiIsRtl);
    }
    pending.clear();
  };

  new MutationObserver((records) => {
    for (const record of records) {
      if (record.type === "characterData") pending.add(record.target);
      else for (const added of record.addedNodes) pending.add(added);
    }
    if (pending.size > 0 && !scheduled) {
      scheduled = true;
      // After the translator's own frame, so text is already in its final form.
      requestAnimationFrame(() => requestAnimationFrame(flush));
    }
  }).observe(body, { childList: true, subtree: true, characterData: true });

  markTree(body, uiIsRtl);
}
