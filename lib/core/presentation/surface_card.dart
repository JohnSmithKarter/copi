import 'package:copi/core/presentation/app_metrics.dart';
import 'package:flutter/cupertino.dart';

/// Мягкая карточка на фоне окна.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    required this.child,
    this.padding = AppPadding.card,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(padding: padding, child: child),
      );
}
