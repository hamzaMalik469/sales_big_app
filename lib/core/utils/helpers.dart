import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../config/constants.dart';
import '../../config/app_colors.dart';

class Helpers {
  Helpers._();

  // Format Currency
  static String formatCurrency(double amount, {String? symbol}) {
    final formatter = NumberFormat.currency(
      symbol: symbol ?? AppConstants.currencySymbol,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  // Format Number
  static String formatNumber(num number, {int decimalDigits = 0}) {
    final formatter = NumberFormat.decimalPattern();
    if (decimalDigits > 0) {
      return number.toStringAsFixed(decimalDigits);
    }
    return formatter.format(number);
  }

  // Format Percentage
  static String formatPercentage(double value, {int decimalDigits = 1}) {
    return '${value.toStringAsFixed(decimalDigits)}%';
  }

  // Format Date
  static String formatDate(DateTime date, {String? format}) {
    final formatter = DateFormat(format ?? AppConstants.dateFormat);
    return formatter.format(date);
  }

  // Format Time
  static String formatTime(DateTime time, {String? format}) {
    final formatter = DateFormat(format ?? AppConstants.timeFormat);
    return formatter.format(time);
  }

  // Format DateTime
  static String formatDateTime(DateTime dateTime, {String? format}) {
    final formatter = DateFormat(format ?? AppConstants.dateTimeFormat);
    return formatter.format(dateTime);
  }

  // Get Relative Time
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  // Get Status Color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return AppColors.statusDraft;
      case 'pending':
        return AppColors.statusPending;
      case 'approved':
        return AppColors.statusApproved;
      case 'rejected':
        return AppColors.statusRejected;
      default:
        return AppColors.grey500;
    }
  }

  // Get Status Background Color
  static Color getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return AppColors.statusDraftBg;
      case 'pending':
        return AppColors.statusPendingBg;
      case 'approved':
        return AppColors.statusApprovedBg;
      case 'rejected':
        return AppColors.statusRejectedBg;
      default:
        return AppColors.grey100;
    }
  }

  // Get Status Icon
  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return Icons.edit_outlined;
      case 'pending':
        return Icons.hourglass_empty;
      case 'approved':
        return Icons.check_circle_outline;
      case 'rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  // Capitalize First Letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Capitalize Each Word
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  // Truncate Text
  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}$suffix';
  }

  // Get Initials
  static String getInitials(String name, {int count = 2}) {
    if (name.isEmpty) return '';
    final words = name.trim().split(' ');
    final initials = words
        .take(count)
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join();
    return initials;
  }

  // Validate Email
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Generate Unique ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Show Snackbar
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
    bool isSuccess = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: isError
            ? AppColors.error
            : isSuccess
            ? AppColors.success
            : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Hide Keyboard
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
}
