/// Normalized calendar dates for SQLite `date()` comparisons.
class FinancialDateUtils {
  FinancialDateUtils._();

  static String isoDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Inclusive month range as `YYYY-MM-DD` (works with `date(date) BETWEEN`).
  static ({String start, String end}) monthRange(DateTime anchor) {
    final start = DateTime(anchor.year, anchor.month, 1);
    final end = DateTime(anchor.year, anchor.month + 1, 0);
    return (start: isoDate(start), end: isoDate(end));
  }
}
