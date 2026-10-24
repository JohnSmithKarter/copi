import 'dart:io';

import 'package:copi/features/access/domain/folder_root.dart';

/// Папка, с которой открывается системный диалог для этого раздела.
String? suggestedDirectory(FolderRootId id) {
  final home = Platform.environment['HOME'];
  if (home == null || home.isEmpty) {
    return null;
  }
  return switch (id) {
    FolderRootId.home => home,
    FolderRootId.desktop => '$home/Desktop',
    FolderRootId.documents => '$home/Documents',
    FolderRootId.downloads => '$home/Downloads',
  };
}
