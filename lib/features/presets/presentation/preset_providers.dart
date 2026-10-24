import 'package:copi/core/logging/app_failure.dart';
import 'package:copi/core/logging/talker_provider.dart';
import 'package:copi/core/storage/shared_preferences_provider.dart';
import 'package:copi/features/access/presentation/folder_access_provider.dart';
import 'package:copi/features/presets/data/preferences_preset_repository.dart';
import 'package:copi/features/presets/domain/preset.dart';
import 'package:copi/features/presets/domain/preset_repository.dart';
import 'package:copi/features/sync/data/sync_engine.dart';
import 'package:copi/features/sync/domain/conflict_decision.dart';
import 'package:copi/features/sync/domain/sync_progress.dart';
import 'package:copi/features/sync/domain/sync_request.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// JSON-хранилище пресетов.
final presetRepositoryProvider = Provider<PresetRepository>(
  (ref) => PreferencesPresetRepository(ref.watch(sharedPreferencesProvider)),
);

/// Список пресетов.
final presetsProvider = AsyncNotifierProvider<PresetsController, List<Preset>>(
  PresetsController.new,
);

/// Сохраняет и удаляет пресеты.
class PresetsController extends AsyncNotifier<List<Preset>> {
  @override
  Future<List<Preset>> build() async =>
      ref.watch(presetRepositoryProvider).load();

  Future<void> delete(String id) async {
    ref.read(appLogProvider).info('Delete preset $id');
    await ref.read(presetRepositoryProvider).delete(id);
    state = AsyncData(ref.read(presetRepositoryProvider).load());
  }

  Future<void> save(Preset preset) async {
    ref.read(appLogProvider).info('Save preset ${preset.name}');
    await ref.read(presetRepositoryProvider).save(preset);
    state = AsyncData(ref.read(presetRepositoryProvider).load());
  }
}

/// Прогресс текущего запуска. Пусто, пока пользователь ничего не запускал.
final syncControllerProvider =
    NotifierProvider<SyncController, SyncProgress?>(SyncController.new);

/// Открывает закладки пресета и гоняет [SyncEngine].
class SyncController extends Notifier<SyncProgress?> {
  CancellationToken? _token;

  @override
  SyncProgress? build() => null;

  void cancel() {
    ref.read(appLogProvider).info('Sync cancel requested');
    _token?.cancel();
  }

  Future<void> start(
    Preset preset, {
    ConflictResolver? onConflict,
  }) async {
    final log = ref.read(appLogProvider);
    final phase = state?.phase;
    final running = phase == SyncPhase.scanning ||
        phase == SyncPhase.copying ||
        phase == SyncPhase.deleting;
    if (running) {
      log.warning('Sync is already running');
      return;
    }

    log.info('Sync preset "${preset.name}"');
    final token = CancellationToken();
    _token = token;
    final gateway = ref.read(bookmarkGatewayProvider);
    final opened = <String>[];
    try {
      final jobs = <SyncRequest>[];
      for (final pair in preset.pairs) {
        log.info('Open ${pair.sourceLabel} -> ${pair.destinationLabel}');
        final source = await gateway.startAccess(pair.sourceBookmark);
        final destination = await gateway.startAccess(
          pair.destinationBookmark,
        );
        opened
          ..add(pair.sourceBookmark)
          ..add(pair.destinationBookmark);
        jobs.add(
          SyncRequest(
            sourcePath: source,
            destinationPath: destination,
            mode: pair.mode,
          ),
        );
      }
      await SyncEngine(log).run(
        jobs: jobs,
        cancellation: token,
        onProgress: (progress) => state = progress,
        onConflict: onConflict,
      );
    } on AppFailure catch (error) {
      state = _errorProgress(error.code.name);
    } on Object catch (error, stackTrace) {
      log.error(
        'Sync preset "${preset.name}" failed',
        error: error,
        stackTrace: stackTrace,
      );
      state = _errorProgress(AppFailureCode.unexpected.name);
    } finally {
      for (final bookmark in opened) {
        try {
          await gateway.stopAccess(bookmark);
        } on AppFailure catch (error) {
          log.warning(
            'Could not close folder access: ${error.message ?? error.code.name}',
          );
        } on Object catch (error, stackTrace) {
          log.error(
            'Could not close folder access',
            error: error,
            stackTrace: stackTrace,
          );
        }
      }
    }
  }

  SyncProgress _errorProgress(String code) {
    final current = state;
    return SyncProgress(
      phase: SyncPhase.error,
      processedFiles: current?.processedFiles ?? 0,
      totalFiles: current?.totalFiles ?? 0,
      processedBytes: current?.processedBytes ?? 0,
      totalBytes: current?.totalBytes ?? 0,
      message: code,
    );
  }
}
