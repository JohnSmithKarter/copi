import 'package:copi/core/domain/sync_phase.dart';

export 'package:copi/core/domain/sync_phase.dart';

/// Снимок прогресса. [message] — имя кода ошибки, если фаза ошибки.
class SyncProgress {
  const SyncProgress({
    required this.phase,
    required this.processedFiles,
    required this.totalFiles,
    required this.processedBytes,
    required this.totalBytes,
    this.currentFile,
    this.message,
  });

  final SyncPhase phase;
  final int processedFiles;
  final int totalFiles;
  final int processedBytes;
  final int totalBytes;
  final String? currentFile;
  final String? message;

  double get fraction {
    if (totalBytes > 0) {
      return processedBytes / totalBytes;
    }
    if (totalFiles == 0) {
      return phase == SyncPhase.done ? 1 : 0;
    }
    return processedFiles / totalFiles;
  }
}
