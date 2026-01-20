/// Private helper functions for [Calculator], extracted to improve testability
/// and reduce clutter in the main class.
library;

import 'dart:math';

import 'package:curo/src/daycounts/convention.dart';
import 'package:curo/src/enums.dart';
import 'package:curo/src/exceptions.dart';
import 'package:curo/src/series.dart';
import 'package:curo/src/utils.dart';

/// Private holder for a cash flow with its day count factor.
class CashFlowWithFactor {
  final CashFlow cashFlow;
  final DayCountFactor factor;

  const CashFlowWithFactor({required this.cashFlow, required this.factor});

  @override
  String toString() =>
      'CashFlowWithFactor(cashFlow: $cashFlow, factor: $factor)';
}

/// Private holder for amortised cash flow data.
class AmortisedItem {
  final CashFlow cashFlow;
  final DayCountFactor factor;
  final double interest;
  final double capitalBalance;

  const AmortisedItem({
    required this.cashFlow,
    required this.factor,
    required this.interest,
    required this.capitalBalance,
  });
}

/// Amortises interest across the cash flow profile for an amortisation schedule.
///
/// Applies interest to the running capital balance using the given [interestRate]
/// (annualised) and rounds using [precision] decimal places.
///
/// The final capitalised payment is adjusted so that the capital balance reaches
/// exactly zero, absorbing any accumulated rounding errors.
///
/// Returns a list of [AmortisedItem] objects, each with a computed [AmortisedItem.interest]
/// field (negative when interest is capitalised due to a negative balance from advances).
///
/// [profiled] must contain cash flows with assigned day count factors.
List<AmortisedItem> amortiseInterest(
  List<CashFlowWithFactor> profiled,
  Convention convention,
  double interestRate,
  int precision,
) {
  final List<AmortisedItem> result = [];

  double capitalBalance = 0.0;
  double periodInterest = 0.0;
  double accruedInterest = 0.0;

  for (final item in profiled) {
    final cf = item.cashFlow;
    final factor = item.factor;

    if (cf.isCharge) {
      if (convention.includeNonFinancingFlows) {
        // Include in carrying balance.
        capitalBalance += cf.amount;
        result.add(
          AmortisedItem(
            cashFlow: cf,
            factor: factor,
            interest: 0.0,
            capitalBalance: capitalBalance,
          ),
        );
      }
      continue;
    }

    periodInterest = gaussRound(
      capitalBalance * interestRate * factor.primaryPeriodFraction,
      precision,
    );

    if (cf.type == CashFlowType.payment) {
      double interest;
      if (cf.isInterestCapitalised!) {
        // Standard case: interest added to payment
        interest = gaussRound(accruedInterest + periodInterest, precision);
        capitalBalance += interest + cf.amount;
        accruedInterest = 0.0;
      } else {
        // Interest accrued
        interest = 0.0;
        accruedInterest += periodInterest;
        capitalBalance += cf.amount;
      }

      result.add(
        AmortisedItem(
          cashFlow: cf,
          factor: factor,
          interest: interest,
          capitalBalance: capitalBalance,
        ),
      );
    } else {
      // Advance
      capitalBalance += cf.amount;
      result.add(
        AmortisedItem(
          cashFlow: cf,
          factor: factor,
          interest: 0.0,
          capitalBalance: capitalBalance,
        ),
      );
      accruedInterest += periodInterest;
    }
  }

  // === Final adjustment: force balance to zero on last payment ===
  final paymentItems =
      result.where((i) => i.cashFlow.isInterestCapitalised == true).toList();
  if (paymentItems.isNotEmpty) {
    final last = paymentItems.last;
    final adjustment =
        -last.capitalBalance; // what we need to add to interest to zero balance
    final adjustedInterest = gaussRound(last.interest + adjustment, precision);

    // Update the last item
    final index = result.indexOf(last);
    result[index] = AmortisedItem(
      cashFlow: last.cashFlow,
      factor: last.factor,
      interest: adjustedInterest,
      capitalBalance: 0.0,
    );
  }

  return result;
}

/// Assigns day count factors to each cash flow using the given [convention].
///
/// Returns a new list of [CashFlowWithFactor] objects with computed
/// [DayCountFactor] values.
///
/// Behaviour depends on [convention.dayCountOrigin]:
/// - [DayCountOrigin.drawdown]: factors measured from earliest advance date
/// - [DayCountOrigin.neighbour]: factors measured between consecutive financing flows
///
/// Charges are assigned zero-length factors if [Convention.includeNonFinancingFlows]
/// is false in neighbour mode.
///
/// Uses [Convention.usePostDates] to select post or value dates.
List<CashFlowWithFactor> assignFactors({
  required List<CashFlow> profile,
  required Convention convention,
}) {
  if (profile.isEmpty) {
    return const [];
  }

  final List<CashFlowWithFactor> withFactors = [];

  // Find the earliest advance (negative amount, not charge) date
  DateTime? drawdownDate;
  for (final cf in profile) {
    if (!cf.isCharge && cf.amount < 0) {
      // It's an advance
      final candidate = convention.usePostDates ? cf.postDate : cf.valueDate;
      if (drawdownDate == null || candidate.isBefore(drawdownDate)) {
        drawdownDate = candidate;
      }
    }
  }

  if (convention.useXirrMethod) {
    // Drawdown XIRR mode - compute factor from drawdown to each cash flow date
    for (final cf in profile) {
      final currentDate = convention.usePostDates ? cf.postDate : cf.valueDate;
      final factor = convention.computeFactor(drawdownDate!, currentDate);
      withFactors.add(CashFlowWithFactor(cashFlow: cf, factor: factor));
    }
  } else {
    // Neighbour mode
    DateTime? previousDate;
    for (final cf in profile) {
      final currentDate = convention.usePostDates ? cf.postDate : cf.valueDate;

      final factor =
          (previousDate == null || !currentDate.isAfter(drawdownDate!))
              ? convention.computeFactor(currentDate, currentDate)
              : convention.computeFactor(previousDate, currentDate);

      withFactors.add(CashFlowWithFactor(cashFlow: cf, factor: factor));

      // Only advance previousDate if it's a financing flow (not charge)
      // This matches Python: charges don't progress the period
      if (!cf.isCharge) {
        previousDate = currentDate;
      }
    }
  }

  return withFactors;
}

/// Finds the root of function [f] in interval [[a], [b]] using Brent's method.
///
/// Requires [f(a)] and [f(b)] to have opposite signs.
///
/// Returns the root with precision better than [tolerance].
///
/// Throws [UnsolvableException] if:
/// - No root exists in the bracket (same-sign endpoints)
/// - Convergence fails within [maxIterations]
double brentSolve({
  required double Function(double) f,
  required double a,
  required double b,
  double tolerance = 1e-8,
  int maxIterations = 100,
}) {
  double fa = f(a);
  double fb = f(b);

  if (fa * fb >= 0) {
    throw UnsolvableException('No root in bracket: f(a) and f(b) same sign');
  }

  if (fa.abs() < fb.abs()) {
    // Swap so |f(b)| <= |f(a)|
    (a, b) = (b, a);
    (fa, fb) = (fb, fa);
  }

  double c = a;
  double fc = fa;
  bool mflag = true;
  double d = 0.0;

  for (int iter = 0; iter < maxIterations; iter++) {
    double s;

    if (fa != fc && fb != fc) {
      // Inverse quadratic interpolation
      s = a * fb * fc / ((fa - fb) * (fa - fc)) +
          b * fa * fc / ((fb - fa) * (fb - fc)) +
          c * fa * fb / ((fc - fa) * (fc - fb));
    } else {
      // Secant method
      s = b - fb * (b - a) / (fb - fa);
    }

    if ((s - b) * (s - (3 * a + b) / 4) >= 0 ||
        (mflag && (s - b).abs() >= (b - c).abs() / 2) ||
        (!mflag && (s - b).abs() >= (c - d).abs() / 2) ||
        (mflag && (b - c).abs() < tolerance) ||
        (!mflag && (c - d).abs() < tolerance)) {
      s = (a + b) / 2;
      mflag = true;
    } else {
      mflag = false;
    }

    final fs = f(s);
    d = c;
    c = b;
    fc = fb;

    if (fa * fs < 0) {
      b = s;
      fb = fs;
    } else {
      a = s;
      fa = fs;
    }

    if (fa.abs() < fb.abs()) {
      (a, b) = (b, a);
      (fa, fb) = (fb, fa);
    }

    if (fs.abs() < tolerance) {
      return s;
    }
  }

  throw UnsolvableException(
    'Brent solver did not converge within $maxIterations iterations',
  );
}

/// Builds or reuses a cash flow profile with assigned day count factors.
///
/// If a valid [existingProfile] is provided (not null and contains no unknown
/// amounts) and the operation is [ValidationMode.solveRate], the cash flows
/// are re-sorted according to the current [convention] and fresh day count
/// factors are assigned. This preserves solved amounts for efficiency and
/// round-trip consistency.
///
/// For [ValidationMode.solveValue], a fresh profile is **always** built from
/// the original [series], ensuring unknowns are present for solving under
/// potentially different conditions (e.g. new convention or rate).
///
/// Otherwise, a fresh profile is built from the original [series] list using
/// the given [convention] and [referenceStartDate].
List<CashFlowWithFactor> buildOrReuseProfile({
  required List<Series> series,
  required Convention convention,
  required ValidationMode validationMode,
  DateTime? referenceStartDate,
  List<CashFlowWithFactor>? existingProfile,
}) {
  // Reuse existing profile
  if (existingProfile != null) {
    final hasUnknowns = existingProfile.any((p) => !p.cashFlow.isKnown);

    // For solveValue: never reuse — always rebuild fresh from original series
    // (allows solving under different conventions/rates without stale amounts)
    if (validationMode == ValidationMode.solveValue) {
      // Force rebuild — fall through to fresh build below
    }
    // For solveRate: reuse if fully solved
    else if (!hasUnknowns) {
      // Re-sort by convention's preferred date
      final profile = existingProfile.map((p) => p.cashFlow).toList();
      sortCashFlows(cashFlows: profile, convention: convention);
      return assignFactors(profile: profile, convention: convention);
    }
  }

  // Build fresh profile from original series
  final profile = buildProfile(
    convention: convention,
    series: series,
    startDate: referenceStartDate,
  );

  switch (validationMode) {
    case ValidationMode.solveRate:
      // Validate all amounts known
      if (profile.any((p) => !p.isKnown)) {
        throw UnknownCashFlowsWhenSolvingRateException();
      }
      break;
    case ValidationMode.solveValue:
      final unknowns = profile.where((cf) => !cf.isKnown).toList();
      if (unknowns.isEmpty) {
        throw MissingUnknownCashFlowException();
      }

      final unknownTypes = unknowns.map((u) => u.type).toSet();
      if (unknownTypes.length > 1) {
        throw MixedUnknownCashFlowsException();
      }
      break;
  }

  validateFinalCapitalisedPayment(profile: profile, convention: convention);

  return assignFactors(profile: profile, convention: convention);
}

/// Builds and sorts a complete cash flow profile from the added [series].
///
/// For undated series, dates are inferred sequentially based on addition order
/// and frequency, respecting [Mode.advance] vs [Mode.arrear].
///
/// Dated series use their explicit [Series.postDateFrom].
///
/// [startDate] overrides the default (today) for the first undated series.
///
/// Returns a chronologically sorted list of [CashFlow] objects,
/// ordered using [convention] rules via [sortCashFlows].
List<CashFlow> buildProfile({
  required Convention convention,
  required List<Series> series,
  DateTime? startDate,
}) {
  final referenceDate = normalizeToMidnightUtc(startDate ?? DateTime.now());

  // Track the last used date for undated series, per type
  DateTime? lastAdvanceDate;
  DateTime? lastPaymentDate;
  DateTime? lastChargeDate;

  final List<CashFlow> cashFlows = [];

  for (final series in series) {
    // Determine the effective reference date for this series if undated
    DateTime effectiveReference = referenceDate;

    if (series.postDateFrom == null) {
      if (series is SeriesAdvance && lastAdvanceDate != null) {
        effectiveReference = lastAdvanceDate;
      } else if (series is SeriesPayment && lastPaymentDate != null) {
        effectiveReference = lastPaymentDate;
      } else if (series is SeriesCharge && lastChargeDate != null) {
        effectiveReference = lastChargeDate;
      }

      if (series.mode == Mode.arrear) {
        // First cashflow due at END of first period
        effectiveReference = rollDate(
          effectiveReference,
          series.frequency,
          effectiveReference.day,
        );
      }
    } else {
      // User-provided from date must be used (effectively Mode.advance)
      effectiveReference = series.postDateFrom!;
    }

    // Generate cashflows using the effective reference
    final seriesCashFlows = series.toCashFlows(effectiveReference);

    // Update the last date tracker for this type
    if (seriesCashFlows.isNotEmpty) {
      final lastCf = seriesCashFlows.last;
      DateTime lastDate =
          convention.usePostDates ? lastCf.postDate : lastCf.valueDate;

      if (series.postDateFrom == null && series.mode == Mode.advance) {
        // Next series should start AFTER this one ends
        lastDate = rollDate(lastDate, series.frequency, lastDate.day);
      }

      if (series is SeriesAdvance) {
        lastAdvanceDate = lastDate;
      } else if (series is SeriesPayment) {
        lastPaymentDate = lastDate;
      } else if (series is SeriesCharge) {
        lastChargeDate = lastDate;
      }
    }

    cashFlows.addAll(seriesCashFlows);
  }

  if (cashFlows.isEmpty) {
    return cashFlows;
  }

  // Final sort by convention's preferred date
  sortCashFlows(cashFlows: cashFlows, convention: convention);

  return cashFlows;
}

/// Calculates the net future value (NFV) of the cash flow profile.
///
/// Uses the assigned day count factors and applies the annualised [rate].
///
/// Behaviour varies by [convention.dayCountOrigin]:
/// - [DayCountOrigin.drawdown]: discounts each flow from drawdown date (XIRR style)
/// - [DayCountOrigin.neighbour]: compounds period-by-period with interest capitalisation
///
/// If [trialBaseValue] is provided, unknown cash flows are temporarily scaled
/// (used during [Calculator.solveValue]).
///
/// Charges are excluded unless [Convention.includeNonFinancingFlows] is true.
///
/// Special handling for [USAppendixJ] using partial and full period adjustments.
double nfv({
  required List<CashFlowWithFactor> profiled,
  required double rate,
  required Convention convention,
  double? trialBaseValue,
}) {
  if (profiled.isEmpty) return 0.0;

  double nfv = 0.0;

  switch (convention.dayCountOrigin) {
    case DayCountOrigin.drawdown:
      for (final item in profiled) {
        final cf = item.cashFlow;

        // Skip charges unless included
        if (cf.isCharge && !convention.includeNonFinancingFlows) continue;

        double amount = cf.amount;
        if (trialBaseValue != null && !cf.isKnown) {
          final scaled = trialBaseValue * cf.weighting;
          amount = cf.amount < 0 ? -scaled : scaled; // preserve sign
        }

        if (convention is USAppendixJ) {
          // Formula: d = a / ((1 + f * i / p) * (1 + i / p)^t)
          // The (1 / p) periodic rate conversion performed in solveValue
          final f = item.factor.partialPeriodFraction ?? 0.0;
          final t = item.factor.primaryPeriodFraction;
          final divisor = (1 + f * rate) * pow(1 + rate, t);
          nfv += amount / divisor;
        } else {
          // All other EAR/APR conventions
          // Formula: d = a × (1 + i)^(-t)
          nfv += amount * pow(1 + rate, -item.factor.primaryPeriodFraction);
        }
      }
      break;
    case DayCountOrigin.neighbour:
      double periodInterest;
      double accruedInterest = 0.0;

      for (final item in profiled) {
        final cf = item.cashFlow;

        // Skip charges unless included
        if (cf.isCharge && !convention.includeNonFinancingFlows) continue;

        double amount = cf.amount;
        if (trialBaseValue != null && !cf.isKnown) {
          final scaled = trialBaseValue * cf.weighting;
          amount = cf.amount < 0 ? -scaled : scaled; // preserve sign
        }

        periodInterest = nfv * rate * item.factor.primaryPeriodFraction;

        if (cf.type == CashFlowType.payment) {
          if (cf.isInterestCapitalised!) {
            nfv += accruedInterest + periodInterest + amount;
            accruedInterest = 0;
          } else {
            accruedInterest += periodInterest;
            nfv += amount;
          }
          continue;
        }

        nfv += periodInterest;
        nfv += amount;
      }
      break;
  }
  return nfv;
}

/// Sorts [cashFlows] in place according to financial scheduling conventions.
///
/// Ordering:
/// 1. By date (earliest first), using postDate or valueDate per [convention]
/// 2. By [CashFlowType] priority (advance > payment > charge)
/// 3. By amount descending (largest first) within same date and type
void sortCashFlows({
  required List<CashFlow> cashFlows,
  required Convention convention,
}) {
  final DateTime Function(CashFlow) dateKey =
      convention.usePostDates ? (cf) => cf.postDate : (cf) => cf.valueDate;

  cashFlows.sort((a, b) {
    // 1. By date
    int dateCmp = dateKey(a).compareTo(dateKey(b));
    if (dateCmp != 0) return dateCmp;

    // 2. By explicit CashFlowType order using the extension
    int typeCmp = a.type.idx.compareTo(b.type.idx);
    if (typeCmp != 0) return typeCmp;

    // 3. By amount magnitude descending (largest |amount| first)
    return b.amount.abs().compareTo(a.amount.abs());
  });
}

/// Updates unknown cash flows in [profiled] with weighted and rounded amounts.
///
/// Applies [perUnitAmount] × [CashFlow.weighting] to each unknown flow,
/// preserving sign, and optionally rounding to [precision] places.
///
/// Returns a new list with updated amounts. Known flows are unchanged.
///
/// Note: [CashFlow.isKnown] is preserved, so computed amounts remain identifiable.
List<CashFlowWithFactor> updateUnknowns({
  required List<CashFlowWithFactor> profiled,
  required double perUnitAmount,
  int? precision,
}) {
  final unknowns = profiled.where((p) => !p.cashFlow.isKnown).toList();
  if (unknowns.isEmpty) return profiled;

  return profiled.map((item) {
    if (item.cashFlow.isKnown) return item;

    final weightedAmount = perUnitAmount * item.cashFlow.weighting;
    final signedAmount =
        item.cashFlow.amount < 0 ? -weightedAmount : weightedAmount;

    return CashFlowWithFactor(
      cashFlow: (
        type: item.cashFlow.type,
        postDate: item.cashFlow.postDate,
        valueDate: item.cashFlow.valueDate,
        amount: (precision == null)
            ? signedAmount
            : gaussRound(signedAmount, precision),
        isKnown: true,
        weighting: item.cashFlow.weighting,
        label: item.cashFlow.label,
        mode: item.cashFlow.mode,
        isInterestCapitalised: item.cashFlow.isInterestCapitalised,
        isCharge: item.cashFlow.isCharge,
      ),
      factor: item.factor,
    );
  }).toList();
}

/// Validates that the final payment date has at least one capitalised payment.
///
/// Throws [FinalPaymentInterestNotCapitalisedException] if there are payments
/// on the latest date but none have [CashFlow.isInterestCapitalised] == true.
///
/// Should be called after cash flows are generated and sorted, but before
/// factoring or solving.
void validateFinalCapitalisedPayment({
  required List<CashFlow> profile,
  required Convention convention,
}) {
  final payments =
      profile.where((cf) => cf.type == CashFlowType.payment).toList();

  if (payments.isEmpty) return;

  final DateTime Function(CashFlow) dateKey =
      convention.usePostDates ? (cf) => cf.postDate : (cf) => cf.valueDate;

  final DateTime lastDate =
      profile.map(dateKey).reduce((a, b) => a.isAfter(b) ? a : b);

  final finalPayments = payments.where((p) => dateKey(p) == lastDate).toList();

  final hasCapitalised =
      finalPayments.any((p) => p.isInterestCapitalised == true);

  if (!hasCapitalised) {
    throw FinalPaymentInterestNotCapitalisedException(lastDate);
  }
}
