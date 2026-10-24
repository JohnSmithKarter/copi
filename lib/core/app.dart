import 'dart:async';

import 'package:copi/core/i18n/strings.g.dart';
import 'package:copi/core/l10n/locale_resolution.dart';
import 'package:copi/core/logging/app_route_observer.dart';
import 'package:copi/core/logging/talker_provider.dart';
import 'package:copi/core/presentation/launch_screen.dart';
import 'package:copi/core/presentation/window_bar.dart';
import 'package:copi/core/storage/shared_preferences_provider.dart';
import 'package:copi/core/theme/accent_provider.dart';
import 'package:copi/core/theme/app_theme.dart';
import 'package:copi/features/home/presentation/directory_providers.dart';
import 'package:copi/features/home/presentation/pages/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The main application class.
class CopiApp extends ConsumerStatefulWidget {
  const CopiApp({super.key});

  @override
  ConsumerState<CopiApp> createState() => _CopiAppState();
}

class _CopiAppState extends ConsumerState<CopiApp> with WidgetsBindingObserver {
  late final List<NavigatorObserver> _navigatorObservers;
  var _windowAppearanceSynced = false;

  @override
  void initState() {
    super.initState();
    _navigatorObservers = [AppRouteObserver(ref.read(appLogProvider))];
    WidgetsBinding.instance.addObserver(this);
    final preferences = ref.read(sharedPreferencesProvider);
    final resolved = resolveInitialLocale(
      stored: preferences.getString(localeStorageKey),
      systemLanguageCode:
          WidgetsBinding.instance.platformDispatcher.locale.languageCode,
    );
    if (preferences.getString(localeStorageKey) == null) {
      unawaited(preferences.setString(localeStorageKey, resolved));
    }
    LocaleSettings.setLocaleSync(
      resolved == 'ru' ? AppLocale.ru : AppLocale.en,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(directoryRevisionProvider.notifier).bump();
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = ref.watch(accentProvider);
    if (!_windowAppearanceSynced) {
      _windowAppearanceSynced = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(syncWindowAppearance(Brightness.dark));
      });
    }

    return TranslationProvider(
      child: Builder(
        builder: (context) => CupertinoApp(
          title: 'copi',
          debugShowCheckedModeBanner: false,
          locale: TranslationProvider.of(context).flutterLocale,
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: appTheme(accent: accent.color),
          navigatorObservers: _navigatorObservers,
          home: const LaunchScreen(child: HomePage()),
        ),
      ),
    );
  }
}
