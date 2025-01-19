import 'package:curo/src/daycount/day_count_factor.dart';
import 'package:test/test.dart';

void main() {
  group('DayCountFactor toString() && toFoldedString()', () {
    test('operandLog[\'(2/365)\',\'1\',\'1\',\'(31/365)\']', () {
      final operandLog = ['(2/365)', '1', '1', '(31/365)'];
      final dayCountFactors = DayCountFactor(2.09041096, operandLog);
      expect(dayCountFactors.toString(),
          '(2/365) + 1 + 1 + (31/365) = 2.09041096');
      expect(dayCountFactors.toFoldedString(),
          '(2/365) + 2 + (31/365) = 2.09041096');
    });
    test('operandLog[\'(2/366)\',\'1\',\'1\',\'(31/365)\']', () {
      final operandLog = ['(2/366)', '1', '1', '(31/365)'];
      final dayCountFactors = DayCountFactor(2.09039599, operandLog);
      expect(dayCountFactors.toString(),
          '(2/366) + 1 + 1 + (31/365) = 2.09039599');
      expect(dayCountFactors.toFoldedString(),
          '(2/366) + 2 + (31/365) = 2.09039599');
    });
    test('operandLog[\'(2/366)\',\'1\',\'1\',\'1\']', () {
      final operandLog = ['(2/366)', '1', '1', '1'];
      final dayCountFactors = DayCountFactor(3.00546448, operandLog);
      expect(dayCountFactors.toString(), '(2/366) + 1 + 1 + 1 = 3.00546448');
      expect(dayCountFactors.toFoldedString(), '(2/366) + 3 = 3.00546448');
    });
    test('operandLog[\'1\',\'1\',\'1\',\'1\']', () {
      final operandLog = ['1', '1', '1', '1'];
      final dayCountFactors = DayCountFactor(4.0, operandLog);
      expect(dayCountFactors.toString(), '1 + 1 + 1 + 1 = 4.00000000');
      expect(dayCountFactors.toFoldedString(), '4 = 4.00000000');
    });
  });
}
