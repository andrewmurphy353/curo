import 'dart:math';

import 'package:curo/curo.dart';
import 'package:tabular/tabular.dart';

class Schedule {
  static const displayPrecision = 6;

  final Profile profile;
  final double rateResult;
  double? valueResult;

  Schedule({
    required this.profile,
    required this.rateResult,
    this.valueResult,
  });

  void prettyPrint({required int example}) {
    print('\nEXAMPLE $example\n');
    if (valueResult != null) {
      print(
        'Computed cash flow value: '
        '${valueResult!.toStringAsFixed(profile.precision)}',
      );
    }
    print('Implicit interest rate: '
        '${(rateResult * 100).toStringAsFixed(displayPrecision)}%');
    print('Day count convention used: ${profile.dayCount}');

    switch (profile.dayCount.dayCountOrigin()) {
      case DayCountOrigin.drawdown:
        _printAprProofSchedule();
        break;
      case DayCountOrigin.neighbour:
      _printAmortisationSchedule();
    }
  }

  // This proof schedule demonstrates that the derived XIRR/APR result is
  // mathematically correct; you can cross-check the result by substituting
  // the inputs from each line into the formula provided at the bottom of
  // the table and then sum the results (use the unrounded XIRR/APR result
  // when you do this).
  //
  // Note that the production of a proof schedule only makes sense in the
  // context of APR and XIRR interest rate calculations where time periods
  // are measured with reference to the initial drawdown date. For
  // calculations based on compound interest the use of an amortisation
  // schedule is required.
  void _printAprProofSchedule() {
    print('\nAPR / XIRR PROOF SCHEDULE\n');
    print(tabular(
      _aprProofLineItems(),
      align: {
        'Day Count Factor': Side.end,
      },
      rowDividers: [1, profile.cashFlows.length + 1],
    ));
    print(
      '\n[1] Amount Discounted = '
      'Amount * ((1 + ImplicitRateAsDecimal) ^ -Factor)',
    );
    print(
      '\n[2] Schedule amounts discounted at the implicit rate of '
      '${(rateResult * 100).toStringAsFixed(displayPrecision)}% should sum\n'
      'to zero, proving the correctness of the rate (negligible variances '
      'may arise\ndue to the rounding precision used)\n\n',
    );
  }

  List<List<dynamic>> _aprProofLineItems() {
    final lineItems = [
      <dynamic>[
        profile.dayCount.usePostDates ? 'Post Date' : 'Value Date',
        'Label',
        'Amount',
        'Day Count Factor',
        'Amount Discounted [1]',
      ],
    ];
    var netTotal = 0.0;
    for (var cashFlow in profile.cashFlows) {
      if (cashFlow is CashFlowCharge &&
          !profile.dayCount.includeNonFinancingFlows) {
        continue;
      }
      final lineTotal = gaussRound(
          cashFlow.value * pow(1 + rateResult, -cashFlow.periodFactor!.factor),
          displayPrecision);
      netTotal += lineTotal;
      lineItems.add([
        _dateToString(
          profile.dayCount.usePostDates
              ? cashFlow.postDate
              : cashFlow.valueDate,
        ),
        cashFlow.label,
        cashFlow.value.toStringAsFixed(profile.precision),
        cashFlow.periodFactor.toString(),
        lineTotal.toStringAsFixed(displayPrecision),
      ]);
    }
    lineItems.add([
      'Net Total [2]',
      '',
      '',
      '',
      netTotal.toStringAsFixed(displayPrecision),
    ]);
    return lineItems;
  }

  void _printAmortisationSchedule() {
    print('\nAMORTISATION SCHEDULE\n');
    print(tabular(_amortisationLineItems()));
    print('\n');
  }

  List<List<dynamic>> _amortisationLineItems() {
    final lineItems = [
      <dynamic>[
        profile.dayCount.usePostDates ? 'Post Date' : 'Value Date',
        'Label',
        'Amount',
        'Interest',
        'Capital Balance',
      ],
    ];
    double capitalBalance = 0.0;
    for (var cashFlow in profile.cashFlows) {
      if (cashFlow is CashFlowAdvance) {
        capitalBalance += gaussRound(
          cashFlow.value,
          profile.precision,
        );
        lineItems.add([
          profile.dayCount.usePostDates
              ? _dateToString(cashFlow.postDate)
              : _dateToString(cashFlow.valueDate),
          cashFlow.label,
          cashFlow.value.toStringAsFixed(profile.precision),
          '',
          capitalBalance.toStringAsFixed(profile.precision),
        ]);
      } else if (cashFlow is CashFlowPayment) {
        capitalBalance += gaussRound(
          cashFlow.value + cashFlow.interest,
          profile.precision,
        );
        lineItems.add([
          _dateToString(cashFlow.postDate),
          cashFlow.label,
          cashFlow.value.toStringAsFixed(profile.precision),
          cashFlow.interest.toStringAsFixed(profile.precision),
          capitalBalance.toStringAsFixed(profile.precision),
        ]);
      }
    }
    return lineItems;
  }

  // Provide basic date format to avoid dependency
  // on intl package to localise
  static String _dateToString(DateTime utcDateTime) {
    final sb = StringBuffer();
    sb.write(utcDateTime.year);
    sb.write('-');
    sb.write(
      utcDateTime.month < 10 ? '0${utcDateTime.month}' : utcDateTime.month,
    );
    sb.write('-');
    sb.write(utcDateTime.day);
    return sb.toString();
  }
}
