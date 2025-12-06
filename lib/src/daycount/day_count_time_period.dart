/// The period specifies the preferred interval to use in day count factor
/// calculations.
///
/// Options are:
/// - year
/// - half-year
/// - quarter
/// - month
/// - fortnight
/// - week
/// - day
///
enum DayCountTimePeriod {
  year(1),
  halfYear(2),
  quarter(4),
  month(12),
  fortnight(26),
  week(52),
  day(1);

  /// The denominator used in day count fraction calculations.
  final int periodsInYear;

  const DayCountTimePeriod(this.periodsInYear);
}
