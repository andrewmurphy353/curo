import 'package:curo/src/daycount/act_360.dart';
import 'package:curo/src/daycount/day_count_origin.dart';
import 'package:test/test.dart';

void main() {
  group('Act360.computeFactor', () {
    const dc = Act360();
    test('28/01/2020 to 28/02/2020', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2020, 1, 28),
        DateTime.utc(2020, 2, 28),
      );
      expect(dcf.factor, 0.08611111111111111);
      expect(dcf.toString(), '(31/360) = 0.08611111');
      expect(dcf.toFoldedString(), '(31/360) = 0.08611111');
    });
    test('28/01/2019 to 28/02/2019', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2019, 1, 28),
        DateTime.utc(2019, 2, 28),
      );
      expect(dcf.factor, 0.08611111111111111);
      expect(dcf.toString(), '(31/360) = 0.08611111');
      expect(dcf.toFoldedString(), '(31/360) = 0.08611111');
    });
    test('31/12/2017 to 31/12/2019', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2017, 12, 31),
        DateTime.utc(2019, 12, 31),
      );
      expect(dcf.factor, 2.0277777777777777);
      expect(dcf.toString(), '2 + (10/360) = 2.02777778');
      expect(dcf.toFoldedString(), '2 + (10/360) = 2.02777778');
    });
    test('31/12/2018 to 31/12/2020', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2018, 12, 31),
        DateTime.utc(2020, 12, 31),
      );
      expect(dcf.factor, 2.0305555555555554);
      expect(dcf.toString(), '2 + (11/360) = 2.03055556');
      expect(dcf.toFoldedString(), '2 + (11/360) = 2.03055556');
    });
    test('30/06/2019 to 30/06/2021', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2019, 6, 30),
        DateTime.utc(2021, 6, 30),
      );
      expect(dcf.factor, 2.0305555555555554);
      expect(dcf.toString(), '2 + (11/360) = 2.03055556');
      expect(dcf.toFoldedString(), '2 + (11/360) = 2.03055556');
    });
  });
  group('Act360 default instance', () {
    const dc = Act360();
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
  group('Act360 useXirrMethod', () {
    const dc = Act360(useXirrMethod: true);
    test('dayCountMethod() to return "drawdown"', () {
      expect(dc.dayCountOrigin(), DayCountOrigin.drawdown);
    });
  });
}
