import 'package:flutter/services.dart';

// Currency Input Formatter
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove non-numeric characters except decimal point
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');

    // Ensure only one decimal point
    if (newText.split('.').length > 2) {
      return oldValue;
    }

    // Limit decimal places to 2
    if (newText.contains('.')) {
      final parts = newText.split('.');
      if (parts[1].length > 2) {
        newText = '${parts[0]}.${parts[1].substring(0, 2)}';
      }
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

// Percentage Input Formatter
class PercentageInputFormatter extends TextInputFormatter {
  final double maxValue;

  PercentageInputFormatter({this.maxValue = 100});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String newText = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');

    if (newText.split('.').length > 2) {
      return oldValue;
    }

    final value = double.tryParse(newText);
    if (value != null && value > maxValue) {
      return oldValue;
    }

    if (newText.contains('.')) {
      final parts = newText.split('.');
      if (parts[1].length > 2) {
        newText = '${parts[0]}.${parts[1].substring(0, 2)}';
      }
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

// Phone Number Formatter
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    String formatted = '';
    for (int i = 0; i < digits.length && i < 10; i++) {
      if (i == 3 || i == 6) {
        formatted += '-';
      }
      formatted += digits[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Quantity Input Formatter (Integer only)
class QuantityInputFormatter extends TextInputFormatter {
  final int maxValue;

  QuantityInputFormatter({this.maxValue = 99999});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final value = int.tryParse(digits);
    if (value != null && value > maxValue) {
      return oldValue;
    }

    // Remove leading zeros
    final cleanedDigits = digits.replaceFirst(RegExp(r'^0+'), '');
    final finalValue = cleanedDigits.isEmpty ? '0' : cleanedDigits;

    return TextEditingValue(
      text: finalValue,
      selection: TextSelection.collapsed(offset: finalValue.length),
    );
  }
}

// Uppercase Text Formatter
class UppercaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

// No Space Formatter
class NoSpaceFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.replaceAll(' ', ''),
      selection: newValue.selection,
    );
  }
}
