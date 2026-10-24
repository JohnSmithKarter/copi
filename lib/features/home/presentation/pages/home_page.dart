import 'dart:async';

import 'package:copi/core/i18n/strings.g.dart';
import 'package:copi/core/navigation/app_routes.dart';
import 'package:copi/core/presentation/app_metrics.dart';
import 'package:copi/core/presentation/macos_button.dart';
import 'package:copi/core/presentation/window_bar.dart';
import 'package:copi/features/home/presentation/widgets/folder_browser.dart';
import 'package:copi/features/presets/presentation/preset_providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Главный экран: папки Mac, пресеты и настройки.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translations = context.t;
    return CupertinoPageScaffold(
      child: SafeArea(
        top: false,
        child: Stack(
          children: [
            const Positioned.fill(
              child: FolderBrowser(
                padding: EdgeInsets.fromLTRB(
                  AppSpace.s12,
                  windowBarHeight + AppSpace.s8,
                  AppSpace.s12,
                  AppSpace.s28,
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: WindowBar(
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MacosButton(
                      label: translations.home.presets,
                      onPressed: () => unawaited(_openPresets(context, ref)),
                    ),
                    AppGap.w8,
                    MacosButton(
                      symbol: 'gearshape',
                      semanticLabel: translations.home.settings,
                      onPressed: () => unawaited(openSettings(context)),
                    ),
                    AppGap.w8,
                    MacosButton(
                      symbol: 'info.circle',
                      semanticLabel: translations.about.title,
                      onPressed: () => unawaited(openAbout(context)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPresets(BuildContext context, WidgetRef ref) async {
    final presets = await ref.read(presetsProvider.future);
    if (!context.mounted) {
      return;
    }
    if (presets.isEmpty) {
      await openPresetEditor(context);
      return;
    }
    await openPresetList(context);
  }
}
