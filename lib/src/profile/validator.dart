import 'cash_flow.dart';
import 'cash_flow_advance.dart';
import 'cash_flow_payment.dart';

/// Validates the number of fractional digits used in the rounding of
/// [CashFlow] values in the notional calculation currency. Valid options
/// are 0, 2, 3 and 4.
bool validatePrecision(int precision) {
  switch (precision) {
    case 0:
    case 2:
    case 3:
    case 4:
      return true;
    default:
      throw Exception('The precision of $precision is not supported. '
          'Valid options are 0, 2, 3 or 4');
  }
}

/// Checks for the presence of one or more [CashFlowAdvance] instances
/// and returns the one with the earliest post date, or throws an
/// exception if non found.
///
/// The post date of the returned instance serves as the initial drawdown
/// date.
///
CashFlowAdvance validateAdvances(List<CashFlow> cashFlows) {
  final advanceCashFlows = cashFlows.whereType<CashFlowAdvance>().toList();
  advanceCashFlows.sort((cf1, cf2) {
    if (cf1.postDate.isBefore(cf2.postDate)) {
      return -1;
    } else if (cf1.postDate.isAfter(cf2.postDate)) {
      return 1;
    } else {
      // Post dates are equal, sort by value date, earliest first
      if (cf1.valueDate.isBefore(cf2.valueDate)) {
        return -1;
      } else if (cf1.valueDate.isAfter(cf2.valueDate)) {
        return 1;
      } else {
        return 0;
      }
    }
  });
  if (advanceCashFlows.isNotEmpty) {
    return advanceCashFlows.first;
  }
  throw Exception('The profile must have at least one instance of '
      'CashFlowAdvance defined.');
}

/// Checks the presence one or more [CashFlowPayment] instances and
/// throws an exception if non found.
///
bool validatePayments(List<CashFlow> cashFlows) {
  if (cashFlows.whereType<CashFlowPayment>().isNotEmpty) {
    return true;
  }
  throw Exception('The profile must have at least one instance of '
      'CashFlowPayment defined.');
}

/// Validates the correct use of the [CashFlow] isKnown property.
///
/// Solving for unknown values is a mutually exclusive computation
/// performed on either advances, or payments, not on a mix of both.
///
/// Note it is permissable to have no unknowns, for example when
/// computing implicit interest rates.
///
bool validateUnknowns(List<CashFlow> cashFlows) {
  if (cashFlows
          .whereType<CashFlowAdvance>()
          .any((element) => !element.isKnown) &&
      cashFlows
          .whereType<CashFlowPayment>()
          .any((element) => !element.isKnown)) {
    throw Exception(
        'The profile should not contain a mix of CashFlowAdvance and '
        'CashFlowPayment objects with unknown values.');
  }
  return true;
}

/// Validates the correct use of the [CashFlowPayment] isInterestCapitalised
/// property.
///
/// It is permissable to define a frequency of interest capitalisation
/// that differs from the [CashFlowPayment] frequency. So to avoid the lost
/// of accrued interest not yet capitalised it is important that the
/// final [CashFlowPayment] object in the cash flow series always has the
/// isInterestCapitalised property set to true.
///
bool validateIsInterestCapitalised(List<CashFlow> cashFlows) {
  // Extract and sort date descending
  final paymentCashFlows = cashFlows.whereType<CashFlowPayment>().toList();
  paymentCashFlows.sort((cf1, cf2) {
    if (cf1.postDate.isBefore(cf2.postDate)) {
      return 1;
    } else if (cf1.postDate.isAfter(cf2.postDate)) {
      return -1;
    } else {
      return 0;
    }
  });
  // Extract objects sharing the same final post date and check
  final paymentIter = paymentCashFlows
      .where((element) => element.postDate == paymentCashFlows[0].postDate);
  for (var payment in paymentIter) {
    // Only requires one of multiple payments sharing the same final
    // post date to have isInterestCapitalised = true as accrued interest
    // is assigned to the first found. Therefore is safe to ignore those
    // remaining as the accued interest register will be zero after
    // interest is capitalised.
    if (payment.isInterestCapitalised) {
      return true;
    }
  }
  throw Exception(
      'The last CashflowPayment object in the profile must have the '
      'isInterestCapitalised property set to \'true\'.');
}
