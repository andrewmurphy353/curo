import '../utilities/math.dart';

/// The day count factor applied to the associated cash flow.
class DayCountFactor {
  final double factor;
  final List<String> operandLog;

  const DayCountFactor(this.factor, this.operandLog);

  /// Provides formatted text containing the operands used in deriving the
  /// factor. This is useful in constructing calculation proofs, for example
  /// to demonstrate how an Annual Percentage Rate (APR) or eXtended
  /// Internal Rate of Return (XIRR) was derived.
  ///
  /// [numerator] defined in days or whole weeks, months or years
  /// between two dates
  ///
  /// [denominator] corresponding to the number of days, weeks or months
  /// in a year
  static String operandsToString(int numerator, int denominator) =>
      '($numerator/$denominator)';

  /// Provides a string representation of the factor equation,
  /// with the factor displayed to 8 decimal points
  /// e.g. '(31/360) = 0.08611111'
  @override
  String toString() {
    final displayText = StringBuffer();
    for (int i = 0; i < operandLog.length; i++) {
      displayText.write(operandLog[i]);
      if (i + 1 != operandLog.length) {
        displayText.write(" + ");
      }
    }
    displayText.write(" = ");
    displayText.write(gaussRound(factor, 8).toStringAsFixed(8));
    return displayText.toString();
  }
}
