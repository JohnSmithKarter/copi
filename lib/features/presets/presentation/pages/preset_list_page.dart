import 'dart:async';

import 'package:copi/core/i18n/strings.g.dart';
import 'package:copi/core/navigation/app_routes.dart';
import 'package:copi/core/presentation/app_metrics.dart';
import 'package:copi/core/presentation/macos_button.dart';
import 'package:copi/core/presentation/surface_card.dart';
import 'package:copi/core/presentation/window_bar.dart';
import 'package:copi/features/presets/domain/preset.dart';
import 'package:copi/features/presets/presentation/preset_providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Сохранённые пресеты и кнопка нового.
class PresetListPage extends ConsumerWidget {
  const PresetListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translations = context.t;
    final presets = ref.watch(presetsProvider);
    return CupertinoPageScaffold(
      navigationBar: WindowBar(
        title: Text(translations.presets.title),
        trailing: MacosButton(
          symbol: 'plus',
          onPressed: () => unawaited(openPresetEditor(context)),
        ),
      ),
      child: SafeArea(
        child: presets.when(
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (error, _) => Center(child: Text('$error')),
          data: (items) {
            if (items.isEmpty) {
              return Center(
                child: MacosButton(
                  label: translations.presets.create,
                  onPressed: () => unawaited(openPresetEditor(context)),
                ),
              );
            }
            return ListView.separated(
              padding: AppPadding.page,
              itemCount: items.length,
              separatorBuilder: (context, index) => AppGap.h12,
              itemBuilder: (context, index) =>
                  _PresetCard(preset: items[index]),
            );
          },
        ),
      ),
    );
  }
}

class _PresetCard extends ConsumerWidget {
  const _PresetCard({required this.preset});

  final Preset preset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translations = context.t.presets;
    return SurfaceCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  preset.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppGap.h4,
                Text(
                  translations.pairCount(count: preset.pairs.length),
                  style: TextStyle(
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
              ],
            ),
          ),
          AppGap.w12,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MacosButton(
                label: translations.run,
                onPressed: () => unawaited(
                  openSync(context, presetId: preset.id),
                ),
              ),
              AppGap.w8,
              MacosButton(
                label: translations.edit,
                onPressed: () => unawaited(
                  openPresetEditor(context, preset: preset),
                ),
              ),
              AppGap.w8,
              MacosButton(
                symbol: 'trash',
                semanticLabel: translations.delete,
                foreground: CupertinoColors.systemRed.resolveFrom(context),
                onPressed: () => unawaited(_confirmDelete(context, ref)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final translations = context.t.presets;
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(translations.deleteTitle),
        content: Text(translations.deleteBody),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: Text(translations.cancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: Text(translations.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await ref.read(presetsProvider.notifier).delete(preset.id);
  }
}
