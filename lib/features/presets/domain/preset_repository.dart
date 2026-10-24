import 'package:copi/features/presets/domain/preset.dart';

/// Хранение пресетов пользователя.
abstract interface class PresetRepository {
  List<Preset> load();

  Future<void> save(Preset preset);

  Future<void> delete(String id);
}
