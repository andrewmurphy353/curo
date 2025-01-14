import 'package:curo/src/daycount/act_isda.dart';
import 'package:curo/src/daycount/day_count_origin.dart';
import 'package:test/test.dart';

void main() {
  group('ActISDA.computeFactor', () {
    const dc = ActISDA();
    test('28/01/2020 to 28/02/2020', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2020, 1, 28),
        DateTime.utc(2020, 2, 28),
      );
      expect(dcf.factor, 0.08469945355191257);
      expect(dcf.toString(), '(31/366) = 0.08469945');
    });
    test('28/01/2019 to 28/02/2019', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2019, 1, 28),
        DateTime.utc(2019, 2, 28),
      );
      expect(dcf.factor, 0.08493150684931507);
      expect(dcf.toString(), '(31/365) = 0.08493151');
    });
    test('31/12/2017 to 31/12/2019', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2017, 12, 31),
        DateTime.utc(2019, 12, 31),
      );
      expect(dcf.factor, 2.0);
      expect(dcf.toString(), '(730/365) = 2.00000000');
    });
    test('31/12/2018 to 31/12/2020', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2018, 12, 31),
        DateTime.utc(2020, 12, 31),
      );
      expect(dcf.factor, 2.0);
      expect(dcf.toString(), '(365/365) + (366/366) = 2.00000000');
    });
    test('30/06/2019 to 30/06/2021', () {
      final dcf = dc.computeFactor(
        DateTime.utc(2019, 6, 30),
        DateTime.utc(2021, 6, 30),
      );
      expect(dcf.factor, 2.0);
      expect(dcf.toString(), '(184/365) + (366/366) + (181/365) = 2.00000000');
    });
  });
  group('ActISDA default instance', () {
    const dc = ActISDA();
    test('dayCountMethod() to return "neighbour"', () {
      expect(dc.dayCountOrigin(), DayCountOrigin.neighbour);
    });
    test('usePostDates() to return "true"', () {
      expect(dc.usePostDates, true);
    });
    test('includeNonFinancingFlows() to return "false"', () {
      expect(dc.includeNonFinancingFlows, false);
    });
  });
  group('ActISDA useXirrMethod', () {
    const dc = ActISDA(useXirrMethod: true);
    test('dayCountMethod() to return "drawdown"', () {
      expect(dc.dayCountOrigin(), DayCountOrigin.drawdown);
    });
  });
}

// describe("ActISDA(undefine, undefined, true|false) - IRR | XIRR", () => {
//   const dummyCFs: CashFlow[] = [];
//   dummyCFs.push(
//     new CashFlowAdvance(new Date(2020, 0, 1), new Date(2020, 0, 1), 1000.0)
//   );
//   dummyCFs.push(new CashFlowPayment(new Date(2020, 1, 1), 172.55));
//   dummyCFs.push(new CashFlowPayment(new Date(2020, 2, 1), 172.55));
//   dummyCFs.push(new CashFlowPayment(new Date(2020, 3, 1), 172.55));
//   dummyCFs.push(new CashFlowPayment(new Date(2020, 4, 1), 172.55));
//   dummyCFs.push(new CashFlowPayment(new Date(2020, 5, 1), 172.55));
//   dummyCFs.push(new CashFlowPayment(new Date(2020, 6, 1), 172.55));
//   const dummyProfile = new Profile(dummyCFs, 2);

//   const calc = new Calculator(2, dummyProfile);

//   it("IRR should return 0.120692 (decimal)", () => {
//     assert.approximately(
//       calc.solveRate(new ActISDA()),
//       0.120692,
//       0.0000005);
//   });

//   it("XIRR should return 0.127601 (decimal)", () => {
//     assert.approximately(
//       calc.solveRate(new ActISDA(undefined, undefined, true)),
//       0.127601,
//       0.0000005
//     );
//   });
// });
