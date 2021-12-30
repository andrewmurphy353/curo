// ignore_for_file: unnecessary_this

import '../../curo.dart';
import '../daycount/convention.dart';
import 'cash_flow.dart';
import 'validator.dart';

/// A container for a series of cash in-flows and out-flows.
///
class Profile {
  /// The cash flow series.
  final List<CashFlow> cashFlows;

  /// The day count convention applied to cash flows in the series.
  final Convention dayCount;

  /// The post date of the *first drawdown*. Analogous to a contract date.
  late final DateTime firstDrawdownPostDate;

  /// The value date of the *first drawdown*. This date is expected to
  /// occur on or after the drawdown post date and is used specifically
  /// in deferred settlement calculations.
  late final DateTime firstDrawdownValueDate;

  /// The number of fractional digits to apply in the rounding of
  /// cash flow values.
  final int precision;

  /// Instantiates a profile instance and performs basic validation.
  ///
  /// [cashFlows] the collection of advance, payment and charge cash flow
  /// objects
  ///
  /// [precision] (optional) the number of fractional digits to apply in the
  /// rounding of cash flow values in the notional currency. Default is 2,
  /// with valid options being 0, 2, 3 and 4
  ///
  /// [dayCount] (optional) the convention to use in computing time periods.
  /// Default is [US30360]
  ///
  Profile({
    required this.cashFlows,
    this.precision = 2,
    this.dayCount = const US30360(),
  }) {
    validatePrecision(precision);

    final firstDrawdown = validateAdvances(cashFlows);
    firstDrawdownPostDate = firstDrawdown.postDate;
    firstDrawdownValueDate = firstDrawdown.valueDate;

    validatePayments(cashFlows);
    validateUnknowns(cashFlows);
    validateIsInterestCapitalised(cashFlows);
  }

  Profile copyWith({
    List<CashFlow>? cashFlows,
    int? precision,
    Convention? dayCount,
  }) =>
      Profile(
        cashFlows: cashFlows ?? this.cashFlows,
        precision: precision ?? this.precision,
        dayCount: dayCount ?? this.dayCount,
      );

  // coverage:ignore-start
  @override
  String toString() {
    final sb = StringBuffer();
    sb.write('Profile [');
    sb.write('cashFlows: $cashFlows, ');
    sb.write('\ndayCount: $dayCount, ');
    sb.write('\nfirstDrawdownPostDate: $firstDrawdownPostDate, ');
    sb.write('\nfirstDrawdownValueDate: $firstDrawdownValueDate, ');
    sb.write('\nprecision: $precision, ');
    sb.write(']');
    return sb.toString();
  }
  // coverage:ignore-end
}
