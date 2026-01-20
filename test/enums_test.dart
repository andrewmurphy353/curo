import 'package:curo/src/enums.dart';
import 'package:test/test.dart';

void main() {
  test('frequency offsetAlias', () {
    expect(Frequency.values.length, 6);
  });
  test('mode values', () {
    expect(Mode.values.length, 2);
  });
  test('dayCountTimePeriod periodsInYear', () {
    expect(DayCountTimePeriod.day.periodsInYear, 365);
    expect(DayCountTimePeriod.week.periodsInYear, 52);
    expect(DayCountTimePeriod.fortnight.periodsInYear, 26);
    expect(DayCountTimePeriod.month.periodsInYear, 12);
    expect(DayCountTimePeriod.quarter.periodsInYear, 4);
    expect(DayCountTimePeriod.halfYear.periodsInYear, 2);
    expect(DayCountTimePeriod.year.periodsInYear, 1);
    expect(DayCountTimePeriod.values.length, 7);
  });
  test('dayCountOrigin values', () {
    expect(DayCountOrigin.drawdown.name, 'drawdown');
    expect(DayCountOrigin.neighbour.name, 'neighbour');
    expect(DayCountOrigin.values.length, 2);
  });
  test('validationMode values', () {
    expect(ValidationMode.values.length, 2);
  });
}
