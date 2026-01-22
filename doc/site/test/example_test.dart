// ignore_for_file: dead_code

import 'package:curo/curo.dart';
import 'package:test/test.dart';

void main() {
  // Set to true when developing locally to see full pretty-printed output
  const bool printOutput = false;

  group('Curo Documentation Examples', () {
    test(
      'Example 1: Determine a payment in arrears repayment profile',
      () async {
        final calculator = Calculator(precision: 2)
          ..add(SeriesAdvance(label: 'Loan', amount: 10000.0))
          ..add(
            SeriesPayment(
              numberOf: 6,
              label: 'Instalment',
              amount: null,
              mode: Mode.arrear,
            ),
          );

        final convention = const US30U360();

        final payment = await calculator.solveValue(
          convention: convention,
          interestRate: 0.0825,
          startDate: DateTime.utc(2026, 1, 5),
        );

        final irr = await calculator.solveRate(convention: convention);

        final schedule = calculator.buildSchedule(
          convention: convention,
          interestRate: irr,
        );

        if (printOutput) {
          print('Example 01');
          print('Monthly instalment: \$${payment.toStringAsFixed(2)}');
          print('Implicit interest rate: ${(irr * 100).toStringAsFixed(2)}%\n');
          schedule.prettyPrint(convention: convention);
        }

        // Core financial assertions
        expect(payment, closeTo(1707.00, 0.01));
        expect(irr, closeTo(0.08250039, 1e-8));

        expect(schedule.length, equals(7));

        // Advance
        final advance = schedule[0];
        expect(advance.date, equals(DateTime.utc(2026, 1, 5)));
        expect(advance.label, equals('Loan'));
        expect(advance.amount, closeTo(-10000.0, 0.01));
        expect(advance.capitalBalance, closeTo(-10000.0, 0.01));
        expect(advance.type, equals(CashFlowType.advance));

        // Final payment
        final finalPayment = schedule.last;
        expect(finalPayment.date, equals(DateTime.utc(2026, 7, 5)));
        expect(finalPayment.label, equals('Instalment'));
        expect(finalPayment.capitalBalance, closeTo(0.0, 0.001));
        expect(finalPayment.type, equals(CashFlowType.payment));

        // Spot check: 3rd instalment
        final thirdInstalment = schedule[3];
        expect(thirdInstalment.date, equals(DateTime.utc(2026, 4, 5)));
        expect(thirdInstalment.amount, closeTo(1707.00, 0.01));
        expect(thirdInstalment.capital, closeTo(1660.85, 0.01));
        expect(thirdInstalment.interest, closeTo(-46.15, 0.01));
        expect(thirdInstalment.capitalBalance, closeTo(-5051.39, 0.01));
      },
    );
    test(
      'Example 2: Determine the APR implicit in a repayment schedule, including charges',
      () async {
        final calculator = Calculator()
          ..add(SeriesAdvance(label: 'Loan', amount: 10000.0))
          ..add(
            SeriesPayment(
              numberOf: 6,
              label: 'Instalment',
              amount: null,
              mode: Mode.arrear,
            ),
          )
          ..add(SeriesCharge(label: 'Fee', amount: 50.0, mode: Mode.arrear));

        final payment = await calculator.solveValue(
          convention: US30U360(),
          interestRate: 0.0825,
          startDate: DateTime.utc(2026, 1, 5),
        );
        final irr = await calculator.solveRate(convention: US30U360());

        final convention = EU200848EC();
        final apr = await calculator.solveRate(convention: convention);
        final schedule = calculator.buildSchedule(
          convention: convention,
          interestRate: apr,
        );

        if (printOutput) {
          print('Example 02');
          print('Monthly instalment: €${payment.toStringAsFixed(2)}');
          print('Annual percentage rate: ${(apr * 100).toStringAsFixed(2)}%\n');
          schedule.prettyPrint(convention: convention);
        }

        // Core financial assertions
        expect(payment, closeTo(1707.0, 0.01));
        expect(irr, closeTo(0.08250039, 1e-8));
        expect(apr, closeTo(0.10447489, 1e-8));
        expect(schedule.length, equals(8));

        // Advance
        final advance = schedule[0];
        expect(advance.date, equals(DateTime.utc(2026, 1, 5)));
        expect(advance.label, equals('Loan'));
        expect(advance.amount, closeTo(-10000.0, 0.01));
        expect(advance.discountLog, equals('t = 0 = 0.00000000'));
        expect(advance.amountDiscounted, closeTo(-10000.0, 0.01));
        expect(advance.discountedBalance, closeTo(-10000.0, 0.01));
        expect(advance.type, equals(CashFlowType.advance));

        // Charge (on second period date)
        final charge = schedule[2];
        expect(charge.date, equals(DateTime.utc(2026, 2, 5)));
        expect(charge.label, equals('Fee'));
        expect(charge.amount, closeTo(50.00, 0.01));
        expect(charge.discountLog, equals('t = 1/12 = 0.08333333'));
        expect(charge.amountDiscounted, closeTo(49.59, 0.01));
        expect(charge.discountedBalance, closeTo(-8257.49, 0.01));
        expect(charge.type, equals(CashFlowType.charge));

        // Final payment
        final finalPayment = schedule.last;
        expect(finalPayment.date, equals(DateTime.utc(2026, 7, 5)));
        expect(finalPayment.label, equals('Instalment'));
        expect(finalPayment.amount, closeTo(1707.00, 0.01));
        expect(finalPayment.discountLog, equals('t = 6/12 = 0.50000000'));
        expect(finalPayment.amountDiscounted, closeTo(1624.26, 0.01));
        expect(finalPayment.discountedBalance, closeTo(0.0, 0.001));
        expect(finalPayment.type, equals(CashFlowType.payment));
      },
    );
    test(
      'Example 3: Determine a payment using a different interest frequency',
      () async {
        final calculator = Calculator()
          ..add(SeriesAdvance(numberOf: 1, label: 'Loan', amount: 10000.0))
          ..add(
            SeriesPayment(
              numberOf: 6,
              label: 'Instalment',
              amount: null,
              frequency: Frequency.monthly,
              postDateFrom: DateTime.utc(2026, 2, 5),
              isInterestCapitalised: false,
            ),
          )
          ..add(
            SeriesPayment(
              numberOf: 2,
              label: 'Interest',
              amount: 0.0, // Zero payment value (interest only)
              frequency: Frequency.quarterly,
              postDateFrom: DateTime.utc(2026, 4, 5),
              isInterestCapitalised: true, // Add interest
            ),
          );

        final convention = const US30U360();

        final payment = await calculator.solveValue(
          convention: convention,
          interestRate: 0.0825,
          startDate: DateTime.utc(2026, 1, 5),
        );

        final irr = await calculator.solveRate(convention: convention);

        final schedule = calculator.buildSchedule(
          convention: convention,
          interestRate: irr,
        );

        if (printOutput) {
          print('Example 03');
          print('Monthly instalment: \$${payment.toStringAsFixed(2)}');
          print('Implicit interest rate: ${(irr * 100).toStringAsFixed(2)}%\n');
          schedule.prettyPrint(convention: convention);
        }

        // Core financial assertions
        expect(payment, closeTo(1706.67, 0.01));
        expect(irr, closeTo(0.08249743, 1e-8));

        expect(schedule.length, equals(9));

        // Advance
        final advance = schedule[0];
        expect(advance.date, equals(DateTime.utc(2026, 1, 5)));
        expect(advance.label, equals('Loan'));
        expect(advance.amount, closeTo(-10000.0, 0.01));
        expect(advance.capitalBalance, closeTo(-10000.0, 0.01));
        expect(advance.type, equals(CashFlowType.advance));

        // Interest only (after same-dated payment)
        final interestOnly = schedule[4];
        expect(interestOnly.date, equals(DateTime.utc(2026, 4, 5)));
        expect(interestOnly.amount, equals(0.00));
        expect(interestOnly.capital, closeTo(-171.04, 0.01));
        expect(interestOnly.interest, closeTo(-171.04, 0.01));
        expect(interestOnly.capitalBalance, closeTo(-5051.03, 0.01));

        // Final payment
        final finalPayment = schedule.last;
        expect(finalPayment.date, equals(DateTime.utc(2026, 7, 5)));
        expect(finalPayment.label, equals('Interest'));
        expect(finalPayment.capitalBalance, closeTo(0.0, 0.001));
        expect(finalPayment.type, equals(CashFlowType.payment));
      },
    );
    test(
      'Example 4: Determine a supplier 0% finance scheme contribution, combined with a deferred settlement',
      () async {
        final calculator = Calculator()
          ..add(
            SeriesAdvance(
              label: 'Cost of car',
              amount: 10000.0,
              postDateFrom: DateTime.utc(2026, 1, 5),
              valueDateFrom: DateTime.utc(2026, 2, 5),
            ),
          )
          ..add(
            SeriesPayment(
              label: 'Deposit',
              amount: 4000.0,
              postDateFrom: DateTime.utc(2026, 1, 5),
            ),
          )
          ..add(
            SeriesPayment(
              label: 'Supplier contribution',
              amount: null,
              postDateFrom: DateTime.utc(2026, 2, 5),
            ),
          )
          ..add(
            SeriesPayment(
              numberOf: 6,
              label: 'Instalment',
              amount: 1000.0,
              postDateFrom: DateTime.utc(2026, 2, 5),
            ),
          );

        final convention = const US30U360(usePostDates: false); // by value date

        final supplierContribution = await calculator.solveValue(
          convention: convention,
          interestRate: 0.050, // lender return on capital
          startDate: DateTime.utc(2026, 1, 5),
        );

        final lenderIrr = await calculator.solveRate(convention: convention);

        final schedule = calculator.buildSchedule(
          convention: convention,
          interestRate: lenderIrr,
        );

        if (printOutput) {
          print('Example 04');
          print(
            'Supplier contribution: \$${supplierContribution.toStringAsFixed(2)}',
          );
          print('Lender\'s IRR: ${(lenderIrr * 100).toStringAsFixed(2)}%\n');
          schedule.prettyPrint(convention: convention);
        }

        // Core financial assertions
        expect(supplierContribution, closeTo(61.9, 0.01));
        expect(lenderIrr, closeTo(0.05000213, 1e-8));

        expect(schedule.length, equals(9));

        // Deposit
        final deposit = schedule[0];
        expect(deposit.date, equals(DateTime.utc(2026, 1, 5)));
        expect(deposit.label, equals('Deposit'));
        expect(deposit.amount, closeTo(4000.0, 0.01));
        expect(deposit.capital, closeTo(4000.0, 0.01));
        expect(deposit.interest, equals(0.0));
        expect(deposit.capitalBalance, closeTo(4000.0, 0.01));
        expect(deposit.type, equals(CashFlowType.payment));

        // Advance
        final advance = schedule[1];
        expect(advance.date, equals(DateTime.utc(2026, 2, 5)));
        expect(advance.label, equals('Cost of car'));
        expect(advance.amount, closeTo(-10000.0, 0.01));
        expect(advance.capital, closeTo(-10000.0, 0.01));
        expect(advance.interest, equals(0.0));
        expect(advance.capitalBalance, closeTo(-6000.0, 0.01));
        expect(advance.type, equals(CashFlowType.advance));

        // Supplier contribution
        final supplierCont = schedule[3];
        expect(supplierCont.date, equals(DateTime.utc(2026, 2, 5)));
        expect(supplierCont.label, equals('Supplier contribution'));
        expect(supplierCont.amount, closeTo(61.90, 0.01));
        expect(supplierCont.capital, closeTo(61.9, 0.01));
        expect(supplierCont.interest, equals(0.0));
        expect(supplierCont.capitalBalance, closeTo(-4938.1, 0.01));
        expect(supplierCont.type, equals(CashFlowType.payment));

        // Final payment
        final finalPayment = schedule.last;
        expect(finalPayment.date, equals(DateTime.utc(2026, 7, 5)));
        expect(finalPayment.label, equals('Instalment'));
        expect(finalPayment.capitalBalance, closeTo(0.0, 0.001));
        expect(finalPayment.type, equals(CashFlowType.payment));
      },
    );
    test(
      'Example 5: Determine a payment using a stepped weighted profile',
      () async {
        final calculator = Calculator(precision: 2)
          ..add(SeriesAdvance(label: 'Loan', amount: 10000.0))
          ..add(
            SeriesPayment(
              numberOf: 4,
              label: 'Instalment',
              amount: null,
              mode: Mode.arrear,
              weighting: 1.0, // 100% of unknown
            ),
          )
          ..add(
            SeriesPayment(
              numberOf: 4,
              label: 'Instalment',
              amount: null,
              mode: Mode.arrear,
              weighting: 0.6, // 60% of unknown
            ),
          )
          ..add(
            SeriesPayment(
              numberOf: 4,
              label: 'Instalment',
              amount: null,
              mode: Mode.arrear,
              weighting: 0.4, // 40% of unknown
            ),
          );

        final convention = const US30U360();

        final paymentNormalWeight = await calculator.solveValue(
          convention: convention,
          interestRate: 0.070,
          startDate: DateTime.utc(2026, 1, 5),
        );

        final lenderIrr = await calculator.solveRate(convention: convention);

        final schedule = calculator.buildSchedule(
          convention: convention,
          interestRate: lenderIrr,
        );

        if (printOutput) {
          print('Example 05');
          print(
            'Payment (normal weight): \$${paymentNormalWeight.toStringAsFixed(2)}',
          );
          print('Lender IRR: ${(lenderIrr * 100).toStringAsFixed(2)}%\n');
          schedule.prettyPrint(convention: convention);
        }

        // Core financial assertions
        expect(paymentNormalWeight, closeTo(1288.89, 0.01));
        expect(lenderIrr, closeTo(0.06999217, 1e-8));

        expect(schedule.length, equals(13));

        // Advance
        final advance = schedule[0];
        expect(advance.date, equals(DateTime.utc(2026, 1, 5)));
        expect(advance.label, equals('Loan'));
        expect(advance.amount, closeTo(-10000.0, 0.01));
        expect(advance.capitalBalance, closeTo(-10000.0, 0.01));
        expect(advance.type, equals(CashFlowType.advance));

        // First payment with 100% weighting
        final payment100 = schedule[1];
        expect(payment100.date, equals(DateTime.utc(2026, 2, 5)));
        expect(payment100.label, equals('Instalment'));
        expect(payment100.amount, closeTo(1288.89, 0.01));
        expect(payment100.capital, closeTo(1230.56, 0.01));
        expect(payment100.interest, closeTo(-58.33, 0.01));
        expect(payment100.capitalBalance, closeTo(-8769.44, 0.01));
        expect(payment100.type, equals(CashFlowType.payment));

        // First payment with 60% weighting
        final payment60 = schedule[5];
        expect(payment60.date, equals(DateTime.utc(2026, 6, 5)));
        expect(payment60.label, equals('Instalment'));
        expect(payment60.amount, closeTo(773.33, 0.01));
        expect(payment60.capital, closeTo(743.97, 0.01));
        expect(payment60.interest, closeTo(-29.36, 0.01));
        expect(payment60.capitalBalance, closeTo(-4290.55, 0.01));
        expect(payment60.type, equals(CashFlowType.payment));

        // First payment with 40% weighting
        final payment40 = schedule[9];
        expect(payment40.date, equals(DateTime.utc(2026, 10, 5)));
        expect(payment40.label, equals('Instalment'));
        expect(payment40.amount, closeTo(515.56, 0.01));
        expect(payment40.capital, closeTo(503.70, 0.01));
        expect(payment40.interest, closeTo(-11.86, 0.01));
        expect(payment40.capitalBalance, closeTo(-1528.82, 0.01));
        expect(payment40.type, equals(CashFlowType.payment));

        // Final payment
        final finalPayment = schedule.last;
        expect(finalPayment.date, equals(DateTime.utc(2027, 1, 5)));
        expect(finalPayment.label, equals('Instalment'));
        expect(finalPayment.capitalBalance, closeTo(0.0, 0.001));
        expect(finalPayment.type, equals(CashFlowType.payment));
      },
    );
    test(
      'Example 6: Determine a payment in a weighted 3+n repayment profile',
      () async {
        final calculator = Calculator(precision: 2)
          ..add(SeriesAdvance(label: 'Equipment purchase', amount: 10000.0))
          ..add(
            SeriesPayment(
              numberOf: 1,
              label: 'Rental',
              amount: null,
              weighting: 3.0, // 3x unknown
            ),
          )
          ..add(SeriesPayment(numberOf: 5, label: 'Rental', amount: null));

        final convention = const US30U360();

        final paymentNormalWeight = await calculator.solveValue(
          convention: convention,
          interestRate: 0.070,
          startDate: DateTime.utc(2026, 1, 5),
        );

        final lenderIrr = await calculator.solveRate(convention: convention);

        final schedule = calculator.buildSchedule(
          convention: convention,
          interestRate: lenderIrr,
        );

        if (printOutput) {
          print('Example 06');
          print(
            'Payment (normal weight): \$${paymentNormalWeight.toStringAsFixed(2)}',
          );
          print('Lender IRR: ${(lenderIrr * 100).toStringAsFixed(2)}%\n');
          schedule.prettyPrint(convention: convention);
        }

        // Core financial assertions
        expect(paymentNormalWeight, closeTo(1263.64, 0.01));
        expect(lenderIrr, closeTo(0.07002542, 1e-8));

        expect(schedule.length, equals(7));

        // Advance
        final advance = schedule[0];
        expect(advance.date, equals(DateTime.utc(2026, 1, 5)));
        expect(advance.label, equals('Equipment purchase'));
        expect(advance.amount, closeTo(-10000.0, 0.01));
        expect(advance.capitalBalance, closeTo(-10000.0, 0.01));
        expect(advance.type, equals(CashFlowType.advance));

        // First payment: 3x weighted (same day as advance!)
        final weightedPayment = schedule[1];
        expect(weightedPayment.date, equals(DateTime.utc(2026, 1, 5)));
        expect(weightedPayment.label, equals('Rental'));
        expect(weightedPayment.amount, closeTo(3790.92, 0.01));
        expect(weightedPayment.capital, closeTo(3790.92, 0.01));
        expect(weightedPayment.interest, equals(0.0));
        expect(weightedPayment.capitalBalance, closeTo(-6209.08, 0.01));
        expect(weightedPayment.type, equals(CashFlowType.payment));

        // A normal payment
        final payment = schedule[2];
        expect(payment.date, equals(DateTime.utc(2026, 2, 5)));
        expect(payment.label, equals('Rental'));
        expect(payment.amount, closeTo(1263.64, 0.01));
        expect(payment.capital, closeTo(1227.41, 0.01));
        expect(payment.interest, closeTo(-36.23, 0.01));
        expect(payment.capitalBalance, closeTo(-4981.67, 0.01));
        expect(payment.type, equals(CashFlowType.payment));

        // Final payment
        final finalPayment = schedule.last;
        expect(finalPayment.date, equals(DateTime.utc(2026, 6, 5)));
        expect(finalPayment.label, equals('Rental'));
        expect(finalPayment.capitalBalance, closeTo(0.0, 0.001));
        expect(finalPayment.type, equals(CashFlowType.payment));
      },
    );
  });
}
