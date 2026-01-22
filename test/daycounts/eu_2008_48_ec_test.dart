import 'package:curo/src/calculator.dart';
import 'package:curo/src/enums.dart';
import 'package:test/test.dart';

void main() {
  group('EU200848EC - default (month)', () {
    final dc = EU200848EC();

    test('default timePeriod is month', () {
      expect(dc.timePeriod, DayCountTimePeriod.month);
    });

    test('fixed flags are correct', () {
      expect(dc.usePostDates, isTrue);
      expect(dc.includeNonFinancingFlows, isTrue);
      expect(dc.useXirrMethod, isTrue);
      expect(dc.dayCountOrigin, DayCountOrigin.drawdown);
    });

    test('same day returns zero', () {
      final factor = dc.computeFactor(
        DateTime.utc(2012, 1, 12),
        DateTime.utc(2012, 1, 12),
      );
      expect(factor.primaryPeriodFraction, 0.0);
      expect(factor.toString(), 't = 0 = 0.00000000');
      expect(factor.toFoldedString(), 't = 0 = 0.00000000');
    });

    test('end before start throws ArgumentError', () {
      expect(
        () => dc.computeFactor(
          DateTime.utc(2020, 2, 1),
          DateTime.utc(2020, 1, 1),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('12/01/2019 <-- 12/01/2020 (exact 12 months)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2019, 1, 12),
        DateTime.utc(2020, 1, 12),
      );
      expect(factor.primaryPeriodFraction, closeTo(1.0, 1e-10));
      expect(factor.toString(), 't = 12/12 = 1.00000000');
      expect(factor.toFoldedString(), 't = 1 = 1.00000000');
    });

    test('31/01/2019 <-- 28/02/2019 (month-end alignment)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2019, 1, 31),
        DateTime.utc(2019, 2, 28),
      );
      expect(factor.primaryPeriodFraction, closeTo(1.0 / 12, 1e-10));
      expect(factor.toString(), 't = 1/12 = 0.08333333');
      expect(factor.toFoldedString(), 't = 1/12 = 0.08333333');
    });

    test('31/01/2020 <-- 29/02/2020 (leap year month-end)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2020, 1, 31),
        DateTime.utc(2020, 2, 29),
      );
      expect(factor.primaryPeriodFraction, closeTo(1.0 / 12, 1e-10));
      expect(factor.toString(), 't = 1/12 = 0.08333333');
      expect(factor.toFoldedString(), 't = 1/12 = 0.08333333');
    });

    test('28/02/2019 <-- 31/03/2019 (non-leap Feb end)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2019, 2, 28),
        DateTime.utc(2019, 3, 31),
      );
      expect(factor.primaryPeriodFraction, closeTo(1.0 / 12, 1e-10));
      expect(factor.toString(), 't = 1/12 = 0.08333333');
      expect(factor.toFoldedString(), 't = 1/12 = 0.08333333');
    });

    test('15/02/2019 <-- 15/03/2019 (mid-month)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2019, 2, 15),
        DateTime.utc(2019, 3, 15),
      );
      expect(factor.primaryPeriodFraction, closeTo(1.0 / 12, 1e-10));
      expect(factor.toString(), 't = 1/12 = 0.08333333');
      expect(factor.toFoldedString(), 't = 1/12 = 0.08333333');
    });

    test('31/01/2019 <-- 01/03/2019 (1 month + fractional days)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2019, 1, 31),
        DateTime.utc(2019, 3, 1),
      );
      // 1 whole month + 1 day -> 1/12 + 1/365
      expect(factor.primaryPeriodFraction, closeTo(1 / 12 + 1 / 365, 1e-10));
      expect(factor.toString(), 't = 1/12 + 1/365 = 0.08607306');
      expect(factor.toFoldedString(), 't = 1/12 + 1/365 = 0.08607306');
    });

    test(
      '31/12/2020 <-- 01/03/2021 (2 months + fractional days leap year)',
      () {
        final factor = dc.computeFactor(
          DateTime.utc(2020, 12, 31),
          DateTime.utc(2021, 3, 1),
        );
        // 2 whole months + 1 day -> 2/12 + 1/366
        expect(factor.primaryPeriodFraction, closeTo(2 / 12 + 1 / 366, 1e-10));
        expect(factor.toString(), 't = 2/12 + 1/366 = 0.16939891');
        expect(factor.toFoldedString(), 't = 2/12 + 1/366 = 0.16939891');
      },
    );

    test('complex: 01/01/2019 <-- 15/06/2020 (17 months + fractional)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2019, 1, 1),
        DateTime.utc(2020, 6, 15),
      );
      // 17 whole months + (14 days)
      expect(factor.primaryPeriodFraction, closeTo(17 / 12 + 14 / 365, 1e-10));
      expect(factor.toString(), 't = 17/12 + 14/365 = 1.45502283');
      expect(factor.toFoldedString(), 't = 1 + 5/12 + 14/365 = 1.45502283');
    });

    test(
      'complex: 01/03/2020 <-- 15/08/2021 (17 months + fractional leap-year)',
      () {
        final factor = dc.computeFactor(
          DateTime.utc(2020, 3, 1),
          DateTime.utc(2021, 8, 15),
        );
        // Year prior to drawdown includes leap day -> days = 366
        expect(
          factor.primaryPeriodFraction,
          closeTo(17 / 12 + 14 / 366, 1e-10),
        );
        expect(factor.toString(), 't = 17/12 + 14/366 = 1.45491803');
        expect(factor.toFoldedString(), 't = 1 + 5/12 + 14/366 = 1.45491803');
      },
    );
  });

  group('EU200848EC - year timePeriod', () {
    final dc = EU200848EC(timePeriod: DayCountTimePeriod.year);

    test('01/01/2019 <-- 01/01/2020 (exact year)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2019, 1, 1),
        DateTime.utc(2020, 1, 1),
      );
      expect(factor.primaryPeriodFraction, 1.0);
      expect(factor.toString(), 't = 1/1 = 1.00000000');
      expect(factor.toFoldedString(), 't = 1 = 1.00000000');
    });
  });

  group('EU200848EC - week timePeriod', () {
    final dc = EU200848EC(timePeriod: DayCountTimePeriod.week);

    test('01/01/2019 <-- 08/01/2019 (exact week)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2019, 1, 1),
        DateTime.utc(2019, 1, 8),
      );
      expect(factor.primaryPeriodFraction, closeTo(1 / 52, 1e-10));
      expect(factor.toString(), 't = 1/52 = 0.01923077');
      expect(factor.toFoldedString(), 't = 1/52 = 0.01923077');
    });
  });

  group('Invalid time period', () {
    test('constructor throws ArgumentError', () {
      expect(
        () => EU200848EC(timePeriod: DayCountTimePeriod.day),
        throwsA(isA<ArgumentError>()),
      );
    });
    test('computeFactor throws StateError', () {
      final convention =
          EU200848EC.testOnly(timePeriod: DayCountTimePeriod.day);
      expect(
        () => convention.computeFactor(
            DateTime(2024, 1, 1), DateTime(2024, 1, 2)),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('Unsupported time period'),
        )),
      );
    });
  });
}
