import 'frequency.dart';
import 'mode.dart';
import 'series.dart';

/// A series of one or more advances paid out by a lender. This could comprise
/// a series of amounts loaned to a borrower, the lessor's net investment in
/// a lease agreement, etc.
///
class SeriesAdvance extends Series {
  ///
  /// [numberOf] The total number of advances in the series. Default is 1.
  ///
  /// [frequency] The compounding frequency of recurring advances in
  /// the series.
  ///
  /// [label] A localised label in singular form to assign to each
  /// cash flow in the series e.g. 'Loan advance'. The label is useful for
  /// annotating the advance cash flow/s listed in an amortisation schedule
  /// or calculation proof.
  ///
  /// [value] The value of the one or more advances in the series.
  /// When undefined, i.e. null, the value is regarded as the unknown
  /// to determine.
  ///
  /// [postDateFrom] The post or drawdown date of the first advance in
  /// the series. Subsequent advance drawdown dates are determined with
  /// reference to this date *and* the offset of the interval defined by the
  /// series frequency. If the date is not defined it will be computed
  /// with reference to the current system date or the end date of a
  /// preceding advance series.
  ///
  /// [valueDateFrom] The value or settlement date of the first advance in
  /// the series. This date is expected to fall on or after the
  /// [postDateFrom] date. Subsequent advance settlement dates are
  /// determined with reference to this date *and* the offset of the
  /// interval defined by the series frequency. The series value date will
  /// usually differ from the post date only when the advance series
  /// models a deferred settlement scheme. If the date is undefined it will
  /// share the date/s derived from the [postDateFrom] date.
  ///
  /// [mode] The advance or arrear mode of recurring advances in the series.
  ///
  /// [weighting] The weighting of unknown advance series values relative
  /// to other unknown advance series values.
  ///
  SeriesAdvance({
    int numberOf = 1,
    Frequency frequency = Frequency.monthly,
    String? label,
    double? value,
    DateTime? postDateFrom,
    DateTime? valueDateFrom,
    Mode mode = Mode.advance,
    double weighting = 1.0,
  }) : super(
          numberOf: numberOf,
          frequency: frequency,
          label: label ?? '',
          value: value,
          postDateFrom: postDateFrom,
          valueDateFrom: valueDateFrom,
          mode: mode,
          weighting: weighting,
        );

  SeriesAdvance copyWith({
    int? numberOf,
    Frequency? frequency,
    String? label,
    double? value,
    DateTime? postDateFrom,
    DateTime? valueDateFrom,
    Mode? mode,
    double? weighting,
  }) =>
      SeriesAdvance(
        numberOf: numberOf ?? this.numberOf,
        frequency: frequency ?? this.frequency,
        label: label ?? this.label,
        value: value ?? this.value,
        postDateFrom: postDateFrom ?? this.postDateFrom,
        valueDateFrom: valueDateFrom ?? this.valueDateFrom,
        mode: mode ?? this.mode,
        weighting: weighting ?? this.weighting,
      );

  // coverage:ignore-start
  @override
  String toString() {
    final sb = StringBuffer();
    sb.write('\nSeriesAdvance [');
    sb.write('numberOf: $numberOf, ');
    sb.write('frequency: $frequency, ');
    sb.write('label: $label, ');
    sb.write('value: $value, ');
    sb.write('postDateFrom: $postDateFrom, ');
    sb.write('valueDateFrom: $valueDateFrom, ');
    sb.write('mode: $mode, ');
    sb.write('weighting: $weighting, ');
    sb.write(']');
    return sb.toString();
  }
  // coverage:ignore-end
}
