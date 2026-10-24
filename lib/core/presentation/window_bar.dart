import 'dart:async';

import 'package:copi/core/presentation/app_metrics.dart';
import 'package:copi/core/presentation/apple_icon.dart';
import 'package:copi/core/presentation/macos_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// Высота шапки. Та же величина стоит в `MainFlutterWindow` у кнопок окна.
const windowBarHeight = 52.0;

/// Слева в шапке сидят кнопки окна. Красная сдвинута на тот же зазор, что и сверху,
/// поэтому «назад» и остальное содержимое начинаются правее.
const windowButtonsInset = 92.0;

/// Заголовок не заезжает на кнопки окна слева и действия справа.
const _titleGutter = 160.0;

const _windowChannel = MethodChannel('copi/window');

/// Шапка окна. Системные кнопки рисует macOS поверх левого края.
class WindowBar extends StatelessWidget
    implements ObstructingPreferredSizeWidget {
  const WindowBar({this.title, this.trailing, super.key});

  /// Заголовок по центру шапки.
  final Widget? title;

  final Widget? trailing;

  @override
  Size get preferredSize => const Size.fromHeight(windowBarHeight);

  @override
  bool shouldFullyObstruct(BuildContext context) => false;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (_) => unawaited(_dragWindow()),
      child: SizedBox(
        height: windowBarHeight,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (title != null)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _titleGutter,
                  ),
                  child: Center(
                    child: DefaultTextStyle.merge(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        height: 1,
                        leadingDistribution: TextLeadingDistribution.even,
                      ),
                      child: title!,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(
                left: windowButtonsInset,
                right: AppSpace.s12,
              ),
              child: Row(
                children: [
                  if (canPop) const WindowBackButton(),
                  const Spacer(),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Круглая кнопка «назад». Нажимается весь круг, не только стрелка.
class WindowBackButton extends StatelessWidget {
  const WindowBackButton({super.key});

  @override
  Widget build(BuildContext context) => MacosButton(
        symbol: 'chevron.backward',
        symbolSize: 16,
        symbolWeight: AppleIconWeight.semibold,
        onPressed: () => Navigator.maybePop(context),
      );
}

Future<void> _dragWindow() async {
  try {
    await _windowChannel.invokeMethod<void>('startDrag');
  } on MissingPluginException {
    // В тестах канала окна нет.
  }
}

/// Светлая или тёмная «стеклянная» подложка окна.
Future<void> syncWindowAppearance(Brightness brightness) async {
  try {
    await _windowChannel.invokeMethod<void>(
      'setAppearance',
      brightness == Brightness.dark ? 'dark' : 'light',
    );
  } on MissingPluginException {
    // В тестах канала окна нет.
  }
}
