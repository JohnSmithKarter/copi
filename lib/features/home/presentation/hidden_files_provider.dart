import 'package:copi/core/storage/shared_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ключ «показывать скрытые файлы» в настройках.
const showHiddenFilesKey = 'show_hidden_files';

/// Показывать ли в списке имена, которые начинаются с точки.
final showHiddenFilesProvider =
    NotifierProvider<ShowHiddenFilesController, bool>(
  ShowHiddenFilesController.new,
);

/// Читает и сохраняет переключатель скрытых файлов. По умолчанию выключен.
class ShowHiddenFilesController extends Notifier<bool> {
  @override
  bool build() =>
      ref.watch(sharedPreferencesProvider).getBool(showHiddenFilesKey) ?? false;

  Future<void> setShown(bool shown) async {
    state = shown;
    await ref.read(sharedPreferencesProvider).setBool(
          showHiddenFilesKey,
          shown,
        );
  }
}
