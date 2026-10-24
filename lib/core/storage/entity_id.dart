int _sequence = 0;

/// Короткий идентификатор для пресета или пары.
String newEntityId() {
  _sequence += 1;
  return '${DateTime.now().microsecondsSinceEpoch}-$_sequence';
}
