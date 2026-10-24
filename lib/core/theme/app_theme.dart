import 'package:flutter/cupertino.dart';

/// Системный шрифт macOS. Это San Francisco, которым рисуется сам интерфейс.
const appleSystemFont = '.AppleSystemUIFont';

/// Тёмная тема. Акцент красится только в [CupertinoThemeData.primaryColor].
///
/// Фон экранов прозрачный: размытие рабочего стола рисует само окно macOS.
CupertinoThemeData appTheme({required Color accent}) => CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: accent,
      scaffoldBackgroundColor: const Color(0x00000000),
      textTheme: _appleTextTheme(accent),
    );

CupertinoTextThemeData _appleTextTheme(Color accent) {
  final base = CupertinoTextThemeData(primaryColor: accent);
  TextStyle apple(TextStyle style) =>
      style.copyWith(fontFamily: appleSystemFont);
  return CupertinoTextThemeData(
    primaryColor: accent,
    textStyle: apple(base.textStyle),
    actionTextStyle: apple(base.actionTextStyle),
    actionSmallTextStyle: apple(base.actionSmallTextStyle),
    tabLabelTextStyle: apple(base.tabLabelTextStyle),
    navTitleTextStyle: apple(base.navTitleTextStyle),
    navLargeTitleTextStyle: apple(base.navLargeTitleTextStyle),
    navActionTextStyle: apple(base.navActionTextStyle),
    pickerTextStyle: apple(base.pickerTextStyle),
    dateTimePickerTextStyle: apple(base.dateTimePickerTextStyle),
  );
}
