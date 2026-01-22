import 'package:curo/src/calculator.dart';
import 'package:curo/src/enums.dart';
import 'package:test/test.dart';

void main() {
  group('Actual360', () {
    const dc = Actual360();

    test('28/01/2020 to 28/02/2020 (leap year)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2020, 1, 28),
        DateTime.utc(2020, 2, 28),
      );
      expect(factor.primaryPeriodFraction, closeTo(31 / 360, 1e-10));
      expect(factor.toString(), 't = 31/360 = 0.08611111');
      expect(factor.toFoldedString(), 't = 31/360 = 0.08611111');
    });

    test('28/01/2019 to 28/02/2019 (non-leap year)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2019, 1, 28),
        DateTime.utc(2019, 2, 28),
      );
      expect(factor.primaryPeriodFraction, closeTo(31 / 360, 1e-10));
      expect(factor.toString(), 't = 31/360 = 0.08611111');
      expect(factor.toFoldedString(), 't = 31/360 = 0.08611111');
    });

    test('31/12/2017 to 31/12/2019 (multi-year)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2017, 12, 31),
        DateTime.utc(2019, 12, 31),
      );
      expect(factor.primaryPeriodFraction, closeTo(730 / 360, 1e-10));
      expect(factor.toString(), 't = 730/360 = 2.02777778');
      expect(factor.toFoldedString(), 't = 2 + 10/360 = 2.02777778');
    });

    test('30/06/2019 to 30/06/2021 (multi-year with folding)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2019, 6, 30),
        DateTime.utc(2021, 6, 30),
      );
      expect(factor.primaryPeriodFraction, closeTo(731 / 360, 1e-10));
      expect(factor.toString(), 't = 731/360 = 2.03055556');
      expect(factor.toFoldedString(), 't = 2 + 11/360 = 2.03055556');
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

    test('toString', () {
      const actual360 = Actual360();
      expect(actual360.toString(),
          'Actual360[usePostDates: true, includeNonFinancingFlows: false, useXirrMethod: false]');
    });

    group('default instance', () {
      test('uses post dates and neighbour origin', () {
        expect(dc.usePostDates, isTrue);
        expect(dc.includeNonFinancingFlows, isFalse);
        expect(dc.dayCountOrigin, DayCountOrigin.neighbour);
      });
    });

    group('with useXirrMethod: true', () {
      const dcXirr = Actual360(useXirrMethod: true);

      test('uses drawdown origin', () {
        expect(dcXirr.dayCountOrigin, DayCountOrigin.drawdown);
      });
    });
  });
}
