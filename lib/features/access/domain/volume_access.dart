import 'package:copi/features/access/domain/external_volume.dart';

/// Диск в списке папок. [path] есть, пока закладка открыта.
class VolumeAccess {
  const VolumeAccess({
    required this.name,
    required this.mountPath,
    required this.path,
    required this.bookmark,
  });

  final String name;
  final String mountPath;
  final String? path;
  final String? bookmark;

  bool get hasAccess => path != null && path!.isNotEmpty;
}

List<VolumeCandidate> decodeMountedVolumes(Object? raw) {
  if (raw is! List) {
    return const [];
  }
  final volumes = <VolumeCandidate>[];
  for (final item in raw) {
    if (item is! Map) {
      continue;
    }
    final map = Map<Object?, Object?>.from(item);
    final name = map['name'];
    final path = map['path'];
    if (name is! String || path is! String) {
      continue;
    }
    volumes.add(
      VolumeCandidate(
        name: name,
        path: path,
        internalDisk: map['internal'] == true,
        ejectable: map['ejectable'] == true,
        removable: map['removable'] == true,
      ),
    );
  }
  return volumes;
}
