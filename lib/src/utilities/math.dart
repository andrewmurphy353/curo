import 'dart:math';

/// Perform gaussian rounding, also known as “bankers” rounding, convergent
/// rounding, Dutch rounding, or odd–even rounding. This is a method of
/// rounding without statistical bias; regular rounding has a native upwards
/// bias. Gaussian rounding avoids this by rounding to the nearest even
/// number.
///
/// Ported and modified from JavaScript source written by Tim Down
/// (http://stackoverflow.com/a/3109234)
///
/// [num] to round
/// [precision] (optional) number of decimal places. Default is 0
double gaussRound(double num, [int precision = 0]) {
  final d = precision.abs();
  final m = pow(10, d);
  final n = double.parse((num * m).toStringAsFixed(8));
  final i = n.floor();
  final f = n - i;
  const e = 1e-8;
  final r = f > 0.5 - e && f < 0.5 + e
      ? i % 2 == 0
          ? i
          : i + 1
      : n.round();
  return r / m;
}
