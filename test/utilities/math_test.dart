import 'package:curo/src/utilities/math.dart';
import 'package:test/test.dart';

void main() {
  test('gaussRound', () {
    expect(gaussRound(1.5), 2.0);
    expect(gaussRound(2.5), 2.0);
    expect(gaussRound(1.535, 2), 1.54);
    expect(gaussRound(1.525, 2), 1.52);
    expect(gaussRound(0.4), 0.0);
    expect(gaussRound(0.5), 0.0);
    expect(gaussRound(0.6), 1.0);
    expect(gaussRound(1.4), 1.0);
    expect(gaussRound(1.6), 2.0);
    expect(gaussRound(23.5), 24.0);
    expect(gaussRound(24.5), 24.0);
    expect(gaussRound(-23.5), -24.0);
    expect(gaussRound(-24.5), -24.0);
  });
}
