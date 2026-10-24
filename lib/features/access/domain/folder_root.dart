import 'package:copi/core/domain/folder_root_id.dart';

export 'package:copi/core/domain/folder_root_id.dart';

/// Разрешение на один раздел. [path] есть, пока закладка открыта.
class ResolvedRoot {
  const ResolvedRoot({
    required this.id,
    required this.bookmark,
    required this.path,
  });

  final FolderRootId id;
  final String? bookmark;
  final String? path;

  bool get hasAccess => path != null && path!.isNotEmpty;
}
