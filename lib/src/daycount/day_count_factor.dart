import '../utilities/math.dart';

/// The day count factor applied to the associated cash flow.
class DayCountFactor {
  final double principalFactor;
  final double? fractionalAdjustment;
  final List<String> operandLog;

  const DayCountFactor(this.principalFactor, this.operandLog,
      {this.fractionalAdjustment});

  const DayCountFactor.usAppendixJ(
    this.principalFactor,
    this.fractionalAdjustment,
    this.operandLog,
  );

  /// Provides formatted text containing the operands used in deriving the
  /// factor. The operands are transformed into whole years and fractions of
  /// years to support compact rendering.
  ///
  /// The operands are useful for constructing calculation proofs, for example
  /// to demonstrate how an Annual Percentage Rate (APR) or eXtended
  /// Internal Rate of Return (XIRR) was derived.
  ///
  /// [numerator] defined in days or whole weeks, months or years
  /// between two dates
  ///
  /// [denominator] corresponding to the number of days, weeks or months
  /// in a year
  static String operandsToString(int numerator, int denominator) {
    if (denominator == 0) {
      return numerator.toString();
    }
    final wholeYear = numerator ~/ denominator;
    final remainder = numerator % denominator;
    if (wholeYear == 0 && remainder != 0) {
      return "($remainder/$denominator)";
    } else if (remainder == 0) {
      return wholeYear.toString();
    } else {
      return "$wholeYear + ($remainder/$denominator)";
    }
  }

  /// Provides a string representation of the factor equation,
  /// with the factor displayed to 8 decimal points
  /// e.g. '(31/360) = 0.08611111'
  ///
  /// Note: Factor string length can become problematic for display
  /// purposes when using certain day count conventions, especially
  /// those designed to use actual days. To overcome this, use the
  /// [toFoldedString] method which folds identical equation operands
  /// whilst ensuring the integrity of displayed formulae is maintained.
  ///
  String toString() {
    final displayText = StringBuffer();
    if (operandLog.isNotEmpty) {
      for (int i = 0; i < operandLog.length; i++) {
        displayText.write(operandLog[i]);
        if (i + 1 != operandLog.length) {
          displayText.write(" + ");
        }
      }
      displayText.write(" = ");
    }
    if (fractionalAdjustment != null) {
      //displayText.write("principal: ");// TODO use abbr. p for (UI localisation)
      displayText.write("p: ");
    }
    displayText.write(gaussRound(principalFactor, 8).toStringAsFixed(8));
    if (fractionalAdjustment != null) {
      //displayText.write(", fractional: "); // TODO use abbr. f for (UI localisation)
      displayText.write(", f: ");
      displayText
          .write(gaussRound(fractionalAdjustment!, 8).toStringAsFixed(8));
    }
    return displayText.toString();
  }

  /// Provides a compressed string representation of the factor equation,
  /// whilst maintaining formulae integrity. This is achieved by counting
  /// the number of whole year operands and representing them as
  /// a single number.
  ///
  /// For example "(100/360) + (365/365) + (365/365) + (31/360) = 2.36388889"
  /// returned from a call to [toString] will be transformed
  /// to "(100/360) + 2 + (31/360) = 2.36388889" by this method.
  ///
  String toFoldedString() {
    String operands = '';
    for (int i = 0; i < operandLog.length; i++) {
      final current = operandLog[i];
      int count = 1;
      for (int j = i + 1; j < operandLog.length; j++) {
        if (operandLog[j] == current) {
          count++;
          i = j;
        } else {
          break;
        }
      }
      if (operands.isEmpty) {
        operands += count > 1 ? '$count' : current;
      } else {
        operands += count > 1 ? ' + $count' : ' + $current';
      }
    }
    final principalString = gaussRound(principalFactor, 8).toStringAsFixed(8);

    if (fractionalAdjustment != null) {
      final fractionalString =
          gaussRound(fractionalAdjustment!, 8).toStringAsFixed(8);
      return '$operands = p: $principalString f:$fractionalString';
    } else {
      // TODO what about USAppendicJ days/365?? Proof with need to show p: or f:
      return '$operands = $principalString';
    }
  }
}
