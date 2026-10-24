import 'package:copi/core/domain/sync_mode.dart';

/// Пара «откуда → куда» внутри пресета.
class PresetPair {
  const PresetPair({
    required this.id,
    required this.sourceBookmark,
    required this.destinationBookmark,
    required this.sourceLabel,
    required this.destinationLabel,
    required this.mode,
  });

  final String id;
  final String sourceBookmark;
  final String destinationBookmark;
  final String sourceLabel;
  final String destinationLabel;
  final SyncMode mode;

  /// Та же пара с другим режимом. Остальные поля не меняются.
  PresetPair copyWith({required SyncMode mode}) => PresetPair(
        id: id,
        sourceBookmark: sourceBookmark,
        destinationBookmark: destinationBookmark,
        sourceLabel: sourceLabel,
        destinationLabel: destinationLabel,
        mode: mode,
      );
}

/// Сохранённый набор пар копирования.
class Preset {
  const Preset({
    required this.id,
    required this.name,
    required this.pairs,
  });

  final String id;
  final String name;
  final List<PresetPair> pairs;
}
