import '../daycount/day_count_factor.dart';
import 'cash_flow.dart';

/// Represents the movement of money, specifically non-interest bearing cash
/// in-flows to the lender, for example cash-based charges or fees. The
/// value of these cash flows must be specified i.e. they cannot be null
/// or unknown.
///
/// The inclusion of charge cash flows in a profile or series has
/// no effect on the calculation of unknown interest-bearing cash flow
/// values, they are skipped over. However they may optionally be included
/// in the calculation of the implicit interest rate in a cash flow series,
/// for example the calculation on an Annual Percentage Rate (APR) of charge.
///
class CashFlowCharge extends CashFlow {
  CashFlowCharge({
    required super.postDate,
    required double value,
    super.label = '',
    super.periodFactor,
  }) : super(
          valueDate: postDate,
          value: value.abs(),
          isKnown: true,
          weighting: 1.0,
        );

  CashFlowCharge copyWith({
    DateTime? postDate,
    double? value,
    String? label,
    DayCountFactor? periodFactor,
  }) =>
      CashFlowCharge(
        postDate: postDate ?? this.postDate,
        value: value ?? this.value,
        label: label ?? this.label,
        periodFactor: periodFactor ?? this.periodFactor,
      );

  // coverage:ignore-start
  @override
  String toString() {
    final sb = StringBuffer();
    sb.write('\nCashFlowCharge [');
    sb.write('postDate: $postDate, ');
    sb.write('value: $value, ');
    sb.write('label: $label, ');
    sb.write('periodFactor: $periodFactor, ');
    sb.write(']');
    return sb.toString();
  }
  // coverage:ignore-end
}
