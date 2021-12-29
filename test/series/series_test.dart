import 'package:curo/src/series/series_advance.dart';
import 'package:test/test.dart';

void main() {
  group('Series constructor', () {
    test('throws exception when numberOf < 1', () {
      expect(
        () => SeriesAdvance(numberOf: -1),
        throwsA(isA<Exception>()),
      );
    });
    test('throws exception when weighting < 1', () {
      expect(
        () => SeriesAdvance(weighting: 0),
        throwsA(isA<Exception>()),
      );
    });
    test(
        'throws exception when valueDateFrom is defined '
        'without a postDateFrom date', () {
      expect(
        () => SeriesAdvance(
          valueDateFrom: DateTime.now(),
        ),
        throwsA(isA<Exception>()),
      );
    });
    test(
        'throws exception when valueDateFrom occurs before '
        'postDateFrom date', () {
      expect(
        () => SeriesAdvance(
          postDateFrom: DateTime.utc(2022, 1, 2),
          valueDateFrom: DateTime.utc(2022, 1, 1),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
