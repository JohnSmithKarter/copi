import 'package:copi/core/i18n/strings.g.dart';
import 'package:copi/core/presentation/app_metrics.dart';
import 'package:copi/core/presentation/surface_card.dart';
import 'package:copi/core/presentation/window_bar.dart';
import 'package:flutter/cupertino.dart';

/// Как выбрать папки, чем отличаются режимы и зачем «Ещё папка».
class PresetHelpPage extends StatelessWidget {
  const PresetHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final help = context.t.presets.help;
    return CupertinoPageScaffold(
      navigationBar: WindowBar(
        title: Text(help.title),
      ),
      child: SafeArea(
        child: ListView(
          padding: AppPadding.page,
          children: [
            _Block(title: help.chooseTitle, body: help.choose),
            AppGap.h12,
            _Block(title: help.modeTitle, body: help.mode),
            AppGap.h12,
            _Block(title: help.moreTitle, body: help.more),
            AppGap.h12,
            _Block(title: help.sameNameTitle, body: help.sameName),
          ],
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            AppGap.h8,
            Text(
              body,
              style: TextStyle(
                height: 1.35,
                color: CupertinoColors.label.resolveFrom(context),
              ),
            ),
          ],
        ),
      );
}
