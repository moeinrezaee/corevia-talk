import { FA_MESSAGES } from "./fa";

/**
 * Safety net for strings that never pass through `tl()`: relative times such as
 * "5m ago", plurals built in code ("4 new commits"), and sentences assembled
 * from template literals. Text nodes and a few attributes are translated in
 * place after render, using the same Persian catalogue plus a few rules.
 * User-written content (messages, the composer, code) is left untouched.
 */

/** Containers whose text is user content or code and is never translated. */
const SKIP_SELECTOR =
  "script, style, code, pre, [contenteditable], .message-markdown, .ProseMirror, .xterm, [data-no-translate]";
/** Form controls hold user input, but their placeholder text is still UI. */
const CONTROL_SELECTOR = "textarea, input";
const ATTRIBUTES = ["placeholder", "title", "aria-label", "alt"] as const;
const HAS_LATIN_WORD = /[A-Za-z]{2,}/;
const HAS_PERSIAN = /[؀-ۿ]/;

const NOUNS: Record<string, string> = {
  "new commit": "کامیت جدید",
  "active project": "پروژهٔ فعال",
  commit: "کامیت",
  task: "وظیفه",
  review: "بازبینی",
  project: "پروژه",
  repository: "مخزن",
  member: "عضو",
  agent: "ایجنت",
  channel: "کانال",
  message: "پیام",
  reply: "پاسخ",
  participant: "شرکت‌کننده",
  run: "اجرا",
  file: "فایل",
  line: "خط",
  draft: "پیش‌نویس",
  reminder: "یادآور",
  workflow: "گردش‌کار",
  team: "تیم",
  post: "پست",
  comment: "نظر",
  note: "یادداشت",
  contributor: "مشارکت‌کننده",
  runtime: "زمان‌اجرا",
  step: "مرحله",
  emoji: "ایموجی",
  entry: "ورودی",
  invite: "دعوت‌نامه",
  use: "بار استفاده",
};

const UNITS: Record<string, string> = {
  s: "ثانیه",
  second: "ثانیه",
  m: "دقیقه",
  minute: "دقیقه",
  h: "ساعت",
  hour: "ساعت",
  d: "روز",
  day: "روز",
  w: "هفته",
  week: "هفته",
  mo: "ماه",
  month: "ماه",
  y: "سال",
  year: "سال",
};

type Rule = [RegExp, (match: RegExpMatchArray) => string];

const RULES: Rule[] = [
  [/^just now$/i, () => "همین الان"],
  [
    /^(\d+)\s?(s|m|h|d|w|mo|y|second|minute|hour|day|week|month|year)s?\s+ago$/i,
    (m) => `${m[1]} ${UNITS[m[2].toLowerCase()]} پیش`,
  ],
  [/^Active (\d+)([smhdw]) ago$/, (m) => `فعال ${m[1]} ${UNITS[m[2]]} پیش`],
  [
    /^(\d+) (new commit|active project|[a-z]+?)s?( opened| created)?$/i,
    (m) => {
      const noun = NOUNS[m[2].toLowerCase()];
      if (!noun) return "";
      const suffix = m[3] ? " باز شد" : "";
      return `${m[1]} ${noun}${suffix}`;
    },
  ],
];

const FIRST_STRONG_ISOLATE = "\u2068";
const POP_ISOLATE = "\u2069";

/**
 * A key may become a template rule only when its fixed text is long enough to
 * be a real sentence and no placeholder is glued to letters (plural suffixes
 * such as "member{1}"). Otherwise "Add Trello board workflow details" would
 * match "{0} workflow{1}".
 */
function isSafeTemplate(key: string): boolean {
  if (!/\{\d+\}/.test(key)) return false;
  if (/[A-Za-z]\{\d+\}|\{\d+\}[A-Za-z]/.test(key)) return false;
  const fixed = key.replace(/\{\d+\}/g, "").trim();
  if (fixed.length < 8) return false;
  return !(key.startsWith("{0}") && fixed.length < 14);
}

const TEMPLATE_RULES: Rule[] = Object.entries(FA_MESSAGES)
  .filter(([key]) => isSafeTemplate(key))
  .sort((a, b) => b[0].length - a[0].length)
  .map(([key, value]): Rule => {
    const pattern = key
      .split(/\{\d+\}/)
      .map((part) => part.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"))
      .join("(.+?)");
    return [
      new RegExp(`^${pattern}$`, "s"),
      (m) =>
        value.replace(/\{(\d+)\}/g, (_x, i) => {
          const part = m[Number(i) + 1] ?? "";
          return part ? `${FIRST_STRONG_ISOLATE}${part}${POP_ISOLATE}` : "";
        }),
    ];
  });

/** Translate one rendered string, or return null to leave it alone. */
export function translateRendered(text: string): string | null {
  const trimmed = text.replace(/\s+/g, " ").trim();
  if (!trimmed || !HAS_LATIN_WORD.test(trimmed) || HAS_PERSIAN.test(trimmed)) {
    return null;
  }
  const exact = FA_MESSAGES[trimmed];
  if (exact !== undefined) return text.replace(trimmed, exact);
  for (const [pattern, build] of RULES) {
    const match = trimmed.match(pattern);
    if (match) {
      const out = build(match);
      if (out) return text.replace(trimmed, out);
    }
  }
  for (const [pattern, build] of TEMPLATE_RULES) {
    const match = trimmed.match(pattern);
    if (match) return text.replace(trimmed, build(match));
  }
  return null;
}

function skipped(node: Node): boolean {
  const element = node instanceof Element ? node : node.parentElement;
  return (
    !element ||
    element.closest(SKIP_SELECTOR) !== null ||
    element.closest(CONTROL_SELECTOR) !== null
  );
}

function translateTextNode(node: Text): void {
  const value = node.nodeValue;
  if (!value || skipped(node)) return;
  const next = translateRendered(value);
  if (next !== null && next !== value) node.nodeValue = next;
}

function translateAttributes(element: Element): void {
  if (element.closest(SKIP_SELECTOR)) return;
  for (const name of ATTRIBUTES) {
    const value = element.getAttribute(name);
    if (!value) continue;
    const next = translateRendered(value);
    if (next !== null && next !== value) element.setAttribute(name, next);
  }
}

function translateTree(root: Node): void {
  if (root.nodeType === Node.TEXT_NODE) {
    translateTextNode(root as Text);
    return;
  }
  if (!(root instanceof Element)) return;
  translateAttributes(root);
  const walker = document.createTreeWalker(
    root,
    NodeFilter.SHOW_TEXT | NodeFilter.SHOW_ELEMENT,
  );
  for (let node = walker.nextNode(); node; node = walker.nextNode()) {
    if (node.nodeType === Node.TEXT_NODE) translateTextNode(node as Text);
    else translateAttributes(node as Element);
  }
}

/** Translate the document now and keep translating whatever renders next. */
export function installDomTranslator(): void {
  const body = globalThis.document?.body;
  if (!body || typeof MutationObserver === "undefined") return;

  const pending = new Set<Node>();
  let scheduled = false;
  const flush = () => {
    scheduled = false;
    for (const node of pending) {
      if (node.isConnected) translateTree(node);
    }
    pending.clear();
  };
  const schedule = (node: Node) => {
    pending.add(node);
    if (!scheduled) {
      scheduled = true;
      requestAnimationFrame(flush);
    }
  };

  new MutationObserver((records) => {
    for (const record of records) {
      if (record.type === "childList") {
        for (const added of record.addedNodes) schedule(added);
      } else if (record.type === "characterData") {
        schedule(record.target);
      } else if (record.type === "attributes") {
        schedule(record.target);
      }
    }
  }).observe(body, {
    childList: true,
    subtree: true,
    characterData: true,
    attributes: true,
    attributeFilter: [...ATTRIBUTES],
  });

  translateTree(body);
}
