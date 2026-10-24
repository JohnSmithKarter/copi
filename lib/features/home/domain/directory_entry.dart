import 'package:copi/core/domain/file_kind.dart';

export 'package:copi/core/domain/file_kind.dart';

/// Один уровень папки: имя, полный путь и вид значка.
class DirectoryEntry {
  const DirectoryEntry({
    required this.name,
    required this.path,
    required this.isDirectory,
    required this.kind,
  });

  final String name;
  final String path;
  final bool isDirectory;
  final FileKind kind;
}

/// Значок по расширению.
FileKind fileKindForName(String name, {bool isDirectory = false}) {
  final extension = _extension(name);
  if (isDirectory) {
    return switch (extension) {
      '.app' => FileKind.application,
      '.pages' || '.rtfd' => FileKind.document,
      '.numbers' => FileKind.spreadsheet,
      '.key' => FileKind.presentation,
      '.band' || '.logicx' => FileKind.audio,
      '.sparsebundle' => FileKind.disk,
      '.sketch' => FileKind.design,
      '.xcodeproj' || '.xcworkspace' || '.playground' => FileKind.code,
      _ => FileKind.folder,
    };
  }
  return switch (extension) {
    '.jpg' ||
    '.jpeg' ||
    '.png' ||
    '.gif' ||
    '.webp' ||
    '.heic' ||
    '.heif' ||
    '.tif' ||
    '.tiff' ||
    '.bmp' ||
    '.svg' ||
    '.ico' ||
    '.raw' ||
    '.dng' ||
    '.avif' =>
      FileKind.image,
    '.mp4' ||
    '.mov' ||
    '.mkv' ||
    '.avi' ||
    '.webm' ||
    '.m4v' ||
    '.mpg' ||
    '.mpeg' =>
      FileKind.video,
    '.mp3' ||
    '.m4a' ||
    '.wav' ||
    '.aac' ||
    '.flac' ||
    '.aiff' ||
    '.aif' ||
    '.ogg' ||
    '.opus' =>
      FileKind.audio,
    '.txt' || '.md' || '.log' || '.rst' || '.tex' => FileKind.text,
    '.pdf' || '.doc' || '.docx' || '.rtf' || '.odt' => FileKind.document,
    '.xls' || '.xlsx' || '.csv' || '.tsv' || '.ods' => FileKind.spreadsheet,
    '.ppt' || '.pptx' || '.odp' => FileKind.presentation,
    '.zip' ||
    '.rar' ||
    '.7z' ||
    '.tar' ||
    '.gz' ||
    '.tgz' ||
    '.bz2' ||
    '.xz' =>
      FileKind.archive,
    '.dart' ||
    '.swift' ||
    '.kt' ||
    '.java' ||
    '.py' ||
    '.js' ||
    '.jsx' ||
    '.ts' ||
    '.tsx' ||
    '.json' ||
    '.xml' ||
    '.html' ||
    '.htm' ||
    '.css' ||
    '.scss' ||
    '.sh' ||
    '.zsh' ||
    '.yaml' ||
    '.yml' ||
    '.go' ||
    '.rs' ||
    '.c' ||
    '.cc' ||
    '.cpp' ||
    '.h' ||
    '.hpp' ||
    '.m' ||
    '.mm' ||
    '.rb' ||
    '.php' ||
    '.sql' ||
    '.plist' ||
    '.toml' =>
      FileKind.code,
    '.dmg' || '.iso' || '.img' || '.sparseimage' => FileKind.disk,
    '.ttf' || '.otf' || '.woff' || '.woff2' || '.ttc' => FileKind.font,
    '.psd' || '.ai' || '.fig' || '.xd' => FileKind.design,
    '.app' ||
    '.exe' ||
    '.apk' ||
    '.ipa' ||
    '.pkg' ||
    '.mpkg' =>
      FileKind.application,
    _ => FileKind.other,
  };
}

String _extension(String name) {
  final dot = name.lastIndexOf('.');
  if (dot <= 0 || dot == name.length - 1) {
    return '';
  }
  return name.substring(dot).toLowerCase();
}
