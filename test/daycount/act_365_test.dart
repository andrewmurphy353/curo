import 'package:curo/src/daycount/act_365.dart';
import 'package:curo/src/daycount/day_count_origin.dart';
import 'package:test/test.dart';

void main() {
  group('Act365.computeFactor', () {
    const dc = Act365();
    test('28/01/2020 to 28/02/2020', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2020, 1, 28),
        DateTime.utc(2020, 2, 28),
      );
      expect(dcf.factor, 0.08493150684931507);
      expect(dcf.toString(), '(31/365) = 0.08493151');
      expect(dcf.toFoldedString(), '(31/365) = 0.08493151');
    });
    test('28/01/2019 to 28/02/2019', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2019, 1, 28),
        DateTime.utc(2019, 2, 28),
      );
      expect(dcf.factor, 0.08493150684931507);
      expect(dcf.toString(), '(31/365) = 0.08493151');
      expect(dcf.toFoldedString(), '(31/365) = 0.08493151');
    });
    test('31/12/2017 to 31/12/2019', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2017, 12, 31),
        DateTime.utc(2019, 12, 31),
      );
      expect(dcf.factor, 2.0);
      expect(dcf.toString(), '2 = 2.00000000');
      expect(dcf.toFoldedString(), '2 = 2.00000000');
    });
    test('31/12/2018 to 31/12/2020', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2018, 12, 31),
        DateTime.utc(2020, 12, 31),
      );
      expect(dcf.factor, 2.0027397260273974);
      expect(dcf.toString(), '2 + (1/365) = 2.00273973');
      expect(dcf.toFoldedString(), '2 + (1/365) = 2.00273973');
    });
    test('30/06/2019 to 30/06/2021', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2019, 6, 30),
        DateTime.utc(2021, 6, 30),
      );
      expect(dcf.factor, 2.0027397260273974);
      expect(dcf.toString(), '2 + (1/365) = 2.00273973');
      expect(dcf.toFoldedString(), '2 + (1/365) = 2.00273973');
    });
  });
  group('Act365 default instance', () {
    const dc = Act365();
    test('dayCountMethod() to return "neighbour"', () {
      expect(dc.dayCountOrigin(), DayCountOrigin.neighbour);
    });
    test('usePostDates to return "true"', () {
      expect(dc.usePostDates, true);
    });
    test('includeNonFinancingFlows() to return "false"', () {
      expect(dc.includeNonFinancingFlows, false);
    });
  });
  group('Act365 useXirrMethod', () {
    const dc = Act365(useXirrMethod: true);
    test('dayCountMethod() to return "drawdown"', () {
      expect(dc.dayCountOrigin(), DayCountOrigin.drawdown);
    });
  });
}
