/// Код ошибки ключевого сценария. По нему экран выбирает перевод.
enum AppFailureCode {
  bookmark,
  accessDenied,
  destinationUnavailable,
  sameLocation,
  fileFailed,
  unexpected,
}

/// Ошибка, которую видит пользователь и журнал сессии.
class AppFailure implements Exception {
  const AppFailure(
    this.code, {
    this.message,
    this.cause,
  });

  final AppFailureCode code;
  final String? message;
  final Object? cause;

  @override
  String toString() => message ?? code.name;
}
