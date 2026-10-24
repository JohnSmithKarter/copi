import 'dart:async';

import 'package:copi/core/logging/app_failure.dart';
import 'package:copi/core/logging/talker_provider.dart';
import 'package:copi/core/storage/shared_preferences_provider.dart';
import 'package:copi/features/access/data/preferences_volume_access_repository.dart';
import 'package:copi/features/access/domain/external_volume.dart';
import 'package:copi/features/access/domain/volume_access.dart';
import 'package:copi/features/access/presentation/folder_access_provider.dart';
import 'package:copi/features/home/presentation/directory_providers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const volumeChannelName = 'copi/volumes';

final volumeAccessRepositoryProvider =
    Provider<PreferencesVolumeAccessRepository>(
  (ref) =>
      PreferencesVolumeAccessRepository(ref.watch(sharedPreferencesProvider)),
);

/// Подключённые внешние диски и сохранённый к ним доступ.
final mountedVolumesProvider =
    AsyncNotifierProvider<VolumeAccessController, List<VolumeAccess>>(
  VolumeAccessController.new,
);

class VolumeAccessController extends AsyncNotifier<List<VolumeAccess>> {
  @override
  Future<List<VolumeAccess>> build() async {
    ref.watch(directoryRevisionProvider);
    final subscription =
        const EventChannel(volumeChannelName).receiveBroadcastStream().listen(
              (_) => ref.invalidateSelf(),
              onError: (Object error, StackTrace stackTrace) {},
            );
    ref.onDispose(() => unawaited(subscription.cancel()));

    final gateway = ref.read(bookmarkGatewayProvider);
    final stored = ref.read(volumeAccessRepositoryProvider).read();
    List<VolumeCandidate> mounted;
    try {
      mounted = externalVolumes(await gateway.mountedVolumes());
    } on AppFailure {
      return const [];
    }
    if (mounted.isNotEmpty) {
      ref.read(appLogProvider).info(
            'External disks: ${mounted.map((volume) => volume.name).join(', ')}',
          );
    }
    final volumes = <VolumeAccess>[];
    for (final volume in mounted) {
      final bookmark = stored[volume.path];
      if (bookmark == null) {
        volumes.add(
          VolumeAccess(
            name: volume.name,
            mountPath: volume.path,
            path: null,
            bookmark: null,
          ),
        );
        continue;
      }
      try {
        final path = await gateway.startAccess(bookmark);
        volumes.add(
          VolumeAccess(
            name: volume.name,
            mountPath: volume.path,
            path: path,
            bookmark: bookmark,
          ),
        );
      } on AppFailure catch (error) {
        ref.read(appLogProvider).warning(
              'Stored permission for ${volume.name} was not restored: ${error.message ?? error.code.name}',
            );
        volumes.add(
          VolumeAccess(
            name: volume.name,
            mountPath: volume.path,
            path: null,
            bookmark: bookmark,
          ),
        );
      }
    }
    return volumes;
  }

  Future<void> grant(String mountPath) async {
    final log = ref.read(appLogProvider);
    final gateway = ref.read(bookmarkGatewayProvider);
    log.info('Permission requested for disk $mountPath');
    final picked = await gateway.pickFolder(directory: mountPath);
    if (picked == null) {
      log.info('Permission cancelled for disk $mountPath');
      return;
    }
    await ref
        .read(volumeAccessRepositoryProvider)
        .save(mountPath, picked.bookmark);
    await gateway.startAccess(picked.bookmark);
    log.info('Permission granted for disk $mountPath');
    ref.invalidateSelf();
  }
}
