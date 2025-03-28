import '../series/frequency.dart';

/// Provides an Utc DateTime instance with only the date fields initialised.
DateTime utcDate(DateTime dateTime) => DateTime.utc(
      dateTime.year,
      dateTime.month,
      dateTime.day,
    );

/// Compute the actual number of days between two dates.
int actualDays(DateTime date1, DateTime date2) =>
    utcDate(date1).difference(utcDate(date2)).inDays.abs();

/// Compute the number of months between two dates.
///
int monthsBetweenDates(DateTime date1, DateTime date2) {
  if (date1.isAfter(date2)) {
    final temp = date1;
    date1 = date2;
    date2 = temp;
  }
  final monthAdj = (date1.day > date2.day &&
          !(hasMonthEndDay(date1) && hasMonthEndDay(date2)))
      ? -1
      : 0;

  return (date2.year - date1.year) * 12 +
      (date2.month - date1.month) +
      monthAdj;
}

/// Check if a date contains a month end day.
///
/// [date] containing the month to check.
bool hasMonthEndDay(DateTime date) {
  if (isLeapYear(date.year) && date.month == 2) {
    return date.day == 29;
  }
  return daysInMonth[date.month - 1] == date.day;
}

/// Check if a particular range of years contains a leap-year.
///
/// [yearFrom] the earlier of two years.
/// [yearTo] the later of two years.
bool hasLeapYear(int yearFrom, int yearTo) {
  for (int i = yearFrom; i <= yearTo; i++) {
    if (isLeapYear(i)) {
      return true;
    }
  }
  return false;
}

/// Check if a year is a leap year per the Gregorian calendar.
///
/// A year is a leap year if it is divisible by 4 but not by 100, or divisible
/// by 400.
///
bool isLeapYear(int year) =>
    (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);

/// Roll a date forward by the period implicit in the provided frequency.
///
/// [dateToRoll] date to roll
/// [frequency] defining the time period to roll forward
/// [dayPref] preferred day of month of returned date
DateTime rollDate(DateTime dateToRoll, Frequency frequency, [int? dayPref]) {
  switch (frequency) {
    case Frequency.weekly:
      return rollDay(dateToRoll, 7);
    case Frequency.fortnightly:
      return rollDay(dateToRoll, 14);
    case Frequency.monthly:
      return rollMonth(dateToRoll, 1, dayPref);
    case Frequency.quarterly:
      return rollMonth(dateToRoll, 3, dayPref);
    case Frequency.halfYearly:
      return rollMonth(dateToRoll, 6, dayPref);
    case Frequency.yearly:
      return rollMonth(dateToRoll, 12, dayPref);
  }
}

/// Roll a date by the number of days specified.
///
/// [dateToRoll] date to roll
/// [numDays] days to roll, may be positive (roll forward) or negative (roll
/// backwards)
DateTime rollDay(DateTime dateToRoll, int numDays) =>
    utcDate(dateToRoll).add(Duration(days: numDays));

/// Roll a date by the number of months specified.
///
/// [dateToRoll] date to roll
/// [numMonths] months to roll, may be positive (roll forward) or
/// negative (roll backwards)
/// [dayPref] (optional) preferred day of month of returned date.
DateTime rollMonth(DateTime dateToRoll, int numMonths, [int? dayPref]) {
  dateToRoll = utcDate(dateToRoll);
  final currentDay = dateToRoll.day;
  final currentMonth = dateToRoll.month;
  final currentYear = dateToRoll.year;

  // Calculate the new month
  var newMonth = (currentMonth + numMonths) % 12;
  if (newMonth <= 0) {
    newMonth += 12;
  }

  // Calculate the new year
  final monthShift = currentMonth + numMonths;
  var newYear = currentYear;
  newYear += (monthShift / 12).floor();
  if (monthShift % 12 == 0) {
    newYear--;
  }

  // Set the day of month
  if (dayPref == null || dayPref <= 0) {
    dayPref = currentDay;
  }
  int newDay;

  if (dayPref > daysInMonth[newMonth - 1]) {
    if (isLeapYear(newYear) && newMonth == 2) {
      newDay = 29;
    } else {
      newDay = daysInMonth[newMonth - 1];
    }
  } else {
    newDay = dayPref;
  }

  return DateTime.utc(newYear, newMonth, newDay);
}

/// Number of days in each month starting January (non leap year)
const daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
