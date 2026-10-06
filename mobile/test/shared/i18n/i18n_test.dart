import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buzz/shared/i18n/app_language.dart';
import 'package:buzz/shared/i18n/persian_date.dart';
import 'package:buzz/shared/i18n/text_direction.dart';

void main() {
  tearDown(() => setActiveLanguage(AppLanguage.en));

  test('English leaves strings untouched', () {
    setActiveLanguage(AppLanguage.en);
    expect(tl('Settings'), 'Settings');
    expect(tlt('Thread in {0}', ['#general']), 'Thread in #general');
  });

  test('Persian translates and interpolates', () {
    setActiveLanguage(AppLanguage.fa);
    expect(tl('Yesterday'), 'دیروز');
    expect(tlt('{0}d left', ['3']), contains('روز'));
    expect(tl('Not a known string'), 'Not a known string');
  });

  test('Gregorian to Jalali', () {
    final d = gregorianToJalali(2026, 10, 6);
    expect((d.year, d.month, d.day), (1405, 7, 14));
    final n = gregorianToJalali(2025, 3, 21);
    expect((n.year, n.month, n.day), (1404, 1, 1));
  });

  test('Tehran time is UTC+3:30 and digits convert', () {
    final t = toTehranTime(DateTime.utc(2026, 1, 1, 0, 0));
    expect((t.hour, t.minute), (3, 30));
    expect(toPersianDigits('12:45'), '۱۲:۴۵');
  });

  test('detectTextDirection follows the first strong character', () {
    expect(detectTextDirection('سلام world'), TextDirection.rtl);
    expect(detectTextDirection('hello سلام'), TextDirection.ltr);
    expect(detectTextDirection('۱۲۳ سلام'), TextDirection.rtl);
    expect(detectTextDirection('123 ...'), isNull);
  });
}
