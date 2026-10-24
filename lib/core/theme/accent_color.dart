import 'package:flutter/painting.dart';

/// Акцентный цвет. Фон и текст остаются системными.
enum AppAccent {
  blue(Color(0xFF0A84FF)),
  indigo(Color(0xFF5E5CE6)),
  purple(Color(0xFFBF5AF2)),
  teal(Color(0xFF64D2FF)),
  green(Color(0xFF30D158)),
  orange(Color(0xFFFF9F0A)),
  pink(Color(0xFFFF375F)),
  graphite(Color(0xFF8E8E93));

  const AppAccent(this.color);

  final Color color;

  static AppAccent fromStorage(String? raw) =>
      AppAccent.values.asNameMap()[raw] ?? AppAccent.blue;
}
