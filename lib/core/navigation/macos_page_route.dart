import 'package:flutter/widgets.dart';

/// Растворение экрана, как при переходе в macOS.
const _duration = Duration(milliseconds: 200);

final Animatable<double> _appear = CurveTween(curve: Curves.easeInOut);

final Animatable<double> _covered = Tween<double>(
  begin: 1,
  end: 0,
).chain(CurveTween(curve: Curves.easeInOut));

/// Экран проявляется на месте. Предыдущий в это же время растворяется.
class MacosPageRoute<T> extends PageRoute<T> {
  MacosPageRoute({required this.builder, super.settings});

  final WidgetBuilder builder;

  @override
  DelegatedTransitionBuilder? get delegatedTransition => _fadeCovered;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => _duration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        child: builder(context),
      );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      FadeTransition(
        opacity: _covered.animate(secondaryAnimation),
        child: FadeTransition(
          opacity: _appear.animate(animation),
          child: child,
        ),
      );
}

/// Просит экран снизу погаснуть вместе с появлением нового, без сдвига.
Widget _fadeCovered(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  bool allowSnapshotting,
  Widget? child,
) =>
    FadeTransition(
      opacity: _covered.animate(secondaryAnimation),
      child: child,
    );
