import 'package:intl/intl.dart';
import 'package:mudabbir/presentation/resources/strings_manager.dart';

/// Locale-aware budget date labels for cards and lists.
class BudgetDateFormat {
  BudgetDateFormat._();

  static bool get _english => AppStrings.isEnglishLocale;

  static DateTime? _parseDate(String raw) => DateTime.tryParse(raw);

  static String formatDate(String raw) {
    final parsed = _parseDate(raw);
    if (parsed == null) return _stripTime(raw);
    final locale = _english ? 'en' : 'ar';
    return DateFormat('d MMM yyyy', locale).format(parsed);
  }

  static String formatPeriodRange(String startRaw, String endRaw) {
    final start = _parseDate(startRaw);
    final end = _parseDate(endRaw);
    if (start == null || end == null) {
      return '${_stripTime(startRaw)} – ${_stripTime(endRaw)}';
    }

    final locale = _english ? 'en' : 'ar';
    if (start.year == end.year && start.month == end.month) {
      final monthYear = DateFormat('MMMM yyyy', locale).format(start);
      return '${start.day} – ${end.day} $monthYear';
    }

    final startLabel = DateFormat('d MMM', locale).format(start);
    final endLabel = DateFormat('d MMM yyyy', locale).format(end);
    return '$startLabel – $endLabel';
  }

  static String _stripTime(String raw) {
    final t = raw.indexOf('T');
    return t >= 0 ? raw.substring(0, t) : raw;
  }
}
