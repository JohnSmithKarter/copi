import 'dart:io';

import 'package:copi/features/home/presentation/directory_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('an open folder shows a file that appears later', () async {
    final folder = await Directory.systemTemp.createTemp('copi_watch_');
    addTearDown(() async => folder.delete(recursive: true));
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final subscription = container.listen(
      directoryListingProvider(folder.path),
      (previous, next) {},
    );
    addTearDown(subscription.close);

    expect(
      await container.read(directoryListingProvider(folder.path).future),
      isEmpty,
    );
    await File('${folder.path}/photo.png').writeAsString('x');

    final names = await _namesAfterChange(container, folder.path);
    expect(names, contains('photo.png'));
  });
}

Future<List<String>> _namesAfterChange(
  ProviderContainer container,
  String path,
) async {
  for (var attempt = 0; attempt < 25; attempt++) {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final listing = container.read(directoryListingProvider(path));
    final entries = listing.asData?.value;
    if (entries != null && entries.any((entry) => entry.name == 'photo.png')) {
      return [for (final entry in entries) entry.name];
    }
  }
  final latest = await container.read(directoryListingProvider(path).future);
  return [for (final entry in latest) entry.name];
}
