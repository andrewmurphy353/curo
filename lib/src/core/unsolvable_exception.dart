/// Exception thrown when the unknown cash flow values or interest rate
/// implicit in a cash flow series cannot be solved within a finite number
/// of iterations.
///
class UnsolvableException implements Exception {
  final String message;
  UnsolvableException(this.message);

  @override
  String toString() => message;
}
