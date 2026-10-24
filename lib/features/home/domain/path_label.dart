import 'package:path/path.dart' as p;

/// Путь для плашки: имя раздела и хвост внутри него.
///
/// Если выбранный путь лежит в нескольких разделах, берётся самый длинный.
String labeledPath({
  required String path,
  required Map<String, String> roots,
}) {
  final normalized = p.normalize(path);
  String? label;
  var bestLength = -1;
  for (final root in roots.entries) {
    final rootPath = p.normalize(root.key);
    if (rootPath.isEmpty || rootPath.length <= bestLength) {
      continue;
    }
    if (p.equals(rootPath, normalized)) {
      bestLength = rootPath.length;
      label = root.value;
      continue;
    }
    if (p.isWithin(rootPath, normalized)) {
      bestLength = rootPath.length;
      final relative = p.relative(normalized, from: rootPath);
      label = '${root.value} / ${p.split(relative).join(' / ')}';
    }
  }
  return label ?? p.basename(normalized);
}
