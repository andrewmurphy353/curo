// The majority of test cases are based on examples extracted from
// https://ec.europa.eu/info/sites/info/files/guidelines_final.pdf

import 'package:curo/src/daycount/day_count_origin.dart';
import 'package:curo/src/daycount/eu_2008_48_ec.dart';
import 'package:test/test.dart';

void main() {
  group('EU200848EC.computeFactor [timePeriod = month]', () {
    const dc = EU200848EC(timePeriod: EUTimePeriod.month);
    test('timePeriod() to return month', () {
      expect(dc.timePeriod, EUTimePeriod.month);
    });
    test('12/01/2019 <-- 12/01/2020', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2019, 1, 12),
        DateTime.utc(2020, 1, 12),
      );
      expect(dcf.factor, 1.0);
      expect(dcf.toString(), '(12/12) = 1.00000000');
    });
    test('12/01/2012 <-- 15/02/2012', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2012, 1, 12),
        DateTime.utc(2012, 2, 15),
      );
      expect(dcf.factor, 0.0915525114155251);
      expect(dcf.toString(), '(1/12) + (3/365) = 0.09155251');
    });
    test('12/01/2012 <-- 15/03/2012', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2012, 1, 12),
        DateTime.utc(2012, 3, 15),
      );
      expect(dcf.factor, 0.17488584474885843);
      expect(dcf.toString(), '(2/12) + (3/365) = 0.17488584');
    });
    test('12/01/2012 <-- 15/04/2012', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2012, 1, 12),
        DateTime.utc(2012, 4, 15),
      );
      expect(dcf.factor, 0.2582191780821918);
      expect(dcf.toString(), '(3/12) + (3/365) = 0.25821918');
    });
    test('12/01/2013 <-- 15/02/2013', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2013, 1, 12),
        DateTime.utc(2013, 2, 15),
      );
      expect(dcf.factor, 0.09153005464480873);
      expect(dcf.toString(), '(1/12) + (3/366) = 0.09153005');
    });
    test('12/01/2013 <-- 15/03/2013', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2013, 1, 12),
        DateTime.utc(2013, 3, 15),
      );
      expect(dcf.factor, 0.17486338797814208);
      expect(dcf.toString(), '(2/12) + (3/366) = 0.17486339');
    });
    test('12/01/2013 <-- 15/04/2013', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2013, 1, 12),
        DateTime.utc(2013, 4, 15),
      );
      expect(dcf.factor, 0.2581967213114754);
      expect(dcf.toString(), '(3/12) + (3/366) = 0.25819672');
    });
    test('25/02/2013 <-- 28/03/2013', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2013, 2, 25),
        DateTime.utc(2013, 3, 28),
      );
      expect(dcf.factor, 0.09153005464480873);
      expect(dcf.toString(), '(1/12) + (3/366) = 0.09153005');
    });
    test('26/02/2013 <-- 29/03/2013', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2013, 2, 26),
        DateTime.utc(2013, 3, 29),
      );
      expect(dcf.factor, 0.08879781420765027);
      expect(dcf.toString(), '(1/12) + (2/366) = 0.08879781');
    });
    test('26/02/2012 <-- 29/03/2012', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2012, 2, 26),
        DateTime.utc(2012, 3, 29),
      );
      expect(dcf.factor, 0.09153005464480873);
      expect(dcf.toString(), '(1/12) + (3/366) = 0.09153005');
    });
    test('26/02/2012 <-- 26/02/2012', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2012, 2, 26),
        DateTime.utc(2012, 2, 26),
      );
      expect(dcf.factor, 0.0);
      expect(dcf.toString(), '(0/365) = 0.00000000');
    });
  });
  group('EU200848EC.computeFactor [timePeriod = year]', () {
    const dc = EU200848EC(timePeriod: EUTimePeriod.year);
    test('timePeriod() to return year', () {
      expect(dc.timePeriod, EUTimePeriod.year);
    });
    test('12/01/2012 <-- 15/02/2012', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2012, 1, 12),
        DateTime.utc(2012, 2, 15),
      );
      expect(dcf.factor, 0.09315068493150686);
      expect(dcf.toString(), '(34/365) = 0.09315068');
    });
    test('12/01/2012 <-- 15/02/2013', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2012, 1, 12),
        DateTime.utc(2013, 2, 15),
      );
      expect(dcf.factor, 1.093150684931507);
      expect(dcf.toString(), '(1/1) + (34/365) = 1.09315068');
    });
    test('12/01/2012 <-- 15/02/2014', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2012, 1, 12),
        DateTime.utc(2014, 2, 15),
      );
      expect(dcf.factor, 2.0931506849315067);
      expect(dcf.toString(), '(2/1) + (34/365) = 2.09315068');
    });
    test('01/01/2020 <-- 15/03/2021', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2020, 1, 1),
        DateTime.utc(2021, 3, 15),
      );
      expect(dcf.factor, 1.2021857923497268);
      expect(dcf.toString(), '(1/1) + (74/366) = 1.20218579');
    });
    test('01/01/2020 <-- 01/01/2020', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2020, 1, 1),
        DateTime.utc(2020, 1, 1),
      );
      expect(dcf.factor, 0.0);
      expect(dcf.toString(), '(0/365) = 0.00000000');
    });
  });
  group('EU200848EC.computeFactor [timePeriod = week]', () {
    const dc = EU200848EC(timePeriod: EUTimePeriod.week);
    test('timePeriod() to return week', () {
      expect(dc.timePeriod, EUTimePeriod.week);
    });
    test('12/01/2012 <-- 26/01/2012', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2012, 1, 12),
        DateTime.utc(2012, 1, 26),
      );
      expect(dcf.factor, 0.038461538461538464);
      expect(dcf.toString(), '(2/52) = 0.03846154');
    });
    test('12/01/2012 <-- 10/01/2013', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2012, 1, 12),
        DateTime.utc(2013, 1, 10),
      );
      expect(dcf.factor, 1.0);
      expect(dcf.toString(), '(52/52) = 1.00000000');
    });
    test('12/01/2012 <-- 30/01/2012', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2012, 1, 12),
        DateTime.utc(2012, 1, 30),
      );
      expect(dcf.factor, 0.0494204425711275);
      expect(dcf.toString(), '(2/52) + (4/365) = 0.04942044');
    });
    test('12/01/2012 <-- 12/01/2013', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2012, 1, 12),
        DateTime.utc(2013, 1, 12),
      );
      expect(dcf.factor, 1.0054794520547945);
      expect(dcf.toString(), '(52/52) + (2/365) = 1.00547945');
    });
    test('12/01/2012 <-- 12/01/2012', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2012, 1, 12),
        DateTime.utc(2012, 1, 12),
      );
      expect(dcf.factor, 0.0);
      expect(dcf.toString(), '(0/365) = 0.00000000');
    });
  });
  group('EU200848EC.computeFactor [timePeriod = undefined]', () {
    const dc = EU200848EC();
    test('timePeriod() to return MONTH by default', () {
      expect(dc.timePeriod, EUTimePeriod.month);
    });
    test('dayCountOrigin() to return DRAWDOWN by default', () {
      expect(dc.dayCountOrigin(), DayCountOrigin.drawdown);
    });
    test('usePostDates() to return true', () {
      expect(dc.usePostDates, true);
    });
    test('includeNonFinancingFlows() to return true', () {
      expect(dc.includeNonFinancingFlows, true);
    });
  });
}
