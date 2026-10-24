import 'dart:async';
import 'dart:math' as math;

import 'package:copi/core/presentation/apple_icon.dart';
import 'package:flutter/cupertino.dart';

const _holdMs = 1000;
const _motionMs = 1400;
const _duration = Duration(milliseconds: _holdMs + _motionMs);
const _diskSize = 112.0;
const _docSize = 54.0;
const _restLift = 64.0;

/// Короткий ролик запуска поверх главного экрана.
///
/// Секунду сцена стоит: два системных диска и лист на левом. Потом лист
/// перелетает на правый, и сцена растворяется. При уменьшении движения
/// в системе ролик пропускается.
class LaunchScreen extends StatefulWidget {
  const LaunchScreen({required this.child, super.key});

  static const markKey = Key('launch-mark');

  final Widget child;

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  var _started = false;
  var _visible = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _visible = false;
      return;
    }
    unawaited(_controller.forward().whenComplete(_hide));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _hide() {
    if (!mounted || !_visible) {
      return;
    }
    setState(() => _visible = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) {
      return widget.child;
    }
    final accent = CupertinoTheme.of(context).primaryColor;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final reveal = Curves.easeOutCubic.transform(
          _span(_motionOf(_controller.value), 0.78, 0.98),
        );
        return Stack(
          children: [
            IgnorePointer(
              child: Opacity(opacity: reveal, child: child),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Semantics(
                  label: 'copi',
                  child: LayoutBuilder(
                    key: LaunchScreen.markKey,
                    builder: (context, constraints) {
                      final scene = _scene(
                        constraints.biggest,
                        _controller.value,
                      );
                      return Opacity(
                        opacity: scene.presence,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _TrailPainter(
                                  from: scene.left,
                                  to: scene.right,
                                  travel: scene.travel,
                                  opacity: scene.presence,
                                  accent: accent,
                                ),
                              ),
                            ),
                            _glyph(
                              at: scene.left,
                              symbol: 'opticaldisc.fill',
                              size: _diskSize,
                              color: accent,
                            ),
                            _glyph(
                              at: scene.right,
                              symbol: 'opticaldisc.fill',
                              size: _diskSize,
                              color: accent,
                            ),
                            _glyph(
                              at: scene.sheet,
                              symbol: 'doc.fill',
                              size: _docSize,
                              color: accent,
                              weight: AppleIconWeight.medium,
                              scale: 0.94 + scene.lift * 0.1,
                              angle: scene.lift * 0.08,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
      child: widget.child,
    );
  }
}

class _TrailPainter extends CustomPainter {
  const _TrailPainter({
    required this.from,
    required this.to,
    required this.travel,
    required this.opacity,
    required this.accent,
  });

  final Offset from;
  final Offset to;
  final double travel;
  final double opacity;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    if (travel <= 0.04 || travel >= 0.98 || opacity <= 0) {
      return;
    }
    final path = Path();
    final start = math.max(0.0, travel - 0.22);
    const steps = 14;
    for (var i = 0; i <= steps; i++) {
      final u = start + (travel - start) * (i / steps);
      final point = _flight(from, to, u);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..color = accent.withValues(alpha: 0.35 * opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  @override
  bool shouldRepaint(_TrailPainter oldDelegate) =>
      oldDelegate.from != from ||
      oldDelegate.to != to ||
      oldDelegate.travel != travel ||
      oldDelegate.opacity != opacity ||
      oldDelegate.accent != accent;
}

class _Scene {
  const _Scene({
    required this.left,
    required this.right,
    required this.sheet,
    required this.travel,
    required this.presence,
    required this.lift,
  });

  final Offset left;
  final Offset right;
  final Offset sheet;
  final double travel;
  final double presence;
  final double lift;
}

_Scene _scene(Size size, double progress) {
  final motion = _motionOf(progress);
  final appeared = Curves.easeOutCubic.transform(_span(progress, 0, 0.07));
  final travel = Curves.easeInOutCubic.transform(_span(motion, 0.16, 0.68));
  final fade = 1 - Curves.easeIn.transform(_span(motion, 0.8, 1));
  final center = Offset(size.width / 2, size.height / 2 - 8);
  const spread = 184.0;
  final left = center + const Offset(-spread, 12);
  final right = center + const Offset(spread, 12);
  return _Scene(
    left: left,
    right: right,
    sheet: _flight(left, right, travel),
    travel: travel,
    presence: appeared * fade,
    lift: math.sin(travel * math.pi),
  );
}

Widget _glyph({
  required Offset at,
  required String symbol,
  required double size,
  required Color color,
  AppleIconWeight weight = AppleIconWeight.regular,
  double scale = 1,
  double angle = 0,
}) =>
    Positioned(
      left: at.dx - size / 2,
      top: at.dy - size / 2,
      width: size,
      height: size,
      child: Transform.rotate(
        angle: angle,
        child: Transform.scale(
          scale: scale,
          child: AppleIcon(
            symbol,
            size: size,
            color: color,
            weight: weight,
          ),
        ),
      ),
    );

Offset _flight(Offset from, Offset to, double t) {
  final arc = math.sin(t * math.pi);
  return Offset(
    from.dx + (to.dx - from.dx) * t,
    from.dy - _restLift - arc * 52,
  );
}

double _motionOf(double t) {
  const hold = _holdMs / (_holdMs + _motionMs);
  if (t <= hold) {
    return 0;
  }
  return (t - hold) / (1 - hold);
}

double _span(double t, double start, double end) {
  final u = (t - start) / (end - start);
  if (u <= 0) {
    return 0;
  }
  if (u >= 1) {
    return 1;
  }
  return u;
}
