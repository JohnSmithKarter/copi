import 'dart:async';
import 'dart:ui';

import 'package:copi/core/i18n/strings.g.dart';
import 'package:copi/core/navigation/app_routes.dart';
import 'package:copi/core/presentation/app_metrics.dart';
import 'package:copi/core/presentation/macos_button.dart';
import 'package:copi/core/presentation/surface_card.dart';
import 'package:copi/core/presentation/window_bar.dart';
import 'package:copi/features/presets/domain/preset.dart';
import 'package:copi/features/presets/presentation/preset_providers.dart';
import 'package:copi/features/sync/domain/conflict_decision.dart';
import 'package:copi/features/sync/domain/sync_progress.dart';
import 'package:copi/features/sync/presentation/conflict_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Прогресс одного запуска. Крупная подпись меняется вместе с фазой.
class SyncPage extends ConsumerStatefulWidget {
  const SyncPage({required this.presetId, super.key});

  final String presetId;

  @override
  ConsumerState<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends ConsumerState<SyncPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(_start());
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(syncControllerProvider);
    final translations = context.t;
    final accent = CupertinoTheme.of(context).primaryColor;
    final phase = progress?.phase ?? SyncPhase.scanning;
    final finished = phase == SyncPhase.done ||
        phase == SyncPhase.error ||
        phase == SyncPhase.cancelled;
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          ref.read(syncControllerProvider.notifier).cancel();
        }
      },
      child: CupertinoPageScaffold(
        navigationBar: WindowBar(
          title: Text(translations.sync.title),
          trailing: phase == SyncPhase.error
              ? MacosButton(
                  symbol: 'list.bullet.rectangle',
                  semanticLabel: translations.settings.logs,
                  onPressed: () => unawaited(openLogs(context)),
                )
              : null,
        ),
        child: SafeArea(
          child: Padding(
            padding: AppPadding.syncPage,
            child: Column(
              children: [
                const Spacer(),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: SurfaceCard(
                      padding: AppPadding.syncCard,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 160,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ImageFiltered(
                                  imageFilter: ImageFilter.blur(
                                    sigmaX: 36,
                                    sigmaY: 36,
                                  ),
                                  child: Container(
                                    width: 140,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: accent.withValues(alpha: 0.45),
                                    ),
                                  ),
                                ),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 280),
                                  child: Text(
                                    _phaseLabel(translations, phase),
                                    key: ValueKey(phase),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AppGap.h8,
                          _ProgressBar(
                            fraction: progress?.fraction ?? 0,
                            color: accent,
                          ),
                          AppGap.h12,
                          Text(
                            translations.sync.progress(
                              done: progress?.processedFiles ?? 0,
                              total: progress?.totalFiles ?? 0,
                            ),
                            style: TextStyle(
                              color: CupertinoColors.secondaryLabel.resolveFrom(
                                context,
                              ),
                            ),
                          ),
                          AppGap.h16,
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              progress?.currentFile ?? '',
                              key: ValueKey(progress?.currentFile),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          if (phase == SyncPhase.error)
                            Padding(
                              padding: AppPadding.top12,
                              child: Text(
                                _errorLabel(translations, progress?.message),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: CupertinoColors.systemRed.resolveFrom(
                                    context,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                MacosButton(
                  label: finished
                      ? translations.sync.close
                      : translations.sync.cancel,
                  onPressed: finished
                      ? () => Navigator.of(context).pop()
                      : () =>
                          ref.read(syncControllerProvider.notifier).cancel(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _start() async {
    final presets = await ref.read(presetsProvider.future);
    Preset? preset;
    for (final item in presets) {
      if (item.id == widget.presetId) {
        preset = item;
        break;
      }
    }
    if (!mounted || preset == null) {
      return;
    }
    await ref.read(syncControllerProvider.notifier).start(
      preset,
      onConflict: (relativePath) async {
        if (!mounted) {
          return const ConflictDecision(
            action: ConflictAction.skip,
            applyToAll: true,
          );
        }
        final decision = await showConflictDialog(
          context,
          relativePath: relativePath,
        );
        return decision ??
            const ConflictDecision(
              action: ConflictAction.skip,
              applyToAll: false,
            );
      },
    );
  }
}

String _phaseLabel(Translations translations, SyncPhase phase) =>
    switch (phase) {
      SyncPhase.scanning => translations.sync.scanning,
      SyncPhase.copying => translations.sync.copying,
      SyncPhase.deleting => translations.sync.deleting,
      SyncPhase.done => translations.sync.done,
      SyncPhase.error => translations.sync.error,
      SyncPhase.cancelled => translations.sync.cancelled,
    };

String _errorLabel(Translations translations, String? code) => switch (code) {
      'destinationUnavailable' => translations.errors.destinationUnavailable,
      'sameLocation' => translations.errors.sameLocation,
      'accessDenied' || 'bookmark' => translations.errors.accessDenied,
      'fileFailed' => translations.errors.fileFailed,
      _ => translations.sync.error,
    };

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.fraction, required this.color});

  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final track = CupertinoColors.separator.resolveFrom(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 6,
        child: LayoutBuilder(
          builder: (context, constraints) => Stack(
            children: [
              ColoredBox(color: track, child: const SizedBox.expand()),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: constraints.maxWidth * fraction.clamp(0, 1),
                height: 6,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
