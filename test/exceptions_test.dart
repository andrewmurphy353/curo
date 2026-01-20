import 'package:curo/src/calculator.dart';
import 'package:test/test.dart';

void main() {
  test('UnsolvableException message', () {
    try {
      throw UnsolvableException('No root in bracket: f(a) and f(b) same sign');
    } catch (e) {
      expect(e.toString(),
          'Unsolvable: No root in bracket: f(a) and f(b) same sign');
    }
  });
  test('DeveloperException message', () {
    try {
      throw DeveloperException('No cash flow series provided');
    } catch (e) {
      expect(e.toString(), 'Configuration error: No cash flow series provided');
    }
  });
  test('FinalPaymentInterestNotCapitalisedException message', () {
    try {
      throw FinalPaymentInterestNotCapitalisedException(
          DateTime.utc(2026, 1, 1));
    } catch (e) {
      expect(
          e.toString(),
          'Invalid input: No payment on the final '
          'date (2026-01-01) has isInterestCapitalised: true. At '
          'least one final payment must capitalise interest to clear '
          'any accrued amount.');
    }
  });
  test('MissingUnknownCashFlowException message', () {
    try {
      throw MissingUnknownCashFlowException();
    } catch (e) {
      expect(
        e.toString(),
        'Invalid input: There must be at least one or more unknown '
        'cash flow amount of the same type when solving for an amount.',
      );
    }
  });
  test('UnknownCashFlowsWhenSolvingRateException message', () {
    try {
      throw UnknownCashFlowsWhenSolvingRateException();
    } catch (e) {
      expect(
        e.toString(),
        'Invalid input: All cash flow amounts must be known when '
        'solving for interest rate.',
      );
    }
  });
  test('MixedUnknownCashFlowsException message', () {
    try {
      throw MixedUnknownCashFlowsException();
    } catch (e) {
      expect(
        e.toString(),
        'Invalid input: Unknown advances and payments cannot be '
        'mixed - only one type can have an unknown amount.',
      );
    }
  });
}
