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
