import 'package:curo/src/series/frequency.dart';
import 'package:curo/src/series/mode.dart';
import 'package:curo/src/series/series.dart';
import 'package:curo/src/series/series_charge.dart';
import 'package:test/test.dart';

void main() {
  group('SeriesCharge', () {
    test('Constructor returns default values', () {
      final SeriesCharge pmt = SeriesCharge(value: 100.0);
      expect(pmt.numberOf, 1);
      expect(pmt.frequency, Frequency.monthly);
      expect(pmt.label, '');
      expect(pmt.value, 100.0);
      expect(pmt.postDateFrom, null);
      expect(pmt.valueDateFrom, null);
      expect(pmt.mode, Mode.advance);
      expect(pmt.weighting, 1.0);
    });
    test('Constructor returns user input', () {
      final Series pmt = SeriesCharge(
        numberOf: 36,
        frequency: Frequency.quarterly,
        label: 'Label',
        value: 100.0,
        postDateFrom: DateTime.utc(22, 1, 1),
        mode: Mode.arrear,
      );
      expect(pmt.numberOf, 36);
      expect(pmt.frequency, Frequency.quarterly);
      expect(pmt.label, 'Label');
      expect(pmt.value, 100.0);
      expect(pmt.postDateFrom, DateTime.utc(22, 1, 1));
      expect(pmt.valueDateFrom, DateTime.utc(22, 1, 1));
      expect(pmt.mode, Mode.arrear);
      expect(pmt.weighting, 1.0);
    });
    test('copyWith returns user input', () {
      final Series chg = SeriesCharge(value: 100.0);
      final sChg = (chg as SeriesCharge).copyWith(
        numberOf: 3,
        frequency: Frequency.quarterly,
        label: 'Label',
        value: 300.0,
        postDateFrom: DateTime.utc(22, 1, 1),
        mode: Mode.arrear,
      );
      expect(sChg.numberOf, 3);
      expect(sChg.frequency, Frequency.quarterly);
      expect(sChg.label, 'Label');
      expect(sChg.value, 300.0);
      expect(sChg.postDateFrom, DateTime.utc(22, 1, 1));
      expect(sChg.valueDateFrom, DateTime.utc(22, 1, 1));
      expect(sChg.mode, Mode.arrear);
      expect(sChg.weighting, 1.0);
    });
  });
}
