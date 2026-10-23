import 'package:aclub2/utils/phone_formatter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatPhoneNumber', () {
    test('formats unformatted 10 digits', () {
      expect(formatPhoneNumber('4035550123'), '403-555-0123');
    });

    test('handles 11 digits with leading 1', () {
      expect(formatPhoneNumber('14035550123'), '403-555-0123');
      expect(formatPhoneNumber('+1 (403) 555-0123'), '403-555-0123');
    });

    test('handles null or empty', () {
      expect(formatPhoneNumber(null), '');
      expect(formatPhoneNumber(''), '');
      expect(formatPhoneNumber('   '), '');
    });

    test('handles partial digits', () {
      expect(formatPhoneNumber('403'), '403');
      expect(formatPhoneNumber('4035'), '403-5');
      expect(formatPhoneNumber('403555'), '403-555');
      expect(formatPhoneNumber('4035550'), '403-555-0');
    });
  });

  group('isValidPhoneNumber', () {
    test('validates 10-digit numbers', () {
      expect(isValidPhoneNumber('403-555-0123'), isTrue);
      expect(isValidPhoneNumber('4035550123'), isTrue);
      expect(isValidPhoneNumber('+1 403 555 0123'), isTrue);
    });

    test('rejects invalid numbers', () {
      expect(isValidPhoneNumber(null), isFalse);
      expect(isValidPhoneNumber(''), isFalse);
      expect(isValidPhoneNumber('403-555'), isFalse);
      expect(isValidPhoneNumber('12345'), isFalse);
      expect(isValidPhoneNumber('abcdefghij'), isFalse);
    });
  });

  group('phoneValidator', () {
    test('reports empty', () {
      expect(phoneValidator(null), 'Enter a phone number');
      expect(phoneValidator(''), 'Enter a phone number');
    });

    test('reports invalid digits', () {
      expect(
        phoneValidator('403-55', label: 'mobile phone number'),
        'Please enter a valid 10-digit mobile phone number (e.g. 403-555-0123)',
      );
    });

    test('passes on valid 10 digits', () {
      expect(phoneValidator('403-555-0123'), isNull);
    });
  });

  group('PhoneNumberFormatter', () {
    const formatter = PhoneNumberFormatter();

    test('formats typing digits one by one', () {
      var oldVal = const TextEditingValue(text: '');
      var newVal = const TextEditingValue(text: '4', selection: TextSelection.collapsed(offset: 1));
      var res = formatter.formatEditUpdate(oldVal, newVal);
      expect(res.text, '4');
      expect(res.selection.baseOffset, 1);

      oldVal = res;
      newVal = const TextEditingValue(text: '403', selection: TextSelection.collapsed(offset: 3));
      res = formatter.formatEditUpdate(oldVal, newVal);
      expect(res.text, '403');
      expect(res.selection.baseOffset, 3);

      oldVal = res;
      newVal = const TextEditingValue(text: '4035', selection: TextSelection.collapsed(offset: 4));
      res = formatter.formatEditUpdate(oldVal, newVal);
      expect(res.text, '403-5');
      expect(res.selection.baseOffset, 5);
    });

    test('formats pasted full number', () {
      const oldVal = TextEditingValue.empty;
      const newVal = TextEditingValue(
        text: '(403) 555-0123',
        selection: TextSelection.collapsed(offset: 14),
      );
      final res = formatter.formatEditUpdate(oldVal, newVal);
      expect(res.text, '403-555-0123');
      expect(res.selection.baseOffset, 12);
    });

    test('handles backspace over a dash', () {
      const oldVal = TextEditingValue(
        text: '403-5',
        selection: TextSelection.collapsed(offset: 4), // cursor right after '-'
      );
      const newVal = TextEditingValue(
        text: '4035', // user deleted '-'
        selection: TextSelection.collapsed(offset: 3),
      );
      final res = formatter.formatEditUpdate(oldVal, newVal);
      expect(res.text, '405');
      expect(res.selection.baseOffset, 2);
    });
  });
}
