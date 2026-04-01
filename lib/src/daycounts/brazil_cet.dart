import 'package:curo/src/daycounts/convention.dart';
import 'package:curo/src/utils.dart';

/// Implements the Brazilian **Custo Efetivo Total (CET)** day count convention
/// per **Resolução CMN nº 4.881/2020, Art. 4**.
///
/// This is a pure **Actual/365 Fixed** convention:
/// - Actual calendar days (**dias corridos**) from initial drawdown (d₀) to each
///   cash flow (dⱼ).
/// - Fixed denominator of **365** (even in leap years).
/// - Used with `useXirrMethod: true` and `includeNonFinancingFlows: true` to
///   solve the effective annual rate via the official IRR formula:
///
///   FC₀ = Σ [FCⱼ / (1 + CET)^((dⱼ - d₀)/365)]
///
/// Special regulatory notes (handled at application level if needed):
/// - Revolving/rotativo operations: fixed 30-day term + full credit limit.
/// - CET must be rounded to exactly **two decimal places** using ABNT NBR 5891.
///
/// See: https://www.bcb.gov.br/content/estabilidadefinanceira/especialnor/Resolu%C3%A7%C3%A3o4881.pdf
///
class BrazilCet extends Convention {
  /// Creates the Brazilian CET day count convention.
  const BrazilCet()
      : super(
          usePostDates: true,
          includeNonFinancingFlows: true,
          useXirrMethod: true,
        );

  @override
  DayCountFactor computeFactor(DateTime start, DateTime end) {
    if (end.isBefore(start)) {
      throw ArgumentError('end must not be before start');
    }

    final days = actualDays(start, end);

    final factor = days / 365.0;

    return DayCountFactor(
      primaryPeriodFraction: factor,
      discountFactorLog: days > 0 ? ['$days/365'] : ['0/365'],
    );
  }
}
