import 'package:aclub2/utils/external_url.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseExternalUrl', () {
    test('keeps an absolute URL as-is', () {
      expect(
        parseExternalUrl('https://maps.google.com/?q=grassi')?.toString(),
        'https://maps.google.com/?q=grassi',
      );
    });

    test('assumes https for a bare host', () {
      expect(
        parseExternalUrl('maps.google.com/?q=grassi')?.toString(),
        'https://maps.google.com/?q=grassi',
      );
    });

    test('trims surrounding whitespace', () {
      expect(parseExternalUrl('  https://caltopo.com/m/abc  ')?.host, 'caltopo.com');
    });

    test('keeps non-http schemes', () {
      expect(parseExternalUrl('geo:51.0,-115.0')?.scheme, 'geo');
    });

    test('returns null for empty or unusable input', () {
      expect(parseExternalUrl(''), isNull);
      expect(parseExternalUrl('   '), isNull);
      expect(parseExternalUrl('https://'), isNull);
      expect(parseExternalUrl('http://'), isNull);
    });
  });
}
