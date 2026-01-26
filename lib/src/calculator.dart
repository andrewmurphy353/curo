export 'calculator_helper.dart' show AmortisedItem, CashFlowWithFactor;
export 'calculator_schedule.dart';
export 'daycounts/convention.dart';
export 'enums.dart' hide DayCountOrigin, ValidationMode;
export 'exceptions.dart';
export 'series.dart';
export 'utils.dart';

import 'dart:math';

import 'package:curo/src/calculator_schedule.dart';
import 'package:curo/src/calculator_helper.dart';
import 'package:curo/src/daycounts/convention.dart';
import 'package:curo/src/enums.dart';
import 'package:curo/src/exceptions.dart';
import 'package:curo/src/series.dart';
import 'package:curo/src/utils.dart';

/// The [Calculator] class performs financial calculations on cash flow series,
/// including solving for effective interest rates and unknown cash flow amounts.
/// It supports multiple day count conventions (e.g., [US30360], [USAppendixJ])
/// and produces results consistent with the `curo-python` library for loan
/// amortisation and APR calculations.
///
/// Key Features:
/// - Solves for interest rates ([solveRate]) to achieve a net future value
///   (NFV) of zero.
/// - Solves for one or more unknown payment or advance amounts ([solveValue])
///   with weighted adjustments.
/// - Supports series-based profiles ([Series] objects).
/// - Handles [USAppendixJ] periodic rate conversions and interest amortisation.
/// - Provides precise, unrounded calculations with optional rounding to
///   specified precision.
///
/// Usage:
/// ```dart
/// import 'package:curo/calculator.dart';
///
/// void main() async {
///   final calculator = Calculator(precision: 2)
///     ..add(SeriesAdvance(amount: 10000.0, label: 'Loan'))
///     ..add(SeriesPayment(numberOf:6, amount: null, label: 'Instalment'));
///   final convention = const US30U360();
///
///   final value = await calculator.solveValue(
///     convention: convention,
///     interestRate: 0.12);                      // => 1708.4
///
///   final rate = await calculator.solveRate(
///     convention: convention);                  // => 0.12000094629126792
///
///   final schedule = calculator.buildSchedule(convention: convention, interestRate: rate);
///   schedule.prettyPrint(convention: convention);
/// }
/// ```
/// Output:
///
/// ```
/// post_date    label                amount        capital       interest  capital_balance
/// ---------------------------------------------------------------------------------------
/// 2026-01-15   Loan             -10,000.00     -10,000.00           0.00       -10,000.00
/// 2026-01-15   Instalment         1,708.40       1,708.40           0.00        -8,291.60
/// 2026-02-15   Instalment         1,708.40       1,625.48         -82.92        -6,666.12
/// 2026-03-15   Instalment         1,708.40       1,641.74         -66.66        -5,024.38
/// 2026-04-15   Instalment         1,708.40       1,658.16         -50.24        -3,366.22
/// 2026-05-15   Instalment         1,708.40       1,674.74         -33.66        -1,691.48
/// 2026-06-15   Instalment         1,708.40       1,691.48         -16.92             0.00
/// ```
class Calculator {
  final int precision;
  final List<Series> _series = [];
  List<CashFlowWithFactor>? _profile;

  /// Creates a new [Calculator] for solving unknown cash flow values and/or
  /// interest rates in a series.
  ///
  /// The optional [precision] specifies the number of decimal places to which
  /// cash flow amounts are rounded (in the notional currency unit). Must be
  /// between 0 and 4 inclusive. Defaults to 2.
  ///
  /// Throws a [DeveloperException] if [precision] is outside the allowed range.
  Calculator({this.precision = 2}) {
    if (precision < 0 || precision > 4) {
      throw DeveloperException('Precision must be between 0 and 4');
    }
  }

  /// The last computed cash flow profile with assigned day count factors.
  ///
  /// Available only after calling [solveRate] or [solveValue]. Returns the profile
  /// as a list of [CashFlowWithFactor] objects.
  ///
  /// Throws a [DeveloperException] if accessed before a solve method has been called.
  List<CashFlowWithFactor> get profile =>
      _profile ??
      (throw DeveloperException(
        'Call solveRate() or solveValue() before accessing profile.',
      ));

  /// Adds a cash flow [series] to the calculator.
  ///
  /// If [Series.amount] is non-null, it is rounded to this calculator's
  /// [precision] using Gaussian rounding.
  ///
  /// Important ordering notes:
  /// - For undated series, cash flow dates are assigned sequentially based on
  ///   the order in which series are added.
  /// - For dated series, the explicit start date is used regardless of addition order.
  /// - Multiple series of the same type can be added – they will be processed
  ///   in addition order.
  void add(Series series) {
    Series roundedSeries = series;

    if (series.amount != null) {
      final roundedAmount = gaussRound(series.amount!, precision);
      if (roundedAmount != series.amount) {
        roundedSeries = series.copyWith(amount: roundedAmount);
      }
    }

    _series.add(roundedSeries);
  }

  /// Computes the effective interest rate that results in a net future value
  /// (NFV) of zero.
  ///
  /// [convention] The day count convention to use (e.g., [US30360], [USAppendixJ]).
  ///
  /// [upperBound] Upper limit for the search. Defaults to 10.0 (1000%).
  ///
  /// [tolerance] Minimum precision required from the returned root.
  ///
  /// [startDate] Optional start date for undated series. Defaults to today if null.
  ///
  /// Returns the annualized effective interest rate, unrounded.
  ///
  /// A [DeveloperException] is thrown if inputs are invalid (e.g., no series,
  /// invalid upperBound).
  ///
  /// An [UnsolvableException] is thrown if no rate can be found within bounds.
  ///
  /// Notes:
  /// - If [solveValue] was called previously, reuses the existing profile but
  ///   re-applies day count factors using the new [convention].
  /// - For [USAppendixJ], the returned rate is the annualized effective rate
  ///   (periodic rate × [DayCountTimePeriod.periodsInYear]).
  Future<double> solveRate({
    required Convention convention,
    double upperBound = 10.0,
    double tolerance = 1e-8,
    DateTime? startDate,
  }) async {
    if (_series.isEmpty) {
      throw DeveloperException('No cash flow series provided');
    }

    if (upperBound <= 0.0) {
      throw DeveloperException('Upper bound must be positive');
    }

    _profile = buildOrReuseProfile(
      series: _series,
      convention: convention,
      validationMode: ValidationMode.solveRate,
      referenceStartDate: startDate,
      existingProfile: _profile,
    );

    double nfvFunc(double r) =>
        nfv(profiled: profile, rate: r, convention: convention);

    try {
      double result = brentSolve(
        f: nfvFunc,
        a: -0.999,
        b: upperBound,
        tolerance: tolerance,
      );

      // Convert back to *annual rate*, except for days
      if (convention is USAppendixJ &&
          convention.timePeriod != DayCountTimePeriod.day) {
        result *= convention.timePeriod.periodsInYear;
      }
      return result;
    } catch (e) {
      throw UnsolvableException('No interest rate found within bounds');
    }
  }

  /// Solves for one or more unknown payment or advance cash flow amounts to achieve
  /// a net future value (NFV) of zero, given a known interest rate.
  ///
  /// [convention] to use in calculation (e.g., [US30360], [USAppendixJ]).
  ///
  /// [interestRate] The known annualized effective interest rate (e.g., 0.12 for 12%).
  ///
  /// [tolerance] Minimum precision required from the returned root.
  ///
  /// [startDate] for constructing the cash flow profile for `undated` series.
  /// Defaults to the current system date if `null`.
  ///
  /// Returns the base (unweighted) cash flow amount, rounded to [precision].
  /// To obtain the actual amount for a weighted series, multiply by the series'
  /// [Series.weighting].
  ///
  /// A [DeveloperException] is thrown if inputs are invalid (e.g., no cash flows,
  /// no unknowns).
  ///
  /// An [UnsolvableException] is thrown if no amount can be found to achieve NFV = 0.
  ///
  /// Notes:
  /// - For USAppendixJ, converts the interest rate to periodic by dividing by
  ///   [DayCountTimePeriod.periodsInYear].
  /// - The returned value is the raw amount before applying weightings. For weighted
  ///   payments, multiply by each series' `weighting` to get the final amount, for
  ///   instance when building bespoke Amortisation or APR schedules.
  Future<double> solveValue({
    required Convention convention,
    required double interestRate,
    double tolerance = 1e-8,
    DateTime? startDate,
  }) async {
    if (_series.isEmpty) {
      throw DeveloperException('No cash flow series provided');
    }

    if (interestRate < 0.0) {
      throw DeveloperException('Interest rate must be non-negative');
    }

    final profiled = buildOrReuseProfile(
      series: _series,
      convention: convention,
      validationMode: ValidationMode.solveValue,
      referenceStartDate: startDate,
      existingProfile: _profile,
    );

    // Convert to *periodic rate*, except for days
    if (convention is USAppendixJ &&
        convention.timePeriod != DayCountTimePeriod.day) {
      interestRate /= convention.timePeriod.periodsInYear;
    }

    double nfvFunc(double baseValue) => nfv(
          profiled: profiled,
          rate: interestRate,
          convention: convention,
          trialBaseValue: baseValue,
        );

    try {
      final baseValue = brentSolve(
        f: nfvFunc,
        a: -1e10,
        b: 1e10,
        tolerance: tolerance,
      );

      // Return the amount for a single unknown with weighting = 1.0
      final result = gaussRound(baseValue, precision);
      _profile = updateUnknowns(
        profiled: profiled,
        perUnitAmount: result,
        precision: precision,
      );

      return result;
    } catch (e) {
      // Coverage note: UnsolvableException in solveValue is unreachable
      // due to validation ensuring monotonic NFV with root in bracket.
      // Convergence failure impossible within valid precision (0-4).
      // coverage:ignore-start
      throw UnsolvableException(
          'No amount found that satisfies the given rate');
      // coverage:ignore-end
    }
  }

  /// Builds an amortisation schedule or APR proof schedule from the last
  /// computed profile.
  ///
  /// The type of schedule produced depends on [Convention.useXirrMethod]:
  /// - `false`: Standard **amortisation schedule** with capital and interest breakdown
  /// - `true`: **APR proof schedule** using the XIRR method with discounted amounts
  ///
  /// [convention] to use in the transformation (e.g., [US30360], [USAppendixJ]).
  ///
  /// [interestRate] expressed as an annual effective interest rate (e.g., 0.12 for 12%).
  ///
  /// Returns a [ScheduleRow] list containing either an **Amortisation schedule**
  /// (attributes: `postDate|valueDate`, `label`, `amount`, `capital`, `interest`,
  /// `capitalBalance`), or an **APR proof schedule** (attributes: `postDate|valueDate`,
  /// `label`, `amount`, `discountLog`, `amountDiscounted`, `discountedBalance`),
  /// depending on [Convention.useXirrMethod]. For the **APR proof schedule**,
  /// [ScheduleRow].`discountedBalance` shows the running total of
  /// [ScheduleRow].`amountDiscounted`, netting to zero.
  ///
  /// A [DeveloperException] is thrown if inputs are invalid (e.g., negative
  /// interest rate, or invalid profile.
  List<ScheduleRow> buildSchedule({
    required Convention convention,
    required double interestRate,
  }) {
    if (interestRate < 0.0) {
      throw DeveloperException('Interest rate must be non-negative');
    }

    if (_profile == null) {
      throw DeveloperException(
        'No profile available — call solveRate or solveValue first',
      );
    }

    final dateKey = convention.usePostDates
        ? (CashFlow cf) => cf.postDate
        : (CashFlow cf) => cf.valueDate;

    final List<ScheduleRow> schedule = [];

    if (convention.useXirrMethod) {
      // APR Proof
      double runningDiscounted = 0.0;

      for (final item in _profile!) {
        final cf = item.cashFlow;
        final factor = item.factor;
        double amountDiscounted;

        if (convention is USAppendixJ) {
          final f = factor.partialPeriodFraction ?? 0.0;
          final t = factor.primaryPeriodFraction;
          final p = convention.timePeriod.periodsInYear;
          final denominator =
              (1 + f * interestRate / p) * pow(1 + interestRate / p, t);
          amountDiscounted =
              denominator != 0 ? cf.amount / denominator : cf.amount;
        } else {
          amountDiscounted =
              cf.amount * pow(1 + interestRate, -factor.primaryPeriodFraction);
        }

        amountDiscounted = gaussRound(amountDiscounted, 6);
        runningDiscounted += amountDiscounted;

        schedule.add((
          type: cf.type,
          date: dateKey(cf),
          label: cf.label,
          amount: cf.amount,
          discountLog: factor.toFoldedString(),
          amountDiscounted: amountDiscounted,
          discountedBalance: gaussRound(runningDiscounted, 6),
          capital: null,
          interest: null,
          capitalBalance: null,
        ));
      }
    } else {
      // Amortisation
      final amortised = amortiseInterest(
        _profile!,
        convention,
        interestRate,
        precision,
      );

      for (final item in amortised) {
        final cf = item.cashFlow;
        final capital = cf.amount + item.interest;

        schedule.add((
          type: cf.type,
          date: dateKey(cf),
          label: cf.label,
          amount: cf.amount,
          capital: gaussRound(capital, precision),
          interest: gaussRound(item.interest, precision),
          capitalBalance: gaussRound(item.capitalBalance, precision),
          discountLog: item.factor.toFoldedString(),
          amountDiscounted: null,
          discountedBalance: null,
        ));
      }
    }

    return schedule;
  }
}
