import 'package:flutter/services.dart';

class UsPhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all non-digits
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Limit to 10 digits
    if (digits.length > 10) digits = digits.substring(0, 10);

    String formatted = '';

    if (digits.length >= 1) {
      formatted = '(${digits.substring(0, digits.length >= 3 ? 3 : digits.length)}';
    }
    if (digits.length >= 4) {
      formatted += ') ${digits.substring(3, digits.length >= 6 ? 6 : digits.length)}';
    }
    if (digits.length >= 7) {
      formatted += '-${digits.substring(6)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
