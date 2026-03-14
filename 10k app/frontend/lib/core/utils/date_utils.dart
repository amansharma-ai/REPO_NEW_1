import 'package:intl/intl.dart';

class AppDateUtils {
  /// Returns "Today", "Yesterday", or a formatted date string.
  static String formatRelativeDate(DateTime date) {
    if (isToday(date)) return 'Today';
    if (isYesterday(date)) return 'Yesterday';
    return DateFormat('MMM d, yyyy').format(date);
  }

  /// Returns a short date string like "Mar 14".
  static String formatShortDate(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  /// Returns the full date string like "March 14, 2026".
  static String formatFullDate(DateTime date) {
    return DateFormat('MMMM d, yyyy').format(date);
  }

  /// Returns the ISO date string (yyyy-MM-dd) used for API calls.
  static String toIsoDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Parses an ISO date string (yyyy-MM-dd) into a [DateTime].
  static DateTime parseIsoDate(String isoDate) {
    return DateTime.parse(isoDate);
  }

  /// Returns the day-of-week name, e.g. "Monday".
  static String dayOfWeekName(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  /// Returns a short day-of-week name, e.g. "Mon".
  static String dayOfWeekShort(DateTime date) {
    return DateFormat('EEE').format(date);
  }

  /// Whether [date] falls on the current calendar day.
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Whether [date] falls on yesterday.
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }
}
