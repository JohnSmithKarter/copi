import 'package:copi/features/access/domain/external_volume.dart';
import 'package:copi/features/access/domain/volume_access.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('external disks stay and the system volume does not', () {
    final visible = externalVolumes(const [
      VolumeCandidate(
        name: 'Macintosh HD',
        path: '/',
        internalDisk: true,
        ejectable: false,
        removable: false,
      ),
      VolumeCandidate(
        name: 'Macintosh HD',
        path: '/System/Volumes/Data',
        internalDisk: true,
        ejectable: false,
        removable: false,
      ),
      VolumeCandidate(
        name: 'HP P600 1',
        path: '/Volumes/HP P600 1',
        internalDisk: false,
        ejectable: true,
        removable: false,
      ),
      VolumeCandidate(
        name: 'HP P600',
        path: '/Volumes/HP P600',
        internalDisk: false,
        ejectable: true,
        removable: true,
      ),
      VolumeCandidate(
        name: '',
        path: '/Volumes/hidden',
        internalDisk: false,
        ejectable: true,
        removable: true,
      ),
    ]);

    expect(
      visible.map((volume) => volume.name),
      ['HP P600', 'HP P600 1'],
    );
  });

  test('an ejectable disk stays even when the system calls it internal', () {
    final visible = externalVolumes(const [
      VolumeCandidate(
        name: 'SD Card',
        path: '/Volumes/SD Card',
        internalDisk: true,
        ejectable: true,
        removable: true,
      ),
    ]);

    expect(visible, hasLength(1));
  });

  test('a volume payload skips rows without a name or a path', () {
    final volumes = decodeMountedVolumes([
      {
        'name': 'HP P600',
        'path': '/Volumes/HP P600',
        'internal': false,
        'ejectable': true,
        'removable': true,
      },
      {'name': 'Broken'},
      'not a volume',
    ]);

    expect(volumes, hasLength(1));
    expect(volumes.single.ejectable, isTrue);
    expect(volumes.single.internalDisk, isFalse);
  });
}
