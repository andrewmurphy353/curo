import 'package:curo/src/calculator.dart';
import 'package:test/test.dart';

void main() {
  group('actualDays', () {
    test('28/01/2020 to 28/02/2020', () {
      expect(
        actualDays(DateTime.utc(2020, 1, 28), DateTime.utc(2020, 2, 28)),
        31,
      );
    });
    test('28/02/2020 to 28/03/2020', () {
      expect(
        actualDays(DateTime.utc(2020, 2, 28), DateTime.utc(2020, 3, 28)),
        29,
      );
    });
    test('29/01/2020 to 29/02/2020', () {
      expect(
        actualDays(DateTime.utc(2020, 1, 29), DateTime.utc(2020, 2, 29)),
        31,
      );
    });
    test('29/02/2020 to 29/03/2020', () {
      expect(
        actualDays(DateTime.utc(2020, 2, 29), DateTime.utc(2020, 3, 29)),
        29,
      );
    });
    test('30/01/2020 to 29/02/2020', () {
      expect(
        actualDays(DateTime.utc(2020, 1, 30), DateTime.utc(2020, 2, 29)),
        30,
      );
    });
    test('29/02/2020 to 30/03/2020', () {
      expect(
        actualDays(DateTime.utc(2020, 2, 29), DateTime.utc(2020, 3, 30)),
        30,
      );
    });
    test('31/01/2020 to 29/02/2020', () {
      expect(
        actualDays(DateTime.utc(2020, 1, 31), DateTime.utc(2020, 2, 29)),
        29,
      );
    });
    test('29/02/2020 to 31/03/2020', () {
      expect(
        actualDays(DateTime.utc(2020, 2, 29), DateTime.utc(2020, 3, 31)),
        31,
      );
    });
    test('01/03/2020 to 01/04/2020', () {
      expect(
        actualDays(DateTime.utc(2020, 3, 1), DateTime.utc(2020, 4, 1)),
        31,
      );
    });
    test('01/02/2020 to 01/03/2020 [leap-year]', () {
      expect(
        actualDays(DateTime.utc(2020, 2, 1), DateTime.utc(2020, 3, 1)),
        29,
      );
    });
    test('01/02/2019 to 01/03/2019 [non leap-year]', () {
      expect(
        actualDays(DateTime.utc(2019, 2, 1), DateTime.utc(2019, 3, 1)),
        28,
      );
    });
    test('01/02/2019 to 02/02/2019', () {
      expect(actualDays(DateTime.utc(2019, 2, 1), DateTime.utc(2019, 2, 2)), 1);
    });
    test('01/02/2019 to 01/02/2019', () {
      expect(actualDays(DateTime.utc(2019, 2, 1), DateTime.utc(2019, 2, 1)), 0);
    });
    test('01/01/2019 to 01/01/2020', () {
      expect(
        actualDays(DateTime.utc(2019, 1, 1), DateTime.utc(2020, 1, 1)),
        365,
      );
    });
    test('01/01/2020 to 01/01/2021', () {
      expect(
        actualDays(DateTime.utc(2020, 1, 1), DateTime.utc(2021, 1, 1)),
        366,
      );
    });
    test('31/12/2019 to 01/01/2021', () {
      expect(
        actualDays(DateTime.utc(2019, 12, 31), DateTime.utc(2021, 1, 1)),
        367,
      );
    });
  });

  group('hasMonthEndDay', () {
    // Extra tests added Jan 2025 to verify special case handling of
    // day counts for monthly periods involving month end dates
    // which relies on this function
    test('31/01/2023 to return true for month of January', () {
      expect(hasMonthEndDay(DateTime.utc(2023, 1, 31)), true);
    });
    test('28/02/2023 to return false for month of February', () {
      expect(hasMonthEndDay(DateTime.utc(2023, 2, 28)), true);
    });
    test('28/02/2024 to return false for month of February', () {
      expect(hasMonthEndDay(DateTime.utc(2024, 2, 28)), false);
    });
    test('29/02/2024 to return true for month of February', () {
      expect(hasMonthEndDay(DateTime.utc(2024, 2, 29)), true);
    });
    test('30/11/2024 to return true for month of November', () {
      expect(hasMonthEndDay(DateTime.utc(2024, 11, 30)), true);
    });
  });

  group('isLeapYear', () {
    test('2019 is not devisible by 4', () {
      expect(isLeapYear(2019), false);
    });
    test(
        '2016 is divisible by 4 but not 100 (every fourth year, excluding '
        'century year)', () {
      expect(isLeapYear(2016), true);
    });
    test(
        '2020 is divisible by 4 but not 100 (every fourth year, excluding '
        'century year)', () {
      expect(isLeapYear(2020), true);
    });
    test(
        '2024 is divisible by 4 but not 100 (every fourth year, excluding '
        'century year)', () {
      expect(isLeapYear(2024), true);
    });
    test(
        '1600 is divisible by 4 and 100 and 400 (every fourth century is '
        'a leap year)', () {
      expect(isLeapYear(1600), true);
    });
    test(
        '2000 is divisible by 4 and 100 and 400 (every fourth century is '
        'a leap year)', () {
      expect(isLeapYear(2000), true);
    });
    test(
        '2400 is divisible by 4 and 100 and 400 (every fourth century is '
        'a leap year)', () {
      expect(isLeapYear(2400), true);
    });
    test(
        '1900 is divisible by 4 and 100 but not 400 (all centuries except '
        'the fourth)', () {
      expect(isLeapYear(1900), false);
    });
    test(
        '2100 is divisible by 4 and 100 but not 400 (all centuries except '
        'the fourth)', () {
      expect(isLeapYear(2100), false);
    });
    test(
        '2200 is divisible by 4 and 100 but not 400 (all centuries except '
        'the fourth)', () {
      expect(isLeapYear(2200), false);
    });
  });

  group('rollDate', () {
    test('28th Feb 2020 by 1 week', () {
      expect(
        rollDate(DateTime.utc(2020, 2, 28), Frequency.weekly),
        DateTime.utc(2020, 3, 6),
      );
    });
    test('Fortnightly: 28th Feb 2020 by 2 weeks', () {
      expect(
        rollDate(DateTime.utc(2020, 2, 28), Frequency.fortnightly),
        DateTime.utc(2020, 3, 13),
      );
    });
    test('28th Feb 2020 by 1 month', () {
      expect(
        rollDate(DateTime.utc(2020, 2, 28), Frequency.monthly),
        DateTime.utc(2020, 3, 28),
      );
    });
    test('28th Feb 2020 by 1 quarter', () {
      expect(
        rollDate(DateTime.utc(2020, 2, 28), Frequency.quarterly),
        DateTime.utc(2020, 5, 28),
      );
    });
    test('28th Feb 2020 by 1 half year', () {
      expect(
        rollDate(DateTime.utc(2020, 2, 28), Frequency.halfYearly),
        DateTime.utc(2020, 8, 28),
      );
    });
    test('28th Feb 2020 by 1 year', () {
      expect(
        rollDate(DateTime.utc(2020, 2, 28), Frequency.yearly),
        DateTime.utc(2021, 2, 28),
      );
    });
  });

  group('rollDay', () {
    test('Leap-year', () {
      expect(rollDay(DateTime.utc(2020, 3, 1), -1), DateTime.utc(2020, 2, 29));
    });
    test('Non leap-year', () {
      expect(rollDay(DateTime.utc(2019, 3, 1), -1), DateTime.utc(2019, 2, 28));
    });
  });

  group('rollMonth', () {
    test('31st January 2019 to last day in February 2019 [non leap-year]', () {
      expect(
        rollMonth(DateTime.utc(2019, 1, 31), 1, 31),
        DateTime.utc(2019, 2, 28),
      );
    });
    test('31st January 2020 to last day in February 2020 [leap-year]', () {
      expect(
        rollMonth(DateTime.utc(2020, 1, 31), 1, 31),
        DateTime.utc(2020, 2, 29),
      );
    });
    test('28th February 2020 to last day in January 2020 [leap-year]', () {
      expect(
        rollMonth(DateTime.utc(2020, 2, 28), -1, 31),
        DateTime.utc(2020, 1, 31),
      );
    });
    test('31st March 2020 to last day in February 2020 [leap-year]', () {
      expect(
        rollMonth(DateTime.utc(2020, 3, 31), -1, 31),
        DateTime.utc(2020, 2, 29),
      );
    });
    test(
        '31st January 2019 to last day in February 2019 [non leap-year, '
        'no preferred day of month]', () {
      expect(
        rollMonth(DateTime.utc(2019, 1, 31), 1),
        DateTime.utc(2019, 2, 28),
      );
    });
    test(
        '28th February 2019 by two months [non-leap-year, '
        'no preferred day of month]', () {
      expect(
        rollMonth(DateTime.utc(2019, 2, 28), 2),
        DateTime.utc(2019, 4, 28),
      );
    });
    test(
        '31st December 2018 by two months [non-leap-year, '
        'no preferred day of month]', () {
      expect(
        rollMonth(DateTime.utc(2018, 12, 31), 2),
        DateTime.utc(2019, 2, 28),
      );
    });
    test(
        '31st January 2020 by one month [leap-year, '
        'no preferred day of month]', () {
      expect(
        rollMonth(DateTime.utc(2020, 1, 31), 1),
        DateTime.utc(2020, 2, 29),
      );
    });
    test(
        '31st March 2019 by one month [non-leap-year, '
        'no preferred day of month]', () {
      expect(
        rollMonth(DateTime.utc(2019, 3, 31), -1),
        DateTime.utc(2019, 2, 28),
      );
    });
    test(
        '31st January 2020 by two months [leap-year, '
        'no preferred day of month]', () {
      expect(
        rollMonth(DateTime.utc(2020, 1, 31), -2),
        DateTime.utc(2019, 11, 30),
      );
    });
  });
  test('gaussRound', () {
    expect(gaussRound(1.5), 2.0);
    expect(gaussRound(2.5), 2.0);
    expect(gaussRound(1.535, 2), 1.54);
    expect(gaussRound(1.525, 2), 1.52);
    expect(gaussRound(0.4), 0.0);
    expect(gaussRound(0.5), 0.0);
    expect(gaussRound(0.6), 1.0);
    expect(gaussRound(1.4), 1.0);
    expect(gaussRound(1.6), 2.0);
    expect(gaussRound(23.5), 24.0);
    expect(gaussRound(24.5), 24.0);
    expect(gaussRound(-23.5), -24.0);
    expect(gaussRound(-24.5), -24.0);
  });
}
