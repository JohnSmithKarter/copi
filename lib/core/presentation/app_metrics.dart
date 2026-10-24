import 'package:flutter/widgets.dart';

/// Шаги отступов. Поля и промежутки собираются только из них.
abstract final class AppSpace {
  static const double s2 = 2;
  static const double s4 = 4;
  static const double s6 = 6;
  static const double s8 = 8;
  static const double s10 = 10;
  static const double s12 = 12;
  static const double s14 = 14;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s22 = 22;
  static const double s24 = 24;
  static const double s28 = 28;
  static const double s32 = 32;
  static const double s36 = 36;
}

/// Поля экранов и блоков.
abstract final class AppPadding {
  static const none = EdgeInsets.zero;

  static const page = EdgeInsets.fromLTRB(
    AppSpace.s20,
    AppSpace.s16,
    AppSpace.s20,
    AppSpace.s32,
  );

  static const editor = EdgeInsets.fromLTRB(
    AppSpace.s20,
    AppSpace.s16,
    AppSpace.s20,
    AppSpace.s16,
  );

  static const card = EdgeInsets.all(AppSpace.s16);

  static const field = EdgeInsets.all(AppSpace.s12);

  /// Боковой отступ текста в овальной кнопке.
  ///
  /// Пара кнопок в редакторе прибавляет его дважды к ширине надписи.
  static const buttonLabel = EdgeInsets.symmetric(horizontal: AppSpace.s22);

  static const horizontal12 = EdgeInsets.symmetric(horizontal: AppSpace.s12);

  static const vertical2 = EdgeInsets.symmetric(vertical: AppSpace.s2);

  static const vertical8 = EdgeInsets.symmetric(vertical: AppSpace.s8);

  static const vertical10 = EdgeInsets.symmetric(vertical: AppSpace.s10);

  static const bottom2 = EdgeInsets.only(bottom: AppSpace.s2);

  static const bottom4 = EdgeInsets.only(bottom: AppSpace.s4);

  static const bottom6 = EdgeInsets.only(bottom: AppSpace.s6);

  static const bottom8 = EdgeInsets.only(bottom: AppSpace.s8);

  static const top8 = EdgeInsets.only(top: AppSpace.s8);

  static const top12 = EdgeInsets.only(top: AppSpace.s12);

  static const emptyFolder = EdgeInsets.only(
    top: AppSpace.s2,
    bottom: AppSpace.s6,
  );

  static const folderBrowser = EdgeInsets.fromLTRB(
    AppSpace.s12,
    AppSpace.s8,
    AppSpace.s12,
    AppSpace.s24,
  );

  static const diskHeading = EdgeInsets.fromLTRB(
    AppSpace.s12,
    AppSpace.s16,
    AppSpace.s12,
    AppSpace.s8,
  );

  static const folderPlate = EdgeInsets.fromLTRB(
    AppSpace.s4,
    AppSpace.s2,
    AppSpace.s4,
    AppSpace.s8,
  );

  static const nestedRows = EdgeInsets.only(left: AppSpace.s28);

  static const paneTitle = EdgeInsets.fromLTRB(
    AppSpace.s16,
    AppSpace.s14,
    AppSpace.s16,
    AppSpace.s4,
  );

  static const paneChip = EdgeInsets.fromLTRB(
    AppSpace.s16,
    0,
    AppSpace.s16,
    AppSpace.s8,
  );

  static const chipLabel = EdgeInsets.fromLTRB(
    AppSpace.s10,
    AppSpace.s4,
    0,
    AppSpace.s4,
  );

  static const chipClear = EdgeInsets.fromLTRB(
    AppSpace.s6,
    AppSpace.s4,
    AppSpace.s8,
    AppSpace.s4,
  );

  static const paneTree = EdgeInsets.fromLTRB(
    AppSpace.s8,
    0,
    AppSpace.s8,
    AppSpace.s12,
  );

  static const syncPage = EdgeInsets.fromLTRB(
    AppSpace.s28,
    AppSpace.s24,
    AppSpace.s28,
    AppSpace.s28,
  );

  static const syncCard = EdgeInsets.fromLTRB(
    AppSpace.s28,
    AppSpace.s36,
    AppSpace.s28,
    AppSpace.s28,
  );
}

/// Промежутки между виджетами.
abstract final class AppGap {
  static const h4 = SizedBox(height: AppSpace.s4);
  static const h8 = SizedBox(height: AppSpace.s8);
  static const h12 = SizedBox(height: AppSpace.s12);
  static const h16 = SizedBox(height: AppSpace.s16);

  static const w6 = SizedBox(width: AppSpace.s6);
  static const w8 = SizedBox(width: AppSpace.s8);
  static const w12 = SizedBox(width: AppSpace.s12);
}
