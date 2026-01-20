/// Type-safe, immutable classes for defining series of advances, payments,
/// and charges.
///
/// Used to build cash flow profiles for rate solving, value solving,
/// and schedule generation in [Calculator].
library;

// Coverage note: The coverage misses in this library are tool limitations, not untested code.

import 'package:curo/src/enums.dart';
import 'package:curo/src/utils.dart';

/// Immutable record representing a single dated cash flow.
///
/// Generated internally from [Series] objects and used throughout calculations.
/// Advances have negative amounts, payments and charges have positive amounts.
typedef CashFlow = ({
  CashFlowType type,
  DateTime postDate,
  DateTime valueDate,
  double amount,
  bool isKnown,
  double weighting,
  String label,
  Mode mode,
  bool? isInterestCapitalised,
  bool isCharge,
});

/// Sealed base class for all cash flow series (advances, payments, charges).
///
/// Defines common behaviour and validation. Subclass via [SeriesAdvance],
/// [SeriesPayment], or [SeriesCharge].
///
/// Series can be **dated** (explicit [postDateFrom]) or **undated** (dates inferred
/// sequentially during profile building).
///
/// If [amount] is `null`, the series contains unknown values to be solved
/// via [Calculator.solveValue].
sealed class Series {
  Series({
    required this.numberOf,
    required this.frequency,
    this.label = '',
    this.amount,
    this.mode = Mode.advance,
    this.postDateFrom,
    this.valueDateFrom,
    this.weighting = 1.0,
  }) {
    if (numberOf < 1) {
      throw ArgumentError('numberOf must be >= 1');
    }
    if (weighting <= 0.0) {
      throw ArgumentError('weighting must be > 0');
    }
    if (postDateFrom != null &&
        valueDateFrom != null &&
        valueDateFrom!.isBefore(postDateFrom!)) {
      throw ArgumentError('valueDateFrom must be on or after postDateFrom');
    }
    if (postDateFrom == null && valueDateFrom != null) {
      throw ArgumentError('postDateFrom is required when valueDateFrom is set');
    }
  }

  /// Number of cash flows in the series.
  final int numberOf;

  /// Frequency of the recurring cash flows.
  final Frequency frequency;

  /// Descriptive singular label (e.g., "Rental", "Loan advance").
  final String label;

  /// Amount of each cash flow. If null, treated as unknown to be solved.
  final double? amount;

  /// Advance (beginning of period) or arrear (end of period).
  final Mode mode;

  /// Optional explicit start date for posting/value.
  final DateTime? postDateFrom;

  /// Optional explicit value/settlement date (advances only).
  final DateTime? valueDateFrom;

  /// Relative weighting when multiple unknowns exist.
  final double weighting;

  /// Generates the dated cash flows for this series.
  ///
  /// Uses [postDateFrom] if provided; otherwise uses [referenceStartDate]
  /// (typically today or the end date of the previous undated series).
  ///
  /// Returns a list of [CashFlow] records with correct signing:
  /// - Advances: negative [amount]
  /// - Payments/Charges: positive [amount]
  ///
  /// Preserves [label], [weighting], [mode], and interest capitalisation flag
  /// where applicable.
  List<CashFlow> toCashFlows(DateTime referenceStartDate) {
    final startPost = postDateFrom ?? referenceStartDate;
    final normalizedPost = normalizeToMidnightUtc(startPost);
    final startValue = valueDateFrom ?? normalizedPost;

    final postDates = _generateDates(normalizedPost, frequency, numberOf);
    final valueDates = _generateDates(startValue, frequency, numberOf);

    final bool isKnown = amount != null;

    // Determine sign and type flags
    final bool isAdvance = this is SeriesAdvance;
    final bool isPayment = this is SeriesPayment;
    final bool isChargeType = this is SeriesCharge;

    final double baseAmount = amount ?? 0.0;
    final double signedAmount = isAdvance ? -baseAmount : baseAmount;

    final List<CashFlow> cashFlows = [];

    for (int i = 0; i < numberOf; i++) {
      cashFlows.add((
        type: switch ((isAdvance, isPayment)) {
          (true, _) => CashFlowType.advance,
          (_, true) => CashFlowType.payment,
          _ => CashFlowType.charge,
        },
        postDate: postDates[i],
        valueDate: valueDates[i],
        amount: signedAmount,
        isKnown: isKnown,
        weighting: weighting,
        label: label,
        mode: mode,
        isInterestCapitalised:
            isPayment ? (this as SeriesPayment).isInterestCapitalised : null,
        isCharge: isChargeType,
      ));
    }

    return cashFlows;
  }

  /// Returns a copy of this series with optionally overridden fields.
  ///
  /// Useful for creating modified versions without mutating the original.
  Series copyWith({
    int? numberOf,
    Frequency? frequency,
    String? label,
    double? amount,
    Mode? mode,
    DateTime? postDateFrom,
    DateTime? valueDateFrom,
    double? weighting,
  });

  /// Internal date sequence generator with month-end preservation.
  List<DateTime> _generateDates(DateTime startDate, Frequency freq, int count) {
    final normalized = normalizeToMidnightUtc(startDate);

    if (count == 1) {
      return [normalized];
    }

    // Determine preferred day — preserve month-end behaviour for monthly+
    int preferredDay = normalized.day;
    final bool monthlyOrHigher = switch (freq) {
      Frequency.weekly || Frequency.fortnightly => false,
      Frequency.monthly ||
      Frequency.quarterly ||
      Frequency.halfYearly ||
      Frequency.yearly =>
        true,
    };

    if (monthlyOrHigher && hasMonthEndDay(normalized)) {
      preferredDay = 31; // rollMonth will cap to last day of target month
    }

    final List<DateTime> dates = [normalized];
    DateTime current = normalized;

    for (int i = 1; i < count; i++) {
      current = rollDate(current, freq, preferredDay);
      dates.add(current);
    }

    return dates;
  }
}

/// Series representing one or more loan advances (funds paid out).
///
/// Supports separate [valueDateFrom] for settlement timing different from
/// posting date (common in lending).
///
/// Amounts are treated as negative cash flows.
class SeriesAdvance extends Series {
  SeriesAdvance({
    super.numberOf = 1,
    super.frequency = Frequency.monthly,
    super.label = '',
    super.amount,
    super.postDateFrom,
    super.valueDateFrom, // meaningful and allowed here
    super.mode = Mode.advance,
    super.weighting = 1.0,
  });

  @override
  SeriesAdvance copyWith({
    int? numberOf,
    Frequency? frequency,
    String? label,
    double? amount,
    Mode? mode,
    DateTime? postDateFrom,
    DateTime? valueDateFrom,
    double? weighting,
  }) =>
      SeriesAdvance(
        numberOf: numberOf ?? this.numberOf,
        frequency: frequency ?? this.frequency,
        label: label ?? this.label,
        amount: amount ?? this.amount,
        postDateFrom: postDateFrom ?? this.postDateFrom,
        valueDateFrom: valueDateFrom ?? this.valueDateFrom,
        mode: mode ?? this.mode,
        weighting: weighting ?? this.weighting,
      );
}

/// Series representing one or more payments received (e.g., instalments,
/// rental payments).
///
/// Payments never have a separate value date — [valueDateFrom] is ignored
/// and forced to match [postDateFrom].
///
/// [isInterestCapitalised] controls whether accrued interest is added
/// to the payment amount (default: `true`).
class SeriesPayment extends Series {
  /// Whether interest is capitalised into the payment amount.
  ///
  /// When `true` (default), interest is added to the capital portion.
  /// When `false`, interest accrues separately (rare).
  final bool isInterestCapitalised;

  SeriesPayment({
    super.numberOf = 1,
    super.frequency = Frequency.monthly,
    super.label = '',
    super.amount,
    super.postDateFrom,
    super.mode = Mode.advance,
    super.weighting = 1.0,
    this.isInterestCapitalised = true,
  }) : super(
          // Payments never have a separate value date
          valueDateFrom: postDateFrom,
        );

  @override
  SeriesPayment copyWith({
    int? numberOf,
    Frequency? frequency,
    String? label,
    double? amount,
    Mode? mode,
    DateTime? postDateFrom,
    DateTime? valueDateFrom, // ignored
    double? weighting,
    bool? isInterestCapitalised,
  }) =>
      SeriesPayment(
        numberOf: numberOf ?? this.numberOf,
        frequency: frequency ?? this.frequency,
        label: label ?? this.label,
        amount: amount ?? this.amount,
        postDateFrom: postDateFrom ?? this.postDateFrom,
        mode: mode ?? this.mode,
        weighting: weighting ?? this.weighting,
        isInterestCapitalised:
            isInterestCapitalised ?? this.isInterestCapitalised,
      );
}

/// Series representing non-financing fees or charges (e.g., arrangement fee,
/// valuation fee).
///
/// Charges are always known ([amount] required) and have positive amounts.
///
/// They are excluded from principal/interest amortisation but may be included
/// in APR calculations depending on the day count convention.
///
/// Like payments, charges have no separate value date.
class SeriesCharge extends Series {
  SeriesCharge({
    super.numberOf = 1,
    super.frequency = Frequency.monthly,
    super.label = '',
    required double amount, // must be known
    super.postDateFrom,
    super.mode = Mode.advance,
    // weighting retained for consistency but typically unused
  }) : super(
          amount: amount,
          // Charges never have a separate value date
          valueDateFrom: postDateFrom,
        );

  /// The non-null amount of each charge (required at construction).
  double get knownAmount => amount!;

  @override
  SeriesCharge copyWith({
    int? numberOf,
    Frequency? frequency,
    String? label,
    double? amount,
    Mode? mode,
    DateTime? postDateFrom,
    DateTime? valueDateFrom, // ignored
    double? weighting,
  }) =>
      SeriesCharge(
        numberOf: numberOf ?? this.numberOf,
        frequency: frequency ?? this.frequency,
        label: label ?? this.label,
        amount: amount ?? this.amount!, // required
        postDateFrom: postDateFrom ?? this.postDateFrom,
        mode: mode ?? this.mode,
      );
}
