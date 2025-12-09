import 'solve_callback.dart';
import 'unsolvable_exception.dart';

class SolveRoot {
  ///
  /// Solves for the unknown root using the Newton-Raphson method.
  ///
  /// [callback] to a root function implementation
  ///
  /// [guess] initial guess (optional)
  ///
  static double solve({
    required SolveCallback callback,
    double guess = 0.1,
  }) {
    try {
      // Try original Newton-Raphson
      return _newtonRaphson(callback: callback, guess: guess);
    } catch (e) {
      // Fallback to bisection
      try {
        return _bisection(callback: callback, initialGuess: guess);
      } catch (e) {
        throw UnsolvableException(
            'Unable to solve ${callback.runtimeType} with Newton-Raphson '
            'or bisection. Last error: $e');
      }
    }
  }

  static double _newtonRaphson({
    required SolveCallback callback,
    required double guess,
  }) {
    double offset;
    double f0;
    double fp;
    double fm;
    double g0;
    double currentGuess = guess;
    int countIter = 0;

    do {
      offset = currentGuess.abs() > 1.0 ? 0.01 * currentGuess : 0.01;
      f0 = callback.compute(currentGuess);
      fp = callback.compute(currentGuess + offset);
      fm = callback.compute(currentGuess - offset);
      g0 = (2.0 * offset * f0) / (fp - fm);
      currentGuess -= g0;
    } while (++countIter < maxIterations && g0.abs() > tolerance);

    if (countIter >= maxIterations || currentGuess.isNaN) {
      throw UnsolvableException('Unable to solve ${callback.runtimeType} '
          'within a maximum $maxIterations attempts. '
          'Final guess: $currentGuess');
    }

    return currentGuess;
  }

  static double _bisection({
    required SolveCallback callback,
    required double initialGuess,
  }) {
    // Initialize bracket around initialGuess
    final guess = initialGuess == 0.0 ? 0.1 : initialGuess; // Avoid zero guess
    double a = guess > 0 ? guess / 10 : guess * 10; // Lower bound
    double b = guess > 0 ? guess * 10 : guess / 10; // Upper bound
    double fa = callback.compute(a);
    double fb = callback.compute(b);
    int bracketAttempts = 0;
    const int maxBracketAttempts = 5; // Limit bracket searches

    // Expand or adjust bracket until a sign change is found
    while (fa * fb >= 0 && bracketAttempts < maxBracketAttempts) {
      // No sign change: expand bracket
      if (guess > 0) {
        a = a / 10; // Smaller values
        b = b * 10; // Larger values
      } else {
        a = a * 10; // Larger (less negative)
        b = b / 10; // Smaller (more negative)
      }
      // Ensure a < b
      if (a > b) {
        final temp = a;
        a = b;
        b = temp;
        fa = callback.compute(a);
        fb = callback.compute(b);
      } else {
        fa = callback.compute(a);
        fb = callback.compute(b);
      }

      // Handle edge cases: try negative or zero
      if (fa * fb >= 0 && bracketAttempts == maxBracketAttempts - 1) {
        // Last attempt: try a wide bracket including negative values
        a = -1e6; // Large negative for cash flows
        b = 1e6; // Large positive for cash flows
        fa = callback.compute(a);
        fb = callback.compute(b);
      }

      bracketAttempts++;
    }

    if (fa * fb >= 0) {
      throw UnsolvableException(
          'No root found in brackets [$a, $b] for ${callback.runtimeType}. '
          'f($a) = $fa, f($b) = $fb');
    }

    // Bisection loop
    int countIter = 0;
    double c = 0;
    double fc = 0;

    while (countIter < maxIterations) {
      c = (a + b) / 2;
      fc = callback.compute(c);

      if (fc.abs() < tolerance || (b - a) / 2 < tolerance) {
        if (c.isNaN) {
          throw UnsolvableException('Bisection produced NaN at x = $c');
        }
        return c;
      }

      if (fc * fa < 0) {
        b = c;
        fb = fc;
      } else {
        a = c;
        fa = fc;
      }

      countIter++;
    }

    throw UnsolvableException(
        'Bisection failed to converge within $maxIterations '
        'iterations for ${callback.runtimeType}. '
        'Final interval: [$a, $b], f($c) = $fc');
  }

  static const int maxIterations = 50;
  static const double tolerance = 1.0e-7;
}
