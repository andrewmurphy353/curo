import 'package:curo/src/daycounts/convention.dart';
import 'package:curo/src/enums.dart';
import 'package:intl/intl.dart';

/// A single row in the schedule returned by [Calculator.buildSchedule].
///
/// Represents either an amortisation row or an APR proof row, depending
/// on the convention used.
typedef ScheduleRow = ({
  CashFlowType type,
  DateTime date,
  String label,
  double amount,
  double? capital,
  double? interest,
  double? capitalBalance,
  String? discountLog,
  double? amountDiscounted,
  double? discountedBalance,
});

extension SchedulePrettyPrint on List<ScheduleRow> {
  /// Prints the schedule in a clean, human-readable tabular format,
  /// similar to the pandas-style output in `curo-python`.
  ///
  /// Column set depends on [Convention.useXirrMethod]:
  /// - `false`: Amortisation schedule with `capital`, `interest`, and `capital_balance`
  /// - `true`:  APR proof schedule with `discount_log`, `amount_disc`, and `disc_balance`
  ///
  /// The date column is labelled `post_date` or `value_date` according to
  /// [Convention.usePostDates].
  ///
  /// [dateFormat] controls the date display format (default: `'yyyy-MM-dd'`).
  void prettyPrint({
    required Convention convention,
    String dateFormat = 'yyyy-MM-dd',
  }) {
    if (isEmpty) {
      print('Empty schedule');
      return;
    }

    final isAprProof = convention.useXirrMethod;
    final dateLabel = convention.usePostDates ? 'post_date' : 'value_date';

    final currencyFmt = NumberFormat('#,##0.00');
    final dateFmt = DateFormat(dateFormat);

    // Column configuration
    final columns = isAprProof
        ? [
            (header: dateLabel, width: 12, rightAlign: false),
            (header: 'label', width: 24, rightAlign: false),
            (header: 'amount', width: 14, rightAlign: true),
            (header: 'discount_log', width: 30, rightAlign: false),
            (header: 'amount_disc', width: 14, rightAlign: true),
            (header: 'disc_balance', width: 16, rightAlign: true),
          ]
        : [
            (header: dateLabel, width: 12, rightAlign: false),
            (header: 'label', width: 24, rightAlign: false),
            (header: 'amount', width: 14, rightAlign: true),
            (header: 'capital', width: 14, rightAlign: true),
            (header: 'interest', width: 14, rightAlign: true),
            (header: 'capital_balance', width: 16, rightAlign: true),
          ];

    // Calculate total width for separator
    final totalWidth = columns.map((c) => c.width).reduce((a, b) => a + b) +
        (columns.length - 1); // spaces between columns

    // Header
    final headerLine = columns.asMap().entries.map((e) {
      final col = e.value;
      return col.rightAlign
          ? col.header.padLeft(col.width)
          : col.header.padRight(col.width);
    }).join(' ');
    print(headerLine);

    // Separator
    print('-' * totalWidth);

    // Rows
    for (final row in this) {
      final dateStr = dateFmt.format(row.date);

      final parts = <String>[];

      // Date
      parts.add(dateStr.padRight(columns[0].width));

      // Label
      parts.add(row.label.padRight(columns[1].width));

      // Amount (always present)
      parts.add(currencyFmt.format(row.amount).padLeft(columns[2].width));

      if (isAprProof) {
        // APR proof columns
        final discountLog = row.discountLog ?? '';
        parts.add(discountLog.padRight(columns[3].width));

        final amountDisc = row.amountDiscounted != null
            ? currencyFmt.format(row.amountDiscounted!)
            : '';
        parts.add(amountDisc.padLeft(columns[4].width));

        final discBalance = row.discountedBalance != null
            ? currencyFmt.format(row.discountedBalance!)
            : '';
        parts.add(discBalance.padLeft(columns[5].width));
      } else {
        // Amortisation columns
        final capital =
            row.capital != null ? currencyFmt.format(row.capital!) : '';
        parts.add(capital.padLeft(columns[3].width));

        final interest =
            row.interest != null ? currencyFmt.format(row.interest!) : '';
        parts.add(interest.padLeft(columns[4].width));

        final balance = row.capitalBalance != null
            ? currencyFmt.format(row.capitalBalance!)
            : '';
        parts.add(balance.padLeft(columns[5].width));
      }

      print(parts.join(' '));
    }
  }
}
