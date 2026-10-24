import 'package:copi/core/l10n/locale_resolution.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('russian system language becomes russian when nothing is stored', () {
    expect(
      resolveInitialLocale(stored: null, systemLanguageCode: 'ru'),
      'ru',
    );
  });

  test('any other system language becomes english', () {
    expect(
      resolveInitialLocale(stored: null, systemLanguageCode: 'ja'),
      'en',
    );
    expect(
      resolveInitialLocale(stored: null, systemLanguageCode: 'en'),
      'en',
    );
  });

  test('stored choice is kept even when the system language differs', () {
    expect(
      resolveInitialLocale(stored: 'en', systemLanguageCode: 'ru'),
      'en',
    );
    expect(
      resolveInitialLocale(stored: 'ru', systemLanguageCode: 'en'),
      'ru',
    );
  });
}
