import 'package:curo/src/calculator.dart';
import 'package:curo/src/calculator_helper.dart';
import 'package:test/test.dart';

class MockConvention extends Convention {
  final List<(DateTime, DateTime, DayCountFactor)> calls = [];

  MockConvention({
    super.usePostDates = false,
    super.includeNonFinancingFlows = false,
    super.useXirrMethod = false,
  });

  @override
  DayCountFactor computeFactor(DateTime start, DateTime end) {
    final days = end.difference(start).inDays;
    final fraction = days / 365.0;
    final factor = DayCountFactor(
      primaryPeriodFraction: fraction,
      discountFactorLog: ['$days/365 = ${gaussRound(fraction, 8)}'],
    );
    calls.add((start, end, factor));
    return factor;
  }
}

void main() {
  final startDate = DateTime.utc(2026, 1, 1);
  final date2 = DateTime.utc(2026, 2, 1);
  //final date3 = DateTime.utc(2026, 3, 1);

  List<CashFlow> buildTestProfile(
      List<Series> series, Convention mockConvention) {
    return buildProfile(
      convention: mockConvention,
      series: series,
      startDate: startDate,
    );
  }

  group('assignFactors - Neighbour mode', () {
    test('first cashflow gets factor 0.0', () {
      final convention = MockConvention(usePostDates: true);
      final profile = buildTestProfile([
        SeriesAdvance(postDateFrom: startDate, amount: 1000.0),
      ], convention);

      final result = assignFactors(profile: profile, convention: convention);
      expect(result.length, 1);
      expect(result[0].factor.primaryPeriodFraction, 0.0);
      expect(convention.calls.length, 1);
      expect(convention.calls[0].$1, startDate);
      expect(convention.calls[0].$2, startDate);
      final expected =
          'CashFlowWithFactor(cashFlow: (amount: -1000.0, isInterestCapitalised: null, isKnown: true, label: , mode: Mode.advance, postDate: 2026-01-01 00:00:00.000Z, type: CashFlowType.advance, valueDate: 2026-01-01 00:00:00.000Z, weighting: 1.0), factor: t = 0/365 = 0.00000000)';
      expect(result[0].toString(), expected);
    });

    test('charges do not advance the period', () {
      final convention =
          MockConvention(usePostDates: true, includeNonFinancingFlows: true);
      final profile = buildTestProfile([
        SeriesAdvance(postDateFrom: startDate, amount: 1000.0),
        SeriesCharge(postDateFrom: startDate, amount: 10.0),
        SeriesPayment(postDateFrom: date2, amount: 1050.0),
      ], convention);

      final result = assignFactors(profile: profile, convention: convention);
      expect(result.map((r) => r.factor.primaryPeriodFraction), [
        0.0,
        0.0,
        closeTo(31 / 365.0, 1e-10),
      ]);
    });

    test('charges included when includeNonFinancingFlows: false', () {
      const convention = US30360(usePostDates: true);
      final profile = buildTestProfile([
        SeriesAdvance(postDateFrom: startDate, amount: 1000.0),
        SeriesCharge(postDateFrom: startDate, amount: 10.0),
        SeriesPayment(postDateFrom: date2, amount: 1050.0),
      ], convention);

      final result = assignFactors(profile: profile, convention: convention);
      expect(result[0].factor.primaryPeriodFraction, 0.0);
      expect(result[1].factor.primaryPeriodFraction, 0.0);
      expect(
        result[2].factor.primaryPeriodFraction,
        closeTo(30 / 360.0, 1e-10),
      );
    });
  });

  group('assignFactors - Drawdown/XIRR mode', () {
    test('all factors from earliest advance', () {
      final convention = MockConvention(
        usePostDates: true,
        useXirrMethod: true,
      );
      final profile = buildTestProfile([
        SeriesAdvance(postDateFrom: startDate, amount: 1000.0),
        SeriesPayment(postDateFrom: date2, amount: 1050.0),
      ], convention);

      assignFactors(profile: profile, convention: convention);

      expect(convention.calls[0].$1, startDate); // from drawdown
      expect(convention.calls[0].$2, startDate); // to first
      expect(convention.calls[1].$1, startDate);
      expect(convention.calls[1].$2, date2);
    });

    test('multiple advances same date', () {
      final convention = MockConvention(usePostDates: true);
      final profile = buildTestProfile([
        SeriesAdvance(postDateFrom: startDate, amount: 600.0),
        SeriesAdvance(
          postDateFrom: startDate,
          valueDateFrom: startDate.add(const Duration(days: 15)),
          amount: 400.0,
        ),
        SeriesPayment(postDateFrom: date2, amount: 1000.0),
      ], convention);

      final result = assignFactors(profile: profile, convention: convention);

      expect(result.map((r) => r.factor.primaryPeriodFraction), [
        0.0,
        0.0,
        closeTo(31 / 365.0, 1e-10),
      ]);
    });
  });
}
