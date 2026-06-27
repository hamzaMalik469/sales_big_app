import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  // Check if same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Check if today
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  // Check if yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  // Check if this week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  // Check if this month
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  // Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  // Get start of week
  static DateTime startOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  // Get end of week
  static DateTime endOfWeek(DateTime date) {
    return startOfWeek(date).add(const Duration(days: 6));
  }

  // Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  // Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  // Format for API
  static String toApiFormat(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Parse from API
  static DateTime fromApiFormat(String dateString) {
    return DateFormat('yyyy-MM-dd').parse(dateString);
  }

  // Format for API with time
  static String toApiFormatWithTime(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }

  // Parse from API with time
  static DateTime fromApiFormatWithTime(String dateString) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateString);
  }

  // Get friendly date text
  static String getFriendlyDate(DateTime date) {
    if (isToday(date)) {
      return 'Today';
    } else if (isYesterday(date)) {
      return 'Yesterday';
    } else if (isThisWeek(date)) {
      return DateFormat('EEEE').format(date); // Day name
    } else if (isThisMonth(date)) {
      return DateFormat('MMM d').format(date);
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  // Get days between dates
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  // Add business days
  static DateTime addBusinessDays(DateTime date, int days) {
    int addedDays = 0;
    DateTime currentDate = date;

    while (addedDays < days) {
      currentDate = currentDate.add(const Duration(days: 1));
      if (currentDate.weekday != DateTime.saturday &&
          currentDate.weekday != DateTime.sunday) {
        addedDays++;
      }
    }

    return currentDate;
  }
}
