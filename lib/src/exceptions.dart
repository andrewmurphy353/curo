/// Library defining validation and unsolvable exception conditions.
library;

import 'package:intl/intl.dart';

/// Thrown when a numerical solver fails to converge on a solution.
final class UnsolvableException implements Exception {
  final String message;
  UnsolvableException(this.message);

  @override
  String toString() => 'Unsolvable: $message';
}

/// Thrown when the developer misuses the library API in a way they have
/// full control over (invalid configuration, wrong combinations, etc.).
final class DeveloperException implements Exception {
  final String message;
  DeveloperException(this.message);

  @override
  String toString() => 'Configuration error: $message';
}

/// Base class for all validation errors originating from end-user input.
sealed class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => 'Invalid input: $message';
}

/// Thrown when no payment on the final date has interest capitalisation enabled,
/// which is required to clear any remaining accrued interest.
final class FinalPaymentInterestNotCapitalisedException
    extends ValidationException {
  static final dateFormat = DateFormat('yyyy-MM-dd');
  FinalPaymentInterestNotCapitalisedException(DateTime finalDate)
      : super(
          'No payment on the final date (${dateFormat.format(finalDate)}) has '
          'isInterestCapitalised: true. At least one final payment must capitalise '
          'interest to clear any accrued amount.',
        );
}

/// Thrown when solving for an unknown cash flow amount, but none are
/// marked as unknown.
final class MissingUnknownCashFlowException extends ValidationException {
  MissingUnknownCashFlowException()
      : super(
          'There must be at least one or more unknown cash flow amount '
          'of the same type when solving for an amount.',
        );
}

/// Thrown when solving for interest rate, but one or more cash flow
/// amounts are unknown.
final class UnknownCashFlowsWhenSolvingRateException
    extends ValidationException {
  UnknownCashFlowsWhenSolvingRateException()
      : super(
          'All cash flow amounts must be known when solving for interest rate.',
        );
}

/// Thrown when both advances and payments contain unknown amounts.
final class MixedUnknownCashFlowsException extends ValidationException {
  MixedUnknownCashFlowsException()
      : super(
          'Unknown advances and payments cannot be mixed - only '
          'one type can have an unknown amount.',
        );
}
