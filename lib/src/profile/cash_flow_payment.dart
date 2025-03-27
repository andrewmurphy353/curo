import '../daycount/day_count_factor.dart';
import 'cash_flow.dart';

/// Represents the movement of money, specifically interest bearing
/// cash in-flows to the lender, for example loan repayments or
/// lease rentals.
///
class CashFlowPayment extends CashFlow {
  /// The amortised interest included in this cash flow value when
  /// isInterestCapitalised is true. The difference between interest and
  /// the cash flow value is the amortised capital.
  final double interest;

  /// Determines whether the interest accrued to date is capitalised (true)
  /// or rolled over (false). Default is true.
  final bool isInterestCapitalised;

  CashFlowPayment({
    required super.postDate,
    super.value = 0.0,
    super.isKnown = true,
    super.weighting = 1.0,
    super.label = '',
    this.interest = 0.0,
    this.isInterestCapitalised = true,
    super.periodFactor,
  }) : super(
          valueDate: postDate,
        );

  CashFlowPayment copyWith({
    DateTime? postDate,
    double? value,
    bool? isKnown,
    double? weighting,
    String? label,
    double? interest,
    bool? isInterestCapitalised,
    DayCountFactor? periodFactor,
  }) =>
      CashFlowPayment(
        postDate: postDate ?? this.postDate,
        value: value ?? this.value,
        isKnown: isKnown ?? this.isKnown,
        weighting: weighting ?? this.weighting,
        label: label ?? this.label,
        interest: interest ?? this.interest,
        isInterestCapitalised:
            isInterestCapitalised ?? this.isInterestCapitalised,
        periodFactor: periodFactor ?? this.periodFactor,
      );

  // coverage:ignore-start
  @override
  String toString() {
    final sb = StringBuffer();
    sb.write('\nCashFlowPayment [');
    sb.write('postDate: $postDate, ');
    sb.write('value: $value, ');
    sb.write('isKnown: $isKnown, ');
    sb.write('weighting: $weighting, ');
    sb.write('label: $label, ');
    sb.write('interest: $interest, ');
    sb.write('isInterestCapitalised: $isInterestCapitalised, ');
    sb.write('periodFactor: $periodFactor, ');
    sb.write(']');
    return sb.toString();
  }
  // coverage:ignore-end
}
