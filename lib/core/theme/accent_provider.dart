import 'package:copi/core/storage/shared_preferences_provider.dart';
import 'package:copi/core/theme/accent_color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ключ акцентного цвета в настройках.
const accentStorageKey = 'accent_color';

/// Выбранный акцент. По умолчанию синий.
final accentProvider = NotifierProvider<AccentController, AppAccent>(
  AccentController.new,
);

/// Читает и сохраняет акцентный цвет.
class AccentController extends Notifier<AppAccent> {
  @override
  AppAccent build() => AppAccent.fromStorage(
        ref.watch(sharedPreferencesProvider).getString(accentStorageKey),
      );

  Future<void> setAccent(AppAccent accent) async {
    state = accent;
    await ref.read(sharedPreferencesProvider).setString(
          accentStorageKey,
          accent.name,
        );
  }
}
