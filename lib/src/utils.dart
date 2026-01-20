/// Internal utility functions for date manipulation and financial rounding.
///
/// Consolidates helpers previously in `dates.dart` and `math.dart`, aligning
/// closely with `curo-python`'s `utils.py` (excluding pandas-specific parts).
///
/// These are intentionally private to the package and may be refactored later
/// (e.g., moving date-rolling logic closer to day count conventions).
library;

import 'dart:math';
import 'package:curo/src/enums.dart';

/// Number of days in each month (non-leap year).
///
/// Index 0 = January, index 11 = December. February has 28 days.
const List<int> daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

/// Normalizes a [DateTime] to midnight UTC, discarding time-of-day and timezone.
///
/// Financial calculations treat all dates as date-only in UTC for consistency
/// and reproducibility.
DateTime normalizeToMidnightUtc(DateTime dt) =>
    DateTime.utc(dt.year, dt.month, dt.day);

/// Returns the absolute number of calendar days between two dates.
///
/// - Includes the start date
/// - Excludes the end date
/// - Normalizes both dates to midnight UTC (ignores time component)
/// - Returns 0 for same-day dates
/// - Always non-negative
int actualDays(DateTime start, DateTime end) {
  final s = normalizeToMidnightUtc(start);
  final e = normalizeToMidnightUtc(end);
  return e.difference(s).inDays.abs();
}

/// Checks if a date is the last day of its month.
bool hasMonthEndDay(DateTime date) {
  final d = normalizeToMidnightUtc(date);
  final month = d.month;
  final year = d.year;

  final daysInThisMonth = (month == DateTime.february && isLeapYear(year))
      ? 29
      : daysInMonth[month - 1];

  return d.day == daysInThisMonth;
}

/// Checks if a year is a leap year (Gregorian calendar).
bool isLeapYear(int year) =>
    (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);

/// Returns a new date by adding or subtracting [days] (positive or negative).
DateTime rollDay(DateTime date, int days) => date.add(Duration(days: days));

/// Rolls a date by the given number of [months] (positive or negative).
///
/// Attempts to preserve the original day of month via [preferredDay]
/// (defaults to the original day).
///
/// If the preferred day does not exist in the target month
/// (e.g., 31st -> April), uses the last day of that month instead.
///
/// Preserves month-end semantics when the original date was month-end.
DateTime rollMonth(DateTime date, int months, [int? preferredDay]) {
  final d = normalizeToMidnightUtc(date);
  final originalDay = d.day;
  final currentMonth = d.month;
  final currentYear = d.year;

  // Preferred day falls back to original day
  final dayPref = preferredDay ?? originalDay;

  // Compute raw month shift
  final monthShift = currentMonth + months;

  // New month (1-12)
  var newMonth = monthShift % 12;
  if (newMonth <= 0) {
    newMonth += 12;
  }

  // New year — floor division for positive, adjust for exact multiples
  var newYear = currentYear + (monthShift / 12).floor();
  if (monthShift % 12 == 0) {
    newYear--;
  }

  // Determine actual day in target month
  final isTargetLeapFeb =
      (newMonth == DateTime.february) && isLeapYear(newYear);
  final daysInTargetMonth = isTargetLeapFeb ? 29 : daysInMonth[newMonth - 1];

  final newDay = dayPref > daysInTargetMonth ? daysInTargetMonth : dayPref;

  return DateTime.utc(newYear, newMonth, newDay);
}

/// Advances a date by one period according to the given [frequency].
///
/// Uses day rolling for weekly/fortnightly frequencies.
/// Uses month rolling (with [preferredDay] preservation) for monthly and higher.
///
/// Critical for generating consistent cash flow dates while respecting
/// month-end conventions.
DateTime rollDate(DateTime date, Frequency frequency, [int? preferredDay]) =>
    switch (frequency) {
      Frequency.weekly => rollDay(date, 7),
      Frequency.fortnightly => rollDay(date, 14),
      Frequency.monthly => rollMonth(date, 1, preferredDay),
      Frequency.quarterly => rollMonth(date, 3, preferredDay),
      Frequency.halfYearly => rollMonth(date, 6, preferredDay),
      Frequency.yearly => rollMonth(date, 12, preferredDay),
    };

/// Gaussian (banker's) rounding to the specified [precision] decimal places.
///
/// Rounds halfway cases to the nearest even number (avoids statistical bias).
///
/// Examples:
/// - 2.5 -> 2 (precision 0)
/// - 3.5 -> 4 (precision 0)
/// - 1.225 -> 1.22 (precision 2, since 1.2250 -> even)
///
/// Ported and adapted from Tim Down's JavaScript implementation.
double gaussRound(double num, [int precision = 0]) {
  if (precision == 0) {
    final i = num.floor();
    final f = num - i;
    if (f > 0.5 - 1e-8 && f < 0.5 + 1e-8) {
      return i % 2 == 0 ? i.toDouble() : (i + 1).toDouble();
    }
    return num.roundToDouble();
  }

  final factor = pow(10, precision.abs());
  final scaled = num * factor;
  final i = scaled.floor();
  final f = scaled - i;

  if (f > 0.5 - 1e-8 && f < 0.5 + 1e-8) {
    final rounded = i % 2 == 0 ? i : i + 1;
    return rounded / factor;
  }

  return scaled.round() / factor;
}
