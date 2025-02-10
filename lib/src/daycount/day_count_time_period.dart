/// The period specifies the preferred interval to use in day count factor
/// calculations.
///
/// Options are:
/// - year
/// - month
/// - week
///
enum DayCountTimePeriod {
  year(1),
  month(12),
  week(52);

  /// The denominator used in day count fraction calculations.
  final int periodsInYear;

  const DayCountTimePeriod(this.periodsInYear);
}
