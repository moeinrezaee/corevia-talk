import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/theme_provider.dart' show savedPrefsProvider;
import 'fa_messages.dart';

const _languageKey = 'corevia_talk_language';

/// First strong isolate / pop directional isolate: keeps an interpolated name
/// or #channel inside a Persian sentence from reordering its neighbours.
// Built from code points: a literal bidi control character in source trips the
// text_direction_code_point_in_literal lint.
final _firstStrongIsolate = String.fromCharCode(0x2068);
final _popIsolate = String.fromCharCode(0x2069);

/// Interface languages the app ships translations for.
enum AppLanguage {
  en(Locale('en')),
  fa(Locale('fa', 'IR'));

  const AppLanguage(this.locale);

  /// The locale handed to [MaterialApp]; `fa` makes Flutter lay out right to
  /// left and use Persian text-direction defaults.
  final Locale locale;

  /// Whether this language is written right to left.
  bool get isRtl => this == AppLanguage.fa;

  /// Font family used for all interface text.
  String get fontFamily => this == AppLanguage.fa ? 'PeydaFaNum' : 'Inter';

  /// Fonts tried when [fontFamily] lacks a glyph. In English, Persian typed
  /// into messages and names still draws in Peyda FaNum while Latin text and
  /// ASCII digits stay in Inter.
  List<String>? get fontFamilyFallback =>
      this == AppLanguage.fa ? null : const ['PeydaFaNum'];
}

AppLanguage _active = AppLanguage.en;

/// The language currently applied. Read by [tl] and the date formatters, which
/// run outside the widget tree.
AppLanguage get activeLanguage => _active;

/// Sets the language used by non-widget code. Call before `runApp` and
/// whenever the user changes the language.
void setActiveLanguage(AppLanguage language) => _active = language;

/// Parses a stored language code, falling back to English.
AppLanguage parseLanguage(String? code) =>
    AppLanguage.values.where((l) => l.name == code).firstOrNull ??
    AppLanguage.en;

/// Reads the saved language from [prefs].
AppLanguage readStoredLanguage(SharedPreferences prefs) =>
    parseLanguage(prefs.getString(_languageKey));

/// Translates an English UI string into the active language. The English text
/// is the lookup key, so untranslated strings fall back to English unchanged.
String tl(String text) =>
    _active == AppLanguage.fa ? (faMessages[text] ?? text) : text;

/// Translates a template with numbered `{0}`, `{1}`… placeholders, e.g.
/// `tlt('Replying to {0}', [name])`. The English template is the lookup key.
String tlt(String template, List<Object?> args) {
  final isFa = _active == AppLanguage.fa;
  return tl(template).replaceAllMapped(RegExp(r'\{(\d+)\}'), (match) {
    final value = '${args[int.parse(match.group(1)!)] ?? ''}';
    return isFa && value.isNotEmpty
        ? '$_firstStrongIsolate$value$_popIsolate'
        : value;
  });
}

/// Tracks the selected interface language and persists it.
class LanguageNotifier extends Notifier<AppLanguage> {
  @override
  AppLanguage build() {
    final language = readStoredLanguage(ref.read(savedPrefsProvider));
    setActiveLanguage(language);
    return language;
  }

  /// Applies and saves [language].
  void setLanguage(AppLanguage language) {
    setActiveLanguage(language);
    state = language;
    ref.read(savedPrefsProvider).setString(_languageKey, language.name);
  }
}

final languageProvider = NotifierProvider<LanguageNotifier, AppLanguage>(
  LanguageNotifier.new,
);
