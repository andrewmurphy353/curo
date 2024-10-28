import 'package:curo/src/profile/cash_flow.dart';
import 'package:curo/src/profile/cash_flow_advance.dart';
import 'package:curo/src/profile/cash_flow_payment.dart';
import 'package:curo/src/profile/validator.dart';
import 'package:curo/src/utilities/dates.dart';
import 'package:test/test.dart';

void main() {
  group('validatePrecision', () {
    test('returns true for supported precision of 2', () {
      expect(
        validatePrecision(2),
        true,
      );
    });
  });
  group('validateAdvances', () {
    test('throws an exception as no CashFlowAdvance object found', () {
      final cashFlows = <CashFlow>[
        CashFlowPayment(postDate: utcDate(DateTime.now())),
      ];
      expect(
        () => validateAdvances(cashFlows),
        throwsA(isA<Exception>()),
      );
    });
    test('returns single CashFlowAdvance object found', () {
      final cashFlows = <CashFlow>[
        CashFlowPayment(postDate: DateTime.utc(2022, 2, 1)),
        CashFlowAdvance(postDate: DateTime.utc(2022, 1, 1)),
      ];
      expect(
        // ignore: unnecessary_type_check
        validateAdvances(cashFlows) is CashFlowAdvance,
        true,
      );
    });
    test('returns earliest dated CashFlowAdvance object', () {
      final earliestDate = DateTime.utc(2022, 1, 1);
      final cashFlows = <CashFlow>[
        CashFlowPayment(postDate: DateTime.utc(2022, 2, 1)),
        CashFlowAdvance(postDate: DateTime.utc(2025, 12, 31)),
        CashFlowAdvance(postDate: DateTime.utc(2025, 12, 31)),
        CashFlowAdvance(postDate: DateTime.utc(2022, 11, 31)),
        CashFlowAdvance(
          postDate: earliestDate,
          valueDate: DateTime.utc(2022, 11, 31),
        ),
        // Has same post date as advance above but has an earlier
        // value date so this is the one expected to be returned
        CashFlowAdvance(postDate: earliestDate),
        CashFlowPayment(postDate: DateTime.utc(2022, 3, 1)),
      ];
      final cashFlowAdvance = validateAdvances(cashFlows);
      expect(
        // ignore: unnecessary_type_check
        cashFlowAdvance is CashFlowAdvance,
        true,
      );
      expect(
        cashFlowAdvance.postDate.isAtSameMomentAs(earliestDate),
        true,
      );
    });
  });
  group('validatePayments', () {
    test('throws an exception as no CashFlowPayment object found', () {
      final cashFlows = <CashFlow>[
        CashFlowAdvance(postDate: DateTime.utc(2022)),
      ];
      expect(
        () => validatePayments(cashFlows),
        throwsA(isA<Exception>()),
      );
    });
    test('returns true as at least one CashFlowPayment object found', () {
      final cashFlows = <CashFlow>[
        CashFlowAdvance(postDate: DateTime.utc(2022, 1, 1)),
        CashFlowPayment(postDate: DateTime.utc(2022, 2, 1)),
      ];
      expect(
        validatePayments(cashFlows),
        true,
      );
    });
  });
  group('validateUnknowns', () {
    test(
        'throws an exception as an unknown CashFlowPayment and '
        'unknown CashFlowAdvance were found', () {
      final cashFlows = <CashFlow>[
        CashFlowAdvance(postDate: DateTime.utc(2021), isKnown: false),
        CashFlowPayment(postDate: DateTime.utc(2021), isKnown: false),
      ];
      expect(
        () => validateUnknowns(cashFlows),
        throwsA(isA<Exception>()),
      );
    });
    test(
        'returns true for an unknown CashFlowPayment and '
        'known CashFlowAdvance value', () {
      final cashFlows = <CashFlow>[
        CashFlowAdvance(postDate: DateTime.utc(2021), value: 100.0),
        CashFlowPayment(postDate: DateTime.utc(2021), isKnown: false),
      ];
      expect(
        validateUnknowns(cashFlows),
        true,
      );
    });
    test(
        'returns true for an known CashFlowPayment and '
        'unknown CashFlowAdvance value', () {
      final cashFlows = <CashFlow>[
        CashFlowAdvance(postDate: DateTime.utc(2021), isKnown: false),
        CashFlowPayment(postDate: DateTime.utc(2021), value: 100.0),
      ];
      expect(
        validateUnknowns(cashFlows),
        true,
      );
    });
    test(
        'returns true for an known CashFlowPayment and '
        'known CashFlowAdvance value', () {
      final cashFlows = <CashFlow>[
        CashFlowAdvance(postDate: DateTime.utc(2021), value: 100.0),
        CashFlowPayment(postDate: DateTime.utc(2021), value: 100.0),
      ];
      expect(
        validateUnknowns(cashFlows),
        true,
      );
    });
  });
  group('validateIsInterestCapitalised', () {
    test(
        'throws an exception as the last '
        'CashFlowPayment.isInterestCapitalised() is false', () {
      final cashFlows = <CashFlow>[
        CashFlowPayment(postDate: DateTime.utc(2022, 2, 1)),
        CashFlowPayment(
          postDate: DateTime.utc(2022, 3, 1),
          isInterestCapitalised: false,
        ), // <-- oldest
        CashFlowPayment(postDate: DateTime.utc(2022, 1, 1)),
      ];
      expect(
        () => validateIsInterestCapitalised(cashFlows),
        throwsA(isA<Exception>()),
      );
    });
    test(
        'returns true as the final CashFlowPayment.isIntCapitalised() '
        'is set to true (by default)', () {
      final cashFlows = <CashFlow>[
        CashFlowPayment(
          postDate: DateTime.utc(2022, 2, 1),
          isInterestCapitalised: false,
        ),
        CashFlowPayment(postDate: DateTime.utc(2022, 3, 1)), // <-- oldest
        CashFlowPayment(
          postDate: DateTime.utc(2022, 1, 1),
          isInterestCapitalised: false,
        ),
      ];
      expect(
        validateIsInterestCapitalised(cashFlows),
        true,
      );
    });
    test(
        'returns true where two CashFlowPayment\'s share same final date, '
        'one with isInterestCapitalised() true the other false', () {
      final cashFlows = <CashFlow>[
        CashFlowPayment(
          postDate: DateTime.utc(2022, 2, 1),
        ),
        CashFlowPayment(
          postDate: DateTime.utc(2022, 3, 1),
        ), // <-- oldest
        CashFlowPayment(
          postDate: DateTime.utc(2022, 1, 1),
        ),
        CashFlowPayment(
          postDate: DateTime.utc(2022, 3, 1),
          isInterestCapitalised: false,
        ), // <-- oldest
      ];
      expect(
        validateIsInterestCapitalised(cashFlows),
        true,
      );
    });
  });
}
