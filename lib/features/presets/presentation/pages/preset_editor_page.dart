import 'dart:async';

import 'package:copi/core/domain/sync_mode.dart';
import 'package:copi/core/i18n/strings.g.dart';
import 'package:copi/core/logging/app_failure.dart';
import 'package:copi/core/navigation/app_routes.dart';
import 'package:copi/core/presentation/app_metrics.dart';
import 'package:copi/core/presentation/apple_icon.dart';
import 'package:copi/core/presentation/macos_button.dart';
import 'package:copi/core/presentation/macos_radio_group.dart';
import 'package:copi/core/presentation/surface_card.dart';
import 'package:copi/core/presentation/window_bar.dart';
import 'package:copi/core/storage/entity_id.dart';
import 'package:copi/features/access/domain/folder_root.dart';
import 'package:copi/features/access/domain/volume_access.dart';
import 'package:copi/features/access/presentation/folder_access_provider.dart';
import 'package:copi/features/access/presentation/volume_access_provider.dart';
import 'package:copi/features/home/domain/path_label.dart';
import 'package:copi/features/home/presentation/widgets/folder_browser.dart';
import 'package:copi/features/presets/domain/preset.dart';
import 'package:copi/features/presets/presentation/preset_providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

/// Два дерева: слева источник, справа назначение.
class PresetEditorPage extends ConsumerStatefulWidget {
  const PresetEditorPage({this.preset, super.key});

  final Preset? preset;

  @override
  ConsumerState<PresetEditorPage> createState() => _PresetEditorPageState();
}

class _PresetEditorPageState extends ConsumerState<PresetEditorPage> {
  late final TextEditingController _name;
  late final List<PresetPair> _pairs;
  String? _sourcePath;
  String? _destinationPath;
  SyncMode _mode = SyncMode.mirror;
  String? _errorCode;

  @override
  void initState() {
    super.initState();
    final preset = widget.preset;
    _name = TextEditingController(text: preset?.name ?? '');
    _pairs = [...?preset?.pairs];
    final first = preset?.pairs;
    if (first != null && first.isNotEmpty) {
      _mode = first.first.mode;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final translations = context.t.presets;
    final editing = widget.preset;
    return CupertinoPageScaffold(
      navigationBar: WindowBar(
        title: Text(editing == null ? translations.newTitle : editing.name),
        trailing: MacosButton(
          symbol: 'info.circle',
          semanticLabel: translations.help.title,
          onPressed: () => unawaited(openPresetHelp(context)),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: AppPadding.editor,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _Pane(
                        title: translations.source,
                        selectedPath: _sourcePath,
                        selectedLabel: _selectedLabel(_sourcePath),
                        clearLabel: translations.clear,
                        onSelect: (path) => _choose(source: true, path: path),
                        onClear: () => _choose(source: true, path: null),
                      ),
                    ),
                    const Padding(
                      padding: AppPadding.horizontal12,
                      child: AppleIcon(
                        'arrow.right',
                        size: 18,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ),
                    Expanded(
                      child: _Pane(
                        title: translations.destination,
                        selectedPath: _destinationPath,
                        selectedLabel: _selectedLabel(_destinationPath),
                        clearLabel: translations.clear,
                        onSelect: (path) => _choose(source: false, path: path),
                        onClear: () => _choose(source: false, path: null),
                      ),
                    ),
                  ],
                ),
              ),
              AppGap.h12,
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CupertinoTextField(
                      controller: _name,
                      placeholder: translations.nameHint,
                      padding: AppPadding.field,
                      decoration: BoxDecoration(
                        color: CupertinoColors.secondarySystemFill.resolveFrom(
                          context,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    if (_errorCode == 'needName')
                      _ErrorLine(text: _errorText(context)),
                    AppGap.h12,
                    MacosRadioGroup<SyncMode>(
                      value: _mode,
                      onChanged: (value) => setState(() => _mode = value),
                      options: [
                        MacosRadioOption(
                          value: SyncMode.mirror,
                          label: translations.mirror,
                        ),
                        MacosRadioOption(
                          value: SyncMode.additive,
                          label: translations.additive,
                        ),
                      ],
                    ),
                    AppGap.h8,
                    Text(
                      _mode == SyncMode.mirror
                          ? translations.mirrorHint
                          : translations.additiveHint,
                      style: TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.secondaryLabel.resolveFrom(
                          context,
                        ),
                      ),
                    ),
                    if (_pairs.isNotEmpty) ...[
                      AppGap.h12,
                      for (final pair in _pairs)
                        Padding(
                          padding: AppPadding.bottom6,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${p.basename(pair.sourceLabel)} → ${p.basename(pair.destinationLabel)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              MacosButton(
                                label: translations.remove,
                                foreground: CupertinoColors.systemRed
                                    .resolveFrom(context),
                                onPressed: () =>
                                    setState(() => _pairs.remove(pair)),
                              ),
                            ],
                          ),
                        ),
                    ],
                    if (_errorCode != null && _errorCode != 'needName')
                      _ErrorLine(text: _errorText(context)),
                    AppGap.h12,
                    _EditorButtons(
                      addLabel: translations.addPair,
                      saveLabel: translations.save,
                      onAdd: () => unawaited(_addPair()),
                      onSave: () => unawaited(_save()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _choose({required bool source, required String? path}) {
    setState(() {
      final current = source ? _sourcePath : _destinationPath;
      final next = path != null && path == current ? null : path;
      if (source) {
        _sourcePath = next;
      } else {
        _destinationPath = next;
      }
      if (_errorCode != 'needName') {
        _errorCode = null;
      }
    });
  }

  Future<void> _addPair() async {
    final pair = await _pairFromSelection();
    if (!mounted || pair == null) {
      return;
    }
    setState(() {
      _pairs.add(pair);
      _sourcePath = null;
      _destinationPath = null;
      _errorCode = null;
    });
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _errorCode = 'needName');
      return;
    }
    if (_sourcePath != null || _destinationPath != null) {
      final pair = await _pairFromSelection();
      if (!mounted) {
        return;
      }
      if (pair == null) {
        return;
      }
      _pairs.add(pair);
      _sourcePath = null;
      _destinationPath = null;
    }
    if (_pairs.isEmpty) {
      setState(() => _errorCode = 'needBoth');
      return;
    }
    await ref.read(presetsProvider.notifier).save(
          Preset(
            id: widget.preset?.id ?? newEntityId(),
            name: name,
            pairs: [for (final pair in _pairs) pair.copyWith(mode: _mode)],
          ),
        );
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  Future<PresetPair?> _pairFromSelection() async {
    final source = _sourcePath;
    final destination = _destinationPath;
    if (source == null || destination == null) {
      setState(() {
        _errorCode = switch ((source, destination)) {
          (null, null) => 'needBoth',
          (null, _) => 'needSource',
          (_, null) => 'needDestination',
          _ => 'needBoth',
        };
      });
      return null;
    }
    final sourcePath = p.normalize(source);
    final destinationPath = p.normalize(destination);
    final copyRoot = p.join(destinationPath, p.basename(sourcePath));
    if (p.equals(sourcePath, destinationPath) ||
        p.equals(sourcePath, copyRoot) ||
        p.isWithin(sourcePath, copyRoot) ||
        p.isWithin(copyRoot, sourcePath)) {
      setState(() => _errorCode = 'sameFolder');
      return null;
    }
    try {
      final gateway = ref.read(bookmarkGatewayProvider);
      final sourceBookmark = await gateway.bookmarkForPath(source);
      final destinationBookmark = await gateway.bookmarkForPath(destination);
      return PresetPair(
        id: newEntityId(),
        sourceBookmark: sourceBookmark,
        destinationBookmark: destinationBookmark,
        sourceLabel: source,
        destinationLabel: destination,
        mode: _mode,
      );
    } on AppFailure {
      setState(() => _errorCode = 'bookmark');
      return null;
    }
  }

  String? _selectedLabel(String? path) {
    final roots =
        ref.watch(folderAccessProvider).value ?? const <ResolvedRoot>[];
    final disks = ref.watch(mountedVolumesProvider).asData?.value ??
        const <VolumeAccess>[];
    if (path == null) {
      return null;
    }
    return labeledPath(
      path: path,
      roots: {
        for (final root in roots)
          if (root.path != null && root.path!.isNotEmpty)
            root.path!: rootLabel(context.t, root.id),
        for (final disk in disks)
          if (disk.path != null && disk.path!.isNotEmpty) disk.path!: disk.name,
      },
    );
  }

  String _errorText(BuildContext context) {
    final presets = context.t.presets;
    return switch (_errorCode) {
      'needBoth' => presets.needBoth,
      'needSource' => presets.needSource,
      'needDestination' => presets.needDestination,
      'sameFolder' => presets.sameFolder,
      'needName' => presets.needName,
      'bookmark' => context.t.errors.bookmark,
      _ => '',
    };
  }
}

/// «Ещё папка» и «Сохранить» одной ширины и высоты.
class _EditorButtons extends StatelessWidget {
  const _EditorButtons({
    required this.addLabel,
    required this.saveLabel,
    required this.onAdd,
    required this.onSave,
  });

  final String addLabel;
  final String saveLabel;
  final VoidCallback onAdd;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final width = _sharedWidth(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        MacosButton(label: addLabel, minWidth: width, onPressed: onAdd),
        AppGap.w8,
        MacosButton(label: saveLabel, minWidth: width, onPressed: onSave),
      ],
    );
  }

  double _sharedWidth(BuildContext context) {
    final style = CupertinoTheme.of(context).textTheme.actionTextStyle;
    final direction = Directionality.of(context);
    var widest = 0.0;
    for (final label in [addLabel, saveLabel]) {
      final painter = TextPainter(
        text: TextSpan(text: label, style: style),
        textDirection: direction,
        maxLines: 1,
      )..layout();
      if (painter.width > widest) {
        widest = painter.width;
      }
    }
    return widest + AppSpace.s22 * 2;
  }
}

class _ErrorLine extends StatelessWidget {
  const _ErrorLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: AppPadding.top8,
        child: Text(
          text,
          style: TextStyle(
            color: CupertinoColors.systemRed.resolveFrom(context),
          ),
        ),
      );
}

class _Pane extends StatelessWidget {
  const _Pane({
    required this.title,
    required this.selectedPath,
    required this.selectedLabel,
    required this.clearLabel,
    required this.onSelect,
    required this.onClear,
  });

  final String title;
  final String? selectedPath;
  final String? selectedLabel;
  final String clearLabel;
  final ValueChanged<String> onSelect;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final accent = CupertinoTheme.of(context).primaryColor;
    final label = selectedLabel;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SurfaceCard(
        padding: AppPadding.none,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: AppPadding.paneTitle,
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
              ),
            ),
            if (label != null)
              Padding(
                padding: AppPadding.paneChip,
                child: Row(
                  children: [
                    Flexible(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Padding(
                                padding: AppPadding.chipLabel,
                                child: Text(
                                  label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            CupertinoButton(
                              padding: AppPadding.chipClear,
                              minimumSize: Size.zero,
                              onPressed: onClear,
                              child: AppleIcon(
                                'xmark',
                                size: 11,
                                weight: AppleIconWeight.semibold,
                                color: accent,
                                semanticLabel: clearLabel,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: FolderBrowser(
                padding: AppPadding.paneTree,
                selectedPath: selectedPath,
                onSelect: onSelect,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
