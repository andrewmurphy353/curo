import '../profile/helper.dart';
import '../profile/profile.dart';
import 'solve_callback.dart';
import 'solve_nfv.dart';

/// Implementation of the function for finding an unknown cash flow value
/// or values.
///
class SolveCashFlow implements SolveCallback {
  late Profile _profile;
  final double effectiveRate;

  /// Provides an instance of the SolveCashFlow object
  ///
  /// [profile] containing the cash flow series
  ///
  /// [effectiveRate] annual interest rate
  ///
  SolveCashFlow({
    required Profile profile,
    required this.effectiveRate,
  }) {
    _profile = profile;
  }

  /// Implementation of the callback function to compute the unknown
  /// cash flow value/s where the cash flow value guess, compounded
  /// at the effective interest rate results in a net future value
  /// of zero.
  ///
  @override
  double compute(double guess) {
    _profile = _profile.copyWith(
      cashFlows: updateUnknowns(
        cashFlows: _profile.cashFlows,
        value: guess,
        precision: _profile.precision,
      ),
    );
    return SolveNfv(profile: _profile).compute(effectiveRate);
  }
}
