import 'package:curo/src/calculator.dart';
import 'package:test/test.dart';

void main() {
  group('Series - Validation', () {
    test('numberOf must be >= 1', () {
      expect(() => SeriesAdvance(numberOf: 0), throwsA(isA<ArgumentError>()));
    });

    test('weighting must be > 0', () {
      expect(
        () => SeriesAdvance(weighting: 0.0),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => SeriesAdvance(weighting: -1.0),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('valueDateFrom must not be before postDateFrom', () {
      final post = DateTime.utc(2025, 1, 1);
      final value = DateTime.utc(2024, 12, 31);
      expect(
        () => SeriesAdvance(postDateFrom: post, valueDateFrom: value),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('valueDateFrom requires postDateFrom', () {
      final value = DateTime.utc(2025, 1, 1);
      expect(
        () => SeriesAdvance(valueDateFrom: value),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('Series - Date Generation & Month-End Preservation', () {
    final today = DateTime.now();
    final normalizedToday = normalizeToMidnightUtc(today);

    test('Single cashflow returns start date', () {
      final start = DateTime.utc(2025, 6, 15);
      final series = SeriesAdvance(numberOf: 1, postDateFrom: start);
      final cfs = series.toCashFlows(normalizedToday);
      expect(cfs.length, 1);
      expect(cfs[0].postDate, start);
      expect(cfs[0].valueDate, start);
    });

    test('Monthly frequency preserves day of month', () {
      final start = DateTime.utc(2025, 1, 15);
      final series = SeriesPayment(
        numberOf: 4,
        frequency: Frequency.monthly,
        postDateFrom: start,
      );
      final cfs = series.toCashFlows(normalizedToday);
      expect(cfs.map((cf) => cf.postDate.day), [15, 15, 15, 15]);
    });

    test('Month-end preservation: 31 Jan -> Feb -> Mar -> Apr', () {
      final start = DateTime.utc(2025, 1, 31); // non-leap
      final series = SeriesPayment(
        numberOf: 5,
        frequency: Frequency.monthly,
        postDateFrom: start,
      );
      final cfs = series.toCashFlows(normalizedToday);

      final expectedDays = [31, 28, 31, 30, 31]; // Jan, Feb, Mar, Apr, May
      final actualDays = cfs.map((cf) => cf.postDate.day).toList();

      expect(actualDays, expectedDays);
    });

    test('Month-end preservation in leap year', () {
      final start = DateTime.utc(2024, 1, 31); // leap year
      final series = SeriesPayment(
        numberOf: 3,
        frequency: Frequency.monthly,
        postDateFrom: start,
      );
      final cfs = series.toCashFlows(normalizedToday);

      expect(cfs[1].postDate.day, 29); // February
    });

    test('Weekly and fortnightly use day rolling (no month-end logic)', () {
      final start = DateTime.utc(2025, 1, 31);
      final weekly = SeriesAdvance(
        numberOf: 3,
        frequency: Frequency.weekly,
        postDateFrom: start,
      );
      final fortnightly = SeriesAdvance(
        numberOf: 3,
        frequency: Frequency.fortnightly,
        postDateFrom: start,
      );

      final weeklyDates =
          weekly.toCashFlows(normalizedToday).map((cf) => cf.postDate);
      final fortnightlyDates =
          fortnightly.toCashFlows(normalizedToday).map((cf) => cf.postDate);

      expect(weeklyDates.elementAt(1), start.add(const Duration(days: 7)));
      expect(
        fortnightlyDates.elementAt(1),
        start.add(const Duration(days: 14)),
      );
    });
  });

  group('Series Types - Specific Behaviour', () {
    final refDate = DateTime.utc(2025, 1, 1);

    test('SeriesAdvance allows separate post and value dates', () {
      final post = DateTime.utc(2025, 1, 10);
      final value = DateTime.utc(2025, 1, 15);
      final series = SeriesAdvance(
        numberOf: 2,
        postDateFrom: post,
        valueDateFrom: value,
        frequency: Frequency.monthly,
      );
      final cfs = series.toCashFlows(refDate);

      expect(cfs[0].postDate, post);
      expect(cfs[0].valueDate, value);
      expect(cfs[1].postDate, post.add(const Duration(days: 31))); // approx
      expect(cfs[1].valueDate, value.add(const Duration(days: 31)));
    });

    test('SeriesPayment forces valueDate = postDate', () {
      final post = DateTime.utc(2025, 1, 10);
      final series = SeriesPayment(postDateFrom: post, numberOf: 1);
      final cf = series.toCashFlows(refDate).first;

      expect(cf.postDate, post);
      expect(cf.valueDate, post);
      expect(cf.isInterestCapitalised, true);
    });

    test('SeriesCharge requires amount and forces valueDate = postDate', () {
      final post = DateTime.utc(2025, 1, 10);
      final series = SeriesCharge(
        amount: 100.0,
        postDateFrom: post,
        label: 'Fee',
      );
      final cf = series.toCashFlows(refDate).first;

      expect(cf.amount, 100.0);
      expect(cf.isKnown, true);
      expect(cf.postDate, post);
      expect(cf.valueDate, post);
      expect(cf.label, 'Fee');
    });

    test('Unknown amount -> isKnown false, amount 0.0 placeholder', () {
      final series = SeriesPayment(amount: null); // unknown payment
      final cf = series.toCashFlows(refDate).first;

      expect(cf.amount, 0.0);
      expect(cf.isKnown, false);
    });
  });

  group('toCashFlows - Fallback to referenceStartDate', () {
    final refDate = DateTime.utc(2025, 6, 1);

    test('Uses referenceStartDate when postDateFrom null', () {
      final series = SeriesAdvance(numberOf: 1);
      final cf = series.toCashFlows(refDate).first;
      expect(cf.postDate, normalizeToMidnightUtc(refDate));
    });
  });

  group('Series - copyWith and knownAmount', () {
    test('SeriesAdvance.copyWith overrides all fields correctly', () {
      final original = SeriesAdvance(
        numberOf: 3,
        frequency: Frequency.quarterly,
        label: 'Original Loan',
        amount: 50000.0,
        mode: Mode.arrear,
        postDateFrom: DateTime.utc(2025, 1, 1),
        valueDateFrom: DateTime.utc(2025, 1, 5),
        weighting: 2.0,
      );

      final modified = original.copyWith(
        numberOf: 6,
        frequency: Frequency.monthly,
        label: 'Modified Loan',
        amount: 100000.0,
        mode: Mode.advance,
        postDateFrom: DateTime.utc(2026, 1, 1),
        valueDateFrom: DateTime.utc(2026, 1, 10),
        weighting: 1.0,
      );

      expect(modified.numberOf, 6);
      expect(modified.frequency, Frequency.monthly);
      expect(modified.label, 'Modified Loan');
      expect(modified.amount, 100000.0);
      expect(modified.mode, Mode.advance);
      expect(modified.postDateFrom, DateTime.utc(2026, 1, 1));
      expect(modified.valueDateFrom, DateTime.utc(2026, 1, 10));
      expect(modified.weighting, 1.0);

      // Original unchanged
      expect(original.numberOf, 3);
      expect(original.postDateFrom, DateTime.utc(2025, 1, 1));
    });

    test('SeriesPayment.copyWith overrides fields and ignores valueDateFrom',
        () {
      final original = SeriesPayment(
        numberOf: 12,
        label: 'Rent',
        amount: 1200.0,
        postDateFrom: DateTime.utc(2025, 1, 31),
        isInterestCapitalised: false,
      );

      final modified = original.copyWith(
        numberOf: 24,
        label: 'New Rent',
        amount: 1300.0,
        postDateFrom: DateTime.utc(2026, 1, 1),
        valueDateFrom: DateTime.utc(2099, 1, 1), // should be ignored
        isInterestCapitalised: true,
      );

      expect(modified.numberOf, 24);
      expect(modified.label, 'New Rent');
      expect(modified.amount, 1300.0);
      expect(modified.postDateFrom, DateTime.utc(2026, 1, 1));
      expect(modified.valueDateFrom,
          DateTime.utc(2026, 1, 1)); // forced to match post
      expect(modified.isInterestCapitalised, true);
    });

    test('SeriesCharge.copyWith requires amount and ignores valueDateFrom', () {
      final original = SeriesCharge(
        amount: 250.0,
        label: 'Arrangement Fee',
        postDateFrom: DateTime.utc(2025, 1, 1),
      );

      final modified = original.copyWith(
        amount: 300.0,
        label: 'Updated Fee',
        postDateFrom: DateTime.utc(2025, 2, 1),
        valueDateFrom: DateTime.utc(2099, 1, 1), // ignored
      );

      expect(modified.knownAmount, 300.0);
      expect(modified.label, 'Updated Fee');
      expect(modified.postDateFrom, DateTime.utc(2025, 2, 1));
      expect(modified.valueDateFrom,
          DateTime.utc(2025, 2, 1)); // forced to match post
    });

    test('SeriesCharge.knownAmount returns non-null amount', () {
      final series = SeriesCharge(amount: 999.99, label: 'Valuation');
      expect(series.knownAmount, 999.99);

      final modified = series.copyWith(amount: 1499.99);
      expect(modified.knownAmount, 1499.99);
    });

    test('Partial copyWith only changes specified fields', () {
      final base = SeriesAdvance(
        numberOf: 1,
        amount: 10000.0,
        label: 'Base',
        postDateFrom: DateTime.utc(2025, 1, 1),
      );

      final partial = base.copyWith(label: 'Only Label Changed');

      expect(partial.label, 'Only Label Changed');
      expect(partial.numberOf, 1);
      expect(partial.amount, 10000.0);
      expect(partial.postDateFrom, DateTime.utc(2025, 1, 1));
    });
  });
}
