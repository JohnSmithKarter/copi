import 'dart:async';

import 'package:copi/core/i18n/strings.g.dart';
import 'package:copi/core/l10n/locale_controller.dart';
import 'package:copi/core/logging/app_failure.dart';
import 'package:copi/core/navigation/app_routes.dart';
import 'package:copi/core/presentation/app_metrics.dart';
import 'package:copi/core/presentation/macos_button.dart';
import 'package:copi/core/presentation/macos_radio_group.dart';
import 'package:copi/core/presentation/macos_switch.dart';
import 'package:copi/core/presentation/surface_card.dart';
import 'package:copi/core/presentation/window_bar.dart';
import 'package:copi/core/theme/accent_color.dart';
import 'package:copi/core/theme/accent_provider.dart';
import 'package:copi/features/access/domain/folder_root.dart';
import 'package:copi/features/access/domain/volume_access.dart';
import 'package:copi/features/access/presentation/folder_access_provider.dart';
import 'package:copi/features/access/presentation/volume_access_provider.dart';
import 'package:copi/features/home/presentation/hidden_files_provider.dart';
import 'package:copi/features/home/presentation/widgets/folder_browser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Версия приложения из платформы.
final packageInfoProvider = FutureProvider<PackageInfo>(
  (ref) => PackageInfo.fromPlatform(),
);

/// Акцент, язык, скрытые файлы, разрешения, версия и логи.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translations = context.t;
    return CupertinoPageScaffold(
      navigationBar: WindowBar(
        title: Text(translations.settings.title),
        trailing: MacosButton(
          symbol: 'list.bullet.rectangle',
          semanticLabel: translations.settings.logs,
          onPressed: () => unawaited(openLogs(context)),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: AppPadding.page,
          children: [
            _SettingsCard(
              title: translations.settings.accent,
              child: const _AccentPicker(),
            ),
            AppGap.h12,
            _SettingsCard(
              title: translations.settings.language,
              child: const _LanguageSwitch(),
            ),
            AppGap.h12,
            _SettingsCard(
              title: translations.settings.files,
              child: const _HiddenFilesSwitch(),
            ),
            AppGap.h12,
            _SettingsCard(
              title: translations.settings.permissions,
              child: const _PermissionList(),
            ),
            AppGap.h12,
            _SettingsCard(
              title: translations.settings.version,
              child: const _VersionLabel(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccentPicker extends ConsumerWidget {
  const _AccentPicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(accentProvider);
    return Wrap(
      spacing: AppSpace.s12,
      runSpacing: AppSpace.s12,
      children: [
        for (final accent in AppAccent.values)
          GestureDetector(
            key: ValueKey(accent),
            onTap: () => unawaited(
              ref.read(accentProvider.notifier).setAccent(accent),
            ),
            child: AnimatedScale(
              scale: selected == accent ? 1 : 0.88,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.color,
                  border: Border.all(
                    color: selected == accent
                        ? CupertinoColors.label.resolveFrom(context)
                        : const Color(0x00000000),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _LanguageSwitch extends ConsumerWidget {
  const _LanguageSwitch();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(localeProvider);
    final translations = context.t.settings;
    return MacosRadioGroup<String>(
      value: code,
      onChanged: (value) =>
          unawaited(ref.read(localeProvider.notifier).setLocale(value)),
      options: [
        MacosRadioOption(value: 'ru', label: translations.russian),
        MacosRadioOption(value: 'en', label: translations.english),
      ],
    );
  }
}

class _HiddenFilesSwitch extends ConsumerWidget {
  const _HiddenFilesSwitch();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shown = ref.watch(showHiddenFilesProvider);
    final label = context.t.settings.showHidden;
    return Row(
      children: [
        Expanded(child: Text(label)),
        AppGap.w12,
        MacosSwitch(
          value: shown,
          semanticLabel: label,
          onChanged: (value) => unawaited(
            ref.read(showHiddenFilesProvider.notifier).setShown(value),
          ),
        ),
      ],
    );
  }
}

class _PermissionList extends ConsumerWidget {
  const _PermissionList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(folderAccessProvider);
    final translations = context.t;
    return access.when(
      loading: () => const CupertinoActivityIndicator(),
      error: (error, _) => Text('$error'),
      data: (roots) {
        final disks = ref.watch(mountedVolumesProvider).asData?.value ??
            const <VolumeAccess>[];
        return Column(
          children: [
            for (final root in roots)
              Padding(
                padding: AppPadding.bottom8,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(rootLabel(translations, root.id)),
                    ),
                    Text(
                      root.hasAccess
                          ? translations.settings.granted
                          : translations.settings.missing,
                      style: TextStyle(
                        color: CupertinoColors.secondaryLabel.resolveFrom(
                          context,
                        ),
                      ),
                    ),
                    if (!root.hasAccess) ...[
                      AppGap.w8,
                      MacosButton(
                        label: translations.home.allow,
                        onPressed: () => unawaited(
                          _grantFolder(context, ref, root.id),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            for (final disk in disks)
              Padding(
                padding: AppPadding.bottom8,
                child: Row(
                  children: [
                    Expanded(child: Text(disk.name)),
                    Text(
                      disk.hasAccess
                          ? translations.settings.granted
                          : translations.settings.missing,
                      style: TextStyle(
                        color: CupertinoColors.secondaryLabel.resolveFrom(
                          context,
                        ),
                      ),
                    ),
                    if (!disk.hasAccess) ...[
                      AppGap.w8,
                      MacosButton(
                        label: translations.home.allow,
                        onPressed: () => unawaited(
                          _grantDisk(context, ref, disk.mountPath),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

Future<void> _grantDisk(
  BuildContext context,
  WidgetRef ref,
  String mountPath,
) async {
  try {
    await ref.read(mountedVolumesProvider.notifier).grant(mountPath);
  } on AppFailure catch (error) {
    if (!context.mounted) {
      return;
    }
    await showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(context.t.errors.bookmark),
        content: Text(error.message ?? error.code.name),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: Text(context.t.presets.cancel),
          ),
        ],
      ),
    );
  }
}

Future<void> _grantFolder(
  BuildContext context,
  WidgetRef ref,
  FolderRootId id,
) async {
  try {
    await ref.read(folderAccessProvider.notifier).grant(id);
  } on AppFailure catch (error) {
    if (!context.mounted) {
      return;
    }
    await showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(context.t.errors.bookmark),
        content: Text(error.message ?? error.code.name),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: Text(context.t.presets.cancel),
          ),
        ],
      ),
    );
  }
}

class _VersionLabel extends ConsumerWidget {
  const _VersionLabel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(packageInfoProvider);
    return info.when(
      loading: () => const CupertinoActivityIndicator(),
      error: (error, _) => Text('$error'),
      data: (package) => Text('${package.version} (${package.buildNumber})'),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(title),
            AppGap.h12,
            child,
          ],
        ),
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: CupertinoColors.secondaryLabel.resolveFrom(context),
        ),
      );
}
