import 'package:copi/features/home/domain/path_label.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const roots = {
    '/Users/me': 'Home',
    '/Users/me/Downloads': 'Downloads',
    '/Users/me/Desktop': 'Desktop',
  };

  test('a standard folder uses its own name', () {
    expect(
      labeledPath(path: '/Users/me/Downloads', roots: roots),
      'Downloads',
    );
  });

  test('a nested file keeps the closest folder name', () {
    expect(
      labeledPath(
        path: '/Users/me/Downloads/Amnezia.pkg',
        roots: roots,
      ),
      'Downloads / Amnezia.pkg',
    );
  });

  test('an unknown path falls back to the file name', () {
    expect(
      labeledPath(path: '/Volumes/SSD/backup', roots: roots),
      'backup',
    );
  });
}
