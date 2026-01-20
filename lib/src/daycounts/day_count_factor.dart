import 'package:curo/src/utils.dart';

/// Represents the result of a day count convention calculation used in
/// financial discount formulas.
///
/// Stores the primary year fraction (`t`) used in all conventions, and for US
/// Appendix J, an optional fractional period (`f`). Includes operand logs for
/// calculation proofs (e.g., demonstrating APR or XIRR derivations).
///
/// Supports two discount formula types:
/// - Standard: `d = a × (1 + i)^(-t)`
/// - US Appendix J: `d = a / ((1 + f * i / p) * (1 + i / p)^t)`
///
/// Only one of [discountFactorLog] or [discountTermsLog] should be non-empty.
///
class DayCountFactor {
  final double primaryPeriodFraction;
  final double? partialPeriodFraction;

  /// Log entries for standard conventions, e.g., \["f = 31/360 = 0.08611111"]
  final List<String> discountFactorLog;

  /// Log entries for US Appendix J, e.g., \["t = 1", "f = 5/30 = 0.16666667", "p = 12"]
  final List<String> discountTermsLog;

  const DayCountFactor({
    required this.primaryPeriodFraction,
    this.partialPeriodFraction,
    List<String>? discountFactorLog,
    List<String>? discountTermsLog,
  }) : discountFactorLog = discountFactorLog ?? const [],
       discountTermsLog = discountTermsLog ?? const [];

  /// Static helper to format numerator/denominator as whole + fractional periods.
  ///
  static String operandsToString(int numerator, int denominator) {
    if (denominator == 0) return numerator.toString();

    final whole = numerator ~/ denominator;
    final remainder = numerator % denominator;

    if (whole == 0 && remainder != 0) {
      return '$remainder/$denominator';
    } else if (remainder == 0) {
      return whole.toString();
    } else {
      return '$whole + $remainder/$denominator';
    }
  }

  /// Standard string representation, rounded to 8 decimals.
  ///
  /// Examples:
  /// - Standard: "f = 31/360 = 0.08611111"
  /// - US Appendix J: "t = 1 : f = 5/30 = 0.16666667 : p = 12"
  ///
  @override
  String toString() {
    if (discountTermsLog.isNotEmpty && discountFactorLog.isNotEmpty) {
      throw StateError(
        'Mix of discount terms and discount factor '
        'log entries not supported',
      );
    }

    if (discountTermsLog.isNotEmpty) {
      return discountTermsLog.join(' : ');
    }

    if (discountFactorLog.isEmpty) {
      return '0';
    }

    // Extract just the operand part (before any "=")
    final operands = discountFactorLog
        .map((e) => e.split(' = ').first.trim())
        .toList();
    final operandText = operands.join(' + ');
    final rounded = gaussRound(primaryPeriodFraction, 8).toStringAsFixed(8);

    return 'f = $operandText = $rounded';
  }

  /// Compressed representation that folds repeated or simplifiable operands.
  ///
  /// Whole periods (e.g., "365/365") become integers, and identical fractions
  /// are counted (e.g., "366/366" + "365/365" -> "2").
  ///
  String toFoldedString() {
    if (discountTermsLog.isNotEmpty && discountFactorLog.isNotEmpty) {
      throw StateError(
        'Mix of discount terms and discount factor '
        'log entries not supported',
      );
    }

    if (discountTermsLog.isNotEmpty) {
      return discountTermsLog.join(' : ');
    }

    if (discountFactorLog.isEmpty) {
      return '0';
    }

    // Group and count identical simplified operands
    final operandCount = <String, int>{};
    for (final entry in discountFactorLog) {
      var operand = entry.split(' = ').first.trim();
      final parts = operand.split(' + ').map((p) => p.trim()).toList();

      final simplifiedParts = parts.map((part) {
        if (part.contains('/')) {
          final nums = part.split('/').map(int.parse).toList();
          return operandsToString(nums[0], nums[1]);
        }
        return part;
      }).toList();

      operand = simplifiedParts.join(' + ');
      operandCount[operand] = (operandCount[operand] ?? 0) + 1;
    }

    final foldedParts = operandCount.entries.map((e) {
      final count = e.value;
      final operand = e.key;
      return count > 1 ? '$count' : operand;
    }).toList();

    final operandText = foldedParts.join(' + ');
    final rounded = gaussRound(primaryPeriodFraction, 8).toStringAsFixed(8);

    return 'f = $operandText = $rounded';
  }
}
