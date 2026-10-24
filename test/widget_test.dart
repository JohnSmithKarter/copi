import 'dart:async';

import 'package:copi/core/app.dart';
import 'package:copi/core/domain/sync_mode.dart';
import 'package:copi/core/l10n/locale_resolution.dart';
import 'package:copi/core/navigation/app_routes.dart';
import 'package:copi/core/presentation/apple_icon.dart';
import 'package:copi/core/presentation/launch_screen.dart';
import 'package:copi/core/presentation/macos_button.dart';
import 'package:copi/core/presentation/macos_switch.dart';
import 'package:copi/core/storage/shared_preferences_provider.dart';
import 'package:copi/core/theme/accent_color.dart';
import 'package:copi/core/theme/accent_provider.dart';
import 'package:copi/features/home/presentation/hidden_files_provider.dart';
import 'package:copi/features/presets/data/preferences_preset_repository.dart';
import 'package:copi/features/presets/presentation/preset_providers.dart';
import 'package:copi/features/sync/domain/sync_progress.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

Finder _appleIcon(String symbol) => find.byWidgetPredicate(
      (widget) => widget is AppleIcon && widget.symbol == symbol,
    );

Finder _macosButton(Finder child) => find.ancestor(
      of: child,
      matching: find.byType(MacosButton),
    );

bool _radioSelected(WidgetTester tester, String label) {
  final containers = tester.widgetList<AnimatedContainer>(
    find.descendant(
      of: find.ancestor(
        of: find.text(label),
        matching: find.byType(CupertinoButton),
      ),
      matching: find.byType(AnimatedContainer),
    ),
  );
  return containers.any((container) => container.constraints?.maxWidth == 6);
}

Future<void> _pumpApp(
  WidgetTester tester, {
  bool settle = true,
  Map<String, Object> stored = const {},
  List<Override> overrides = const [],
}) async {
  SharedPreferences.setMockInitialValues({
    localeStorageKey: 'en',
    ...stored,
  });
  PackageInfo.setMockInitialValues(
    appName: 'copi',
    packageName: 'copi',
    version: '1.0.0',
    buildNumber: '1',
    buildSignature: 'test',
  );
  final preferences = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        ...overrides,
      ],
      child: const CopiApp(),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }
}

class _FailedSync extends SyncController {
  @override
  SyncProgress? build() => const SyncProgress(
        phase: SyncPhase.error,
        processedFiles: 1,
        totalFiles: 2,
        processedBytes: 0,
        totalBytes: 0,
        message: 'fileFailed',
      );
}

void main() {
  testWidgets('home shows presets, settings, and standard folders', (
    tester,
  ) async {
    await _pumpApp(tester);

    expect(find.text('Copies'), findsOneWidget);
    expect(_appleIcon('gearshape'), findsOneWidget);
    expect(_appleIcon('info.circle'), findsOneWidget);
    expect(
      tester.getSize(_macosButton(find.text('Copies'))).height,
      tester.getSize(_macosButton(_appleIcon('gearshape'))).height,
    );
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Desktop'), findsOneWidget);
    expect(find.text('Documents'), findsOneWidget);
    expect(find.text('Downloads'), findsOneWidget);
  });

  testWidgets('launch mark plays, then leaves the home', (tester) async {
    await _pumpApp(tester, settle: false);

    expect(find.byKey(LaunchScreen.markKey), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(LaunchScreen.markKey), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byKey(LaunchScreen.markKey), findsNothing);
    expect(find.text('Copies'), findsOneWidget);
  });

  testWidgets('reduce motion skips the launch mark', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await _pumpApp(tester, settle: false);

    expect(find.byKey(LaunchScreen.markKey), findsNothing);
    expect(find.text('Copies'), findsOneWidget);
  });

  testWidgets('the app is dark', (tester) async {
    await _pumpApp(tester);

    final theme = tester.widget<CupertinoApp>(find.byType(CupertinoApp)).theme;
    expect(theme?.brightness, Brightness.dark);
    expect(theme?.textTheme.textStyle.fontFamily, '.AppleSystemUIFont');
  });

  testWidgets('accent choice is stored', (tester) async {
    await _pumpApp(tester);
    await tester.tap(_appleIcon('gearshape'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey(AppAccent.green)));
    await tester.pump();

    final theme = tester.widget<CupertinoApp>(find.byType(CupertinoApp)).theme;
    expect(theme?.primaryColor, AppAccent.green.color);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString(accentStorageKey), AppAccent.green.name);
  });

  testWidgets('settings fades in without sliding home aside', (tester) async {
    await _pumpApp(tester);
    final copies = find.text('Copies');
    final homeX = tester.getCenter(copies).dx;

    await tester.tap(_appleIcon('gearshape'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final width = tester.view.physicalSize.width / tester.view.devicePixelRatio;
    expect(find.text('Settings'), findsOneWidget);
    expect(tester.getCenter(find.text('Settings')).dx, closeTo(width / 2, 24));
    expect(tester.getCenter(copies).dx, closeTo(homeX, 1));
  });

  testWidgets('new copy screen shows both folders and the save card', (
    tester,
  ) async {
    await _pumpApp(tester);
    await tester.tap(find.text('Copies'));
    await tester.pumpAndSettle();

    expect(find.text('New copy'), findsOneWidget);
    expect(find.text('From'), findsOneWidget);
    expect(find.text('To'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);

    await tester.tap(_appleIcon('info.circle'));
    await tester.pumpAndSettle();

    expect(find.text('How to use'), findsOneWidget);
    expect(find.textContaining('remembers the current pair'), findsOneWidget);
  });

  testWidgets('changing the mode of a saved copy sticks', (tester) async {
    await _pumpApp(
      tester,
      stored: {
        presetsStorageKey: '''
[{"id":"1","name":"Monthly","pairs":[{"id":"a","sourceBookmark":"s1","destinationBookmark":"d1","sourceLabel":"/Downloads","destinationLabel":"/Volumes/HP","mode":"mirror"},{"id":"b","sourceBookmark":"s2","destinationBookmark":"d2","sourceLabel":"/projects","destinationLabel":"/Volumes/HP","mode":"mirror"}]}]
''',
      },
    );
    await tester.tap(find.text('Copies'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(_radioSelected(tester, 'Match source'), isTrue);
    expect(_radioSelected(tester, 'New and changed'), isFalse);

    await tester.tap(find.text('New and changed'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(_radioSelected(tester, 'New and changed'), isTrue);
    expect(_radioSelected(tester, 'Match source'), isFalse);
    final preferences = await SharedPreferences.getInstance();
    final modes = decodePresets(
      preferences.getString(presetsStorageKey),
    ).single.pairs.map((pair) => pair.mode);
    expect(modes, [SyncMode.additive, SyncMode.additive]);
  });

  testWidgets('a failed copy offers the logs button', (tester) async {
    await _pumpApp(
      tester,
      overrides: [syncControllerProvider.overrideWith(_FailedSync.new)],
    );

    unawaited(
      openSync(
        tester.element(find.text('Copies')),
        presetId: 'missing',
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'A file could not be handled. What was already done stays on the disk.',
      ),
      findsOneWidget,
    );
    await tester.tap(_appleIcon('list.bullet.rectangle'));
    await tester.pumpAndSettle();

    expect(find.text('Logs'), findsWidgets);
  });

  testWidgets('logs title stays centered clear of the back button', (
    tester,
  ) async {
    await _pumpApp(tester);
    await tester.tap(_appleIcon('gearshape'));
    await tester.pumpAndSettle();
    await tester.tap(_appleIcon('list.bullet.rectangle'));
    await tester.pumpAndSettle();

    final width = tester.view.physicalSize.width / tester.view.devicePixelRatio;
    Rect? titleBox;
    for (final element in find.text('Logs').evaluate()) {
      final box = element.renderObject! as RenderBox;
      final rect = box.localToGlobal(Offset.zero) & box.size;
      if (titleBox == null || rect.top < titleBox.top) {
        titleBox = rect;
      }
    }
    final title = titleBox!;
    final backBox = tester.getRect(_appleIcon('chevron.backward'));
    expect(title.top, lessThan(80));
    expect(title.center.dx, closeTo(width / 2, 24));
    expect(title.overlaps(backBox), isFalse);

    await tester.tap(_appleIcon('chevron.backward'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('hidden files switch is remembered', (tester) async {
    await _pumpApp(tester);
    await tester.tap(_appleIcon('gearshape'));
    await tester.pumpAndSettle();

    final toggle = find.byType(MacosSwitch);
    expect(find.text('Show hidden files'), findsOneWidget);
    expect(tester.widget<MacosSwitch>(toggle).value, isFalse);

    await tester.tap(toggle);
    await tester.pumpAndSettle();

    expect(tester.widget<MacosSwitch>(toggle).value, isTrue);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool(showHiddenFilesKey), isTrue);
  });

  testWidgets('language switch updates the settings title', (tester) async {
    await _pumpApp(tester);
    await tester.tap(_appleIcon('gearshape'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Русский'));
    await tester.pumpAndSettle();

    expect(find.text('Настройки'), findsOneWidget);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString(localeStorageKey), 'ru');
  });
}
