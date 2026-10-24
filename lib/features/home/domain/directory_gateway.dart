import 'package:copi/features/home/domain/directory_entry.dart';

/// Читает один уровень папки, без символических ссылок.
///
/// Имена с точкой попадают в список только при [includeHidden].
abstract interface class DirectoryGateway {
  Future<List<DirectoryEntry>> list(
    String directory, {
    bool includeHidden = false,
  });
}
