import 'package:copi/core/i18n/strings.g.dart';
import 'package:copi/core/presentation/app_metrics.dart';
import 'package:copi/core/presentation/surface_card.dart';
import 'package:copi/core/presentation/window_bar.dart';
import 'package:flutter/cupertino.dart';

/// Зачем приложение, что оно умеет и чего не делает.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final about = context.t.about;
    return CupertinoPageScaffold(
      navigationBar: WindowBar(
        title: Text(about.title),
      ),
      child: SafeArea(
        child: ListView(
          padding: AppPadding.page,
          children: [
            _Block(title: about.goalTitle, body: about.goal),
            AppGap.h12,
            _Block(title: about.canTitle, body: about.can),
            AppGap.h12,
            _Block(title: about.limitsTitle, body: about.limits),
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
