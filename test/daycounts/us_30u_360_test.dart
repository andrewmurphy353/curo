import 'package:curo/src/calculator.dart';
import 'package:curo/src/enums.dart';
import 'package:test/test.dart';

void main() {
  group('US30U360', () {
    const dc = US30U360();

    test(
      '28/01/2020 to 28/02/2020 (non-leap, Feb 28 -> treat Feb as 30 days)',
      () {
        final factor = dc.computeFactor(
          DateTime.utc(2020, 1, 28),
          DateTime.utc(2020, 2, 28),
        );
        expect(factor.primaryPeriodFraction, closeTo(30 / 360, 1e-10));
        expect(factor.toString(), 't = 30/360 = 0.08333333');
        expect(factor.toFoldedString(), 't = 30/360 = 0.08333333');
      },
    );

    test(
      '28/01/2020 to 29/02/2020 (leap year, Feb 29 -> treat Feb as 30 days)',
      () {
        final factor = dc.computeFactor(
          DateTime.utc(2020, 1, 28),
          DateTime.utc(2020, 2, 29),
        );
        // 28/1->28/2 = 30 + 28/2 -> 30/2 = 2 days, 32 total
        expect(factor.primaryPeriodFraction, closeTo(32 / 360, 1e-10));
        expect(factor.toString(), 't = 32/360 = 0.08888889');
        expect(factor.toFoldedString(), 't = 32/360 = 0.08888889');
      },
    );
    test('29/01/2020 to 29/02/2020 (leap year, -> Feb 29, 1 month)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2020, 1, 29),
        DateTime.utc(2020, 2, 29), // 1 month
      );
      expect(factor.primaryPeriodFraction, closeTo(30 / 360, 1e-10));
      expect(factor.toString(), 't = 30/360 = 0.08333333');
      expect(factor.toFoldedString(), 't = 30/360 = 0.08333333');
    });
    test('30/01/2020 to 29/02/2020 (leap year, -> Feb 29, 30 days)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2020, 1, 30),
        DateTime.utc(2020, 2, 29), // 30 days
      );
      expect(factor.primaryPeriodFraction, closeTo(30 / 360, 1e-10));
      expect(factor.toString(), 't = 30/360 = 0.08333333');
      expect(factor.toFoldedString(), 't = 30/360 = 0.08333333');
    });
    test('31/01/2020 to 29/02/2020 (leap year, -> Feb 29, 1 month)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2020, 1, 31),
        DateTime.utc(2020, 2, 29), // 1 month
      );
      expect(factor.primaryPeriodFraction, closeTo(30 / 360, 1e-10));
      expect(factor.toString(), 't = 30/360 = 0.08333333');
      expect(factor.toFoldedString(), 't = 30/360 = 0.08333333');
    });
    test('29/02/2020 to 31/03/2020 (leap year, Feb 29 -> 1 month)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2020, 2, 29),
        DateTime.utc(2020, 3, 31),
      );
      expect(factor.primaryPeriodFraction, closeTo(30 / 360, 1e-10));
      expect(factor.toString(), 't = 30/360 = 0.08333333');
      expect(factor.toFoldedString(), 't = 30/360 = 0.08333333');
    });
    test('29/02/2020 to 30/03/2020 (leap year, Feb 29 -> 30 days)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2020, 2, 29),
        DateTime.utc(2020, 3, 30),
      );
      expect(factor.primaryPeriodFraction, closeTo(30 / 360, 1e-10));
      expect(factor.toString(), 't = 30/360 = 0.08333333');
      expect(factor.toFoldedString(), 't = 30/360 = 0.08333333');
    });
    test('29/02/2020 to 29/03/2020 (leap year, Feb 29 -> 30 days)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2020, 2, 29),
        DateTime.utc(2020, 3, 29),
      );
      expect(factor.primaryPeriodFraction, closeTo(30 / 360, 1e-10));
      expect(factor.toString(), 't = 30/360 = 0.08333333');
      expect(factor.toFoldedString(), 't = 30/360 = 0.08333333');
    });
    test('28/02/2019 to 28/03/2019 (non-leap, Feb 28 -> 30 days)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2019, 2, 28),
        DateTime.utc(2019, 3, 28),
      );
      expect(factor.primaryPeriodFraction, closeTo(30 / 360, 1e-10));
      expect(factor.toString(), 't = 30/360 = 0.08333333');
      expect(factor.toFoldedString(), 't = 30/360 = 0.08333333');
    });
    test('31/01/2020 to 31/03/2020 (both 31 -> 30)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2020, 1, 31),
        DateTime.utc(2020, 3, 31),
      );
      expect(factor.primaryPeriodFraction, closeTo(60 / 360, 1e-10));
      expect(factor.toString(), 't = 60/360 = 0.16666667');
      expect(factor.toFoldedString(), 't = 60/360 = 0.16666667');
    });
    test('01/01/2018 to 01/01/2020 (multi-year exact)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2018, 1, 1),
        DateTime.utc(2020, 1, 1),
      );
      expect(factor.primaryPeriodFraction, closeTo(720 / 360, 1e-10));
      expect(factor.toString(), 't = 2 = 2.00000000');
      expect(factor.toFoldedString(), 't = 2 = 2.00000000');
    });
    test('15/12/2023 --> 29/02/2024 (cross-year, leap)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2023, 12, 15),
        DateTime.utc(2024, 2, 29),
      );
      expect(factor.primaryPeriodFraction, closeTo(75 / 360, 1e-10));
      expect(factor.toString(), 't = 75/360 = 0.20833333');
      expect(factor.toFoldedString(), 't = 75/360 = 0.20833333');
    });
    test('28/02/2023 --> 29/02/2024 (non-leap -> leap, Feb ends)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2023, 2, 28),
        DateTime.utc(2024, 2, 29),
      );
      expect(factor.primaryPeriodFraction, closeTo(360 / 360, 1e-10));
      expect(factor.toString(), 't = 1 = 1.00000000');
      expect(factor.toFoldedString(), 't = 1 = 1.00000000');
    });
    test('29/12/2024 --> 28/02/2025 (2 months, -> Feb 28, 60 days)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2024, 12, 29),
        DateTime.utc(2025, 2, 28),
      );
      expect(factor.primaryPeriodFraction, closeTo(60 / 360, 1e-10));
      expect(factor.toString(), 't = 60/360 = 0.16666667');
      expect(factor.toFoldedString(), 't = 60/360 = 0.16666667');
    });

    test('same day returns zero', () {
      final factor = dc.computeFactor(
        DateTime.utc(2020, 1, 1),
        DateTime.utc(2020, 1, 1),
      );
      expect(factor.primaryPeriodFraction, 0.0);
      expect(factor.toString(), 't = 0/360 = 0.00000000');
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

    group('default instance', () {
      test('uses post dates and neighbour origin', () {
        expect(dc.usePostDates, isTrue);
        expect(dc.includeNonFinancingFlows, isFalse);
        expect(dc.dayCountOrigin, DayCountOrigin.neighbour);
      });
    });

    group('with useXirrMethod: true', () {
      const dcXirr = US30U360(useXirrMethod: true);

      test('uses drawdown origin', () {
        expect(dcXirr.dayCountOrigin, DayCountOrigin.drawdown);
      });
    });
  });
}
