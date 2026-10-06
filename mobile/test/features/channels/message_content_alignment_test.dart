import 'package:buzz/features/channels/message_content.dart';
import 'package:buzz/shared/i18n/app_language.dart';
import 'package:buzz/shared/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gpt_markdown/custom_widgets/indent_widget.dart';
import 'package:gpt_markdown/custom_widgets/unordered_ordered_list.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Widget _app(AppLanguage language, Widget child) => ProviderScope(
  child: MaterialApp(
    theme: AppTheme.light(),
    locale: language.locale,
    supportedLocales: [for (final l in AppLanguage.values) l.locale],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    builder: (context, child) => AppMarkdownTheme(child: child!),
    home: Scaffold(
      body: Align(alignment: Alignment.topLeft, child: child),
    ),
  ),
);

Future<void> _pump(
  WidgetTester tester,
  AppLanguage language,
  String content, {
  bool bubble = false,
  bool own = false,
}) async {
  setActiveLanguage(language);
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(400, 800);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    _app(
      language,
      SizedBox(
        width: 400,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: MessageContent(
            content: content,
            bubble: bubble,
            bubbleIsOwn: own,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

RichText _paragraph(WidgetTester tester, String needle) => tester
    .widgetList<RichText>(find.byType(RichText))
    .firstWhere((r) => r.text.toPlainText().contains(needle));

void main() {
  tearDown(() => setActiveLanguage(AppLanguage.en));

  testWidgets('Persian mode aligns an English message to the right', (
    tester,
  ) async {
    await _pump(tester, AppLanguage.fa, 'Hello there, team');
    final paragraph = _paragraph(tester, 'Hello there');
    expect(paragraph.textAlign, TextAlign.right);
    // Run order still follows the message's own first strong character.
    expect(paragraph.textDirection, TextDirection.ltr);
  });

  testWidgets('English mode aligns a Persian message to the left', (
    tester,
  ) async {
    await _pump(tester, AppLanguage.en, 'سلام به همه');
    final paragraph = _paragraph(tester, 'سلام');
    expect(paragraph.textAlign, TextAlign.left);
    expect(paragraph.textDirection, TextDirection.rtl);
  });

  testWidgets('mixed text orders runs by the first strong character', (
    tester,
  ) async {
    await _pump(tester, AppLanguage.fa, 'PR #42 را بررسی کنید');
    expect(
      _paragraph(tester, 'PR').textDirection,
      TextDirection.ltr,
      reason: 'starts with Latin, so the paragraph runs left to right',
    );
    await _pump(tester, AppLanguage.fa, 'لطفاً PR #42 را ببینید');
    expect(
      _paragraph(tester, 'لطفاً').textDirection,
      TextDirection.rtl,
      reason: 'starts with Persian, so the paragraph runs right to left',
    );
    // Both stay on the UI start edge (right in Persian mode).
    expect(_paragraph(tester, 'لطفاً').textAlign, TextAlign.right);
  });

  testWidgets('a message with no letters keeps the UI direction', (
    tester,
  ) async {
    await _pump(tester, AppLanguage.fa, '1234');
    expect(_paragraph(tester, '1234').textDirection, TextDirection.rtl);
    expect(_paragraph(tester, '1234').textAlign, TextAlign.right);
  });

  for (final (language, markerOnRight) in [
    (AppLanguage.fa, true),
    (AppLanguage.en, false),
  ]) {
    testWidgets('list markers sit on the UI start side (${language.name})', (
      tester,
    ) async {
      // An English list in Persian mode (and vice versa): the marker follows
      // the UI direction, not the script of the text.
      await _pump(
        tester,
        language,
        language == AppLanguage.fa
            ? '- first item\n- second item'
            : '- مورد اول\n- مورد دوم',
      );
      final item = find.byType(UnorderedListView).first;
      final marker = tester.getCenter(
        find.descendant(of: item, matching: find.byType(Container)).first,
      );
      final text = tester.getCenter(
        find.descendant(of: item, matching: find.byType(RichText)).last,
      );
      expect(marker.dx > text.dx, markerOnRight);
    });
  }

  testWidgets('block quote bars follow the UI direction, not the script', (
    tester,
  ) async {
    await _pump(tester, AppLanguage.fa, '> quoted english text');
    expect(
      tester.widget<BlockQuoteWidget>(find.byType(BlockQuoteWidget)).direction,
      TextDirection.rtl,
    );
    await _pump(tester, AppLanguage.en, '> نقل قول فارسی');
    expect(
      tester.widget<BlockQuoteWidget>(find.byType(BlockQuoteWidget)).direction,
      TextDirection.ltr,
    );
  });

  testWidgets('bubble hugs short text and rounds mirrored corners', (
    tester,
  ) async {
    await _pump(tester, AppLanguage.en, 'ok', bubble: true);
    final bubble = find.byKey(const ValueKey('message-bubble'));
    expect(bubble, findsOneWidget);
    final size = tester.getSize(bubble);
    expect(size.width, lessThan(100), reason: 'a short message hugs its text');
    final decoration =
        (tester.widget<DecoratedBox>(bubble)).decoration as BoxDecoration;
    expect(
      decoration.borderRadius,
      const BorderRadiusDirectional.only(
        topStart: Radius.circular(6),
        topEnd: Radius.circular(18),
        bottomStart: Radius.circular(18),
        bottomEnd: Radius.circular(18),
      ),
    );
  });

  testWidgets('bubble stays within the maximum width for long text', (
    tester,
  ) async {
    await _pump(tester, AppLanguage.en, 'word ' * 200, bubble: true);
    final width = tester.getSize(find.byKey(const ValueKey('message-bubble')));
    expect(width.width, lessThanOrEqualTo(400 * 0.78 + 0.01));
    expect(width.width, greaterThan(400 * 0.7));
  });

  testWidgets('bubble sits on the UI start edge in Persian mode', (
    tester,
  ) async {
    await _pump(tester, AppLanguage.fa, 'ok', bubble: true);
    final rect = tester.getRect(find.byKey(const ValueKey('message-bubble')));
    expect(rect.right, closeTo(400, 0.5));
  });

  testWidgets('own bubbles use the end-side tight corner and a primary tint', (
    tester,
  ) async {
    await _pump(tester, AppLanguage.en, 'mine', bubble: true, own: true);
    final bubble = find.byKey(const ValueKey('message-bubble'));
    final decoration =
        tester.widget<DecoratedBox>(bubble).decoration as BoxDecoration;
    expect(
      decoration.borderRadius,
      const BorderRadiusDirectional.only(
        topStart: Radius.circular(18),
        topEnd: Radius.circular(6),
        bottomStart: Radius.circular(18),
        bottomEnd: Radius.circular(18),
      ),
    );
    final primary = Theme.of(tester.element(bubble)).colorScheme.primary;
    expect(
      (decoration.color!).toARGB32() & 0x00FFFFFF,
      primary.toARGB32() & 0x00FFFFFF,
    );
  });
}
