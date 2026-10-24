import 'package:copi/core/presentation/app_metrics.dart';
import 'package:flutter/cupertino.dart';

const _radioSize = 16.0;
const _radioDot = 6.0;

/// Один пункт переключателя.
class MacosRadioOption<T> {
  const MacosRadioOption({required this.value, required this.label});

  final T value;
  final String label;
}

/// Кружки как в настройках macOS: выбранный залит акцентом, остальные пустые.
class MacosRadioGroup<T> extends StatelessWidget {
  const MacosRadioGroup({
    required this.value,
    required this.onChanged,
    required this.options,
    super.key,
  });

  final T value;
  final ValueChanged<T> onChanged;
  final List<MacosRadioOption<T>> options;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: AppSpace.s20,
        runSpacing: AppSpace.s10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final option in options)
            _MacosRadio(
              label: option.label,
              selected: option.value == value,
              onPressed: () => onChanged(option.value),
            ),
        ],
      );
}

class _MacosRadio extends StatelessWidget {
  const _MacosRadio({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final accent = CupertinoTheme.of(context).primaryColor;
    final ring = CupertinoColors.systemGrey.resolveFrom(context);
    return CupertinoButton(
      padding: AppPadding.vertical2,
      minimumSize: Size.zero,
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            width: _radioSize,
            height: _radioSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? accent : const Color(0x00000000),
              border: Border.all(
                color: selected ? accent : ring,
                width: selected ? 0 : 1.5,
              ),
            ),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOutCubic,
                width: selected ? _radioDot : 0,
                height: selected ? _radioDot : 0,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          AppGap.w6,
          Text(
            label,
            style: TextStyle(
              color: CupertinoColors.label.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }
}
