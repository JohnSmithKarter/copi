import 'dart:async';

import 'package:copi/core/i18n/strings.g.dart';
import 'package:copi/core/logging/app_failure.dart';
import 'package:copi/core/presentation/app_metrics.dart';
import 'package:copi/core/presentation/apple_icon.dart';
import 'package:copi/core/presentation/macos_button.dart';
import 'package:copi/features/access/domain/folder_root.dart';
import 'package:copi/features/access/domain/volume_access.dart';
import 'package:copi/features/access/presentation/folder_access_provider.dart';
import 'package:copi/features/access/presentation/volume_access_provider.dart';
import 'package:copi/features/home/domain/directory_entry.dart';
import 'package:copi/features/home/presentation/directory_providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Дерево стандартных папок. Стрелка раскрывает один уровень.
class FolderBrowser extends ConsumerStatefulWidget {
  const FolderBrowser({
    this.selectedPath,
    this.onSelect,
    this.padding = AppPadding.folderBrowser,
    super.key,
  });

  final String? selectedPath;
  final ValueChanged<String>? onSelect;
  final EdgeInsetsGeometry padding;

  @override
  ConsumerState<FolderBrowser> createState() => _FolderBrowserState();
}

class _FolderBrowserState extends ConsumerState<FolderBrowser> {
  final Set<String> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final access = ref.watch(folderAccessProvider);
    final disks = ref.watch(mountedVolumesProvider).asData?.value ??
        const <VolumeAccess>[];
    final translations = context.t;
    return access.when(
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (error, _) => Center(child: Text('$error')),
      data: (roots) => ListView(
        padding: widget.padding,
        children: [
          for (final root in roots)
            _RootSection(
              root: root,
              label: rootLabel(translations, root.id),
              expanded: _expanded,
              selectedPath: widget.selectedPath,
              onToggle: _toggle,
              onSelect: widget.onSelect,
              onAllow: () => unawaited(_allow(root.id)),
            ),
          if (disks.isNotEmpty) ...[
            Padding(
              padding: AppPadding.diskHeading,
              child: Text(
                translations.home.disks,
                style: TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
              ),
            ),
            for (final disk in disks)
              _DiskSection(
                disk: disk,
                expanded: _expanded,
                selectedPath: widget.selectedPath,
                onToggle: _toggle,
                onSelect: widget.onSelect,
                onAllow: () => unawaited(_allowDisk(disk.mountPath)),
              ),
          ],
        ],
      ),
    );
  }

  void _toggle(String path) => setState(() {
        if (!_expanded.add(path)) {
          _expanded.remove(path);
        }
      });

  Future<void> _allow(FolderRootId id) async {
    try {
      await ref.read(folderAccessProvider.notifier).grant(id);
    } on AppFailure catch (error) {
      if (!mounted) {
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

  Future<void> _allowDisk(String mountPath) async {
    try {
      await ref.read(mountedVolumesProvider.notifier).grant(mountPath);
    } on AppFailure catch (error) {
      if (!mounted) {
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
}

class _RootSection extends StatelessWidget {
  const _RootSection({
    required this.root,
    required this.label,
    required this.expanded,
    required this.selectedPath,
    required this.onToggle,
    required this.onSelect,
    required this.onAllow,
  });

  final ResolvedRoot root;
  final String label;
  final Set<String> expanded;
  final String? selectedPath;
  final ValueChanged<String> onToggle;
  final ValueChanged<String>? onSelect;
  final VoidCallback onAllow;

  @override
  Widget build(BuildContext context) {
    final path = root.path;
    if (path == null) {
      return _EntryRow(
        name: label,
        kind: FileKind.folder,
        expanded: false,
        selected: false,
        showChevron: false,
        trailing: MacosButton(
          label: context.t.home.allow,
          onPressed: onAllow,
        ),
        subtitle: context.t.home.noAccess,
        onToggle: () {},
      );
    }
    final isExpanded = expanded.contains(path);
    return _FolderGroup(
      expanded: isExpanded,
      header: _EntryRow(
        name: label,
        kind: FileKind.folder,
        expanded: isExpanded,
        selected: selectedPath == path,
        showChevron: true,
        onToggle: () => onToggle(path),
        onSelect: onSelect == null ? null : () => onSelect!(path),
      ),
      children: _Children(
        path: path,
        visible: isExpanded,
        expanded: expanded,
        selectedPath: selectedPath,
        onToggle: onToggle,
        onSelect: onSelect,
      ),
    );
  }
}

class _DiskSection extends StatelessWidget {
  const _DiskSection({
    required this.disk,
    required this.expanded,
    required this.selectedPath,
    required this.onToggle,
    required this.onSelect,
    required this.onAllow,
  });

  final VolumeAccess disk;
  final Set<String> expanded;
  final String? selectedPath;
  final ValueChanged<String> onToggle;
  final ValueChanged<String>? onSelect;
  final VoidCallback onAllow;

  @override
  Widget build(BuildContext context) {
    final path = disk.path;
    if (!disk.hasAccess || path == null) {
      return _EntryRow(
        name: disk.name,
        kind: FileKind.disk,
        expanded: false,
        selected: false,
        showChevron: false,
        trailing: MacosButton(
          label: context.t.home.allow,
          onPressed: onAllow,
        ),
        subtitle: context.t.home.noAccess,
        onToggle: () {},
      );
    }
    final isExpanded = expanded.contains(path);
    return _FolderGroup(
      expanded: isExpanded,
      header: _EntryRow(
        name: disk.name,
        kind: FileKind.disk,
        expanded: isExpanded,
        selected: selectedPath == path,
        showChevron: true,
        onToggle: () => onToggle(path),
        onSelect: onSelect == null ? null : () => onSelect!(path),
      ),
      children: _Children(
        path: path,
        visible: isExpanded,
        expanded: expanded,
        selectedPath: selectedPath,
        onToggle: onToggle,
        onSelect: onSelect,
      ),
    );
  }
}

/// Раскрытая папка и то, что внутри неё.
///
/// Заливка только у внешней папки. Вложенные уровни держит линия,
/// иначе каждый слой темнеет и сливается в лесенку.
class _FolderGroup extends StatelessWidget {
  const _FolderGroup({
    required this.expanded,
    required this.header,
    required this.children,
    this.plate = true,
  });

  final bool expanded;
  final Widget header;
  final Widget children;
  final bool plate;

  @override
  Widget build(BuildContext context) {
    final showPlate = expanded && plate;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      margin: showPlate ? AppPadding.bottom4 : AppPadding.none,
      padding: showPlate ? AppPadding.folderPlate : AppPadding.none,
      decoration: BoxDecoration(
        color: showPlate
            ? CupertinoColors.tertiarySystemFill.resolveFrom(context)
            : const Color(0x00000000),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          children,
        ],
      ),
    );
  }
}

class _Children extends ConsumerWidget {
  const _Children({
    required this.path,
    required this.visible,
    required this.expanded,
    required this.selectedPath,
    required this.onToggle,
    required this.onSelect,
  });

  final String path;
  final bool visible;
  final Set<String> expanded;
  final String? selectedPath;
  final ValueChanged<String> onToggle;
  final ValueChanged<String>? onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!visible) {
      return const AnimatedSize(
        duration: Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: SizedBox(width: double.infinity),
      );
    }
    final listing = ref.watch(directoryListingProvider(path));
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: _Guide(
        child: listing.when(
          loading: () => const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: AppPadding.vertical8,
              child: CupertinoActivityIndicator(),
            ),
          ),
          error: (error, _) => Padding(
            padding: AppPadding.vertical8,
            child: Text('$error'),
          ),
          data: (entries) {
            if (entries.isEmpty) {
              return Padding(
                padding: AppPadding.emptyFolder,
                child: Text(
                  context.t.home.empty,
                  style: TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final entry in entries)
                  if (entry.isDirectory)
                    _FolderGroup(
                      plate: false,
                      expanded: expanded.contains(entry.path),
                      header: _EntryRow(
                        name: entry.name,
                        kind: entry.kind,
                        expanded: expanded.contains(entry.path),
                        selected: selectedPath == entry.path,
                        showChevron: true,
                        onToggle: () => onToggle(entry.path),
                        onSelect: onSelect == null
                            ? null
                            : () => onSelect!(entry.path),
                      ),
                      children: _Children(
                        path: entry.path,
                        visible: expanded.contains(entry.path),
                        expanded: expanded,
                        selectedPath: selectedPath,
                        onToggle: onToggle,
                        onSelect: onSelect,
                      ),
                    )
                  else
                    _EntryRow(
                      name: entry.name,
                      kind: entry.kind,
                      expanded: false,
                      selected: false,
                      showChevron: false,
                      onToggle: () {},
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Вертикальная линия от папки к её строкам.
class _Guide extends StatelessWidget {
  const _Guide({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Positioned(
            left: 15,
            top: 0,
            bottom: 4,
            child: ColoredBox(
              color: CupertinoColors.separator.resolveFrom(context),
              child: const SizedBox(width: 1),
            ),
          ),
          Padding(
            padding: AppPadding.nestedRows,
            child: child,
          ),
        ],
      );
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({
    required this.name,
    required this.kind,
    required this.expanded,
    required this.selected,
    required this.showChevron,
    required this.onToggle,
    this.onSelect,
    this.trailing,
    this.subtitle,
  });

  final String name;
  final FileKind kind;
  final bool expanded;
  final bool selected;
  final bool showChevron;
  final VoidCallback onToggle;
  final VoidCallback? onSelect;
  final Widget? trailing;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final accent = CupertinoTheme.of(context).primaryColor;
    return Padding(
      padding: AppPadding.bottom2,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.16) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: showChevron
                  ? CupertinoButton(
                      padding: AppPadding.none,
                      minimumSize: const Size(32, 32),
                      onPressed: onToggle,
                      child: AnimatedRotation(
                        turns: expanded ? 0.25 : 0,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        child: AppleIcon(
                          'chevron.right',
                          size: 16,
                          color: accent,
                        ),
                      ),
                    )
                  : null,
            ),
            AppleIcon(
              _symbolForFileKind(kind),
              color: kind == FileKind.folder || kind == FileKind.disk
                  ? accent
                  : CupertinoColors.secondaryLabel,
              size: 20,
            ),
            AppGap.w8,
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onSelect ?? (showChevron ? onToggle : null),
                child: Padding(
                  padding: AppPadding.vertical10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.secondaryLabel.resolveFrom(
                              context,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

/// Имя SF Symbol для вида файла.
String _symbolForFileKind(FileKind kind) => switch (kind) {
      FileKind.folder => 'folder.fill',
      FileKind.application => 'app.fill',
      FileKind.image => 'photo.fill',
      FileKind.video => 'film.fill',
      FileKind.audio => 'music.note',
      FileKind.text => 'doc.plaintext',
      FileKind.document => 'doc.text.fill',
      FileKind.spreadsheet => 'tablecells.fill',
      FileKind.presentation => 'rectangle.stack.fill',
      FileKind.archive => 'archivebox.fill',
      FileKind.code => 'chevron.left.forwardslash.chevron.right',
      FileKind.disk => 'externaldrive.fill',
      FileKind.font => 'textformat',
      FileKind.design => 'paintbrush.fill',
      FileKind.other => 'doc',
    };

/// Локализованное имя стандартного раздела.
String rootLabel(Translations translations, FolderRootId id) => switch (id) {
      FolderRootId.home => translations.home.roots.home,
      FolderRootId.desktop => translations.home.roots.desktop,
      FolderRootId.documents => translations.home.roots.documents,
      FolderRootId.downloads => translations.home.roots.downloads,
    };
