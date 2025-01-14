import '../daycount/convention.dart';
import '../daycount/day_count_factor.dart';
import '../daycount/day_count_origin.dart';
import '../profile/cash_flow.dart';
import '../profile/cash_flow_advance.dart';
import '../profile/cash_flow_charge.dart';
import '../profile/cash_flow_payment.dart';
import '../series/mode.dart';
import '../series/series.dart';
import '../series/series_advance.dart';
import '../series/series_charge.dart';
import '../series/series_payment.dart';
import '../utilities/dates.dart';
import '../utilities/math.dart';
import 'profile.dart';

/// Utility method for building out a cash flow series into separate
/// cash flow instances of the specific type, e.g. advances, payments
/// or charges.
///
/// All cash flow instances are dated with reference to the series start
/// date input, if provided, otherwise are computed with reference to the
/// [startDate] parameter value.
///
/// The interval between cash flows is determined by the series frequency,
/// and the series mode determines whether a cash flow value occurs at the
/// beginning or end of the period defined by the frequency.
///
/// Where the start dates of two or more series of the same type are
/// *defined* it is possible the respective cash flow series may overlap.
/// This is intentional to allow for the creation of advanced cash flow
/// profiles.
///
/// Where the start dates of two or more series of the same type are
/// *undefined*, the start date of any subsequent series is determined
/// with reference to the end date of the preceding series. The order
/// that each undated series is defined and added to the series array is
/// therefore very important as each is processed sequentially.
///
/// The mixing of dated and undated series is permissable but discouraged,
/// unless you know what you are doing of course. It is recommended you
/// either stick to explicitly defining the start dates of *all* cash flow
/// series, or alternativey leave dates undefined and allow the builder
/// to resolve them with reference to the provided [startDate].
///
List<CashFlow> build({
  required List<Series> series,
  required DateTime startDate,
}) {
  if (series.isEmpty) {
    throw Exception("The cash flow series is empty. Build aborted.");
  }

  final List<CashFlow> cashFlows = [];

  // Keep track of computed dates for undated series
  DateTime nextAdvPeriod = startDate;
  DateTime nextPmtPeriod = startDate;
  DateTime nextChgPeriod = startDate;

  for (var seriesItem in series) {
    DateTime postDateToUse;
    int postDateDay;
    if (seriesItem.postDateFrom == null) {
      // Computed date
      if (seriesItem is SeriesAdvance) {
        postDateToUse = nextAdvPeriod;
      } else if (seriesItem is SeriesPayment) {
        postDateToUse = nextPmtPeriod;
      } else if (seriesItem is SeriesCharge) {
        postDateToUse = nextChgPeriod;
      } else {
        throw Exception('SeriesType $seriesItem not supported.');
      }
      postDateDay = startDate.day;
    } else {
      // Provided date
      postDateToUse = seriesItem.postDateFrom!;
      postDateDay = postDateToUse.day;
    }

    if (seriesItem.mode == Mode.arrear) {
      postDateToUse =
          rollDate(postDateToUse, seriesItem.frequency, postDateDay);
    }

    if (seriesItem is SeriesAdvance) {
      // Process value dates for advances only
      DateTime valueDateToUse;
      int valueDateDay;

      if (seriesItem.valueDateFrom == null) {
        valueDateToUse = postDateToUse;
        valueDateDay = postDateDay;
      } else {
        valueDateToUse = seriesItem.valueDateFrom!;
        valueDateDay = valueDateToUse.day;
        if (seriesItem.mode == Mode.arrear) {
          valueDateToUse =
              rollDate(valueDateToUse, seriesItem.frequency, valueDateDay);
        }
      }
      for (var j = 0; j < seriesItem.numberOf; j++) {
        final value = seriesItem.value != null ? -seriesItem.value!.abs() : 0.0;
        cashFlows.add(CashFlowAdvance(
          postDate: postDateToUse,
          valueDate: valueDateToUse,
          value: value,
          isKnown: seriesItem.value != null,
          weighting: seriesItem.weighting,
          label: seriesItem.label,
        ));
        if (j < seriesItem.numberOf - 1) {
          postDateToUse =
              rollDate(postDateToUse, seriesItem.frequency, postDateDay);
          valueDateToUse =
              rollDate(valueDateToUse, seriesItem.frequency, valueDateDay);
        }
      }
      if (seriesItem.postDateFrom == null) {
        if (seriesItem.mode == Mode.advance) {
          // Shift current series window end date to the end of the
          //last compounding period
          nextAdvPeriod =
              rollDate(postDateToUse, seriesItem.frequency, postDateDay);
        } else {
          nextAdvPeriod = postDateToUse;
        }
      }
    } else if (seriesItem is SeriesPayment) {
      for (var j = 0; j < seriesItem.numberOf; j++) {
        final value = seriesItem.value != null ? seriesItem.value!.abs() : 0.0;
        cashFlows.add(CashFlowPayment(
            postDate: postDateToUse,
            value: value,
            isKnown: seriesItem.value != null,
            weighting: seriesItem.weighting,
            isInterestCapitalised: seriesItem.isInterestCapitalised,
            label: seriesItem.label));
        if (j < seriesItem.numberOf - 1) {
          postDateToUse =
              rollDate(postDateToUse, seriesItem.frequency, postDateDay);
        }
      }
      if (seriesItem.postDateFrom == null) {
        if (seriesItem.mode == Mode.advance) {
          // Shift current series window end date to the end of the
          // last compounding period
          nextPmtPeriod =
              rollDate(postDateToUse, seriesItem.frequency, postDateDay);
        } else {
          nextPmtPeriod = postDateToUse;
        }
      }
    } else if (seriesItem is SeriesCharge) {
      // Charge value must be defined
      for (var j = 0; j < seriesItem.numberOf; j++) {
        final value = seriesItem.value != null ? seriesItem.value!.abs() : 0.0;
        cashFlows.add(CashFlowCharge(
            postDate: postDateToUse, value: value, label: seriesItem.label));
        if (j < seriesItem.numberOf - 1) {
          postDateToUse =
              rollDate(postDateToUse, seriesItem.frequency, postDateDay);
        }
      }
      if (seriesItem.postDateFrom == null) {
        if (seriesItem.mode == Mode.advance) {
          // Shift current series window end date to the end of the
          // last compounding period
          nextChgPeriod =
              rollDate(postDateToUse, seriesItem.frequency, postDateDay);
        } else {
          nextChgPeriod = postDateToUse;
        }
      }
    } else {
      throw Exception('SeriesType ${seriesItem.runtimeType} not supported');
    }
  }
  return cashFlows;
}

/// Assigns day count factors to each cash flow in the profile series.
///
/// [profile]
///
Profile assignFactors(
  Profile profile,
) {
  var cashFlows = sort(profile.cashFlows, profile.dayCount);
  final drawdownDate = profile.dayCount.usePostDates
      ? profile.firstDrawdownPostDate
      : profile.firstDrawdownValueDate;

  cashFlows = computeFactors(cashFlows, profile.dayCount, drawdownDate);
  return profile.copyWith(
    cashFlows: cashFlows,
  );
}

/// Sort the cash flow series, first in date ascending order, then
/// by instance type CashFlowAdvance first.
///
List<CashFlow> sort(
  List<CashFlow> cashFlows,
  Convention dayCount,
) {
  cashFlows.sort((CashFlow cf1, CashFlow cf2) {
    // Order by dates
    if (dayCount.usePostDates) {
      if (cf1.postDate.isBefore(cf2.postDate)) {
        return -1;
      } else if (cf1.postDate.isAfter(cf2.postDate)) {
        return 1;
      } else {
        // Secondary-sort same-dated CashFlowAdvance's on value dates
        if (cf1 is CashFlowAdvance && cf2 is CashFlowAdvance) {
          if (cf1.valueDate.isBefore(cf2.valueDate)) {
            return -1;
          } else if (cf1.valueDate.isAfter(cf2.valueDate)) {
            return 1;
          }
        }
      }
    } else {
      if (cf1.valueDate.isBefore(cf2.valueDate)) {
        return -1;
      } else if (cf1.valueDate.isAfter(cf2.valueDate)) {
        return 1;
      } else {
        // Secondary-sort same-dated CashFlowAdvance's on post dates
        if (cf1 is CashFlowAdvance && cf2 is CashFlowAdvance) {
          if (cf1.postDate.isBefore(cf2.postDate)) {
            return -1;
          } else if (cf1.postDate.isAfter(cf2.postDate)) {
            return 1;
          }
        }
      }
    }

    // Sort same dated CashFlowPayment's by isInterestCapitalised,
    // false values first
    if (cf1 is CashFlowPayment && cf2 is CashFlowPayment) {
      return (cf1.isInterestCapitalised == cf2.isInterestCapitalised)
          ? 0
          : cf1.isInterestCapitalised
              ? 1
              : -1;
    }

    // Sort CashFlowAdvance's to be first amongst samed-dated
    // payment and charge cash flows
    return cf1 is CashFlowAdvance ? -1 : 1;
  });
  return cashFlows;
}

/// Computes the cash flow periodic factors using the day count convention
/// implementation provided.
///
/// [dayCount]
///
/// [drawDownDate] determined by the [dayCount] attribute usePostDates
/// value, so if usePostDates is true then the post date of the initial
/// CashFlowAdvance in the series should be provided, and if false
/// the initial CashFlowAdvance value date.
///
List<CashFlow> computeFactors(
  List<CashFlow> cashFlows,
  Convention dayCount,
  DateTime drawDownDate,
) {
  final newCashFlows = <CashFlow>[];
  DateTime cashFlowDate;
  // Neighbouring cashflow time period calculations start from the
  // drawdown date, so initialise with this date.
  DateTime neighbourDate = drawDownDate;

  for (var cashFlow in cashFlows) {
    cashFlowDate =
        dayCount.usePostDates ? cashFlow.postDate : cashFlow.valueDate;

    if (cashFlow is CashFlowCharge && !dayCount.includeNonFinancingFlows) {
      newCashFlows.add(
        cashFlow.copyWith(
          periodFactor: dayCount.computeFactor(
            cashFlowDate,
            cashFlowDate,
          ),
        ),
      );
      continue;
    }

    DayCountFactor periodFactor;
    if (!cashFlowDate.isAfter(drawDownDate)) {
      // CashFlow predates initial drawdown so period factor is zero
      periodFactor = dayCount.computeFactor(
        cashFlowDate,
        cashFlowDate,
      );
    } else {
      switch (dayCount.dayCountOrigin()) {
        case DayCountOrigin.drawdown:
          periodFactor = dayCount.computeFactor(
            drawDownDate,
            cashFlowDate,
          );
          break;
        case DayCountOrigin.neighbour:
          periodFactor = dayCount.computeFactor(
            neighbourDate,
            cashFlowDate,
          );
          neighbourDate = cashFlowDate;
          break;
      }
    }
    if (cashFlow is CashFlowAdvance) {
      newCashFlows.add(
        cashFlow.copyWith(periodFactor: periodFactor),
      );
    } else if (cashFlow is CashFlowPayment) {
      newCashFlows.add(
        cashFlow.copyWith(periodFactor: periodFactor),
      );
    } else if (cashFlow is CashFlowCharge) {
      newCashFlows.add(
        cashFlow.copyWith(periodFactor: periodFactor),
      );
    }
  }
  return newCashFlows;
}

/// Updates the value of cash flows flagged as unknown. Returns the value,
/// unmodified or rounded as appropriate.
///
/// [cashFlows]
///
/// [value] the value to assign, which may be negative or positive
///
/// [precision] to use when [isRounded] is true
///
/// [isRounded] flag to control rounding of the value prior to update.
/// Rounding should only be undertaken *after* an unknown value has
/// been computed. Default is false, no rounding.
///
List<CashFlow> updateUnknowns({
  required List<CashFlow> cashFlows,
  required double value,
  required int precision,
  bool isRounded = false,
}) {
  final newCashFlows = <CashFlow>[];
  for (var cashFlow in cashFlows) {
    if (!cashFlow.isKnown) {
      double newValue;
      if (isRounded) {
        newValue = weightAdjustedValue(
          value: value,
          weighting: cashFlow.weighting,
          precision: precision,
        );
      } else {
        newValue = weightAdjustedValue(
          value: value,
          weighting: cashFlow.weighting,
        );
      }
      if (cashFlow is CashFlowAdvance) {
        newCashFlows.add(cashFlow.copyWith(value: newValue));
      } else if (cashFlow is CashFlowPayment) {
        newCashFlows.add(cashFlow.copyWith(value: newValue));
      }
    } else {
      newCashFlows.add(cashFlow);
    }
  }
  return newCashFlows;
}

/// Updates the amortised interest value of payment cash flows
/// once the unknown values have been determined.
///
/// [interestRate] annual rate of interest to use in
/// calculating the interest monetary value
///
List<CashFlow> amortiseInterest(
  List<CashFlow> cashFlows,
  double interestRate,
  int precision,
) {
  double capitalBalance = 0.0;
  double periodInterest;
  double accruedInterest = 0.0;
  final newCashFlows = <CashFlow>[];

  for (var cashFlow in cashFlows) {
    if (cashFlow is CashFlowCharge) {
      newCashFlows.add(cashFlow);
      continue;
    }

    periodInterest = gaussRound(
        capitalBalance * interestRate * cashFlow.periodFactor!.factor,
        precision);

    if (cashFlow is CashFlowPayment) {
      double interest;
      if (cashFlow.isInterestCapitalised) {
        interest = gaussRound(accruedInterest + periodInterest, precision);
        capitalBalance += interest + cashFlow.value;
        accruedInterest = 0.0;
      } else {
        interest = 0.0;
        accruedInterest += periodInterest;
        capitalBalance += cashFlow.value;
      }
      newCashFlows.add(cashFlow.copyWith(interest: interest));
      continue;
    } else {
      newCashFlows.add(cashFlow);
    }
    // Cash out flows
    capitalBalance += periodInterest + cashFlow.value;
  }

  // Adjust interest total in the last cash flow due to the
  // decrepancies that arise from the cumulative effect of
  // rounding differences.
  for (var i = newCashFlows.length - 1; i >= 0; i--) {
    final newCashFlow = newCashFlows[i];
    if (newCashFlow is CashFlowPayment) {
      newCashFlows.removeAt(i);
      newCashFlows.insert(
        i,
        newCashFlow.copyWith(
          interest: gaussRound(
            newCashFlow.interest - capitalBalance,
            precision,
          ),
        ),
      );
      break;
    }
  }
  return newCashFlows;
}

/// Computes the cash flow value taking into account the weighting factor and
/// optional precision.
///
/// [value] the unweighted value to use in computing the new cash flow value.
///
/// [weighting] of the associated cash flow.
///
/// [precision] (optional) the number of fractional digits to apply in
/// the rounding of unknown cash flow values. Should only be provided
/// after an unknown value has been solved.
///
double weightAdjustedValue({
  required double value,
  required double weighting,
  int? precision,
}) {
  if (precision == null) {
    // No rounding
    return value * weighting;
  } else {
    return gaussRound(value * weighting, precision);
  }
}
