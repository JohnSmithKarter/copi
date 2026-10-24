import 'dart:async';
import 'dart:io';

import 'package:copi/features/home/data/io_directory_gateway.dart';
import 'package:copi/features/home/domain/directory_entry.dart';
import 'package:copi/features/home/domain/directory_gateway.dart';
import 'package:copi/features/home/presentation/hidden_files_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Чтение одного уровня папки.
final directoryGatewayProvider = Provider<DirectoryGateway>(
  (ref) => const IoDirectoryGateway(),
);

/// Растёт, когда приложение снова становится активным и списки надо перечитать.
final directoryRevisionProvider =
    NotifierProvider<DirectoryRevision, int>(DirectoryRevision.new);

/// Счётчик перечитывания открытых папок.
class DirectoryRevision extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

/// Дети папки. Пока строка свёрнута, провайдер отпускается.
///
/// Пока папка открыта, следит за ней и подхватывает новые файлы без перезапуска.
final directoryListingProvider =
    FutureProvider.autoDispose.family<List<DirectoryEntry>, String>((
  ref,
  directory,
) {
  ref.watch(directoryRevisionProvider);
  final includeHidden = ref.watch(showHiddenFilesProvider);
  _watchDirectory(ref, directory);
  return ref.watch(directoryGatewayProvider).list(
        directory,
        includeHidden: includeHidden,
      );
});

void _watchDirectory(Ref ref, String directory) {
  StreamSubscription<FileSystemEvent>? subscription;
  Timer? timer;
  try {
    subscription = Directory(directory).watch().listen(
      (_) {
        timer?.cancel();
        timer = Timer(const Duration(milliseconds: 400), () {
          ref.invalidateSelf();
        });
      },
      onError: (Object error, StackTrace stackTrace) {
        // Наблюдение недоступно. Список остаётся тем, что уже прочитан.
      },
    );
  } on FileSystemException {
    return;
  }
  ref.onDispose(() {
    timer?.cancel();
    unawaited(subscription?.cancel());
  });
}
