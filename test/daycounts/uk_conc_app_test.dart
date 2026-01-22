import 'package:curo/src/calculator.dart';
import 'package:curo/src/enums.dart';
import 'package:test/test.dart';

void main() {
  group('UKConcApp - secured (App 1.1), monthly', () {
    final dc = UKConcApp(
      isSecuredOnLand: true,
      timePeriod: DayCountTimePeriod.month,
    );

    test('31/01/2025 -> 28/02/2025 (whole month, non-leap)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2025, 1, 31),
        DateTime.utc(2025, 2, 28),
      );
      expect(factor.primaryPeriodFraction, closeTo(1 / 12, 1e-10));
      expect(factor.toString(), 't = 1/12 = 0.08333333');
      expect(factor.toFoldedString(), 't = 1/12 = 0.08333333');
    });

    test('31/01/2025 -> 28/02/2029 (multiple years)', () {
      final factor = dc.computeFactor(
          DateTime.utc(2025, 1, 31), DateTime.utc(2031, 2, 28));
      expect(factor.primaryPeriodFraction, closeTo(6 + 1 / 12, 1e-10));
      expect(factor.toString(), 't = 73/12 = 6.08333333');
      expect(factor.toFoldedString(), 't = 6 + 1/12 = 6.08333333');
    });

    test('12/01/2025 -> 15/02/2025 (1 whole month + 3 residual days)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2025, 1, 12),
        DateTime.utc(2025, 2, 15),
      );
      expect(factor.primaryPeriodFraction, closeTo(1 / 12 + 3 / 365, 1e-10));
      expect(factor.toString(), 't = 1/12 + 3/365 = 0.09155251');
      expect(factor.toFoldedString(), 't = 1/12 + 3/365 = 0.09155251');
    });

    test('31/01/2020 -> 29/02/2020 (leap year whole month)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2020, 1, 31),
        DateTime.utc(2020, 2, 29),
      );
      expect(factor.primaryPeriodFraction, closeTo(1 / 12, 1e-10));
      expect(factor.toString(), 't = 1/12 = 0.08333333');
      expect(factor.toFoldedString(), 't = 1/12 = 0.08333333');
    });
  });
  group('UKConcApp - secured (App 1.1), weekly', () {
    final dc = UKConcApp(
      isSecuredOnLand: true,
      timePeriod: DayCountTimePeriod.week,
    );

    test('01/01/2020 -> 22/01/2020 (exactly 3 weeks)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2020, 1, 1),
        DateTime.utc(2020, 1, 22),
      );
      // 21 days = exactly 3 weeks, no residual
      expect(factor.primaryPeriodFraction, closeTo(3 / 52, 1e-10));
      expect(factor.toString(), 't = 3/52 = 0.05769231');
      expect(factor.toFoldedString(), 't = 3/52 = 0.05769231');
    });
    test('01/01/2020 -> 29/01/2020 (exactly 4 weeks)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2020, 1, 1),
        DateTime.utc(2020, 1, 29),
      );
      expect(factor.primaryPeriodFraction, closeTo(4 / 52, 1e-10));
      expect(factor.toString(), 't = 4/52 = 0.07692308');
      expect(factor.toFoldedString(), 't = 4/52 = 0.07692308');
    });
    test('01/01/2020 -> 23/01/2020 (3 weeks + 1 day residual)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2020, 1, 1),
        DateTime.utc(2020, 1, 23),
      );
      // 22 days = 3 weeks + 1 day
      expect(factor.primaryPeriodFraction, closeTo(3 / 52 + 1 / 366, 1e-10));
      expect(factor.toString(), 't = 3/52 + 1/366 = 0.06042455');
      expect(factor.toFoldedString(), 't = 3/52 + 1/366 = 0.06042455');
    });
  });
  group(
    'UKConcApp - secured single payment (month preference overrides week)',
    () {
      final dc = UKConcApp(
        isSecuredOnLand: true,
        hasSinglePayment: true,
        timePeriod: DayCountTimePeriod.week, // month should win
      );

      test(
        '01/02/2020 -> 01/03/2020 (exact month preferred over 4 weeks)',
        () {
          final factor = dc.computeFactor(
            DateTime.utc(2020, 2, 1),
            DateTime.utc(2020, 3, 1),
          );
          expect(factor.primaryPeriodFraction, closeTo(1 / 12, 1e-10));
          expect(factor.toString(), 't = 1/12 = 0.08333333');
          expect(factor.toFoldedString(), 't = 1/12 = 0.08333333');
        },
      );
      test('1/02/2025 --> 01/03/2029 (multiple years)', () {
        final factor = dc.computeFactor(
          DateTime.utc(2025, 2, 1),
          DateTime.utc(2031, 3, 1),
        );
        expect(factor.primaryPeriodFraction, 6.08333333333333333);
        expect(factor.toString(), 't = 73/12 = 6.08333333');
        expect(factor.toFoldedString(), 't = 6 + 1/12 = 6.08333333');
      });
    },
  );
  group('UKConcApp - non-secured (App 1.2), monthly', () {
    final dc = UKConcApp(
      isSecuredOnLand: false,
      timePeriod: DayCountTimePeriod.month,
    );

    test('31/01/2025 -> 28/02/2025 (whole month, non-leap)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2025, 1, 31),
        DateTime.utc(2025, 2, 28),
      );
      expect(factor.primaryPeriodFraction, closeTo(1 / 12, 1e-10));
      expect(factor.toString(), 't = 1/12 = 0.08333333');
      expect(factor.toFoldedString(), 't = 1/12 = 0.08333333');
    });
    test('12/01/2025 -> 15/02/2025 (1 whole month + 3 residual days)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2025, 1, 12),
        DateTime.utc(2025, 2, 15),
      );
      expect(factor.primaryPeriodFraction, closeTo(1 / 12 + 3 / 365, 1e-10));
      expect(factor.toString(), 't = 1/12 + 3/365 = 0.09155251');
      expect(factor.toFoldedString(), 't = 1/12 + 3/365 = 0.09155251');
    });
    test('31/01/2020 -> 29/02/2020 (leap year whole month)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2020, 1, 31),
        DateTime.utc(2020, 2, 29),
      );
      expect(factor.primaryPeriodFraction, closeTo(1 / 12, 1e-10));
      expect(factor.toString(), 't = 1/12 = 0.08333333');
      expect(factor.toFoldedString(), 't = 1/12 = 0.08333333');
    });
    test('15/12/2023 --> 29/02/2024 (cross-year, leap)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2023, 12, 15),
        DateTime.utc(2024, 2, 29),
      );
      expect(factor.primaryPeriodFraction, closeTo(2 / 12 + 14 / 366, 1e-10));
      expect(factor.toString(), 't = 2/12 + 14/366 = 0.20491803');
    });
    test('20/11/2023 --> 15/01/2024 (remaining days cross-year, leap)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2023, 11, 20),
        DateTime.utc(2024, 1, 15),
      );
      expect(factor.primaryPeriodFraction,
          closeTo(1 / 12 + 11 / 365 + 14 / 366, 1e-10));
      expect(factor.toString(), 't = 1/12 + 11/365 + 14/366 = 0.15172169');
    });
  });

  group('UKConcApp - non-secured (App 1.2), weekly', () {
    final dc = UKConcApp(
      isSecuredOnLand: false,
      timePeriod: DayCountTimePeriod.week,
    );

    test('01/01/2020 -> 22/01/2020 (exactly 3 weeks)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2020, 1, 1),
        DateTime.utc(2020, 1, 22),
      );
      // 21 days = exactly 3 weeks, no residual
      expect(factor.primaryPeriodFraction, closeTo(3 / 52, 1e-10));
      expect(factor.toString(), 't = 3/52 = 0.05769231');
      expect(factor.toFoldedString(), 't = 3/52 = 0.05769231');
    });
    test('01/01/2020 -> 29/01/2020 (exactly 4 weeks)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2020, 1, 1),
        DateTime.utc(2020, 1, 29),
      );
      expect(factor.primaryPeriodFraction, closeTo(4 / 52, 1e-10));
      expect(factor.toString(), 't = 4/52 = 0.07692308');
      expect(factor.toFoldedString(), 't = 4/52 = 0.07692308');
    });
    test('01/01/2020 -> 23/01/2020 (3 weeks + 1 day residual)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2020, 1, 1),
        DateTime.utc(2020, 1, 23),
      );
      // 22 days = 3 weeks + 1 day
      expect(factor.primaryPeriodFraction, closeTo(3 / 52 + 1 / 366, 1e-10));
      expect(factor.toString(), 't = 3/52 + 1/366 = 0.06042455');
      expect(factor.toFoldedString(), 't = 3/52 + 1/366 = 0.06042455');
    });
    test('31/01/2025 --> 28/02/2025 (whole weeks)', () {
      final factor = dc.computeFactor(
          DateTime.utc(2025, 1, 31), DateTime.utc(2025, 2, 28));
      expect(factor.primaryPeriodFraction, closeTo(4 / 52, 1e-10));
      expect(factor.toString(), 't = 4/52 = 0.07692308');
    });
    test('01/01/2023 --> 14/01/2024 (whole weeks, cross-year)', () {
      final factor =
          dc.computeFactor(DateTime.utc(2023, 1, 1), DateTime.utc(2024, 1, 14));
      expect(factor.primaryPeriodFraction, closeTo(1 + 2 / 52, 1e-10));
      expect(factor.toString(), 't = 54/52 = 1.03846154');
      expect(factor.toFoldedString(), 't = 1 + 2/52 = 1.03846154');
    });
    test('12/01/2024 --> 30/01/2024 (non-whole)', () {
      final factor = dc.computeFactor(
          DateTime.utc(2024, 1, 12), DateTime.utc(2024, 1, 30));
      expect(factor.primaryPeriodFraction, closeTo(2 / 52 + 4 / 366, 1e-10));
      expect(factor.toString(), 't = 2/52 + 4/366 = 0.04939050');
    });
    test('02/12/2023 --> 05/01/2024 (remaining days cross-year, leap)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2023, 12, 2),
        DateTime.utc(2024, 1, 5),
      );
      expect(factor.primaryPeriodFraction,
          closeTo(4 / 52 + 1 / 365 + 4 / 366, 1e-10));
      expect(factor.toString(), 't = 4/52 + 1/365 + 4/366 = 0.09059176');
    });
  });

  group('UKConcApp - defaults and properties', () {
    final dc = UKConcApp();

    test('defaults are correct', () {
      expect(dc.isSecuredOnLand, isFalse);
      expect(dc.hasSinglePayment, isFalse);
      expect(dc.timePeriod, DayCountTimePeriod.month);
      expect(dc.dayCountOrigin, DayCountOrigin.drawdown);
      expect(dc.usePostDates, isTrue);
      expect(dc.includeNonFinancingFlows, isTrue);
    });
  });

  test('invalid timePeriod throws ArgumentError', () {
    expect(
      () => UKConcApp(timePeriod: DayCountTimePeriod.day),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('same day returns zero', () {
    final dc = UKConcApp();
    final factor = dc.computeFactor(
      DateTime.utc(2020, 1, 1),
      DateTime.utc(2020, 1, 1),
    );
    expect(factor.primaryPeriodFraction, 0.0);
    expect(factor.toString(), 't = 0 = 0.00000000');
    expect(factor.toFoldedString(), 't = 0 = 0.00000000');
  });

  test('end before start throws ArgumentError', () {
    final dc = UKConcApp();
    expect(
      () => dc.computeFactor(
        DateTime.utc(2020, 2, 1),
        DateTime.utc(2020, 1, 1),
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
}
