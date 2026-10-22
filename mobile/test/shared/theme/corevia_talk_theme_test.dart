import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:corevia_talk/shared/theme/theme.dart';
import 'package:corevia_talk/shared/widgets/frosted_app_bar.dart';

void main() {
  group('Corevia Talk theme catalog entries', () {
    test('both halves are in the catalog', () {
      expect(findTheme(coreviaTalkThemeName), isNotNull);
      expect(findTheme(coreviaTalkDarkThemeName), isNotNull);
    });

    test('borrow the GitHub palettes', () {
      final corevia-talk = findTheme(coreviaTalkThemeName)!;
      final github = findTheme('github-light')!;
      expect(corevia-talk.bg, github.bg);
      expect(corevia-talk.fg, github.fg);
      expect(corevia-talk.comment, github.comment);

      final coreviaTalkDark = findTheme(coreviaTalkDarkThemeName)!;
      final githubDark = findTheme('github-dark')!;
      expect(coreviaTalkDark.bg, githubDark.bg);
      expect(coreviaTalkDark.fg, githubDark.fg);
      expect(coreviaTalkDark.comment, githubDark.comment);
    });

    test('are a light/dark pair', () {
      expect(findTheme(coreviaTalkThemeName)!.isDark, isFalse);
      expect(findTheme(coreviaTalkDarkThemeName)!.isDark, isTrue);
      expect(themePairFor(coreviaTalkThemeName), coreviaTalkDarkThemeName);
      expect(themePairFor(coreviaTalkDarkThemeName), coreviaTalkThemeName);
    });

    test('appear as a single System-mode option labelled "Corevia Talk"', () {
      final paired = themeGroups().paired.map((t) => t.name);
      expect(paired, contains(coreviaTalkThemeName));
      expect(paired, isNot(contains(coreviaTalkDarkThemeName)));
      expect(pairedThemeLabel(coreviaTalkThemeName), 'Corevia Talk');
      expect(themeSelectionLabel(coreviaTalkThemeName, ThemeMode.system), 'Corevia Talk');
      expect(themeSelectionLabel(coreviaTalkDarkThemeName, ThemeMode.system), 'Corevia Talk');
    });

    test('forces neutral rendering without changing the stored accent', () {
      const storedAccent = '#ef4444';

      expect(
        effectiveAccentIndex(coreviaTalkThemeName, storedAccent),
        neutralAccentIndex,
      );
      expect(
        effectiveAccentIndex(coreviaTalkDarkThemeName, storedAccent),
        neutralAccentIndex,
      );
      expect(
        effectiveAccentIndex('github-light', storedAccent),
        accentIndexForWireValue(storedAccent),
      );
      expect(storedAccent, '#ef4444');
    });

    test('resolve across brightnesses like any other pair', () {
      final resolved = resolveSchemes(coreviaTalkThemeName, ThemeMode.system);
      expect(resolved.forcedMode, isNull);
      expect(resolved.light.brightness, Brightness.light);
      expect(resolved.dark.brightness, Brightness.dark);
      expect(resolved.lightTheme?.name, coreviaTalkThemeName);
      expect(resolved.darkTheme?.name, coreviaTalkDarkThemeName);

      expect(
        effectiveTheme(coreviaTalkThemeName, ThemeMode.dark)?.name,
        coreviaTalkDarkThemeName,
      );
      expect(
        effectiveTheme(coreviaTalkDarkThemeName, ThemeMode.light)?.name,
        coreviaTalkThemeName,
      );
    });

    test(
      'fallbacks expose the effective Corevia Talk theme for gradient selection',
      () {
        final coerced = resolveSchemes('nord', ThemeMode.light);
        expect(coerced.lightTheme?.name, coreviaTalkThemeName);
        expect(
          coreviaTalkTopSectionGradient(
            coerced.lightTheme!.name,
            coerced.light.brightness,
          ),
          isNotNull,
        );

        final unknown = resolveSchemes('not-a-theme', ThemeMode.light);
        expect(unknown.lightTheme?.name, coreviaTalkThemeName);
        expect(
          coreviaTalkTopSectionGradient(
            unknown.lightTheme!.name,
            unknown.light.brightness,
          ),
          isNotNull,
        );
      },
    );
  });

  group('coreviaTalkTopSectionGradient', () {
    test('is null for non-CoreviaTalk themes', () {
      expect(coreviaTalkTopSectionGradient('github-light', Brightness.light), isNull);
      expect(coreviaTalkTopSectionGradient('nord', Brightness.dark), isNull);
    });

    test('paints top to bottom for both halves of the pair', () {
      for (final name in [coreviaTalkThemeName, coreviaTalkDarkThemeName]) {
        final gradient = coreviaTalkTopSectionGradient(name, Brightness.light);
        expect(gradient, isNotNull, reason: '$name should be gradient-backed');
        expect(gradient!.begin, Alignment.topCenter);
        expect(gradient.end, Alignment.bottomCenter);
        expect(gradient.colors, hasLength(2));
      }
    });

    test('brightness selects the stops, not the theme name', () {
      // Both halves enable the gradient, so System mode keeps it on across an
      // OS switch — the applied brightness alone decides which stops are used.
      final light = coreviaTalkTopSectionGradient(coreviaTalkThemeName, Brightness.light)!;
      final dark = coreviaTalkTopSectionGradient(coreviaTalkThemeName, Brightness.dark)!;

      expect(light.colors, isNot(dark.colors));
      expect(
        coreviaTalkTopSectionGradient(coreviaTalkDarkThemeName, Brightness.dark)!.colors,
        dark.colors,
      );
      expect(
        coreviaTalkTopSectionGradient(coreviaTalkDarkThemeName, Brightness.light)!.colors,
        light.colors,
      );
    });

    test('is opaque so the color replaces the frosted fill', () {
      for (final brightness in Brightness.values) {
        final gradient = coreviaTalkTopSectionGradient(coreviaTalkThemeName, brightness)!;
        for (final color in gradient.colors) {
          expect(color.a, 1.0);
        }
      }
    });
  });

  group('theme threading', () {
    BoxDecoration barDecoration(WidgetTester tester) {
      final container = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(FrostedAppBar),
              matching: find.byType(Container),
            ),
          )
          .first;
      return container.decoration! as BoxDecoration;
    }

    Widget harness(ThemeData theme) => MaterialApp(
      theme: theme,
      home: Builder(
        builder: (context) => Stack(
          children: [
            FrostedAppBar(
              gradient: context.appColors.topSectionGradient,
              title: const Text('Home'),
            ),
          ],
        ),
      ),
    );

    testWidgets('AppTheme carries the gradient to the top section', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          AppTheme.light(
            topSectionGradient: coreviaTalkTopSectionGradient(
              coreviaTalkThemeName,
              Brightness.light,
            ),
          ),
        ),
      );

      final decoration = barDecoration(tester);
      expect(decoration.gradient, isNotNull);
      // A BoxDecoration cannot paint a color and a gradient at once.
      expect(decoration.color, isNull);
    });

    testWidgets('non-CoreviaTalk themes keep the frosted surface fill', (
      tester,
    ) async {
      await tester.pumpWidget(harness(AppTheme.light()));

      final decoration = barDecoration(tester);
      expect(decoration.gradient, isNull);
      expect(decoration.color, isNotNull);
    });

    testWidgets('Corevia Talk section labels use 80% neutral foreground', (
      tester,
    ) async {
      await tester.pumpWidget(
        harness(
          AppTheme.light(
            topSectionGradient: coreviaTalkTopSectionGradient(
              coreviaTalkThemeName,
              Brightness.light,
            ),
          ),
        ),
      );

      final context = tester.element(find.text('Home'));
      expect(
        navigationSectionForeground(context),
        Colors.black.withValues(alpha: 0.8),
      );
    });

    testWidgets('navigation roles inherit non-CoreviaTalk theme tokens', (
      tester,
    ) async {
      const primaryForeground = Color(0xFF123456);
      const secondaryForeground = Color(0xFF789ABC);
      const searchSurface = Color(0xFFDEF012);
      final theme = ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple).copyWith(
          onSurface: primaryForeground,
          onSurfaceVariant: secondaryForeground,
          surfaceContainerHighest: searchSurface,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(body: SizedBox()),
        ),
      );

      final context = tester.element(find.byType(SizedBox));
      expect(navigationPrimaryForeground(context), primaryForeground);
      expect(navigationSecondaryForeground(context), secondaryForeground);
      expect(navigationSectionForeground(context), secondaryForeground);
      expect(navigationSearchSurface(context), const Color(0xFFF0F0F0));
      expect(
        navigationDivider(context, 0.15),
        primaryForeground.withValues(alpha: 0.15),
      );
    });
  });

  group('isCoreviaTalkTheme', () {
    test('matches only the Corevia Talk pair', () {
      expect(isCoreviaTalkTheme(coreviaTalkThemeName), isTrue);
      expect(isCoreviaTalkTheme(coreviaTalkDarkThemeName), isTrue);
      expect(isCoreviaTalkTheme('github-light'), isFalse);
      expect(isCoreviaTalkTheme(''), isFalse);
    });
  });
}
