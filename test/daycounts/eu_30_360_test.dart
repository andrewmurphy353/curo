import 'package:curo/src/calculator.dart';
import 'package:curo/src/enums.dart';
import 'package:test/test.dart';

void main() {
  group('EU30360', () {
    const dc = EU30360();

    test('28/01/2020 to 29/02/2020 (leap year)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2020, 1, 28),
        DateTime.utc(2020, 2, 29),
      );
      expect(factor.primaryPeriodFraction, closeTo(31 / 360, 1e-10));
      expect(factor.toString(), 'f = 31/360 = 0.08611111');
      expect(factor.toFoldedString(), 'f = 31/360 = 0.08611111');
    });

    test('28/01/2019 to 28/02/2019 (non-leap year)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2019, 1, 28),
        DateTime.utc(2019, 2, 28),
      );
      expect(factor.primaryPeriodFraction, closeTo(30 / 360, 1e-10));
      expect(factor.toString(), 'f = 30/360 = 0.08333333');
      expect(factor.toFoldedString(), 'f = 30/360 = 0.08333333');
    });

    test('31/01/2020 to 31/03/2020 (both 31 -> 30)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2020, 1, 31),
        DateTime.utc(2020, 3, 31),
      );
      expect(factor.primaryPeriodFraction, closeTo(60 / 360, 1e-10));
      expect(factor.toString(), 'f = 60/360 = 0.16666667');
      expect(factor.toFoldedString(), 'f = 60/360 = 0.16666667');
    });

    test('31/12/2017 to 31/12/2019 (multi-year)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2017, 12, 31),
        DateTime.utc(2019, 12, 31),
      );
      expect(factor.primaryPeriodFraction, closeTo(720 / 360, 1e-10));
      expect(factor.toString(), 'f = 720/360 = 2.00000000');
      expect(factor.toFoldedString(), 'f = 2 = 2.00000000');
    });

    test('30/06/2019 to 30/06/2021 (multi-year exact)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2019, 6, 30),
        DateTime.utc(2021, 6, 30),
      );
      expect(factor.primaryPeriodFraction, closeTo(720 / 360, 1e-10));
      expect(factor.toString(), 'f = 720/360 = 2.00000000');
      expect(factor.toFoldedString(), 'f = 2 = 2.00000000');
    });

    test('same day returns zero', () {
      final factor = dc.computeFactor(
        DateTime.utc(2020, 1, 1),
        DateTime.utc(2020, 1, 1),
      );
      expect(factor.primaryPeriodFraction, 0.0);
      expect(factor.toString(), 'f = 0/360 = 0.00000000');
      expect(factor.toFoldedString(), 'f = 0 = 0.00000000');
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
      const dcXirr = EU30360(useXirrMethod: true);

      test('uses drawdown origin', () {
        expect(dcXirr.dayCountOrigin, DayCountOrigin.drawdown);
      });
    });
  });
}
