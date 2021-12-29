// ignore_for_file: unnecessary_this

import '../daycount/day_count_factor.dart';

/// Represents the movement of money, inbound or outbound.
///
abstract class CashFlow {
  // The due date of the cash flow value.
  final DateTime postDate;

  /// The settlement date of the cashflow value. It should not predate
  /// the post date.
  final DateTime valueDate;

  /// The positive or negative cash flow value.
  final double value;

  /// Flag indicating if the cash flow [value] is known, or is to be computed.
  final bool isKnown;

  /// Weighting determines the scale of an unknown cash flow value relative
  /// to other unknown cash flows in a cash flow series. Note, the weighting
  /// has no effect when applied to cash flows with known values.
  /// Default value is 1.0
  final double weighting;

  /// Localised free text description of the cash flow e.g. Loan, Payment,
  /// Fee, etc.
  final String label;

  ///
  final DayCountFactor? periodFactor;

  CashFlow({
    required this.postDate,
    required this.valueDate,
    required this.value,
    required this.isKnown,
    required this.weighting,
    required this.label,
    this.periodFactor,
  }) {
    if (!postDate.isUtc || !this.valueDate.isUtc) {
      throw Exception(
        'The cash flow dates must be provided in UTC format.',
      );
    }
    if (this.valueDate.isBefore(postDate)) {
      throw Exception(
        'The cash flow value date must fall on or after the post date.',
      );
    }
    if (!(weighting > 0.0)) {
      throw Exception(
        'The cash flow weighting value must be greater than 0.0',
      );
    }
  }
}
