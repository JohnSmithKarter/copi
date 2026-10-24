import 'dart:io';

import 'package:copi/features/home/domain/directory_entry.dart';
import 'package:copi/features/home/domain/directory_gateway.dart';
import 'package:path/path.dart' as p;

/// Список ближайших детей папки через `dart:io`.
class IoDirectoryGateway implements DirectoryGateway {
  const IoDirectoryGateway();

  @override
  Future<List<DirectoryEntry>> list(
    String directory, {
    bool includeHidden = false,
  }) async {
    final entities =
        await Directory(directory).list(followLinks: false).toList();
    final entries = <DirectoryEntry>[];
    for (final entity in entities) {
      if (entity is Link) {
        continue;
      }
      final name = p.basename(entity.path);
      if (name.isEmpty || (!includeHidden && name.startsWith('.'))) {
        continue;
      }
      final isDirectory = entity is Directory;
      entries.add(
        DirectoryEntry(
          name: name,
          path: entity.path,
          isDirectory: isDirectory,
          kind: fileKindForName(name, isDirectory: isDirectory),
        ),
      );
    }
    entries.sort((a, b) {
      if (a.isDirectory != b.isDirectory) {
        return a.isDirectory ? -1 : 1;
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return entries;
  }
}
