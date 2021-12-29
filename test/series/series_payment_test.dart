import 'package:curo/src/series/frequency.dart';
import 'package:curo/src/series/mode.dart';
import 'package:curo/src/series/series.dart';
import 'package:curo/src/series/series_payment.dart';
import 'package:test/test.dart';

void main() {
  group('SeriesPayment', () {
    test('Constructor returns default values', () {
      final SeriesPayment pmt = SeriesPayment();
      expect(pmt.numberOf, 1);
      expect(pmt.frequency, Frequency.monthly);
      expect(pmt.label, '');
      expect(pmt.value, null);
      expect(pmt.postDateFrom, null);
      expect(pmt.valueDateFrom, null);
      expect(pmt.mode, Mode.advance);
      expect(pmt.weighting, 1.0);
      expect(pmt.isInterestCapitalised, true);
    });
    test('Constructor returns user input', () {
      final SeriesPayment pmt = SeriesPayment(
        numberOf: 36,
        frequency: Frequency.quarterly,
        label: 'Label',
        value: 100.0,
        postDateFrom: DateTime.utc(22, 1, 1),
        mode: Mode.arrear,
        weighting: 3.5,
        isInterestCapitalised: false,
      );
      expect(pmt.numberOf, 36);
      expect(pmt.frequency, Frequency.quarterly);
      expect(pmt.label, 'Label');
      expect(pmt.value, 100.0);
      expect(pmt.postDateFrom, DateTime.utc(22, 1, 1));
      expect(pmt.valueDateFrom, DateTime.utc(22, 1, 1));
      expect(pmt.mode, Mode.arrear);
      expect(pmt.weighting, 3.5);
      expect(pmt.isInterestCapitalised, false);
    });
    test('copyWith returns user input', () {
      final Series pmt = SeriesPayment();
      final sPmt = (pmt as SeriesPayment).copyWith(
        numberOf: 36,
        frequency: Frequency.quarterly,
        label: 'Label',
        value: 100.0,
        postDateFrom: DateTime.utc(22, 1, 1),
        mode: Mode.arrear,
        weighting: 3.5,
        isInterestCapitalised: false,
      );
      expect(sPmt.numberOf, 36);
      expect(sPmt.frequency, Frequency.quarterly);
      expect(sPmt.label, 'Label');
      expect(sPmt.value, 100.0);
      expect(sPmt.postDateFrom, DateTime.utc(22, 1, 1));
      expect(sPmt.valueDateFrom, DateTime.utc(22, 1, 1));
      expect(sPmt.mode, Mode.arrear);
      expect(sPmt.weighting, 3.5);
      expect(sPmt.isInterestCapitalised, false);
    });
  });
}
