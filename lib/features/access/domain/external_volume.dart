/// Том, который macOS сейчас смонтировала.
class VolumeCandidate {
  const VolumeCandidate({
    required this.name,
    required this.path,
    required this.internalDisk,
    required this.ejectable,
    required this.removable,
  });

  final String name;
  final String path;
  final bool internalDisk;
  final bool ejectable;
  final bool removable;
}

/// Внешние и извлекаемые диски. Внутренний системный том сюда не входит.
List<VolumeCandidate> externalVolumes(List<VolumeCandidate> volumes) {
  final visible = [
    for (final volume in volumes)
      if (_visible(volume)) volume,
  ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return visible;
}

bool _visible(VolumeCandidate volume) {
  if (volume.name.isEmpty || volume.path.isEmpty || volume.path == '/') {
    return false;
  }
  return !volume.internalDisk || volume.ejectable || volume.removable;
}
