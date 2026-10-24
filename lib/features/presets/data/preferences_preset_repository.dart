import 'dart:convert';

import 'package:copi/core/domain/sync_mode.dart';
import 'package:copi/features/presets/domain/preset.dart';
import 'package:copi/features/presets/domain/preset_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ключ JSON-списка пресетов.
const presetsStorageKey = 'presets';

/// Пресеты лежат одним JSON-списком в настройках.
class PreferencesPresetRepository implements PresetRepository {
  const PreferencesPresetRepository(this._preferences);

  final SharedPreferences _preferences;

  @override
  Future<void> delete(String id) async {
    final next = load().where((preset) => preset.id != id).toList();
    await _write(next);
  }

  @override
  List<Preset> load() =>
      decodePresets(_preferences.getString(presetsStorageKey));

  @override
  Future<void> save(Preset preset) async {
    final stored = load();
    final index = stored.indexWhere((item) => item.id == preset.id);
    if (index == -1) {
      stored.add(preset);
    } else {
      stored[index] = preset;
    }
    await _write(stored);
  }

  Future<void> _write(List<Preset> presets) => _preferences.setString(
        presetsStorageKey,
        jsonEncode(presets.map(_encodePreset).toList()),
      );
}

List<Preset> decodePresets(String? raw) {
  if (raw == null || raw.isEmpty) {
    return [];
  }
  final Object? decoded = jsonDecode(raw) as Object?;
  if (decoded is! List) {
    return [];
  }
  final presets = <Preset>[];
  for (final item in decoded) {
    if (item is! Map) {
      continue;
    }
    final preset = _decodePreset(Map<Object?, Object?>.from(item));
    if (preset != null) {
      presets.add(preset);
    }
  }
  return presets;
}

Map<String, Object?> _encodePreset(Preset preset) => {
      'id': preset.id,
      'name': preset.name,
      'pairs': preset.pairs.map(_encodePair).toList(),
    };

Map<String, Object?> _encodePair(PresetPair pair) => {
      'id': pair.id,
      'sourceBookmark': pair.sourceBookmark,
      'destinationBookmark': pair.destinationBookmark,
      'sourceLabel': pair.sourceLabel,
      'destinationLabel': pair.destinationLabel,
      'mode': pair.mode.name,
    };

Preset? _decodePreset(Map<Object?, Object?> json) {
  final id = json['id'];
  final name = json['name'];
  final rawPairs = json['pairs'];
  if (id is! String || name is! String || rawPairs is! List) {
    return null;
  }
  final pairs = <PresetPair>[];
  for (final item in rawPairs) {
    if (item is! Map) {
      continue;
    }
    final pair = _decodePair(Map<Object?, Object?>.from(item));
    if (pair != null) {
      pairs.add(pair);
    }
  }
  return Preset(id: id, name: name, pairs: pairs);
}

PresetPair? _decodePair(Map<Object?, Object?> json) {
  final id = json['id'];
  final sourceBookmark = json['sourceBookmark'];
  final destinationBookmark = json['destinationBookmark'];
  final sourceLabel = json['sourceLabel'];
  final destinationLabel = json['destinationLabel'];
  final mode = json['mode'];
  if (id is! String ||
      sourceBookmark is! String ||
      destinationBookmark is! String ||
      sourceLabel is! String ||
      destinationLabel is! String ||
      mode is! String) {
    return null;
  }
  final syncMode = SyncMode.values.asNameMap()[mode];
  if (syncMode == null) {
    return null;
  }
  return PresetPair(
    id: id,
    sourceBookmark: sourceBookmark,
    destinationBookmark: destinationBookmark,
    sourceLabel: sourceLabel,
    destinationLabel: destinationLabel,
    mode: syncMode,
  );
}
