import 'dart:io';

import 'package:copi/core/logging/app_failure.dart';
import 'package:copi/core/logging/app_log.dart';
import 'package:copi/features/sync/data/sync_engine.dart';
import 'package:copi/core/domain/sync_mode.dart';
import 'package:copi/features/sync/domain/conflict_decision.dart';
import 'package:copi/features/sync/domain/sync_plan.dart';
import 'package:copi/features/sync/domain/sync_progress.dart';
import 'package:copi/features/sync/domain/sync_request.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:talker/talker.dart';

void main() {
  test('planner copies new and changed files and deletes extras only in mirror',
      () {
    final older = DateTime.utc(2020);
    final newer = DateTime.utc(2024);
    final source = SyncTree(
      files: {
        'a.txt': FileSnapshot(
          relativePath: 'a.txt',
          size: 2,
          modified: newer,
        ),
        'b.txt': FileSnapshot(
          relativePath: 'b.txt',
          size: 1,
          modified: older,
        ),
      },
      directories: {'nested'},
    );
    final destination = SyncTree(
      files: {
        'a.txt': FileSnapshot(
          relativePath: 'a.txt',
          size: 2,
          modified: older,
        ),
        'old.txt': FileSnapshot(
          relativePath: 'old.txt',
          size: 4,
          modified: older,
        ),
      },
      directories: {'gone'},
    );

    final mirror = planOperations(
      source: source,
      destination: destination,
      mode: SyncMode.mirror,
    );
    expect(
      mirror.map(
          (operation) => '${operation.action.name}:${operation.relativePath}'),
      [
        'copy:a.txt',
        'copy:b.txt',
        'deleteFile:old.txt',
        'deleteDirectory:gone',
      ],
    );

    final additive = planOperations(
      source: source,
      destination: destination,
      mode: SyncMode.additive,
    );
    expect(
      additive.map((operation) => operation.relativePath),
      ['a.txt', 'b.txt'],
    );
  });

  test('mirror removes extras and additive keeps them', () async {
    final source = await Directory.systemTemp.createTemp('copi_source_');
    final destination = await Directory.systemTemp.createTemp('copi_dest_');
    addTearDown(() async {
      await source.delete(recursive: true);
      if (destination.existsSync()) {
        await destination.delete(recursive: true);
      }
    });
    final placed = Directory(
      p.join(destination.path, p.basename(source.path)),
    );
    await placed.create();
    await File('${source.path}/keep.txt').writeAsString('newer');
    final previous = File('${placed.path}/keep.txt');
    await previous.writeAsString('old');
    await previous.setLastModified(DateTime.utc(2020));
    await File('${placed.path}/extra.txt').writeAsString('stay');

    await _run(
      source: source.path,
      destination: destination.path,
      mode: SyncMode.additive,
    );
    expect(File('${placed.path}/extra.txt').existsSync(), isTrue);
    expect(await File('${placed.path}/keep.txt').readAsString(), 'newer');

    await _run(
      source: source.path,
      destination: destination.path,
      mode: SyncMode.mirror,
    );
    expect(File('${placed.path}/extra.txt').existsSync(), isFalse);
    expect(await File('${placed.path}/keep.txt').readAsString(), 'newer');
  });

  test('hidden files and folders are copied', () async {
    final source = await Directory.systemTemp.createTemp('copi_hidden_source_');
    final destination =
        await Directory.systemTemp.createTemp('copi_hidden_dest_');
    addTearDown(() async {
      await source.delete(recursive: true);
      await destination.delete(recursive: true);
    });
    await File('${source.path}/visible.txt').writeAsString('yes');
    await File('${source.path}/.secret').writeAsString('hidden');
    await Directory('${source.path}/.git').create();
    await File('${source.path}/.git/HEAD')
        .writeAsString('ref: refs/heads/main');

    await _run(
      source: source.path,
      destination: destination.path,
      mode: SyncMode.additive,
    );

    final placed = p.join(destination.path, p.basename(source.path));
    expect(await File('$placed/.secret').readAsString(), 'hidden');
    expect(
      await File('$placed/.git/HEAD').readAsString(),
      'ref: refs/heads/main',
    );
    await File('$placed/.gone').writeAsString('extra');

    await _run(
      source: source.path,
      destination: destination.path,
      mode: SyncMode.additive,
    );
    expect(File('$placed/.gone').existsSync(), isTrue);

    await _run(
      source: source.path,
      destination: destination.path,
      mode: SyncMode.mirror,
    );
    expect(File('$placed/.secret').existsSync(), isTrue);
    expect(File('$placed/.git/HEAD').existsSync(), isTrue);
    expect(File('$placed/.gone').existsSync(), isFalse);
    expect(File('${destination.path}/visible.txt').existsSync(), isFalse);
  });

  test('symbolic links are copied as links and not followed', () async {
    final source = await Directory.systemTemp.createTemp('copi_link_source_');
    final destination =
        await Directory.systemTemp.createTemp('copi_link_dest_');
    final outside = await Directory.systemTemp.createTemp('copi_link_outside_');
    addTearDown(() async {
      await source.delete(recursive: true);
      await destination.delete(recursive: true);
      await outside.delete(recursive: true);
    });
    await File('${source.path}/note.txt').writeAsString('inside');
    Link('${source.path}/alias.txt').createSync('note.txt');
    final outsideFile = File('${outside.path}/secret.txt');
    await outsideFile.writeAsString('outside');
    Link('${source.path}/jump').createSync(outsideFile.path);

    await _run(
      source: source.path,
      destination: destination.path,
      mode: SyncMode.additive,
    );

    final placed = p.join(destination.path, p.basename(source.path));
    expect(_linkTarget('$placed/alias.txt'), 'note.txt');
    expect(_linkTarget('$placed/jump'), outsideFile.path);
    expect(File('$placed/secret.txt').existsSync(), isFalse);
    expect(await File('$placed/note.txt').readAsString(), 'inside');

    Link('$placed/extra-link').createSync('note.txt');
    await _run(
      source: source.path,
      destination: destination.path,
      mode: SyncMode.additive,
    );
    expect(_linkTarget('$placed/extra-link'), 'note.txt');

    await _run(
      source: source.path,
      destination: destination.path,
      mode: SyncMode.mirror,
    );
    expect(
      FileSystemEntity.typeSync('$placed/extra-link', followLinks: false),
      FileSystemEntityType.notFound,
    );
    expect(_linkTarget('$placed/alias.txt'), 'note.txt');

    Link('${source.path}/alias.txt').deleteSync();
    Link('${source.path}/alias.txt').createSync('missing.txt');
    await _run(
      source: source.path,
      destination: destination.path,
      mode: SyncMode.additive,
    );
    expect(_linkTarget('$placed/alias.txt'), 'missing.txt');
  });

  test('same folder does not change files', () async {
    final folder = await Directory.systemTemp.createTemp('copi_same_');
    addTearDown(() async => folder.delete(recursive: true));
    final file = File('${folder.path}/note.txt');
    await file.writeAsString('untouched');

    await expectLater(
      _run(
          source: folder.path, destination: folder.path, mode: SyncMode.mirror),
      throwsA(
        isA<AppFailure>().having(
          (error) => error.code,
          'code',
          AppFailureCode.sameLocation,
        ),
      ),
    );
    expect(await file.readAsString(), 'untouched');
  });

  test('missing destination does not delete an existing backup', () async {
    final backup = await Directory.systemTemp.createTemp('copi_backup_');
    addTearDown(() async => backup.delete(recursive: true));
    final kept = File('${backup.path}/kept.txt');
    await kept.writeAsString('safe');

    await expectLater(
      _run(
        source: backup.path,
        destination: '${backup.path}-missing',
        mode: SyncMode.mirror,
      ),
      throwsA(
        isA<AppFailure>().having(
          (error) => error.code,
          'code',
          AppFailureCode.destinationUnavailable,
        ),
      ),
    );
    expect(await kept.readAsString(), 'safe');
  });

  test('an unreadable source is logged as access denied and not copied',
      () async {
    final source = await Directory.systemTemp.createTemp('copi_locked_source_');
    final destination =
        await Directory.systemTemp.createTemp('copi_locked_dest_');
    addTearDown(() async {
      await Process.run('chmod', ['u+rwx', source.path]);
      if (source.existsSync()) {
        await source.delete(recursive: true);
      }
      if (destination.existsSync()) {
        await destination.delete(recursive: true);
      }
    });
    await File(p.join(source.path, 'photo.jpg')).writeAsString('secret');
    await Process.run('chmod', ['000', source.path]);

    await expectLater(
      _run(
        source: source.path,
        destination: destination.path,
        mode: SyncMode.additive,
      ),
      throwsA(
        isA<AppFailure>().having(
          (error) => error.code,
          'code',
          AppFailureCode.accessDenied,
        ),
      ),
    );
    expect(
      File(
        p.join(destination.path, p.basename(source.path), 'photo.jpg'),
      ).existsSync(),
      isFalse,
    );
  });

  test('a failed copy keeps the previous file', () async {
    final source = await Directory.systemTemp.createTemp('copi_fail_source_');
    final destination =
        await Directory.systemTemp.createTemp('copi_fail_dest_');
    addTearDown(() async {
      await source.delete(recursive: true);
      if (destination.existsSync()) {
        await destination.delete(recursive: true);
      }
    });
    final album = Directory(p.join(source.path, 'album'));
    await album.create();
    await File(p.join(album.path, 'photo.jpg')).writeAsString('new');
    final placed = Directory(p.join(destination.path, p.basename(source.path)));
    await placed.create();
    final blocker = File(p.join(placed.path, 'album'));
    await blocker.writeAsString('not-a-folder');

    await expectLater(
      _run(
        source: source.path,
        destination: destination.path,
        mode: SyncMode.additive,
      ),
      throwsA(
        isA<AppFailure>().having(
          (error) => error.code,
          'code',
          AppFailureCode.fileFailed,
        ),
      ),
    );
    expect(await blocker.readAsString(), 'not-a-folder');
  });

  test('cancel does not start the next file', () async {
    final source = await Directory.systemTemp.createTemp('copi_cancel_source_');
    final destination =
        await Directory.systemTemp.createTemp('copi_cancel_dest_');
    addTearDown(() async {
      await source.delete(recursive: true);
      await destination.delete(recursive: true);
    });
    await File('${source.path}/a.txt').writeAsString('a');
    await File('${source.path}/b.txt').writeAsString('b');
    final token = CancellationToken();

    await SyncEngine(_quietLog()).run(
      jobs: [
        SyncRequest(
          sourcePath: source.path,
          destinationPath: destination.path,
          mode: SyncMode.additive,
        ),
      ],
      cancellation: token,
      onProgress: (progress) {
        if (progress.processedFiles >= 1) {
          token.cancel();
        }
      },
    );

    final placed = Directory(p.join(destination.path, p.basename(source.path)));
    final names = placed
        .listSync()
        .whereType<File>()
        .map((file) => p.basename(file.path))
        .toList();
    expect(names, ['a.txt']);
  });

  test('the chosen folder is copied onto the disk under its own name',
      () async {
    final disk = await Directory.systemTemp.createTemp('copi_disk_');
    final home = await Directory.systemTemp.createTemp('copi_home_');
    addTearDown(() async {
      await disk.delete(recursive: true);
      await home.delete(recursive: true);
    });
    final downloads = Directory(p.join(home.path, 'Downloads'));
    await downloads.create();
    await File(p.join(downloads.path, 'photo.jpg')).writeAsString('one');
    await File(p.join(disk.path, 'other.txt')).writeAsString('keep');

    await _run(
      source: downloads.path,
      destination: disk.path,
      mode: SyncMode.additive,
    );
    expect(
      await File(p.join(disk.path, 'Downloads', 'photo.jpg')).readAsString(),
      'one',
    );
    expect(File(p.join(disk.path, 'photo.jpg')).existsSync(), isFalse);
    expect(await File(p.join(disk.path, 'other.txt')).readAsString(), 'keep');

    await File(p.join(downloads.path, 'photo2.jpg')).writeAsString('two');
    await _run(
      source: downloads.path,
      destination: disk.path,
      mode: SyncMode.additive,
    );
    expect(
      await File(p.join(disk.path, 'Downloads', 'photo2.jpg')).readAsString(),
      'two',
    );
    expect(
      await File(p.join(disk.path, 'Downloads', 'photo.jpg')).readAsString(),
      'one',
    );
  });

  test('same name asks, keep both leaves the old file', () async {
    final source = await Directory.systemTemp.createTemp('copi_ask_source_');
    final destination = await Directory.systemTemp.createTemp('copi_ask_dest_');
    addTearDown(() async {
      await source.delete(recursive: true);
      if (destination.existsSync()) {
        await destination.delete(recursive: true);
      }
    });
    final placed = Directory(p.join(destination.path, p.basename(source.path)));
    await placed.create();
    await File(p.join(source.path, 'photo.jpg')).writeAsString('new');
    final previous = File(p.join(placed.path, 'photo.jpg'));
    await previous.writeAsString('old');
    await previous.setLastModified(DateTime.utc(2020));
    await File(p.join(placed.path, 'photo (1).jpg')).writeAsString('taken');
    await File(p.join(placed.path, 'extra.txt')).writeAsString('stay');
    final asked = <String>[];

    await _run(
      source: source.path,
      destination: destination.path,
      mode: SyncMode.additive,
      onConflict: (path) async {
        asked.add(path);
        return const ConflictDecision(
          action: ConflictAction.keepBoth,
          applyToAll: false,
        );
      },
    );

    expect(asked, ['photo.jpg']);
    expect(await File(p.join(placed.path, 'photo.jpg')).readAsString(), 'old');
    expect(
      await File(p.join(placed.path, 'photo (1).jpg')).readAsString(),
      'taken',
    );
    expect(
      await File(p.join(placed.path, 'photo (2).jpg')).readAsString(),
      'new',
    );
    expect(await File(p.join(placed.path, 'extra.txt')).readAsString(), 'stay');
  });

  test('apply to all asks once and skip leaves both files', () async {
    final source = await Directory.systemTemp.createTemp('copi_all_source_');
    final destination = await Directory.systemTemp.createTemp('copi_all_dest_');
    addTearDown(() async {
      await source.delete(recursive: true);
      if (destination.existsSync()) {
        await destination.delete(recursive: true);
      }
    });
    final placed = Directory(p.join(destination.path, p.basename(source.path)));
    await placed.create();
    await File(p.join(source.path, 'a.jpg')).writeAsString('a-new');
    await File(p.join(source.path, 'b.jpg')).writeAsString('b-new');
    final older = DateTime.utc(2020);
    final previousA = File(p.join(placed.path, 'a.jpg'));
    final previousB = File(p.join(placed.path, 'b.jpg'));
    await previousA.writeAsString('a-old');
    await previousB.writeAsString('b-old');
    await previousA.setLastModified(older);
    await previousB.setLastModified(older);
    var asked = 0;

    await _run(
      source: source.path,
      destination: destination.path,
      mode: SyncMode.additive,
      onConflict: (path) async {
        asked += 1;
        return const ConflictDecision(
          action: ConflictAction.skip,
          applyToAll: true,
        );
      },
    );

    expect(asked, 1);
    expect(await File(p.join(placed.path, 'a.jpg')).readAsString(), 'a-old');
    expect(await File(p.join(placed.path, 'b.jpg')).readAsString(), 'b-old');
  });

  test('an unchanged file is not asked about', () async {
    final source = await Directory.systemTemp.createTemp('copi_same_source_');
    final destination =
        await Directory.systemTemp.createTemp('copi_same_dest_');
    addTearDown(() async {
      await source.delete(recursive: true);
      if (destination.existsSync()) {
        await destination.delete(recursive: true);
      }
    });
    final placed = Directory(p.join(destination.path, p.basename(source.path)));
    await placed.create();
    final stamp = DateTime.utc(2024, 6, 1, 12);
    final sourceFile = File(p.join(source.path, 'photo.jpg'));
    final destinationFile = File(p.join(placed.path, 'photo.jpg'));
    await sourceFile.writeAsString('same');
    await destinationFile.writeAsString('same');
    await sourceFile.setLastModified(stamp);
    await destinationFile.setLastModified(stamp);
    var asked = 0;

    await _run(
      source: source.path,
      destination: destination.path,
      mode: SyncMode.additive,
      onConflict: (path) async {
        asked += 1;
        return const ConflictDecision(
          action: ConflictAction.replace,
          applyToAll: false,
        );
      },
    );

    expect(asked, 0);
    expect(await destinationFile.readAsString(), 'same');
  });
}

String _linkTarget(String path) {
  expect(
    FileSystemEntity.typeSync(path, followLinks: false),
    FileSystemEntityType.link,
  );
  return Link(path).targetSync();
}

Future<void> _run({
  required String source,
  required String destination,
  required SyncMode mode,
  ConflictResolver? onConflict,
}) =>
    SyncEngine(_quietLog()).run(
      jobs: [
        SyncRequest(
          sourcePath: source,
          destinationPath: destination,
          mode: mode,
        ),
      ],
      cancellation: CancellationToken(),
      onProgress: (_) {},
      onConflict: onConflict,
    );

AppLog _quietLog() => AppLog(
      Talker(settings: TalkerSettings(useConsoleLogs: false)),
    );
