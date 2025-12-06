import '../utilities/math.dart';

/// The day count factor applied to the associated cash flow.
class DayCountFactor {
  final double principalFactor;
  final double? fractionalAdjustment;
  final List<String> principalOperandLog;
  final List<String>? fractionalOperandLog;

  const DayCountFactor(this.principalFactor, this.principalOperandLog,
      {this.fractionalAdjustment, this.fractionalOperandLog});

  const DayCountFactor.usAppendixJ(
    this.principalFactor,
    this.fractionalAdjustment,
    this.principalOperandLog,
    this.fractionalOperandLog,
  );

  /// Provides formatted text containing the operands used in deriving the
  /// principal and/or fractional factor. The operands are transformed into
  /// whole periods and fractions of periods to support compact rendering.
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
  /// with the factor displayed to 8 decimal points, for example:
  ///
  /// - '(31/360) = 0.08611111' for standard day count conventions, or;
  /// - 't: 1 + 1 = 2', 'f: 5/30 = 0.16666667' for conventions that
  /// consider full and fractional periods separately i.e. US Appendix J.
  ///
  /// Note: Factor string length can become problematic for display
  /// purposes when using certain day count conventions, especially
  /// those designed to use actual days. To overcome this, use the
  /// [toFoldedString] method which folds identical equation operands
  /// whilst ensuring the integrity of displayed formulae is maintained.
  ///
  @override
  String toString() {
    final principalDisplayText = StringBuffer();
    // Handle standard log entries
    if (principalOperandLog.isNotEmpty) {
      for (int i = 0; i < principalOperandLog.length; i++) {
        principalDisplayText.write(principalOperandLog[i]);
        if (i + 1 != principalOperandLog.length) {
          principalDisplayText.write(" + ");
        }
      }
      principalDisplayText.write(" = ");

      if (fractionalAdjustment == null) {
        principalDisplayText.write(
          gaussRound(principalFactor, 8).toStringAsFixed(8),
        );
        return principalDisplayText.toString();
      }
    }

    // Handle standard log entries which contain fractional log entries
    // i.e. USAppendixJ day count convention
    final fractionalDisplayText = StringBuffer();
    if (fractionalAdjustment != null && fractionalOperandLog != null) {
      if (fractionalOperandLog!.isNotEmpty) {
        for (int i = 0; i < fractionalOperandLog!.length; i++) {
          fractionalDisplayText.write(fractionalOperandLog![i]);
          if (i + 1 != fractionalOperandLog!.length) {
            fractionalDisplayText.write(" + ");
          }
        }
      } else {
        fractionalDisplayText.write("0");
      }
      fractionalDisplayText.write(" = ");
      fractionalDisplayText.write(
        gaussRound(fractionalAdjustment!, 8).toStringAsFixed(8),
      );
    }
    if (principalOperandLog.isEmpty) {
      // Will be if there are *only* fractional entries.
      // Buffer should be empty but clear anyway.
      principalDisplayText.clear();
      principalDisplayText.write("0 = 0");
    } else {
      // The principal factor will always be a whole period integer
      // value when a fractional factor exists
      principalDisplayText.write(principalFactor.toInt());
    }

    final combinedDisplayText = StringBuffer();
    // 't', the number of full unit-periods from the beginning of the term
    // of the transaction to the nth cash flow value
    combinedDisplayText.write('[t = ${principalDisplayText.toString()}]');
    combinedDisplayText.write(' ');
    // 'f', the fraction of the unit-period in the time interval from the
    // beginning of the term of the transaction to the nth cash flow value
    combinedDisplayText.write('[f = ${fractionalDisplayText.toString()}]');
    return combinedDisplayText.toString();
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
    final principalDisplayText = StringBuffer();
    String principalOperands = '';

    // Handle standard log entries
    if (principalOperandLog.isNotEmpty) {
      for (int i = 0; i < principalOperandLog.length; i++) {
        final current = principalOperandLog[i];
        int count = 1;
        for (int j = i + 1; j < principalOperandLog.length; j++) {
          if (principalOperandLog[j] == current) {
            count++;
            i = j;
          } else {
            break;
          }
        }
        if (principalOperands.isEmpty) {
          principalOperands += count > 1 ? '$count' : current;
        } else {
          principalOperands += count > 1 ? ' + $count' : ' + $current';
        }
      }
      if (fractionalAdjustment == null) {
        principalDisplayText.write(principalOperands);
        principalDisplayText.write(' = ');
        principalDisplayText.write(
          gaussRound(principalFactor, 8).toStringAsFixed(8),
        );
        return principalDisplayText.toString();
      }
    }

    // Handle standard log entries which contain fractional log entries
    // i.e. USAppendixJ day count convention.
    // The fractional log is likely only to ever have a single entry, so
    // folding probably not required - simply append entry/entries for now.
    final fractionalDisplayText = StringBuffer();
    if (fractionalAdjustment != null && fractionalOperandLog != null) {
      if (fractionalOperandLog!.isNotEmpty) {
        for (int i = 0; i < fractionalOperandLog!.length; i++) {
          fractionalDisplayText.write(fractionalOperandLog![i]);
          if (i + 1 != fractionalOperandLog!.length) {
            fractionalDisplayText.write(" + ");
          }
        }
      } else {
        fractionalDisplayText.write("0");
      }
      fractionalDisplayText.write(" = ");
      fractionalDisplayText.write(
        gaussRound(fractionalAdjustment!, 8).toStringAsFixed(8),
      );
    }
    if (principalOperandLog.isEmpty) {
      // Will be if there are *only* fractional entries.
      // Buffer should be empty but clear anyway.
      principalDisplayText.clear();
      principalDisplayText.write("0");
    } else {
      // The principal factor will always be a whole period integer
      // value when a fractional factor exists
      principalDisplayText.write(principalFactor.toInt());
    }

    final combinedDisplayText = StringBuffer();
    // 't', the number of full unit-periods from the beginning of the term
    // of the transaction to the nth cash flow value
    combinedDisplayText.write('[t = ${principalDisplayText.toString()}]');
    combinedDisplayText.write(' ');
    // 'f', the fraction of the unit-period in the time interval from the
    // beginning of the term of the transaction to the nth cash flow value
    combinedDisplayText.write('[f = ${fractionalDisplayText.toString()}]');
    return combinedDisplayText.toString();
  }
}
