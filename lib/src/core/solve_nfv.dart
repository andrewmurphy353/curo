import 'dart:math';

import '../daycount/day_count_origin.dart';
import '../profile/cash_flow_charge.dart';
import '../profile/cash_flow_payment.dart';
import '../profile/profile.dart';

import 'solve_callback.dart';

/// Implementation of the function for finding the interest rate where the
/// net future value (nfv) of cash flows equals zero.
///
/// Unlike the similar net present value (npv) calculation solved
/// algebraically using regular time periods, this function is designed
/// to find unknowns where time periods may be either regular or irregular.
///
class SolveNfv implements SolveCallback {
  final Profile profile;

  /// Provides an instance of the SolveNfv object
  ///
  /// [profile] containing the cash flow series
  ///
  SolveNfv({
    required this.profile,
  }); // {

  /// Implementation of the callback function to compute the net future
  /// value of the cash flow series using the given interest rate.
  ///
  /// [rateGuess] interest rate guess or actual rate if known
  ///
  @override
  double compute(double rateGuess) {
    double capitalBalance = 0.0;

    switch (profile.dayCount.dayCountOrigin()) {
      case DayCountOrigin.drawdown:
        for (var cashFlow in profile.cashFlows) {
          if (cashFlow is CashFlowCharge &&
              !profile.dayCount.includeNonFinancingFlows) {
            continue;
          }
          capitalBalance += cashFlow.value *
              pow(1 + rateGuess, -cashFlow.periodFactor!.factor);
        }
        break;

      case DayCountOrigin.neighbour:
      double periodInterest;
        double accruedInterest = 0.0;
        for (var cashFlow in profile.cashFlows) {
          if (cashFlow is CashFlowCharge &&
              !profile.dayCount.includeNonFinancingFlows) {
            continue;
          }

          periodInterest =
              capitalBalance * rateGuess * cashFlow.periodFactor!.factor;

          if (cashFlow is CashFlowPayment) {
            if (cashFlow.isInterestCapitalised) {
              capitalBalance +=
                  accruedInterest + periodInterest + cashFlow.value;
              accruedInterest = 0;
            } else {
              accruedInterest += periodInterest;
              capitalBalance += cashFlow.value;
            }
            continue;
          }

          // Cash outflows
          capitalBalance += periodInterest;
          capitalBalance += cashFlow.value;
        }
        break;
    }
    return capitalBalance;
  }
}
