import 'package:curo/src/calculator_helper.dart';
import 'package:curo/src/daycounts/convention.dart';
import 'package:curo/src/enums.dart';
import 'package:curo/src/series.dart';
import 'package:test/test.dart';

void main() {
  final d1 = DateTime.utc(2026, 1, 1);
  final d2 = DateTime.utc(2026, 2, 1);

  CashFlow cf({
    required CashFlowType type,
    required DateTime postDate,
    required DateTime valueDate,
    required double amount,
  }) =>
      (
        type: type,
        postDate: postDate,
        valueDate: valueDate,
        amount: amount,
        isKnown: true,
        weighting: 1.0,
        label: '',
        mode: Mode.arrear,
        isInterestCapitalised: null,
        isCharge: type == CashFlowType.charge,
      );

  group('sortCashFlows', () {
    test('sorts by date first (postDate when usePostDates=true)', () {
      final cashFlows = [
        cf(
            type: CashFlowType.payment,
            postDate: d2,
            valueDate: d2,
            amount: 100.0),
        cf(
            type: CashFlowType.advance,
            postDate: d1,
            valueDate: d1,
            amount: -1000.0),
      ];

      sortCashFlows(
          cashFlows: cashFlows, convention: const US30360(usePostDates: true));
      expect(cashFlows[0].postDate, d1);
      expect(cashFlows[1].postDate, d2);
    });

    test('within same date: advance > payment > charge', () {
      final cashFlows = [
        cf(
            type: CashFlowType.charge,
            postDate: d1,
            valueDate: d1,
            amount: 50.0),
        cf(
            type: CashFlowType.payment,
            postDate: d1,
            valueDate: d1,
            amount: 300.0),
        cf(
            type: CashFlowType.advance,
            postDate: d1,
            valueDate: d1,
            amount: -1000.0),
      ];

      sortCashFlows(cashFlows: cashFlows, convention: const US30360());
      expect(cashFlows.map((cf) => cf.type), [
        CashFlowType.advance,
        CashFlowType.payment,
        CashFlowType.charge,
      ]);
    });

    test('within same date and type: largest amount first', () {
      final cashFlows = [
        cf(
            type: CashFlowType.advance,
            postDate: d1,
            valueDate: d1,
            amount: -500.0),
        cf(
            type: CashFlowType.advance,
            postDate: d1,
            valueDate: d1,
            amount: -1500.0),
      ];
      sortCashFlows(cashFlows: cashFlows, convention: const US30360());
      expect(cashFlows.map((cf) => cf.amount), [-1500.0, -500.0]);
    });
  });
}
