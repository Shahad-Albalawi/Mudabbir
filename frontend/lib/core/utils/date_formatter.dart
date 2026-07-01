import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Arabic / English date labels for UI lists and headers.
abstract final class AppDateFormatter {
  AppDateFormatter._();

  static String _locale(BuildContext context) =>
      Localizations.localeOf(context).toString();

  /// e.g. ٣ مارس / 3 Mar
  static String short(DateTime date, BuildContext context) =>
      DateFormat('d MMM', _locale(context)).format(date);

  /// e.g. ٣ مارس ٢٠٢٦ / 3 Mar 2026
  static String medium(DateTime date, BuildContext context) =>
      DateFormat('d MMM yyyy', _locale(context)).format(date);

  /// e.g. مارس ٢٠٢٦ / March 2026
  static String monthYear(DateTime date, BuildContext context) =>
      DateFormat('MMMM yyyy', _locale(context)).format(date);

  /// e.g. ٣:٣٠ م / 3:30 PM
  static String time(DateTime date, BuildContext context) =>
      DateFormat('h:mm a', _locale(context)).format(date);

  static String? tryParseIso(String raw, BuildContext context) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return null;
    return short(parsed, context);
  }
}

typedef DateFormatter = AppDateFormatter;
