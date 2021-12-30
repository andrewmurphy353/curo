import 'frequency.dart';
import 'mode.dart';
import 'series.dart';

/// A series of one or more loan payments, lease rentals, etc., received
/// by a lender.
///
class SeriesPayment extends Series {
  final bool isInterestCapitalised;

  ///
  /// [numberOf] The total number of payments in the series. Default is 1.
  ///
  /// [frequency] The compounding frequency of recurring payments in
  /// the series.
  ///
  /// [label] A localised label in singular form to assign to each
  /// cash flow in the series e.g. 'Rental' (not 'Rentals'). The label is
  /// useful for annotating the payment cash flows listed in an amortisation
  /// schedule or calculation proof.
  ///
  /// [value] The value of the one or more payments in the series.
  /// When undefined, i.e. null, the value is regarded as the unknown
  /// to determine.
  ///
  /// [postDateFrom] The post or due date of the first payment in
  /// the series. Subsequent payment due dates are determined with
  /// reference to this date *and* the offset of the interval defined by the
  /// series frequency. If the date is not defined it will be computed
  /// with reference to the current system date or the end date of a
  /// preceding payment series.
  ///
  /// [mode] The advance or arrear mode of recurring payments in the series.
  ///
  /// [weighting] The weighting of unknown payment series values relative
  /// to other unknown payment series values.
  ///
  /// [isInterestCapitalised] Flag to determine whether interest should be
  /// compounded in line with the frequency of the payment series or not.
  /// Useful in defining payment series where interest is compounded at
  /// a different frequency e.g. monthly payments with quarterly compound
  /// interest.
  ///
  SeriesPayment({
    int numberOf = 1,
    Frequency frequency = Frequency.monthly,
    String? label,
    double? value,
    DateTime? postDateFrom,
    Mode mode = Mode.advance,
    double weighting = 1.0,
    this.isInterestCapitalised = true,
  }) : super(
          numberOf: numberOf,
          frequency: frequency,
          label: label ?? '',
          value: value,
          postDateFrom: postDateFrom,
          valueDateFrom: postDateFrom, // uses same post date
          mode: mode,
          weighting: weighting,
        );

  SeriesPayment copyWith({
    int? numberOf,
    Frequency? frequency,
    String? label,
    double? value,
    DateTime? postDateFrom,
    Mode? mode,
    double? weighting,
    bool? isInterestCapitalised,
  }) =>
      SeriesPayment(
        numberOf: numberOf ?? this.numberOf,
        frequency: frequency ?? this.frequency,
        label: label ?? this.label,
        value: value ?? this.value,
        postDateFrom: postDateFrom ?? this.postDateFrom,
        mode: mode ?? this.mode,
        weighting: weighting ?? this.weighting,
        isInterestCapitalised:
            isInterestCapitalised ?? this.isInterestCapitalised,
      );

  // coverage:ignore-start
  @override
  String toString() {
    final sb = StringBuffer();
    sb.write('\nSeriesPayment [');
    sb.write('numberOf: $numberOf, ');
    sb.write('frequency: $frequency, ');
    sb.write('label: $label, ');
    sb.write('value: $value, ');
    sb.write('postDateFrom: $postDateFrom, ');
    sb.write('mode: $mode, ');
    sb.write('weighting: $weighting, ');
    sb.write('isInterestCapitalised: $isInterestCapitalised, ');
    sb.write(']');
    return sb.toString();
  }
  // coverage:ignore-end
}
