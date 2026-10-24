import 'package:copi/features/presets/data/preferences_preset_repository.dart';
import 'package:copi/features/presets/domain/preset.dart';
import 'package:copi/core/domain/sync_mode.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('presets round-trip through json', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = PreferencesPresetRepository(preferences);
    const preset = Preset(
      id: '1',
      name: 'Monthly',
      pairs: [
        PresetPair(
          id: 'pair',
          sourceBookmark: 'source-bookmark',
          destinationBookmark: 'dest-bookmark',
          sourceLabel: '/docs',
          destinationLabel: '/backup',
          mode: SyncMode.mirror,
        ),
      ],
    );

    await repository.save(preset);
    final loaded = repository.load();

    expect(loaded, hasLength(1));
    expect(loaded.single.name, 'Monthly');
    expect(loaded.single.pairs.single.mode, SyncMode.mirror);
    expect(loaded.single.pairs.single.sourceBookmark, 'source-bookmark');

    await repository.delete('1');
    expect(repository.load(), isEmpty);
  });
}
