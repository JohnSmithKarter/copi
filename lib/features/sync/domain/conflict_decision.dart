/// Что сделать с файлом, имя которого уже занято на диске.
enum ConflictAction {
  /// Стереть файл на диске и записать новый.
  replace,

  /// Оставить файл на диске и записать копию с « (1)» в имени.
  keepBoth,

  /// Не копировать этот файл.
  skip,
}

/// Ответ на вопрос про одинаковое имя.
class ConflictDecision {
  const ConflictDecision({required this.action, required this.applyToAll});

  final ConflictAction action;

  /// Повторять [action] для остальных конфликтов этого запуска.
  final bool applyToAll;
}

/// Спрашивает пользователя. Вызывается только если файл на диске уже есть.
typedef ConflictResolver = Future<ConflictDecision> Function(
  String relativePath,
);
