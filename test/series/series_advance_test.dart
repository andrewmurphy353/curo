import 'package:curo/src/series/frequency.dart';
import 'package:curo/src/series/mode.dart';
import 'package:curo/src/series/series.dart';
import 'package:curo/src/series/series_advance.dart';
import 'package:test/test.dart';

void main() {
  group('SeriesAdvance', () {
    test('Constructor returns default values', () {
      final Series adv = SeriesAdvance();
      expect(adv.numberOf, 1);
      expect(adv.frequency, Frequency.monthly);
      expect(adv.label, '');
      expect(adv.value, null);
      expect(adv.postDateFrom, null);
      expect(adv.valueDateFrom, null);
      expect(adv.mode, Mode.advance);
      expect(adv.weighting, 1.0);
    });
    test('Constructor returns user input', () {
      final Series adv = SeriesAdvance(
        numberOf: 2,
        frequency: Frequency.quarterly,
        label: 'Label',
        value: 1000.0,
        postDateFrom: DateTime.utc(22, 1, 1),
        valueDateFrom: DateTime.utc(22, 1, 15),
        mode: Mode.arrear,
        weighting: 3.5,
      );
      expect(adv.numberOf, 2);
      expect(adv.frequency, Frequency.quarterly);
      expect(adv.label, 'Label');
      expect(adv.value, 1000.0);
      expect(adv.postDateFrom, DateTime.utc(22, 1, 1));
      expect(adv.valueDateFrom, DateTime.utc(22, 1, 15));
      expect(adv.mode, Mode.arrear);
      expect(adv.weighting, 3.5);
    });
    test('copyWith returns user input', () {
      final Series adv = SeriesAdvance();
      final sAdv = (adv as SeriesAdvance).copyWith(
        numberOf: 2,
        frequency: Frequency.quarterly,
        label: 'Label',
        value: 1000.0,
        postDateFrom: DateTime.utc(22, 1, 1),
        valueDateFrom: DateTime.utc(22, 1, 15),
        mode: Mode.arrear,
        weighting: 3.5,
      );
      expect(sAdv.numberOf, 2);
      expect(sAdv.frequency, Frequency.quarterly);
      expect(sAdv.label, 'Label');
      expect(sAdv.value, 1000.0);
      expect(sAdv.postDateFrom, DateTime.utc(22, 1, 1));
      expect(sAdv.valueDateFrom, DateTime.utc(22, 1, 15));
      expect(sAdv.mode, Mode.arrear);
      expect(sAdv.weighting, 3.5);
    });
  });
}
