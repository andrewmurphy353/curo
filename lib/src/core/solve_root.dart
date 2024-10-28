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
    double offset;
    double f0;
    double fp;
    double fm;
    double g0;

    int countIter = 0;
    do {
      offset = guess.abs() > 1.0 ? 0.01 * guess : 0.01;
      f0 = callback.compute(guess);
      fp = callback.compute(guess + offset);
      fm = callback.compute(guess - offset);
      g0 = (2.0 * offset * f0) / (fp - fm);
      guess -= g0;
    } while (++countIter < maxIterations && g0.abs() > tolerance);

    if (countIter >= maxIterations || guess.isNaN) {
      throw UnsolvableException('Unable to solve ${callback.runtimeType} '
          'within a maximum $maxIterations attempts.');
    }

    return guess;
  }

  static const int maxIterations = 50;

  /// The tolerance used to determine convergence
  static const double tolerance = 1.0e-7;
}
