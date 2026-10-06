# Persian (fa) + RTL guidelines

Every client (desktop, mobile, admin-web, web) follows the same rules. English
stays untouched: left-to-right, Latin digits, Gregorian dates, local time zone.

## Language and text
1. The UI language is a user setting (English / فارسی), stored per client and
   applied without a visible half-translated screen. English string is the
   dictionary key; strings built in code, plurals, relative times, tooltips,
   placeholders and aria labels are translated too. Brand/technical names
   (Buzz, Nostr, npub) stay as is.
2. Persian uses **Peyda FaNum** with every shipped weight (ExtraLight, Regular,
   SemiBold, Bold, ExtraBold, Black, ExtraBlack). Digits are Persian in Persian
   text and Latin in English text.
3. Persian typed inside the English UI (messages, names, composer) is still
   drawn in Peyda (Arabic-script fallback); Latin text and ASCII digits stay in
   the English font.
4. Persian titles are one weight step heavier than English ones, and Persian
   text never gets letter-spacing (negative tracking breaks letter joins).
5. Persian UI only: Jalali (Shamsi) dates and the Asia/Tehran time zone.

## Layout and direction
6. Persian UI = right-to-left layout that is an exact mirror of the English
   layout (icons and arrows that point along the reading direction flip).
7. Text boxes, text areas, the composer and **their placeholders/hints** align
   with the UI: right in Persian, left in English, whatever is typed. Only the
   run order of mixed Persian/English text follows the typed text (bidi
   first-strong), with URLs, mentions and code isolated.
8. Select / combo boxes: the arrow and the label are the same distance from
   their edges, in both directions; the arrow sits on the end side.
9. Themes: light, dark and system stay in harmony.

## Chat
10. The sender (your own messages) sits on the reading-start side (right in
    Persian, left in English); the other person on the opposite side.
11. Every message is a rounded bubble that is only as wide as its text. Other
    people: neutral tint. Your own: light blue wash. **No borders** on bubbles.
12. Message text aligns with the UI (rule 7), not the message language. Lists
    and quotes follow the UI direction.
13. Block quotes: a distinct box with almost square corners and the quote bar on
    the start side.
14. Header: name next to the avatar, then time; the role line (agent owner,
    persona) sits under the name; the other person's header is the mirror image
    of yours. Names may use up to 80% of the room width.

## Process
Every change requested for one client applies to **all** clients (desktop,
mobile, admin-web, web) wherever the surface exists. Update this document when a
rule changes, then apply it everywhere and check each client visually.
