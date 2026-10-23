import 'package:flutter/services.dart';

/// Formats a raw phone string into `###-###-####` format.
///
/// Handles 10-digit North American numbers, automatically stripping
/// leading +1 / 1 if 11 digits are provided.
String formatPhoneNumber(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '';
  var digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 11 && digits.startsWith('1')) {
    digits = digits.substring(1);
  }
  if (digits.length > 10) {
    digits = digits.substring(0, 10);
  }

  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i == 3 || i == 6) {
      buffer.write('-');
    }
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// Validates whether a phone number string contains exactly 10 digits.
bool isValidPhoneNumber(String? value) {
  if (value == null) return false;
  var digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 11 && digits.startsWith('1')) {
    digits = digits.substring(1);
  }
  return digits.length == 10;
}

/// A validator for phone fields.
String? phoneValidator(String? value, {String label = 'phone number'}) {
  if (value == null || value.trim().isEmpty) {
    return 'Enter a $label';
  }
  if (!isValidPhoneNumber(value)) {
    return 'Please enter a valid 10-digit $label (e.g. 403-555-0123)';
  }
  return null;
}

/// A [TextInputFormatter] that formats phone numbers into `###-###-####`.
class const PhoneNumberFormatter() extends TextInputFormatter {

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (oldValue.text == newValue.text) {
      return newValue;
    }

    var newText = newValue.text;
    var digits = newText.replaceAll(RegExp(r'\D'), '');

    // Handle backspacing over a dash
    var deletedExtraDigit = false;
    final isDeleting = oldValue.text.length > newValue.text.length;
    if (isDeleting && oldValue.selection.isCollapsed) {
      final deletedIndex = newValue.selection.end;
      if (deletedIndex < oldValue.text.length && oldValue.text[deletedIndex] == '-') {
        var digitsUpToDeleted = 0;
        for (var i = 0; i < deletedIndex && i < oldValue.text.length; i++) {
          if (RegExp(r'\d').hasMatch(oldValue.text[i])) {
            digitsUpToDeleted++;
          }
        }
        if (digitsUpToDeleted > 0 && digitsUpToDeleted <= digits.length) {
          digits = digits.substring(0, digitsUpToDeleted - 1) + digits.substring(digitsUpToDeleted);
          deletedExtraDigit = true;
        }
      }
    }

    // Strip leading 1 if 11 digits
    if (digits.length == 11 && digits.startsWith('1')) {
      digits = digits.substring(1);
    }
    if (digits.length > 10) {
      digits = digits.substring(0, 10);
    }

    final formatted = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 3 || i == 6) {
        formatted.write('-');
      }
      formatted.write(digits[i]);
    }
    final formattedText = formatted.toString();

    // Calculate cursor position based on digits before cursor in newValue
    var digitsBeforeCursor = 0;
    final cursorEnd = newValue.selection.end.clamp(0, newValue.text.length);
    for (var i = 0; i < cursorEnd; i++) {
      if (RegExp(r'\d').hasMatch(newValue.text[i])) {
        digitsBeforeCursor++;
      }
    }
    if (deletedExtraDigit && digitsBeforeCursor > 0) {
      digitsBeforeCursor--;
    }

    if (newValue.text.replaceAll(RegExp(r'\D'), '').length == 11 &&
        newValue.text.replaceAll(RegExp(r'\D'), '').startsWith('1')) {
      if (digitsBeforeCursor > 0) digitsBeforeCursor--;
    }
    if (digitsBeforeCursor > 10) digitsBeforeCursor = 10;

    var newCursorOffset = 0;
    var countedDigits = 0;
    for (var i = 0; i < formattedText.length; i++) {
      if (RegExp(r'\d').hasMatch(formattedText[i])) {
        countedDigits++;
      }
      if (countedDigits == digitsBeforeCursor) {
        newCursorOffset = i + 1;
        break;
      }
    }
    if (digitsBeforeCursor == 0) {
      newCursorOffset = 0;
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newCursorOffset),
    );
  }
}
