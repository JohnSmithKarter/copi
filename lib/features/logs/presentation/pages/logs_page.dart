import 'package:copi/core/i18n/strings.g.dart';
import 'package:copi/core/logging/talker_provider.dart';
import 'package:copi/core/presentation/window_bar.dart';
import 'package:copi/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Высота шапки Talker. Кнопка назад лежит поверх неё, а не в узком слоте leading.
const _talkerToolbarHeight = 60.0;

/// Журнал текущего запуска. После перезапуска список пустой.
class LogsPage extends ConsumerWidget {
  const LogsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final talker = ref.watch(talkerProvider);
    return Stack(
      children: [
        Material(
          type: MaterialType.transparency,
          child: Builder(
            builder: (context) {
              final theme = Theme.of(context);
              return Theme(
                data: theme.copyWith(
                  textTheme: theme.textTheme.apply(fontFamily: appleSystemFont),
                  primaryTextTheme: theme.primaryTextTheme.apply(
                    fontFamily: appleSystemFont,
                  ),
                  appBarTheme: theme.appBarTheme.copyWith(centerTitle: true),
                ),
                child: TalkerScreen(
                  talker: talker,
                  appBarTitle: context.t.logs.title,
                  appBarLeading: const SizedBox.shrink(),
                  theme: const TalkerScreenTheme(
                    backgroundColor: Color(0x00000000),
                    cardColor: Color(0xFF2C2C2E),
                  ),
                ),
              );
            },
          ),
        ),
        const Positioned(
          left: windowButtonsInset,
          top: 0,
          height: _talkerToolbarHeight,
          child: Center(child: WindowBackButton()),
        ),
      ],
    );
  }
}
