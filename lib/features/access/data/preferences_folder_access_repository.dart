import 'dart:convert';

import 'package:copi/features/access/domain/folder_access_repository.dart';
import 'package:copi/features/access/domain/folder_root.dart';
import 'package:shared_preferences/shared_preferences.dart';

const folderBookmarksKey = 'folder_bookmarks';

/// JSON-карта идентификатор папки → закладка.
class PreferencesFolderAccessRepository implements FolderAccessRepository {
  const PreferencesFolderAccessRepository(this._preferences);

  final SharedPreferences _preferences;

  @override
  Map<FolderRootId, String> read() =>
      decodeFolderBookmarks(_preferences.getString(folderBookmarksKey));

  @override
  Future<void> save(FolderRootId id, String bookmark) async {
    final stored = read()..[id] = bookmark;
    final encoded = <String, String>{
      for (final entry in stored.entries) entry.key.name: entry.value,
    };
    await _preferences.setString(folderBookmarksKey, jsonEncode(encoded));
  }
}

Map<FolderRootId, String> decodeFolderBookmarks(String? raw) {
  if (raw == null || raw.isEmpty) {
    return {};
  }
  final Object? decoded = jsonDecode(raw) as Object?;
  if (decoded is! Map) {
    return {};
  }
  final map = Map<Object?, Object?>.from(decoded);
  final result = <FolderRootId, String>{};
  for (final entry in map.entries) {
    final key = entry.key;
    final value = entry.value;
    if (key is! String || value is! String) {
      continue;
    }
    final id = FolderRootId.values.asNameMap()[key];
    if (id == null) {
      continue;
    }
    result[id] = value;
  }
  return result;
}
