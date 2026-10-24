import 'package:copi/core/logging/app_failure.dart';
import 'package:copi/core/logging/app_log.dart';
import 'package:copi/features/access/domain/bookmark_gateway.dart';
import 'package:copi/features/access/domain/external_volume.dart';
import 'package:copi/features/access/domain/volume_access.dart';
import 'package:flutter/services.dart';

const bookmarkChannelName = 'copi/bookmarks';

/// Мост к AppDelegate: диалог выбора папки и security-scoped bookmark.
class MethodChannelBookmarkGateway implements BookmarkGateway {
  MethodChannelBookmarkGateway({
    required AppLog log,
    MethodChannel? channel,
  })  : _log = log,
        _channel = channel ?? const MethodChannel(bookmarkChannelName);

  final AppLog _log;
  final MethodChannel _channel;

  @override
  Future<String> bookmarkForPath(String path) async {
    final bookmark = await _invoke('bookmarkForPath', {'path': path});
    if (bookmark is! String || bookmark.isEmpty) {
      _log.abort(AppFailureCode.bookmark, message: 'empty bookmark');
    }
    return bookmark;
  }

  @override
  Future<PickedFolder?> pickFolder({String? directory}) async {
    _log.info('Open folder panel${directory == null ? '' : ': $directory'}');
    final Object? result = await _invoke('pickFolder', {
      'directory': directory,
    });
    if (result == null) {
      _log.info('Folder panel closed without a selection');
      return null;
    }
    if (result is! Map) {
      _log.abort(
        AppFailureCode.bookmark,
        message: 'unexpected picker result',
      );
    }
    final map = Map<Object?, Object?>.from(result);
    final path = map['path'];
    final bookmark = map['bookmark'];
    if (path is! String || bookmark is! String) {
      _log.abort(
        AppFailureCode.bookmark,
        message: 'unexpected picker result',
      );
    }
    _log.info('Folder selected: $path');
    return PickedFolder(path: path, bookmark: bookmark);
  }

  @override
  Future<String> startAccess(String bookmark) async {
    final path = await _invoke('startAccess', {'bookmark': bookmark});
    if (path is! String || path.isEmpty) {
      _log.abort(AppFailureCode.bookmark, message: 'access was not granted');
    }
    return path;
  }

  @override
  Future<void> stopAccess(String bookmark) async {
    await _invoke('stopAccess', {'bookmark': bookmark});
  }

  @override
  Future<List<VolumeCandidate>> mountedVolumes() async {
    try {
      final result = await _channel.invokeMethod<Object?>('mountedVolumes');
      return decodeMountedVolumes(result);
    } on MissingPluginException {
      return const [];
    } on PlatformException catch (error, stackTrace) {
      final details = error.details;
      final detailText = details == null ? '' : ' ($details)';
      _log.abort(
        AppFailureCode.bookmark,
        message:
            '${error.code}: ${error.message ?? 'mountedVolumes'}$detailText',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<Object?> _invoke(String method, Map<String, Object?> arguments) async {
    try {
      return await _channel.invokeMethod<Object?>(method, arguments);
    } on PlatformException catch (error, stackTrace) {
      final details = error.details;
      final detailText = details == null ? '' : ' ($details)';
      _log.abort(
        AppFailureCode.bookmark,
        message: '${error.code}: ${error.message ?? method}$detailText',
        cause: error,
        stackTrace: stackTrace,
      );
    } on MissingPluginException catch (error, stackTrace) {
      _log.abort(
        AppFailureCode.bookmark,
        message: error.message ?? 'Missing plugin for $method',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }
}
