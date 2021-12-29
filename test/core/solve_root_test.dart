import 'package:curo/src/core/solve_callback.dart';
import 'package:curo/src/core/solve_root.dart';
import 'package:test/test.dart';

class MockUnsolvable implements SolveCallback {
  @override
  double compute(double guess) => 0.0;
}

class MockSolveRoot implements SolveCallback {
  @override
  double compute(double guess) =>
      (guess + 15) * (guess + 10) * (guess + 20) * (guess - 4.5);
}

void main() {
  test('Throws error when unable to solve root in max iterations', () {
    expect(
      () => SolveRoot.solve(callback: MockUnsolvable()),
      throwsA(isA<Exception>()),
    );
  });
  test(
      'Solving for the root of function '
      '(x + 15) * (x + 10) * (x + 20) * (x - 4.5)', () {
    expect(
      double.parse(
        SolveRoot.solve(callback: MockSolveRoot()).toStringAsFixed(1),
      ),
      4.5,
    );
  });
}
