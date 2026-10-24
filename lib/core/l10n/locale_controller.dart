import 'dart:ui';

import 'package:copi/core/i18n/strings.g.dart';
import 'package:copi/core/l10n/locale_resolution.dart';
import 'package:copi/core/storage/shared_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Текущий язык интерфейса: `ru` или `en`.
final localeProvider = NotifierProvider<LocaleController, String>(
  LocaleController.new,
);

/// Сохраняет язык и сразу переключает строки.
class LocaleController extends Notifier<String> {
  @override
  String build() => resolveInitialLocale(
        stored:
            ref.watch(sharedPreferencesProvider).getString(localeStorageKey),
        systemLanguageCode: PlatformDispatcher.instance.locale.languageCode,
      );

  Future<void> setLocale(String code) async {
    final locale = code == 'ru' ? AppLocale.ru : AppLocale.en;
    LocaleSettings.setLocaleSync(locale);
    state = locale.languageCode;
    await ref.read(sharedPreferencesProvider).setString(
          localeStorageKey,
          locale.languageCode,
        );
  }
}
