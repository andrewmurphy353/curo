import '../daycount/day_count_factor.dart';
import 'cash_flow.dart';

/// Represents the movement of money, specifically the cash
/// out flows of a lender, for example the amounts advanced under a
/// loan or leasing arrangement.
///
class CashFlowAdvance extends CashFlow {
  CashFlowAdvance({
    required super.postDate,
    DateTime? valueDate,
    super.value = 0.0,
    super.isKnown = true,
    super.weighting = 1.0,
    super.label = '',
    super.periodFactor,
  }) : super(
          valueDate: valueDate ?? postDate,
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
  bool operator ==(Object other) =>
      other is CashFlowAdvance &&
      other.runtimeType == runtimeType &&
      other.postDate == postDate &&
      other.valueDate == valueDate &&
      other.value == value &&
      other.isKnown == isKnown &&
      other.weighting == weighting &&
      other.label == label &&
      other.periodFactor == periodFactor;

  @override
  int get hashCode => Object.hash(
        postDate,
        valueDate,
        value,
        isKnown,
        weighting,
        label,
        periodFactor,
      );

  // coverage:ignore-start
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
  // coverage:ignore-end
}
