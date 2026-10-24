import 'dart:ui';

import 'package:copi/core/app.dart';
import 'package:copi/core/i18n/strings.g.dart';
import 'package:copi/core/l10n/locale_resolution.dart';
import 'package:copi/core/logging/talker_provider.dart';
import 'package:copi/core/storage/shared_preferences_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker/talker.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final talker = Talker()..info('Application started');
  final stored = preferences.getString(localeStorageKey);
  final resolved = resolveInitialLocale(
    stored: stored,
    systemLanguageCode: PlatformDispatcher.instance.locale.languageCode,
  );
  if (stored == null) {
    await preferences.setString(localeStorageKey, resolved);
  }
  LocaleSettings.setLocaleSync(
    resolved == 'ru' ? AppLocale.ru : AppLocale.en,
  );
  runApp(
    ProviderScope(
      observers: [
        TalkerRiverpodObserver(
          talker: talker,
          settings: const TalkerRiverpodLoggerSettings(
            printStateFullData: false,
          ),
        ),
      ],
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        talkerProvider.overrideWithValue(talker),
      ],
      child: const CopiApp(),
    ),
  );
}
