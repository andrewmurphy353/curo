import '../daycount/day_count_factor.dart';
import 'cash_flow.dart';

/// Represents the movement of money, specifically the cash
/// out flows of a lender, for example the amounts advanced under a
/// loan or leasing arrangement.
///
class CashFlowAdvance extends CashFlow {
  CashFlowAdvance({
    required DateTime postDate,
    DateTime? valueDate,
    double value = 0.0,
    bool isKnown = false,
    double weighting = 1.0,
    String label = '',
    DayCountFactor? periodFactor,
  }) : super(
          postDate: postDate,
          valueDate: valueDate ?? postDate,
          value: value,
          isKnown: isKnown,
          weighting: weighting,
          label: label,
          periodFactor: periodFactor,
        );

  CashFlowAdvance copyWith({
    DateTime? postDate,
    DateTime? valueDate,
    double? value,
    bool? isKnown,
    double? weighting,
    String? label,
    DayCountFactor? periodFactor,
  }) =>
      CashFlowAdvance(
        postDate: postDate ?? this.postDate,
        valueDate: valueDate ?? this.valueDate,
        value: value ?? this.value,
        isKnown: isKnown ?? this.isKnown,
        weighting: weighting ?? this.weighting,
        label: label ?? this.label,
        periodFactor: periodFactor ?? this.periodFactor,
      );

  @override
  String toString() {
    final sb = StringBuffer();
    sb.write('\nCashFlowAdvance [');
    sb.write('postDate: $postDate, ');
    sb.write('valueDate: $valueDate, ');
    sb.write('value: $value, ');
    sb.write('isKnown: $isKnown, ');
    sb.write('weighting: $weighting, ');
    sb.write('label: $label, ');
    sb.write('periodFactor: $periodFactor, ');
    sb.write(']');
    return sb.toString();
  }
}
