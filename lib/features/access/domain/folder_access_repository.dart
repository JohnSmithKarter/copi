import 'package:copi/features/access/domain/folder_root.dart';

/// Сохранённые закладки стандартных папок.
abstract interface class FolderAccessRepository {
  Map<FolderRootId, String> read();

  Future<void> save(FolderRootId id, String bookmark);
}
