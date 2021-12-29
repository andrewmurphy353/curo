import 'package:curo/src/profile/cash_flow.dart';
import 'package:test/test.dart';

class MockCashFlow extends CashFlow {
  MockCashFlow({
    required DateTime postDate,
    DateTime? valueDate,
    double weighting = 1.0,
  }) : super(
          postDate: postDate,
          valueDate: valueDate ?? postDate,
          value: 0.0,
          isKnown: false,
          weighting: weighting,
          label: '',
        );
}

void main() {
  group('CashFlow constructor', () {
    test(
        'Exception expected when the cash flow value-date predates '
        'the post-date', () {
      expect(
        () => MockCashFlow(
          postDate: DateTime(2022, 2, 1),
          valueDate: DateTime(2022, 1, 1),
        ),
        throwsA(isA<Exception>()),
      );
    });
    test('Exception expected when the weighting value is less than 0', () {
      expect(
        () => MockCashFlow(
          postDate: DateTime.utc(2022, 1, 1),
          valueDate: DateTime.utc(2022, 1, 1),
          weighting: -2.0,
        ),
        throwsA(isA<Exception>()),
      );
    });
    test('Assigns the post date to the value date when undefined', () {
      final cf = MockCashFlow(
        postDate: DateTime.utc(2022, 1, 1),
      );
      expect(DateTime.utc(2022, 1, 1), cf.valueDate);
    });
  }, skip: false);
}
