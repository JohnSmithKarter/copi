import 'dart:io';

import 'package:copi/features/home/data/io_directory_gateway.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('hidden names stay out of the list until asked for', () async {
    final folder = await Directory.systemTemp.createTemp('copi_list_');
    addTearDown(() => folder.delete(recursive: true));
    await File('${folder.path}/note.txt').writeAsString('yes');
    await File('${folder.path}/.secret').writeAsString('no');
    await Directory('${folder.path}/.git').create();

    const gateway = IoDirectoryGateway();
    final hidden = await gateway.list(folder.path);
    expect(hidden.map((entry) => entry.name), ['note.txt']);

    final shown = await gateway.list(folder.path, includeHidden: true);
    expect(
      shown.map((entry) => entry.name),
      ['.git', '.secret', 'note.txt'],
    );
  });
}
