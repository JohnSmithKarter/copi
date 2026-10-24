import 'dart:io';

import 'package:copi/core/logging/app_failure.dart';
import 'package:copi/core/logging/app_log.dart';
import 'package:copi/features/sync/domain/conflict_decision.dart';
import 'package:copi/features/sync/domain/sync_plan.dart';
import 'package:copi/features/sync/domain/sync_progress.dart';
import 'package:copi/features/sync/domain/sync_request.dart';
import 'package:path/path.dart' as p;

/// Сравнивает папки и выполняет план. Отмена не начинает следующий файл.
class SyncEngine {
  SyncEngine(this._log);

  final AppLog _log;
  ConflictResolver? _onConflict;
  ConflictAction? _forAll;

  Future<void> run({
    required List<SyncRequest> jobs,
    required CancellationToken cancellation,
    required void Function(SyncProgress progress) onProgress,
    ConflictResolver? onConflict,
  }) async {
    _onConflict = onConflict;
    _forAll = null;
    _log.info('Sync started: ${jobs.length} pair(s)');
    final placed = <SyncRequest>[];
    for (final job in jobs) {
      _validate(job);
      placed.add(_place(job));
    }

    final throttle = _ProgressThrottle(onProgress)
      ..emit(
        const SyncProgress(
          phase: SyncPhase.scanning,
          processedFiles: 0,
          totalFiles: 0,
          processedBytes: 0,
          totalBytes: 0,
        ),
        force: true,
      );
    await Future<void>.delayed(Duration.zero);

    final plans = <_JobPlan>[];
    for (final job in placed) {
      if (cancellation.isCancelled) {
        _finishCancelled(throttle, 0, 0);
        return;
      }
      final source = _scan(job.sourcePath, source: true);
      final destination = _scan(job.destinationPath, source: false);
      _log.info(
        'Scanned ${source.files.length} source files and ${destination.files.length} destination files',
      );
      plans.add(
        _JobPlan(
          job: job,
          operations: planOperations(
            source: source,
            destination: destination,
            mode: job.mode,
          ),
        ),
      );
    }

    final operations = [for (final plan in plans) ...plan.operations];
    final totalFiles = operations.length;
    final totalBytes = operations.fold<int>(
      0,
      (sum, operation) =>
          operation.action == PlannedAction.copy ? sum + operation.size : sum,
    );
    var processedFiles = 0;
    var processedBytes = 0;
    SyncPhase? phase;

    for (final plan in plans) {
      for (final operation in plan.operations) {
        if (cancellation.isCancelled) {
          _finishCancelled(
            throttle,
            processedFiles,
            totalFiles,
            processedBytes: processedBytes,
            totalBytes: totalBytes,
          );
          return;
        }
        final nextPhase = switch (operation.action) {
          PlannedAction.copy => SyncPhase.copying,
          PlannedAction.deleteFile ||
          PlannedAction.deleteDirectory =>
            SyncPhase.deleting,
        };
        final phaseChanged = phase != nextPhase;
        phase = nextPhase;
        throttle.emit(
          SyncProgress(
            phase: nextPhase,
            processedFiles: processedFiles,
            totalFiles: totalFiles,
            processedBytes: processedBytes,
            totalBytes: totalBytes,
            currentFile: operation.relativePath,
          ),
          force: phaseChanged,
        );
        final outcome = await _perform(plan.job, operation, cancellation);
        processedFiles += 1;
        if (outcome.wrote) {
          processedBytes += operation.size;
        }
        _log.info(outcome.log);
        throttle.emit(
          SyncProgress(
            phase: nextPhase,
            processedFiles: processedFiles,
            totalFiles: totalFiles,
            processedBytes: processedBytes,
            totalBytes: totalBytes,
            currentFile: operation.relativePath,
          ),
          force: true,
        );
        await Future<void>.delayed(Duration.zero);
      }
    }

    throttle.emit(
      SyncProgress(
        phase: SyncPhase.done,
        processedFiles: totalFiles,
        totalFiles: totalFiles,
        processedBytes: totalBytes,
        totalBytes: totalBytes,
      ),
      force: true,
    );
    _log.info('Sync finished');
  }

  void _validate(SyncRequest job) {
    final source = Directory(job.sourcePath);
    final parent = Directory(job.destinationPath);
    try {
      if (!source.existsSync()) {
        _log.abort(
          AppFailureCode.accessDenied,
          message: 'Source is unavailable. Nothing was copied.',
        );
      }
      if (!parent.existsSync()) {
        _log.abort(
          AppFailureCode.destinationUnavailable,
          message: 'Destination unavailable. Nothing was deleted.',
        );
      }
      final copyRoot = _copyRoot(job);
      final sourcePath = source.resolveSymbolicLinksSync();
      if (p.equals(sourcePath, copyRoot) ||
          p.isWithin(sourcePath, copyRoot) ||
          p.isWithin(copyRoot, sourcePath)) {
        _log.abort(
          AppFailureCode.sameLocation,
          message: 'Source and destination are the same folder.',
        );
      }
    } on FileSystemException catch (error, stackTrace) {
      _log.abort(
        AppFailureCode.destinationUnavailable,
        message: 'Could not open the folders. Nothing was copied.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Папка источника ложится внутрь выбранного места под своим именем.
  SyncRequest _place(SyncRequest job) {
    try {
      final copyRoot = _copyRoot(job);
      Directory(copyRoot).createSync();
      return SyncRequest(
        sourcePath: Directory(job.sourcePath).resolveSymbolicLinksSync(),
        destinationPath: copyRoot,
        mode: job.mode,
      );
    } on FileSystemException catch (error, stackTrace) {
      _log.abort(
        AppFailureCode.destinationUnavailable,
        message: 'Destination unavailable. Nothing was deleted.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  String _copyRoot(SyncRequest job) {
    final source = Directory(job.sourcePath).resolveSymbolicLinksSync();
    final parent = Directory(job.destinationPath).resolveSymbolicLinksSync();
    return p.join(parent, p.basename(source));
  }

  SyncTree _scan(String root, {required bool source}) {
    final files = <String, FileSnapshot>{};
    final directories = <String>{};
    final links = <String, String>{};
    try {
      for (final entity in Directory(root).listSync(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is Link) {
          final relative = _relative(root, entity.path);
          if (relative.isEmpty) {
            continue;
          }
          links[relative] = entity.targetSync();
          continue;
        }
        final relative = _relative(root, entity.path);
        if (relative.isEmpty) {
          continue;
        }
        if (entity is Directory) {
          directories.add(relative);
          continue;
        }
        if (entity is! File) {
          continue;
        }
        final stat = entity.statSync();
        files[relative] = FileSnapshot(
          relativePath: relative,
          size: stat.size,
          modified: stat.modified,
        );
      }
    } on FileSystemException catch (error, stackTrace) {
      _log.abort(
        source
            ? AppFailureCode.accessDenied
            : AppFailureCode.destinationUnavailable,
        message: source
            ? 'Could not read $root. Nothing was copied.'
            : 'Could not read $root. Nothing was deleted.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
    return SyncTree(files: files, directories: directories, links: links);
  }

  Future<_Outcome> _perform(
    SyncRequest job,
    PlannedOperation operation,
    CancellationToken cancellation,
  ) async {
    final target = _join(job.destinationPath, operation.relativePath);
    final label = '${operation.action.name} ${operation.relativePath}';
    switch (operation.action) {
      case PlannedAction.copy:
        return _copy(job, operation, target, cancellation);
      case PlannedAction.deleteFile:
        _deleteFile(target, operation.relativePath);
        return _Outcome(log: label);
      case PlannedAction.deleteDirectory:
        _deleteDirectory(target, operation.relativePath);
        return _Outcome(log: label);
    }
  }

  Future<_Outcome> _copy(
    SyncRequest job,
    PlannedOperation operation,
    String target,
    CancellationToken cancellation,
  ) async {
    try {
      return await _copyUnlocked(job, operation, target, cancellation);
    } on FileSystemException catch (error, stackTrace) {
      _log.abort(
        AppFailureCode.fileFailed,
        message: 'Could not copy ${operation.relativePath}',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<_Outcome> _copyUnlocked(
    SyncRequest job,
    PlannedOperation operation,
    String target,
    CancellationToken cancellation,
  ) async {
    final linkTarget = operation.linkTarget;
    if (linkTarget != null) {
      return _copyLink(operation, target, linkTarget, cancellation);
    }
    final source = File(_join(job.sourcePath, operation.relativePath));
    final kind = _kind(target);
    if (kind == FileSystemEntityType.link) {
      Link(target).deleteSync();
      await _write(source, target);
      return _Outcome(
        wrote: true,
        log: 'copy ${operation.relativePath}',
      );
    }
    if (kind == FileSystemEntityType.notFound) {
      await _write(source, target);
      return _Outcome(
        wrote: true,
        log: 'copy ${operation.relativePath}',
      );
    }
    if (kind != FileSystemEntityType.file) {
      final copyPath = _duplicate(target);
      await _write(source, copyPath);
      return _Outcome(
        wrote: true,
        log: 'keepBoth ${operation.relativePath} -> ${p.basename(copyPath)}',
      );
    }
    final action = await _resolve(operation.relativePath);
    if (cancellation.isCancelled) {
      return _Outcome(log: 'skip ${operation.relativePath}');
    }
    switch (action) {
      case ConflictAction.skip:
        return _Outcome(log: 'skip ${operation.relativePath}');
      case ConflictAction.replace:
        await _replace(source, target);
        return _Outcome(
          wrote: true,
          log: 'replace ${operation.relativePath}',
        );
      case ConflictAction.keepBoth:
        final copyPath = _duplicate(target);
        await _write(source, copyPath);
        return _Outcome(
          wrote: true,
          log: 'keepBoth ${operation.relativePath} -> ${p.basename(copyPath)}',
        );
    }
  }

  Future<_Outcome> _copyLink(
    PlannedOperation operation,
    String target,
    String linkTarget,
    CancellationToken cancellation,
  ) async {
    final kind = _kind(target);
    if (kind == FileSystemEntityType.notFound) {
      _createLink(target, linkTarget);
      return _Outcome(wrote: true, log: 'link ${operation.relativePath}');
    }
    if (kind == FileSystemEntityType.link) {
      final existing = Link(target);
      if (existing.targetSync() == linkTarget) {
        return _Outcome(log: 'link unchanged ${operation.relativePath}');
      }
      existing.deleteSync();
      _createLink(target, linkTarget);
      return _Outcome(wrote: true, log: 'link ${operation.relativePath}');
    }
    if (kind == FileSystemEntityType.directory) {
      final copyPath = _duplicate(target);
      _createLink(copyPath, linkTarget);
      return _Outcome(
        wrote: true,
        log: 'keepBoth ${operation.relativePath} -> ${p.basename(copyPath)}',
      );
    }
    final action = await _resolve(operation.relativePath);
    if (cancellation.isCancelled || action == ConflictAction.skip) {
      return _Outcome(log: 'skip ${operation.relativePath}');
    }
    if (action == ConflictAction.keepBoth) {
      final copyPath = _duplicate(target);
      _createLink(copyPath, linkTarget);
      return _Outcome(
        wrote: true,
        log: 'keepBoth ${operation.relativePath} -> ${p.basename(copyPath)}',
      );
    }
    File(target).deleteSync();
    _createLink(target, linkTarget);
    return _Outcome(wrote: true, log: 'link ${operation.relativePath}');
  }

  void _createLink(String path, String linkTarget) {
    Directory(p.dirname(path)).createSync(recursive: true);
    Link(path).createSync(linkTarget);
  }

  void _deleteFile(String target, String relativePath) {
    try {
      final kind = _kind(target);
      if (kind == FileSystemEntityType.link) {
        Link(target).deleteSync();
        return;
      }
      if (kind == FileSystemEntityType.file) {
        File(target).deleteSync();
      }
    } on FileSystemException catch (error, stackTrace) {
      _log.abort(
        AppFailureCode.fileFailed,
        message: 'Could not delete $relativePath',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _deleteDirectory(String target, String relativePath) {
    try {
      if (_kind(target) != FileSystemEntityType.directory) {
        return;
      }
      final directory = Directory(target);
      if (directory.listSync(followLinks: false).isEmpty) {
        directory.deleteSync();
      }
    } on FileSystemException catch (error, stackTrace) {
      _log.abort(
        AppFailureCode.fileFailed,
        message: 'Could not delete $relativePath',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<ConflictAction> _resolve(String relativePath) async {
    final remembered = _forAll;
    if (remembered != null) {
      return remembered;
    }
    final resolver = _onConflict;
    if (resolver == null) {
      return ConflictAction.replace;
    }
    final decision = await resolver(relativePath);
    if (decision.applyToAll) {
      _forAll = decision.action;
    }
    return decision.action;
  }

  Future<void> _write(File source, String target) async {
    Directory(p.dirname(target)).createSync(recursive: true);
    await source.copy(target);
  }

  /// Сначала пишет копию рядом. Старый файл удаляется только после этого.
  Future<void> _replace(File source, String target) async {
    final partial = p.join(
      p.dirname(target),
      '.${p.basename(target)}.copi-partial',
    );
    try {
      await _write(source, partial);
      final existing = File(target);
      if (existing.existsSync()) {
        existing.deleteSync();
      }
      File(partial).renameSync(target);
    } on FileSystemException {
      await _restorePartial(partial, target);
      rethrow;
    }
  }

  Future<void> _restorePartial(String partial, String target) async {
    final copied = File(partial);
    if (!copied.existsSync()) {
      return;
    }
    try {
      if (File(target).existsSync()) {
        copied.deleteSync();
        return;
      }
      copied.renameSync(target);
    } on FileSystemException catch (error, stackTrace) {
      _log.error(
        'Could not remove partial copy $partial',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Свободное имя рядом: `photo.jpg` становится `photo (1).jpg`.
  String _duplicate(String target) {
    final directory = p.dirname(target);
    final name = p.basenameWithoutExtension(target);
    final extension = p.extension(target);
    var index = 1;
    while (_kind(p.join(directory, '$name ($index)$extension')) !=
        FileSystemEntityType.notFound) {
      index += 1;
    }
    return p.join(directory, '$name ($index)$extension');
  }

  FileSystemEntityType _kind(String path) =>
      FileSystemEntity.typeSync(path, followLinks: false);

  void _finishCancelled(
    _ProgressThrottle throttle,
    int processedFiles,
    int totalFiles, {
    int processedBytes = 0,
    int totalBytes = 0,
  }) {
    _log.info('Sync cancelled');
    throttle.emit(
      SyncProgress(
        phase: SyncPhase.cancelled,
        processedFiles: processedFiles,
        totalFiles: totalFiles,
        processedBytes: processedBytes,
        totalBytes: totalBytes,
      ),
      force: true,
    );
  }

  String _join(String root, String relative) =>
      p.joinAll([root, ...relative.split('/')]);

  String _relative(String root, String full) {
    final relative = p.relative(p.normalize(full), from: p.normalize(root));
    if (relative == '.' || relative.startsWith('..')) {
      return '';
    }
    return p.split(relative).join('/');
  }
}

class _Outcome {
  const _Outcome({required this.log, this.wrote = false});

  final bool wrote;
  final String log;
}

class _JobPlan {
  const _JobPlan({required this.job, required this.operations});

  final SyncRequest job;
  final List<PlannedOperation> operations;
}

class _ProgressThrottle {
  _ProgressThrottle(this._emit);

  final void Function(SyncProgress progress) _emit;
  DateTime? _last;

  void emit(SyncProgress progress, {bool force = false}) {
    final now = DateTime.now();
    final last = _last;
    final due = last == null ||
        now.difference(last) >= const Duration(milliseconds: 100);
    if (!force && !due) {
      return;
    }
    _last = now;
    _emit(progress);
  }
}
