import 'package:curo/src/calculator.dart';
import 'package:curo/src/enums.dart';
import 'package:test/test.dart';

void main() {
  group('ActualISDA', () {
    const dc = ActualISDA();

    test('28/01/2020 to 28/02/2020 (leap year)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2020, 1, 28),
        DateTime.utc(2020, 2, 28),
      );
      expect(factor.primaryPeriodFraction, closeTo(31 / 366, 1e-10));
      expect(factor.toString(), 'f = 31/366 = 0.08469945');
      expect(factor.toFoldedString(), 'f = 31/366 = 0.08469945');
    });

    test('28/01/2019 to 28/02/2019 (non-leap year)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2019, 1, 28),
        DateTime.utc(2019, 2, 28),
      );
      expect(factor.primaryPeriodFraction, closeTo(31 / 365, 1e-10));
      expect(factor.toString(), 'f = 31/365 = 0.08493151');
      expect(factor.toFoldedString(), 'f = 31/365 = 0.08493151');
    });

    test('31/12/2017 to 31/12/2019 (multi-year non-leap)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2017, 12, 31),
        DateTime.utc(2019, 12, 31),
      );
      // 1 day (2017) / 365 + 365/365 (2018) + 364/365 (2019) = 2
      // (Last day in 2019 isn't counted)
      expect(factor.primaryPeriodFraction, closeTo(730 / 365, 1e-10));
      expect(factor.toString(), 'f = 1/365 + 365/365 + 364/365 = 2.00000000');
      expect(factor.toFoldedString(), 'f = 1/365 + 1 + 364/365 = 2.00000000');
    });

    test('30/06/2019 to 30/06/2021 (leap year in middle)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2019, 6, 30),
        DateTime.utc(2021, 6, 30),
      );
      // 185 days in 2019 / 365 + full 2020 / 366 + 180 days in 2021 / 365
      expect(factor.primaryPeriodFraction, closeTo(2.0, 1e-10));
      expect(factor.toString(), 'f = 185/365 + 366/366 + 180/365 = 2.00000000');
      expect(factor.toFoldedString(), 'f = 185/365 + 1 + 180/365 = 2.00000000');
    });

    test('2020-02-29 to 2021-02-28 (leap day to non-leap)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2020, 2, 29),
        DateTime.utc(2021, 2, 28),
      );
      // 307 days in 2020 (Feb 29 -> Dec 31 inclusive) / 366
      // + 58 days in 2021 (Jan 1 -> Feb 28 exclusive) / 365
      expect(
        factor.primaryPeriodFraction,
        closeTo(307 / 366 + 58 / 365, 1e-10),
      );
      expect(factor.toString(), 'f = 307/366 + 58/365 = 0.99770192');
      expect(factor.toFoldedString(), 'f = 307/366 + 58/365 = 0.99770192');
    });

    test('2019-12-31 to 2020-01-01 (single day across leap year)', () {
      final factor = dc.computeFactor(
        DateTime.utc(2019, 12, 31),
        DateTime.utc(2020, 1, 1),
      );
      expect(factor.primaryPeriodFraction, closeTo(1 / 365, 1e-10));
      expect(factor.toString(), 'f = 1/365 = 0.00273973');
      expect(factor.toFoldedString(), 'f = 1/365 = 0.00273973');
    });

    test('same day returns zero', () {
      final factor = dc.computeFactor(
        DateTime.utc(2020, 1, 1),
        DateTime.utc(2020, 1, 1),
      );
      expect(factor.primaryPeriodFraction, 0.0);
      expect(factor.toString(), 'f = 0/365 = 0.00000000');
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
      const dcXirr = ActualISDA(useXirrMethod: true);

      test('uses drawdown origin', () {
        expect(dcXirr.dayCountOrigin, DayCountOrigin.drawdown);
      });
    });
  });
}
