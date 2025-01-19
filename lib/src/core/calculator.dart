import '../daycount/convention.dart';
import '../profile/helper.dart';
import '../profile/profile.dart';
import '../series/series.dart';
import '../series/series_advance.dart';
import '../series/series_charge.dart';
import '../series/series_payment.dart';
import '../utilities/dates.dart';
import '../utilities/math.dart';
import 'solve_cashflow.dart';
import 'solve_nfv.dart';
import 'solve_root.dart';

/// The calculator class provides the entry point for solving unknown values
/// and/or unknown interest rates implicit in a cash flow series.
///
class Calculator {
  late final int _precision;
  Profile? _profile;
  late final bool _isBespokeProfile;
  late final List<Series> _series;

  /// Instantiates a calculator instance.
  ///
  /// [precision] (optional) the number of fractional digits
  /// to apply in the rounding of cash flow values in the notional currency.
  /// Default is 2, with valid options being 0 through to 4 inclusive.
  ///
  /// [profile] (optional) containing a bespoke collection of cash flows
  /// created manually. Use with caution, and only then if the default
  /// profile builder doesn't handle a specific use case. Be aware that the
  /// precision defined in a bespoke profile takes precedence, hence will
  /// override any precision value passed as an argument to this constructor.
  ///
  Calculator({
    int precision = 2,
    Profile? profile,
  }) {
    final prec = (profile == null ? precision : profile.precision);
    if (0 <= prec || prec <= 4) {
      _precision = (profile == null) ? precision : profile.precision;
    } else {
      throw Exception('The precision of $precision is unsupported. '
          'Valid options are between 0 and 4 inclusive');
    }
    if (profile == null) {
      _isBespokeProfile = false;
    } else {
      _isBespokeProfile = true;
      _profile = profile;
    }
    _series = [];
  }

  /// Returns the number of fractional digits used in the rounding of
  /// cash flow values.
  ///
  int get precision => _precision;

  /// Returns a reference to the cash flow profile.
  ///
  Profile? get profile {
    if (_profile == null) {
      throw Exception("The profile has not been initialised yet.");
    }
    return _profile;
  }

  /// Returns a reference to series current state.
  ///
  List<Series> get series => _series;

  /// Adds a cash flow series item to the series array.
  ///
  /// Please note the order of addition is important for *undated* series
  /// items, as the internal computation of cash flow dates is inferred
  /// from the natural order of the series array. Hence a more recent
  /// undated series addition is deemed to follow on from another added
  /// previously.
  ///
  /// *Dated* series are unaffected and will use the series start-date
  /// provided.
  ///
  void add(Series series) {
    if (_isBespokeProfile) {
      throw Exception('The add(series) option cannot be used with a '
          'user-defined profile.');
    }

    // Coerce series monetary value to specified precision
    if (series.value != null) {
      final value = gaussRound(series.value!, _precision);
      if (series is SeriesAdvance) {
        series = series.copyWith(value: value);
      } else if (series is SeriesPayment) {
        series = series.copyWith(value: value);
      } else if (series is SeriesCharge) {
        series = series.copyWith(value: value);
      }
    }
    _series.add(series);
  }

  /// Solves for an unknown value or values.
  ///
  /// IMPORTANT: If the calculation involves solving for unknown *weighted*
  /// payment values, the result returned will be the raw value *before* the
  /// weightings are applied. In order to display the result in the UI you
  /// should multiple the returned value by the appropriate payment series
  /// weighting. This will ensure the adjusted result will correspond to the
  /// payment reflected in the amortisation schedule / APR proof schedule.
  ///
  /// An UnsolvableException is thrown when the unknown cannot be determined.
  ///
  /// [dayCount] convention for determining time intervals between cash flows
  ///
  /// [interestRate] the annual effective interest rate expressed as a decimal
  /// e.g. 5.25% is 0.0525 as a decimal
  ///
  /// [startDate] to use in constructing the cash flow profile when cash
  /// flow series dates are *not* provided. The current system date is used
  /// if left undefined.
  ///
  Future<double> solveValue({
    required Convention dayCount,
    required double interestRate,
    DateTime? startDate,
  }) async {
    if (_profile == null && !_isBespokeProfile) {
      _buildProfile(startDate: startDate);
    }
    _profile = _profile!.copyWith(dayCount: dayCount);
    _profile = assignFactors(_profile!);

    var value = SolveRoot.solve(
      callback: SolveCashFlow(
        profile: _profile!,
        effectiveRate: interestRate,
      ),
    );
    value = gaussRound(value, _precision);

    _profile = _profile!.copyWith(
      cashFlows: updateUnknowns(
        cashFlows: _profile!.cashFlows,
        value: value,
        precision: _precision,
      ),
    );

    if (!dayCount.useXirrMethod) {
      // Only amortise when non-xirr convention
      _profile = _profile!.copyWith(
        cashFlows: amortiseInterest(
          _profile!.cashFlows,
          interestRate,
          _precision,
        ),
      );
    }

    return value;
  }

  /// Solves for an unknown interest rate, returning the result expressed as
  /// a decimal.
  ///
  /// An UnsolvableException is thrown when the unknown cannot be determined.
  ///
  /// [dayCount] convention for determining time intervals between cash flows
  ///
  /// [startDate] to use in constructing the cash flow profile when cash
  /// flow series dates are *not* provided. The current system date is used
  /// if left undefined.
  ///
  Future<double> solveRate({
    required Convention dayCount,
    DateTime? startDate,
  }) async {
    if (_profile == null && !_isBespokeProfile) {
      _buildProfile(startDate: startDate);
    }
    _profile = _profile!.copyWith(dayCount: dayCount);
    _profile = assignFactors(_profile!);

    final interest = SolveRoot.solve(
      callback: SolveNfv(profile: _profile!),
    );

    if (!dayCount.useXirrMethod) {
      // Only amortise when non-xirr convention
      _profile = _profile!.copyWith(
        cashFlows: amortiseInterest(
          _profile!.cashFlows,
          interest,
          _precision,
        ),
      );
    }

    return interest;
  }

  /// Utility method that builds the profile from the cash flow
  /// series.
  ///
  void _buildProfile({DateTime? startDate}) {
    _profile = Profile(
      cashFlows: build(
        series: _series,
        startDate:
            startDate == null ? utcDate(DateTime.now()) : utcDate(startDate),
      ),
      precision: _precision,
    );
  }
}
