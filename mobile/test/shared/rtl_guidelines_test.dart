import 'dart:convert';

import 'package:corevia_talk/shared/i18n/app_language.dart';
import 'package:corevia_talk/shared/reminders/reminder_time_presets.dart';
import 'package:corevia_talk/shared/theme/theme.dart';
import 'package:corevia_talk/shared/widgets/corevia_talk_search_field.dart';
import 'package:corevia_talk/shared/widgets/message_author_meta.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(AppLanguage language, Widget child) => MaterialApp(
  theme: AppTheme.light(),
  locale: language.locale,
  supportedLocales: [for (final l in AppLanguage.values) l.locale],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  home: Scaffold(
    body: Center(child: SizedBox(width: 300, child: child)),
  ),
);

/// The rect the text's glyphs actually cover (a hint's widget box spans the
/// whole field, so its own rect says nothing about alignment).
Rect _glyphRect(WidgetTester tester, Finder finder) {
  final paragraph = tester.renderObject<RenderParagraph>(finder);
  final boxes = paragraph.getBoxesForSelection(
    TextSelection(
      baseOffset: 0,
      extentOffset: paragraph.text.toPlainText().length,
    ),
  );
  final local = boxes
      .map((b) => b.toRect())
      .reduce((a, b) => a.expandToInclude(b));
  return local.shift(paragraph.localToGlobal(Offset.zero));
}

void main() {
  tearDown(() => setActiveLanguage(AppLanguage.en));

  group('rule 3: Persian typed in the English UI uses Peyda', () {
    test('English text styles fall back to PeydaFaNum', () {
      setActiveLanguage(AppLanguage.en);
      final style = AppTheme.light().textTheme.bodyMedium!;
      expect(style.fontFamily, 'Inter');
      expect(style.fontFamilyFallback, contains('PeydaFaNum'));
    });

    test('Persian text styles use PeydaFaNum with no fallback needed', () {
      setActiveLanguage(AppLanguage.fa);
      final style = AppTheme.light().textTheme.bodyMedium!;
      expect(style.fontFamily, 'PeydaFaNum');
      expect(style.fontFamilyFallback, isNull);
    });
  });

  group('rule 4: Persian weights and tracking', () {
    test('Peyda weights are shifted one step heavier', () async {
      final manifest =
          jsonDecode(await rootBundle.loadString('FontManifest.json'))
              as List<dynamic>;
      final peyda =
          (manifest.firstWhere((f) => f['family'] == 'PeydaFaNum')['fonts']
                  as List<dynamic>)
              .cast<Map<String, dynamic>>();
      String assetFor(int weight) =>
          peyda.firstWhere((f) => f['weight'] == weight)['asset'] as String;
      expect(assetFor(400), endsWith('PeydaFaNum-Regular.ttf'));
      expect(assetFor(500), endsWith('PeydaFaNum-SemiBold.ttf'));
      expect(assetFor(600), endsWith('PeydaFaNum-Bold.ttf'));
      expect(assetFor(700), endsWith('PeydaFaNum-ExtraBold.ttf'));
      expect(assetFor(800), endsWith('PeydaFaNum-Black.ttf'));
    });

    test('Persian dialog titles have no negative letter spacing', () {
      setActiveLanguage(AppLanguage.fa);
      expect(AppTheme.light().dialogTheme.titleTextStyle!.letterSpacing, 0);
      setActiveLanguage(AppLanguage.en);
      expect(
        AppTheme.light().dialogTheme.titleTextStyle!.letterSpacing,
        lessThan(0),
      );
    });
  });

  group('rule 7: placeholder follows the UI mode', () {
    for (final (language, hintOnRight) in [
      (AppLanguage.fa, true),
      (AppLanguage.en, false),
    ]) {
      testWidgets('search field hint sits on the UI start (${language.name})', (
        tester,
      ) async {
        setActiveLanguage(language);
        await tester.pumpWidget(
          _app(
            language,
            CoreviaTalkSearchField(
              controller: TextEditingController(),
              focusNode: FocusNode(),
              hintText: 'Search',
              iconColor: Colors.grey,
              inputColor: Colors.black,
              placeholderColor: Colors.grey,
              surfaceColor: Colors.white,
              isEditing: false,
              reduceMotion: true,
              motionDuration: Duration.zero,
              onTap: () {},
              onChanged: (_) {},
              onSubmitted: (_) {},
            ),
          ),
        );
        final field = tester.getRect(find.byType(TextField));
        final hint = _glyphRect(tester, find.text('Search'));
        final nearRight = (field.right - hint.right) < (hint.left - field.left);
        expect(nearRight, hintOnRight);
      });
    }
  });

  group('rule 14: message header', () {
    Widget header({required bool mirrored, String? role}) => MessageAuthorMeta(
      displayName: 'Alex',
      timestamp: '09:15',
      nameColor: Colors.black,
      metadataColor: Colors.grey,
      roleLine: role,
      mirrored: mirrored,
      displayNameKey: const ValueKey('name'),
      timestampKey: const ValueKey('time'),
    );

    testWidgets('own header lists name then time away from the avatar', (
      tester,
    ) async {
      await tester.pumpWidget(_app(AppLanguage.en, header(mirrored: false)));
      expect(
        tester.getCenter(find.byKey(const ValueKey('name'))).dx,
        lessThan(tester.getCenter(find.byKey(const ValueKey('time'))).dx),
      );
    });

    testWidgets('the other person\'s header is the mirror image', (
      tester,
    ) async {
      await tester.pumpWidget(_app(AppLanguage.en, header(mirrored: true)));
      expect(
        tester.getCenter(find.byKey(const ValueKey('name'))).dx,
        greaterThan(tester.getCenter(find.byKey(const ValueKey('time'))).dx),
      );
    });

    testWidgets('the role line sits under the name', (tester) async {
      await tester.pumpWidget(
        _app(
          AppLanguage.en,
          header(mirrored: false, role: 'Agent managed by Sam'),
        ),
      );
      final name = tester.getRect(find.byKey(const ValueKey('name')));
      final role = tester.getRect(find.text('Agent managed by Sam'));
      expect(role.top, greaterThanOrEqualTo(name.bottom - 0.5));
      expect(role.left, closeTo(name.left, 0.5));
    });

    testWidgets('a long name is capped at 80% of the row', (tester) async {
      await tester.pumpWidget(
        _app(
          AppLanguage.en,
          MessageAuthorMeta(
            displayName: 'A very long display name ' * 8,
            timestamp: '09:15',
            nameColor: Colors.black,
            metadataColor: Colors.grey,
            displayNameKey: const ValueKey('name'),
          ),
        ),
      );
      expect(
        tester.getSize(find.byKey(const ValueKey('name'))).width,
        lessThanOrEqualTo(300 * 0.8 + 0.5),
      );
    });
  });

  group('rule 5: Persian UI uses Tehran time for reminders', () {
    test(
      '"tomorrow at 9am" is 9:00 Asia/Tehran in Persian, device time in English',
      () {
        // 05:00 UTC is 08:30 in Tehran.
        final now = DateTime.utc(2026, 10, 6, 5);
        setActiveLanguage(AppLanguage.fa);
        expect(
          DateTime.fromMillisecondsSinceEpoch(
            nextDayAt9am(1, now: now) * 1000,
            isUtc: true,
          ),
          DateTime.utc(2026, 10, 7, 5, 30),
        );
        expect(
          DateTime.fromMillisecondsSinceEpoch(
            combineCustomDateTime(DateTime.utc(2099, 1, 1), 9, 0)! * 1000,
            isUtc: true,
          ),
          DateTime.utc(2099, 1, 1, 5, 30),
        );
        setActiveLanguage(AppLanguage.en);
        final local = DateTime.fromMillisecondsSinceEpoch(
          nextDayAt9am(1, now: DateTime(2026, 10, 6, 5)) * 1000,
        );
        expect((local.day, local.hour), (7, 9));
      },
    );
  });
}
