import 'package:copi/core/presentation/app_metrics.dart';
import 'package:flutter/cupertino.dart';

const _trackWidth = 38.0;
const _trackHeight = 22.0;
const _thumbSize = 18.0;
const _thumbInset = 2.0;

/// Тумблер как `NSSwitch`: серая дорожка, бегунок справа на акценте.
class MacosSwitch extends StatelessWidget {
  const MacosSwitch({
    required this.value,
    required this.onChanged,
    this.semanticLabel,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final accent = CupertinoTheme.of(context).primaryColor;
    const off = Color(0xFF636366);
    return Semantics(
      button: true,
      toggled: value,
      label: semanticLabel,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(!value),
          child: Padding(
            padding: AppPadding.vertical2,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              width: _trackWidth,
              height: _trackHeight,
              decoration: BoxDecoration(
                color: value ? accent : off,
                borderRadius: BorderRadius.circular(_trackHeight / 2),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: const Padding(
                  padding: EdgeInsets.all(_thumbInset),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CupertinoColors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x40000000),
                          blurRadius: 1,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: SizedBox.square(dimension: _thumbSize),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
