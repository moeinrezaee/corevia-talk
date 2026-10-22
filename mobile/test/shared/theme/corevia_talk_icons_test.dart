import 'package:corevia_talk/shared/theme/corevia_talk_icons.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Unarchive uses restoration instead of crossed-out archiving', () {
    expect(CoreviaTalkIcons.archiveRestore.codePoint, 0xfafd);
    expect(CoreviaTalkIcons.archiveRestore, isNot(CoreviaTalkIcons.archive));
    expect(CoreviaTalkIcons.archiveRestore.codePoint, isNot(0xf0ad));
  });

  test('temporary channels use an hourglass distinct from running status', () {
    expect(CoreviaTalkIcons.clockFading.codePoint, 0xef93);
    expect(CoreviaTalkIcons.clockFading, isNot(CoreviaTalkIcons.clock3));
  });
}
