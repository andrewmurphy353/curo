import 'frequency.dart';
import 'mode.dart';

/// Contains the definition of properties shared amongst child classes.
///
abstract class Series {
  final int numberOf;
  final Frequency frequency;
  final String label;
  final double? value;
  final Mode mode;
  final DateTime? postDateFrom;
  final DateTime? valueDateFrom;
  final double weighting;

  Series({
    required this.numberOf,
    required this.frequency,
    required this.label,
    this.value,
    required this.mode,
    this.postDateFrom,
    this.valueDateFrom,
    this.weighting = 1.0,
  }) {
    if (numberOf < 1) {
      throw Exception(
        'The series numberOf value must be greater or equal to 1.',
      );
    }
    if (!(weighting > 0.0)) {
      throw Exception(
        'The series weighting value must be greater than 0.0',
      );
    }
    if (postDateFrom == null && valueDateFrom != null) {
      throw Exception(
        'The series post date must be provided when a value date '
        'is defined.',
      );
    } else if (postDateFrom != null &&
        valueDateFrom != null &&
        valueDateFrom!.isBefore(postDateFrom!)) {
      throw Exception(
        'The series value date must fall on or after the post date.',
      );
    }
  }
}
