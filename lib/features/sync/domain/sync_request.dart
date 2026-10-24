import 'package:copi/core/domain/sync_mode.dart';

/// Одна пара папок, уже открытая для чтения и записи.
class SyncRequest {
  const SyncRequest({
    required this.sourcePath,
    required this.destinationPath,
    required this.mode,
  });

  final String sourcePath;
  final String destinationPath;
  final SyncMode mode;
}

/// Отмена проверяется между файлами.
class CancellationToken {
  bool _cancelled = false;

  bool get isCancelled => _cancelled;

  void cancel() => _cancelled = true;
}
