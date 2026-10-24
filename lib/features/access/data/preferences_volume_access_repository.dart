import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const volumeBookmarksKey = 'volume_bookmarks';

/// JSON-карта путь тома → закладка.
class PreferencesVolumeAccessRepository {
  const PreferencesVolumeAccessRepository(this._preferences);

  final SharedPreferences _preferences;

  Map<String, String> read() =>
      decodeVolumeBookmarks(_preferences.getString(volumeBookmarksKey));

  Future<void> save(String mountPath, String bookmark) async {
    final stored = read()..[mountPath] = bookmark;
    await _preferences.setString(volumeBookmarksKey, jsonEncode(stored));
  }
}

Map<String, String> decodeVolumeBookmarks(String? raw) {
  if (raw == null || raw.isEmpty) {
    return {};
  }
  final Object? decoded = jsonDecode(raw) as Object?;
  if (decoded is! Map) {
    return {};
  }
  final map = Map<Object?, Object?>.from(decoded);
  final result = <String, String>{};
  for (final entry in map.entries) {
    final key = entry.key;
    final value = entry.value;
    if (key is String && value is String && key.isNotEmpty) {
      result[key] = value;
    }
  }
  return result;
}
