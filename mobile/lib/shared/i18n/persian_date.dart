import 'app_language.dart';

/// Iran has used a fixed UTC+03:30 offset since it dropped daylight saving in
/// 2022, so Tehran time is a constant shift from UTC.
const tehranUtcOffset = Duration(hours: 3, minutes: 30);

const _persianMonths = [
  'فروردین',
  'اردیبهشت',
  'خرداد',
  'تیر',
  'مرداد',
  'شهریور',
  'مهر',
  'آبان',
  'آذر',
  'دی',
  'بهمن',
  'اسفند',
];

/// Weekday names, indexed by [DateTime.weekday] - 1 (Monday first).
const _persianWeekdays = [
  'دوشنبه',
  'سه‌شنبه',
  'چهارشنبه',
  'پنجشنبه',
  'جمعه',
  'شنبه',
  'یکشنبه',
];

/// A date in the Solar Hijri (Jalali) calendar.
class JalaliDate {
  const JalaliDate(this.year, this.month, this.day);

  final int year;
  final int month;
  final int day;

  /// Persian name of [month].
  String get monthName => _persianMonths[month - 1];

  @override
  String toString() => '$year/$month/$day';
}

/// Converts a Gregorian calendar date to the Solar Hijri calendar.
JalaliDate gregorianToJalali(int gy, int gm, int gd) {
  const daysBeforeMonth = [
    0,
    31,
    59,
    90,
    120,
    151,
    181,
    212,
    243,
    273,
    304,
    334,
  ];
  final gy2 = gm > 2 ? gy + 1 : gy;
  var days =
      355666 +
      365 * gy +
      (gy2 + 3) ~/ 4 -
      (gy2 + 99) ~/ 100 +
      (gy2 + 399) ~/ 400 +
      gd +
      daysBeforeMonth[gm - 1];
  var jy = -1595 + 33 * (days ~/ 12053);
  days %= 12053;
  jy += 4 * (days ~/ 1461);
  days %= 1461;
  if (days > 365) {
    jy += (days - 1) ~/ 365;
    days = (days - 1) % 365;
  }
  final jm = days < 186 ? 1 + days ~/ 31 : 7 + (days - 186) ~/ 30;
  final jd = 1 + (days < 186 ? days % 31 : (days - 186) % 30);
  return JalaliDate(jy, jm, jd);
}

/// Replaces ASCII digits with Persian digits.
String toPersianDigits(String input) => input.replaceAllMapped(
  RegExp('[0-9]'),
  (match) => String.fromCharCode(0x06F0 + int.parse(match.group(0)!)),
);

/// [value] shifted to Tehran wall-clock time. The result is a UTC-flagged
/// [DateTime] whose fields read as Tehran local time.
DateTime toTehranTime(DateTime value) => value.toUtc().add(tehranUtcOffset);

/// The Persian weekday name for a (Tehran) [date].
String persianWeekdayName(DateTime date) => _persianWeekdays[date.weekday - 1];

/// `HH:mm` in Persian digits, in Tehran time.
String persianTime(DateTime value) {
  final t = toTehranTime(value);
  final hh = t.hour.toString().padLeft(2, '0');
  final mm = t.minute.toString().padLeft(2, '0');
  return toPersianDigits('$hh:$mm');
}

/// `۱۴ مهر` (or `۱۴ مهر ۱۴۰۵` with [withYear]), in Tehran time.
String persianMonthDay(DateTime value, {bool withYear = false}) {
  final t = toTehranTime(value);
  final j = gregorianToJalali(t.year, t.month, t.day);
  final text = withYear
      ? '${j.day} ${j.monthName} ${j.year}'
      : '${j.day} ${j.monthName}';
  return toPersianDigits(text);
}

/// `۱۴۰۵/۷/۱۴`, in Tehran time.
String persianNumericDate(DateTime value) {
  final t = toTehranTime(value);
  return toPersianDigits(gregorianToJalali(t.year, t.month, t.day).toString());
}

/// Whether dates should be shown in the Persian calendar right now.
bool get usesPersianCalendar => activeLanguage == AppLanguage.fa;
