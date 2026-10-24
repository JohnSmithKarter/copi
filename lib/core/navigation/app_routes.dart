import 'package:copi/core/navigation/macos_page_route.dart';
import 'package:copi/features/about/presentation/pages/about_page.dart';
import 'package:copi/features/logs/presentation/pages/logs_page.dart';
import 'package:copi/features/presets/domain/preset.dart';
import 'package:copi/features/presets/presentation/pages/preset_editor_page.dart';
import 'package:copi/features/presets/presentation/pages/preset_help_page.dart';
import 'package:copi/features/presets/presentation/pages/preset_list_page.dart';
import 'package:copi/features/settings/presentation/pages/settings_page.dart';
import 'package:copi/features/sync/presentation/pages/sync_page.dart';
import 'package:flutter/widgets.dart';

/// Настройки.
Future<void> openSettings(BuildContext context) => Navigator.of(context).push(
      MacosPageRoute<void>(
        settings: const RouteSettings(name: 'settings'),
        builder: (context) => const SettingsPage(),
      ),
    );

/// Логи текущей сессии.
Future<void> openLogs(BuildContext context) => Navigator.of(context).push(
      MacosPageRoute<void>(
        settings: const RouteSettings(name: 'logs'),
        builder: (context) => const LogsPage(),
      ),
    );

/// Экран о приложении.
Future<void> openAbout(BuildContext context) => Navigator.of(context).push(
      MacosPageRoute<void>(
        settings: const RouteSettings(name: 'about'),
        builder: (context) => const AboutPage(),
      ),
    );

/// Список пресетов.
Future<void> openPresetList(BuildContext context) => Navigator.of(context).push(
      MacosPageRoute<void>(
        settings: const RouteSettings(name: 'presets'),
        builder: (context) => const PresetListPage(),
      ),
    );

/// Редактор нового или существующего пресета.
Future<void> openPresetEditor(BuildContext context, {Preset? preset}) =>
    Navigator.of(context).push(
      MacosPageRoute<void>(
        settings: const RouteSettings(name: 'editor'),
        builder: (context) => PresetEditorPage(preset: preset),
      ),
    );

/// Как пользоваться экраном новой копии.
Future<void> openPresetHelp(BuildContext context) => Navigator.of(context).push(
      MacosPageRoute<void>(
        settings: const RouteSettings(name: 'preset-help'),
        builder: (context) => const PresetHelpPage(),
      ),
    );

/// Прогресс запуска пресета.
Future<void> openSync(BuildContext context, {required String presetId}) =>
    Navigator.of(context).push(
      MacosPageRoute<void>(
        settings: const RouteSettings(name: 'sync'),
        builder: (context) => SyncPage(presetId: presetId),
      ),
    );
