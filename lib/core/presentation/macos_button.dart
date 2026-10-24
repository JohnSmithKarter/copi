import 'package:copi/core/presentation/app_metrics.dart';
import 'package:copi/core/presentation/apple_icon.dart';
import 'package:flutter/cupertino.dart';

const macosButtonSize = 32.0;

/// Кнопка как в macOS: текст в овале, значок в круге.
///
/// Акцент только у надписи и значка. Заливка — та же, что у карточек,
/// обводка — цвет разделителя.
class MacosButton extends StatelessWidget {
  const MacosButton({
    required this.onPressed,
    this.label,
    this.symbol,
    this.symbolSize = 18,
    this.symbolWeight = AppleIconWeight.medium,
    this.semanticLabel,
    this.foreground,
    this.minWidth = 0,
    super.key,
  }) : assert(
          label != null || symbol != null,
          'A button needs a label or a symbol',
        );

  final VoidCallback onPressed;
  final String? label;
  final String? symbol;
  final double symbolSize;
  final AppleIconWeight symbolWeight;
  final String? semanticLabel;
  final Color? foreground;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    final text = label;
    final iconOnly = text == null;
    final color = foreground ?? CupertinoTheme.of(context).primaryColor;
    return CupertinoButton(
      padding: AppPadding.none,
      minimumSize: Size.zero,
      onPressed: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
          borderRadius:
              const BorderRadius.all(Radius.circular(macosButtonSize)),
          border: Border.all(
            color: CupertinoColors.separator.resolveFrom(context),
          ),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: iconOnly ? macosButtonSize : minWidth,
            maxWidth: iconOnly ? macosButtonSize : double.infinity,
            minHeight: macosButtonSize,
            maxHeight: macosButtonSize,
          ),
          child: Padding(
            padding: iconOnly ? AppPadding.none : AppPadding.buttonLabel,
            child: Center(
              widthFactor: 1,
              child: text == null
                  ? AppleIcon(
                      symbol!,
                      size: symbolSize,
                      weight: symbolWeight,
                      color: color,
                      semanticLabel: semanticLabel,
                    )
                  : Text(text, style: TextStyle(color: color)),
            ),
          ),
        ),
      ),
    );
  }
}
