import 'solve_callback.dart';
import 'unsolvable_exception.dart';

/// Implementation of the function for finding unknown roots.
///
/// This is an enhanced and more efficient implementation
/// of the Newton-Raphson method, first outlined by NC Shammas
/// in 'Enhancing Newton's Method' (Dr Dobbs Journal, June 2002).
///
class SolveRoot {
  /// Solves for the unknown root using the Enhanced Newton-Raphson method.
  ///
  /// [callback] to a root function implementation
  /// [guess] initial guess (optional)
  ///
  static double solve({required SolveCallback callback, double guess = 0.1}) {
    double offset;
    double f0;
    double fp;
    double fm;
    double deriv1;
    double deriv2;
    double g0;
    double g1;
    double g2;

    int countIter = 0;
    do {
      offset = guess.abs() > 1.0 ? 0.01 * guess : 0.01;

      // Compute function values at x, x+offset, and x-offset
      f0 = callback.compute(guess);
      fp = callback.compute(guess + offset);
      fm = callback.compute(guess - offset);

      // Calculate first and second derivatives
      deriv1 = (fp - fm) / (2 * offset);
      deriv2 = (fp - 2 * f0 + fm) / (offset * offset);

      // Calculate 1st guess
      g0 = guess - f0 / deriv1;

      // Calculate refinement of guess
      g1 = guess - f0 / (deriv1 + (deriv2 * (g0 - guess)) / 2);

      // Calculate guess update
      g2 = f0 / (deriv1 + (deriv2 * (g1 - guess)) / 2);
      guess -= g2;
    } while (++countIter < maxIterations && g2.abs() > tolerance);

    if (countIter >= maxIterations || guess.isNaN) {
      throw UnsolvableException('Unable to solve ${callback.runtimeType} '
          'within a maximum $maxIterations attempts.');
    }

    return guess;
  }

  static const int maxIterations = 50;

  /// The tolerance used to determine convergence */
  static const double tolerance = 1.0e-7;
}
