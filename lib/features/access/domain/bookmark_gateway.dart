import 'package:copi/features/access/domain/external_volume.dart';

/// Папка, выбранная системным диалогом.
class PickedFolder {
  const PickedFolder({required this.path, required this.bookmark});

  final String path;
  final String bookmark;
}

/// Закладки доступа к папкам. На macOS это security-scoped bookmark.
abstract interface class BookmarkGateway {
  Future<PickedFolder?> pickFolder({String? directory});

  Future<String> bookmarkForPath(String path);

  Future<String> startAccess(String bookmark);

  Future<void> stopAccess(String bookmark);

  /// Смонтированные тома. Пустой список, если канал недоступен.
  Future<List<VolumeCandidate>> mountedVolumes();
}
