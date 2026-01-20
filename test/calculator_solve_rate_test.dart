import 'package:curo/src/calculator.dart';
import 'package:test/test.dart';

void main() {
  late Calculator calculator;
  final startDate = DateTime.utc(2022, 1, 1);
  final date2 = DateTime.utc(2022, 2, 1);
  final date3 = DateTime.utc(2022, 3, 1);
  final date4 = DateTime.utc(2022, 4, 1);

  setUp(() {
    calculator = Calculator(precision: 2);
  });

  test('solve_rate regular drawdown ~19.71% with charges included', () async {
    const convention = US30360(
      includeNonFinancingFlows: true,
      useXirrMethod: true,
    );

    calculator
      ..add(SeriesAdvance(postDateFrom: startDate, amount: 1000.0))
      ..add(SeriesCharge(postDateFrom: startDate, amount: 10.0))
      ..add(SeriesPayment(postDateFrom: date2, amount: 340.02))
      ..add(SeriesPayment(postDateFrom: date3, amount: 340.02))
      ..add(SeriesPayment(postDateFrom: date4, amount: 340.02));

    final rate = await calculator.solveRate(
      convention: convention,
      upperBound: 10.0,
    );

    expect(rate, closeTo(0.19712195, 1e-8));
  });

  test('solve_rate USAppendixJ annualization', () async {
    const convention = USAppendixJ();

    calculator
      ..add(SeriesAdvance(postDateFrom: startDate, amount: 1000.0))
      ..add(SeriesPayment(postDateFrom: date2, amount: 340.02))
      ..add(SeriesPayment(postDateFrom: date3, amount: 340.02))
      ..add(SeriesPayment(postDateFrom: date4, amount: 340.02));

    final rate = await calculator.solveRate(
      convention: convention,
      upperBound: 10.0,
    );

    expect(rate, closeTo(0.11996224, 1e-8));
  });

  test('solve_rate empty series throws', () {
    expect(
      () => calculator.solveRate(convention: const US30360()),
      throwsA(isA<DeveloperException>()),
    );
  });

  test('solve_rate invalid upper bound throws', () {
    calculator.add(SeriesAdvance(amount: 1000.0));
    calculator.add(SeriesPayment(amount: 1100.0));

    expect(
      () => calculator.solveRate(convention: const US30360(), upperBound: 0.0),
      throwsA(isA<DeveloperException>()),
    );
  });

  test('solve_rate no solution throws UnsolvableError', () {
    calculator
      ..add(SeriesAdvance(postDateFrom: startDate, amount: 1000.0))
      ..add(SeriesPayment(postDateFrom: date2, amount: 0.01));

    expect(
      () => calculator.solveRate(convention: const US30360(), upperBound: 10.0),
      throwsA(isA<UnsolvableException>()),
    );
  });
}
