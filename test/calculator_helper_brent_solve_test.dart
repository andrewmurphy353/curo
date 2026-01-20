import 'dart:math';

import 'package:curo/src/calculator_helper.dart';
import 'package:curo/src/exceptions.dart';
import 'package:test/test.dart';

void main() {
  group('brentSolve', () {
    test('finds root of simple linear function', () {
      final root = brentSolve(
        f: (x) => x - 5.0,
        a: 0.0,
        b: 10.0,
        tolerance: 1e-10,
        maxIterations: 100,
      );
      expect(root, closeTo(5.0, 1e-10));
    });

    test('solves cubic equation x³ - x - 2 = 0', () {
      final root = brentSolve(
        f: (x) => x * x * x - x - 2.0,
        a: 1.0,
        b: 2.0,
        tolerance: 1e-12,
      );
      expect(root, closeTo(1.5213797068045674, 1e-10));
    });

    test('throws when no root in interval (same sign)', () {
      expect(
        () => brentSolve(f: (x) => x * x + 1, a: -1.0, b: 1.0),
        throwsA(isA<UnsolvableException>()),
      );
    });

    test('converges quickly on well-behaved function', () {
      var evalCount = 0;
      brentSolve(
        f: (x) {
          evalCount++;
          return x - 3.0;
        },
        a: 0.0,
        b: 10.0,
      );
      expect(evalCount, lessThan(20)); // Brent is efficient
    });

    test('throws when solver does not converge within 100 iterations', () {
      expect(
        () => brentSolve(f: (x) => sin(1 / x), a: -1.0, b: 1.0),
        throwsA(isA<UnsolvableException>()),
      );
    });
  });
}
