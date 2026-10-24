import 'package:copi/core/domain/file_kind.dart';
import 'package:copi/features/home/domain/directory_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('file names map to distinct kinds', () {
    expect(fileKindForName('photo.HEIC'), FileKind.image);
    expect(fileKindForName('clip.mov'), FileKind.video);
    expect(fileKindForName('song.mp3'), FileKind.audio);
    expect(fileKindForName('notes.txt'), FileKind.text);
    expect(fileKindForName('report.pdf'), FileKind.document);
    expect(fileKindForName('budget.xlsx'), FileKind.spreadsheet);
    expect(fileKindForName('slides.pptx'), FileKind.presentation);
    expect(fileKindForName('backup.tar.gz'), FileKind.archive);
    expect(fileKindForName('main.dart'), FileKind.code);
    expect(fileKindForName('Installer.dmg'), FileKind.disk);
    expect(fileKindForName('Inter.ttf'), FileKind.font);
    expect(fileKindForName('poster.psd'), FileKind.design);
    expect(fileKindForName('Tool.exe'), FileKind.application);
    expect(fileKindForName('readme'), FileKind.other);
  });

  test('app bundles stay directories but use the application icon', () {
    expect(
      fileKindForName('Safari.app', isDirectory: true),
      FileKind.application,
    );
    expect(fileKindForName('Documents', isDirectory: true), FileKind.folder);
    expect(
      fileKindForName('Essay.pages', isDirectory: true),
      FileKind.document,
    );
  });
}
