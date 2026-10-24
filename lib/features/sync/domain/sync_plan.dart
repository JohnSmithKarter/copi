import 'package:copi/core/domain/planned_action.dart';
import 'package:copi/core/domain/sync_mode.dart';

export 'package:copi/core/domain/planned_action.dart';

/// Файл, который участвует в сравнении.
class FileSnapshot {
  const FileSnapshot({
    required this.relativePath,
    required this.size,
    required this.modified,
  });

  final String relativePath;
  final int size;
  final DateTime modified;
}

/// Результат обхода одной папки. Ссылка хранится как цель, без перехода по ней.
class SyncTree {
  const SyncTree({
    required this.files,
    required this.directories,
    this.links = const <String, String>{},
  });

  final Map<String, FileSnapshot> files;
  final Set<String> directories;
  final Map<String, String> links;
}

/// Одна операция плана. Удаление папки идёт после удаления файлов.
class PlannedOperation {
  const PlannedOperation({
    required this.action,
    required this.relativePath,
    required this.size,
    this.linkTarget,
  });

  final PlannedAction action;
  final String relativePath;
  final int size;

  /// Цель символической ссылки. Пусто, если операция про обычный файл.
  final String? linkTarget;
}

/// Сравнивает уже собранные деревья и ничего не пишет на диск.
List<PlannedOperation> planOperations({
  required SyncTree source,
  required SyncTree destination,
  required SyncMode mode,
}) {
  final operations = <PlannedOperation>[];
  final sourcePaths = source.files.keys.toList()..sort();
  for (final path in sourcePaths) {
    final sourceFile = source.files[path];
    if (sourceFile == null) {
      continue;
    }
    final destinationFile = destination.files[path];
    final changed =
        destinationFile == null || _changed(sourceFile, destinationFile);
    if (changed) {
      operations.add(
        PlannedOperation(
          action: PlannedAction.copy,
          relativePath: path,
          size: sourceFile.size,
        ),
      );
    }
  }

  final linkPaths = source.links.keys.toList()..sort();
  for (final path in linkPaths) {
    final linkTarget = source.links[path];
    if (linkTarget == null || destination.links[path] == linkTarget) {
      continue;
    }
    operations.add(
      PlannedOperation(
        action: PlannedAction.copy,
        relativePath: path,
        size: 0,
        linkTarget: linkTarget,
      ),
    );
  }

  if (mode == SyncMode.mirror) {
    final extraFiles = destination.files.keys
        .where((path) => !_inSource(source, path))
        .toList()
      ..sort();
    for (final path in extraFiles) {
      operations.add(
        PlannedOperation(
          action: PlannedAction.deleteFile,
          relativePath: path,
          size: 0,
        ),
      );
    }
    final extraLinks = destination.links.keys
        .where((path) => !_inSource(source, path))
        .toList()
      ..sort();
    for (final path in extraLinks) {
      operations.add(
        PlannedOperation(
          action: PlannedAction.deleteFile,
          relativePath: path,
          size: 0,
        ),
      );
    }
    final extraDirectories = destination.directories
        .where(
          (path) =>
              !source.directories.contains(path) && !_inSource(source, path),
        )
        .toList()
      ..sort((a, b) => b.split('/').length.compareTo(a.split('/').length));
    for (final path in extraDirectories) {
      operations.add(
        PlannedOperation(
          action: PlannedAction.deleteDirectory,
          relativePath: path,
          size: 0,
        ),
      );
    }
  }

  return operations;
}

bool _inSource(SyncTree source, String path) =>
    source.files.containsKey(path) || source.links.containsKey(path);

bool _changed(FileSnapshot source, FileSnapshot destination) =>
    source.size != destination.size ||
    _seconds(source.modified) != _seconds(destination.modified);

int _seconds(DateTime value) => value.millisecondsSinceEpoch ~/ 1000;
