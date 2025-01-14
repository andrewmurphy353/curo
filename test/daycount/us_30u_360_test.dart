import 'package:curo/curo.dart';
import 'package:test/test.dart';

void main() {
  group('US30U360.computeFactor', () {
    const dc = US30U360();
    test('28/01/2020 to 28/02/2020', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2020, 1, 28),
        DateTime.utc(2020, 2, 28),
      );
      expect(dcf.factor, 0.08333333333333333);
      expect(dcf.toString(), '(30/360) = 0.08333333');
    });
    test('28/01/2020 to 29/02/2020', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2020, 1, 28), // 2 days
        DateTime.utc(2020, 2, 29), //30 days
      );
      expect(dcf.factor, 0.08888888888888889);
      expect(dcf.toString(), '(32/360) = 0.08888889');
    });
    test('29/01/2020 to 29/02/2020', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2020, 1, 29),
        DateTime.utc(2020, 2, 29), //30 days
      );
      expect(dcf.factor, 0.08333333333333333);
      expect(dcf.toString(), '(30/360) = 0.08333333');
    });
    test('30/01/2020 to 29/02/2020', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2020, 1, 30),
        DateTime.utc(2020, 2, 29), //30 days
      );
      expect(dcf.factor, 0.08333333333333333);
      expect(dcf.toString(), '(30/360) = 0.08333333');
    });
    test('31/01/2020 to 29/02/2020', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2020, 1, 31),
        DateTime.utc(2020, 2, 29), //30 days
      );
      expect(dcf.factor, 0.08333333333333333);
      expect(dcf.toString(), '(30/360) = 0.08333333');
    });
    test('01/02/2020 to 15/03/2020', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2020, 2, 1), // 29 days
        DateTime.utc(2020, 3, 15), //15 days
      );
      expect(dcf.factor, 0.12222222222222222);
      expect(dcf.toString(), '(44/360) = 0.12222222');
    });
    test('28/02/2020 to 15/03/2020', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2020, 2, 28), // 2 days
        DateTime.utc(2020, 3, 15), //15 days
      );
      expect(dcf.factor, 0.04722222222222222);
      expect(dcf.toString(), '(17/360) = 0.04722222');
    });
    test('28/02/2020 to 28/03/2020', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2020, 2, 28),
        DateTime.utc(2020, 3, 28), //30 days
      );
      expect(dcf.factor, 0.08333333333333333);
      expect(dcf.toString(), '(30/360) = 0.08333333');
    });
    test('29/02/2020 to 29/03/2020', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2020, 2, 29),
        DateTime.utc(2020, 3, 29), //30 days
      );
      expect(dcf.factor, 0.08333333333333333);
      expect(dcf.toString(), '(30/360) = 0.08333333');
    });
    test('29/02/2020 to 30/03/2020', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2020, 2, 29),
        DateTime.utc(2020, 3, 30), //30 days
      );
      expect(dcf.factor, 0.08333333333333333);
      expect(dcf.toString(), '(30/360) = 0.08333333');
    });
    test('29/02/2020 to 31/03/2020', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2020, 2, 29),
        DateTime.utc(2020, 3, 31), //30 days
      );
      expect(dcf.factor, 0.08333333333333333);
      expect(dcf.toString(), '(30/360) = 0.08333333');
    });
    test('28/01/2021 to 28/02/2021', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2021, 1, 28),
        DateTime.utc(2021, 2, 28), //30 days
      );
      expect(dcf.factor, 0.08333333333333333);
      expect(dcf.toString(), '(30/360) = 0.08333333');
    });
    test('29/01/2021 to 28/02/2021', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2021, 1, 29), // 1 day
        DateTime.utc(2021, 2, 28), //29 days (special case)
      );
      expect(dcf.factor, 0.08333333333333333);
      expect(dcf.toString(), '(30/360) = 0.08333333');
    });
    test('30/01/2021 to 28/02/2021', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2021, 1, 30),
        DateTime.utc(2021, 2, 28), //30 days
      );
      expect(dcf.factor, 0.08333333333333333);
      expect(dcf.toString(), '(30/360) = 0.08333333');
    });
    test('31/01/2021 to 28/02/2021', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2021, 1, 31),
        DateTime.utc(2021, 2, 28), //30 days
      );
      expect(dcf.factor, 0.08333333333333333);
      expect(dcf.toString(), '(30/360) = 0.08333333');
    });
    test('28/02/2021 to 28/03/2021', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2021, 2, 28),
        DateTime.utc(2021, 3, 28), //30 days
      );
      expect(dcf.factor, 0.08333333333333333);
      expect(dcf.toString(), '(30/360) = 0.08333333');
    });
    test('28/02/2021 to 29/03/2021', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2021, 2, 28), // 1 day (special case - 29 day month)
        DateTime.utc(2021, 3, 29), //29 days
      );
      expect(dcf.factor, 0.08333333333333333);
      expect(dcf.toString(), '(30/360) = 0.08333333');
    });
    test('28/02/2021 to 30/03/2021', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2021, 2, 28),
        DateTime.utc(2021, 3, 30), //30 days
      );
      expect(dcf.factor, 0.08333333333333333);
      expect(dcf.toString(), '(30/360) = 0.08333333');
    });
    test('28/02/2021 to 31/03/2021', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2021, 2, 28),
        DateTime.utc(2021, 3, 31), //30 days
      );
      expect(dcf.factor, 0.08333333333333333);
      expect(dcf.toString(), '(30/360) = 0.08333333');
    });

    test('28/01/2019 to 28/02/2019', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2019, 1, 28),
        DateTime.utc(2019, 2, 28),
      );
      expect(dcf.factor, 0.08333333333333333);
      expect(dcf.toString(), '(30/360) = 0.08333333');
    });
    test('16/06/2019 to 31/07/2019', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2019, 6, 16),
        DateTime.utc(2019, 7, 31),
      );
      expect(dcf.factor, 0.12222222222222222);
      expect(dcf.toString(), '(44/360) = 0.12222222');
    });
    test('31/12/2017 to 31/12/2019', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2017, 12, 31),
        DateTime.utc(2019, 12, 31),
      );
      expect(dcf.factor, 2.0);
      expect(dcf.toString(), '(720/360) = 2.00000000');
    });
    test('31/12/2018 to 31/12/2020', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2018, 12, 31),
        DateTime.utc(2020, 12, 31),
      );
      expect(dcf.factor, 2.0);
      expect(dcf.toString(), '(720/360) = 2.00000000');
    });
    test('30/06/2019 to 30/06/2021', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2019, 6, 30),
        DateTime.utc(2021, 6, 30),
      );
      expect(dcf.factor, 2.0);
      expect(dcf.toString(), '(720/360) = 2.00000000');
    });
  });
  group('US360360 default instance', () {
    const dc = US30U360();
    test('dayCountOrigin() to return "neighbour"', () {
      expect(dc.dayCountOrigin(), DayCountOrigin.neighbour);
    });
    test('usePostDates() to return "true"', () {
      expect(dc.usePostDates, true);
    });
    test('includeNonFinancingFlows() to return "false"', () {
      expect(dc.includeNonFinancingFlows, false);
    });
  });
  group('US360360 useXirrMethod', () {
    const dc = US30U360(useXirrMethod: true);
    test('dayCountOrigin() to return "drawdown"', () {
      expect(dc.dayCountOrigin(), DayCountOrigin.drawdown);
    });
  });
}
