import 'package:flutter/widgets.dart';

final _letter = RegExp(r'\p{L}', unicode: true);

bool _isRtlRune(int rune) =>
    (rune >= 0x0590 && rune <= 0x08FF) ||
    (rune >= 0xFB1D && rune <= 0xFDFF) ||
    (rune >= 0xFE70 && rune <= 0xFEFF);

/// The direction of [text], from its first strong letter (the rule behind
/// HTML's `dir="auto"`): Arabic-script and Hebrew text runs right to left,
/// any other letter runs left to right. Returns null when there is no letter
/// yet (digits, symbols, emoji, or an empty string), so callers can keep the
/// inherited direction.
TextDirection? detectTextDirection(String text) {
  for (final rune in text.runes) {
    if (_isRtlRune(rune)) return TextDirection.rtl;
    if (_letter.hasMatch(String.fromCharCode(rune))) return TextDirection.ltr;
  }
  return null;
}

/// Physical text alignment for message and composer text: the UI direction's
/// start edge (right in Persian/RTL mode, left in English/LTR mode),
/// regardless of the script the text is written in. Only the order of runs
/// inside a paragraph follows the text's own direction ([detectTextDirection]).
TextAlign uiStartTextAlign(BuildContext context) =>
    Directionality.of(context) == TextDirection.rtl
    ? TextAlign.right
    : TextAlign.left;

// Built from code points: a literal bidi control character in source trips the
// text_direction_code_point_in_literal lint.
final _firstStrongIsolate = String.fromCharCode(0x2068);
final _popIsolate = String.fromCharCode(0x2069);

/// Wraps [text] in a first-strong isolate (FSI ... PDI) so a run of opposite
/// direction (a URL, @mention, #channel, code span or number) cannot reorder
/// the words around it in a generated string.
String isolateBidi(String text) =>
    text.isEmpty ? text : '$_firstStrongIsolate$text$_popIsolate';

/// Mirrors [child] horizontally in right-to-left layouts, for directional
/// glyphs (chevrons, back arrows) that are not mirrored by their icon font.
class BidiFlip extends StatelessWidget {
  const BidiFlip({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (Directionality.of(context) != TextDirection.rtl) return child;
    return Transform.flip(flipX: true, child: child);
  }
}
