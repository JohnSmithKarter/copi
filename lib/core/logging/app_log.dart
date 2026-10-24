import 'package:copi/core/logging/app_failure.dart';
import 'package:talker/talker.dart';

/// Единая точка журнала и ошибок ключевых сценариев.
class AppLog {
  AppLog(this._talker);

  final Talker _talker;

  void info(String message) => _talker.info(message);

  void warning(String message) => _talker.warning(message);

  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _talker.error(message, error, stackTrace);

  /// Пишет ошибку в журнал и пробрасывает [AppFailure].
  Never abort(
    AppFailureCode code, {
    String? message,
    Object? cause,
    StackTrace? stackTrace,
  }) {
    final failure = AppFailure(code, message: message, cause: cause);
    error(
      message ?? code.name,
      error: cause ?? failure,
      stackTrace: stackTrace,
    );
    throw failure;
  }
}
