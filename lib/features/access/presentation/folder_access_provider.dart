import 'package:copi/core/logging/app_failure.dart';
import 'package:copi/core/logging/talker_provider.dart';
import 'package:copi/core/storage/shared_preferences_provider.dart';
import 'package:copi/features/access/data/method_channel_bookmark_gateway.dart';
import 'package:copi/features/access/data/preferences_folder_access_repository.dart';
import 'package:copi/features/access/data/suggested_directory.dart';
import 'package:copi/features/access/domain/bookmark_gateway.dart';
import 'package:copi/features/access/domain/folder_access_repository.dart';
import 'package:copi/features/access/domain/folder_root.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Мост к системным закладкам.
final bookmarkGatewayProvider = Provider<BookmarkGateway>(
  (ref) => MethodChannelBookmarkGateway(log: ref.watch(appLogProvider)),
);

/// Закладки четырёх стандартных папок.
final folderAccessRepositoryProvider = Provider<FolderAccessRepository>(
  (ref) => PreferencesFolderAccessRepository(
    ref.watch(sharedPreferencesProvider),
  ),
);

/// Открытые разделы главной страницы.
final folderAccessProvider =
    AsyncNotifierProvider<FolderAccessController, List<ResolvedRoot>>(
  FolderAccessController.new,
);

/// Читает сохранённые закладки и открывает к ним доступ.
class FolderAccessController extends AsyncNotifier<List<ResolvedRoot>> {
  @override
  Future<List<ResolvedRoot>> build() async {
    final stored = ref.watch(folderAccessRepositoryProvider).read();
    final gateway = ref.read(bookmarkGatewayProvider);
    final roots = <ResolvedRoot>[];
    for (final id in FolderRootId.values) {
      final bookmark = stored[id];
      if (bookmark == null) {
        roots.add(ResolvedRoot(id: id, bookmark: null, path: null));
        continue;
      }
      try {
        final path = await gateway.startAccess(bookmark);
        roots.add(ResolvedRoot(id: id, bookmark: bookmark, path: path));
      } on AppFailure catch (error) {
        ref.read(appLogProvider).warning(
              'Stored permission for ${id.name} was not restored: ${error.message ?? error.code.name}',
            );
        roots.add(ResolvedRoot(id: id, bookmark: bookmark, path: null));
      }
    }
    return roots;
  }

  /// Системный диалог и сохранение закладки для одного раздела.
  Future<void> grant(FolderRootId id) async {
    final log = ref.read(appLogProvider);
    final gateway = ref.read(bookmarkGatewayProvider);
    log.info('Permission requested for ${id.name}');
    final picked = await gateway.pickFolder(directory: suggestedDirectory(id));
    if (picked == null) {
      log.info('Permission cancelled for ${id.name}');
      return;
    }
    await ref.read(folderAccessRepositoryProvider).save(id, picked.bookmark);
    final path = await gateway.startAccess(picked.bookmark);
    log.info('Permission granted for ${id.name}: $path');
    final current = {
      for (final root in state.value ?? <ResolvedRoot>[]) root.id: root,
    };
    state = AsyncData([
      for (final rootId in FolderRootId.values)
        if (rootId == id)
          ResolvedRoot(id: id, bookmark: picked.bookmark, path: path)
        else
          current[rootId] ??
              ResolvedRoot(id: rootId, bookmark: null, path: null),
    ]);
  }
}
