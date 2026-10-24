import 'package:copi/core/i18n/strings.g.dart';
import 'package:copi/core/presentation/app_metrics.dart';
import 'package:copi/core/presentation/apple_icon.dart';
import 'package:copi/features/sync/domain/conflict_decision.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;

/// Вопрос: заменить файл, оставить оба или пропустить.
Future<ConflictDecision?> showConflictDialog(
  BuildContext context, {
  required String relativePath,
}) {
  final name = p.basename(relativePath);
  final shown = name == relativePath ? name : relativePath;
  return showCupertinoDialog<ConflictDecision>(
    context: context,
    builder: (context) => _ConflictDialog(name: shown),
  );
}

class _ConflictDialog extends StatefulWidget {
  const _ConflictDialog({required this.name});

  final String name;

  @override
  State<_ConflictDialog> createState() => _ConflictDialogState();
}

class _ConflictDialogState extends State<_ConflictDialog> {
  var _applyToAll = false;

  void _close(ConflictAction action) {
    Navigator.pop(
      context,
      ConflictDecision(action: action, applyToAll: _applyToAll),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sync = context.t.sync;
    final accent = CupertinoTheme.of(context).primaryColor;
    return CupertinoAlertDialog(
      title: Text(sync.conflictTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(sync.conflictBody(name: widget.name)),
          AppGap.h12,
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _applyToAll = !_applyToAll),
            child: Row(
              children: [
                _Check(checked: _applyToAll, accent: accent),
                AppGap.w8,
                Expanded(
                  child: Text(
                    sync.conflictApplyToAll,
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () => _close(ConflictAction.replace),
          child: Text(sync.conflictReplace),
        ),
        CupertinoDialogAction(
          onPressed: () => _close(ConflictAction.keepBoth),
          child: Text(sync.conflictKeepBoth),
        ),
        CupertinoDialogAction(
          onPressed: () => _close(ConflictAction.skip),
          child: Text(sync.conflictSkip),
        ),
      ],
    );
  }
}

class _Check extends StatelessWidget {
  const _Check({required this.checked, required this.accent});

  final bool checked;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final ring = CupertinoColors.systemGrey.resolveFrom(context);
    return Container(
      width: 16,
      height: 16,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: checked ? accent : const Color(0x00000000),
        border: Border.all(
          color: checked ? accent : ring,
          width: checked ? 0 : 1.5,
        ),
      ),
      child: checked
          ? const AppleIcon(
              'checkmark',
              size: 11,
              weight: AppleIconWeight.bold,
              color: Color(0xFFFFFFFF),
            )
          : null,
    );
  }
}
