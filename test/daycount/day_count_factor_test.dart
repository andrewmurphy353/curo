import 'package:curo/src/daycount/day_count_factor.dart';
import 'package:test/test.dart';

void main() {
  group('DayCountFactor toString() && toFoldedString()', () {
    test('operandLog[\'(2/365)\',\'(365/365)\',\'(366/366)\',\'(31/365)\']',
        () {
      final operandLog = ['(2/365)', '(365/365)', '(366/366)', '(31/365)'];
      final dayCountFactors = DayCountFactor(2.09041096, operandLog);
      expect(dayCountFactors.toString(),
          '(2/365) + (365/365) + (366/366) + (31/365) = 2.09041096');
      expect(dayCountFactors.toFoldedString(),
          '(2/365) + (365/365) + (366/366) + (31/365) = 2.09041096');
    });
    test('operandLog[\'(2/366)\',\'(365/365)\',\'(365/365)\',\'(31/365)\']',
        () {
      final operandLog = ['(2/366)', '(365/365)', '(365/365)', '(31/365)'];
      final dayCountFactors = DayCountFactor(2.09039599, operandLog);
      expect(dayCountFactors.toString(),
          '(2/366) + (365/365) + (365/365) + (31/365) = 2.09039599');
      expect(dayCountFactors.toFoldedString(),
          '(2/366) + 2(365/365) + (31/365) = 2.09039599');
    });
    test('operandLog[\'(2/366)\',\'(365/365)\',\'(365/365)\',\'(365/365)\']',
        () {
      final operandLog = ['(2/366)', '(365/365)', '(365/365)', '(365/365)'];
      final dayCountFactors = DayCountFactor(3.00546448, operandLog);
      expect(dayCountFactors.toString(),
          '(2/366) + (365/365) + (365/365) + (365/365) = 3.00546448');
      expect(dayCountFactors.toFoldedString(),
          '(2/366) + 3(365/365) = 3.00546448');
    });
    test('operandLog[\'(365/365)\',\'(365/365)\',\'(365/365)\',\'(365/365)\']',
        () {
      final operandLog = ['(365/365)', '(365/365)', '(365/365)', '(365/365)'];
      final dayCountFactors = DayCountFactor(4.0, operandLog);
      expect(dayCountFactors.toString(),
          '(365/365) + (365/365) + (365/365) + (365/365) = 4.00000000');
      expect(dayCountFactors.toFoldedString(), '4(365/365) = 4.00000000');
    });
  });
}
