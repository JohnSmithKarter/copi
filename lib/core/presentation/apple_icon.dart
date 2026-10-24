import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

const _channel = MethodChannel('copi/symbols');

final _cache = <_SymbolKey, Uint8List>{};
final _inflight = <_SymbolKey, Future<Uint8List?>>{};

typedef _SymbolKey = ({
  String symbol,
  double size,
  int color,
  String weight,
  double scale,
});

/// Насыщенность системного значка Apple.
enum AppleIconWeight {
  regular,
  medium,
  semibold,
  bold,
}

/// Значок SF Symbols. Имя — системное, например `chevron.backward`.
class AppleIcon extends StatefulWidget {
  const AppleIcon(
    this.symbol, {
    this.size = 24,
    this.color,
    this.weight = AppleIconWeight.medium,
    this.semanticLabel,
    super.key,
  });

  final String symbol;
  final double size;
  final Color? color;
  final AppleIconWeight weight;
  final String? semanticLabel;

  @override
  State<AppleIcon> createState() => _AppleIconState();
}

class _AppleIconState extends State<AppleIcon> {
  _SymbolKey? _requested;
  Uint8List? _bytes;

  @override
  Widget build(BuildContext context) {
    final color = CupertinoDynamicColor.resolve(
      widget.color ?? CupertinoColors.label,
      context,
    );
    _schedule(
      (
        symbol: widget.symbol,
        size: widget.size,
        color: color.toARGB32(),
        weight: widget.weight.name,
        scale: MediaQuery.devicePixelRatioOf(context),
      ),
    );
    final bytes = _bytes;
    Widget child = DecoratedBox(
      decoration: const BoxDecoration(),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Center(
          child: bytes == null
              ? const SizedBox.shrink()
              : Image.memory(
                  bytes,
                  scale: _requested?.scale ?? 1,
                  width: widget.size,
                  height: widget.size,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                  excludeFromSemantics: true,
                ),
        ),
      ),
    );
    final label = widget.semanticLabel;
    if (label != null) {
      child = Semantics(label: label, child: child);
    }
    return child;
  }

  void _schedule(_SymbolKey key) {
    final cached = _cache[key];
    if (cached != null) {
      _bytes = cached;
      _requested = key;
      return;
    }
    if (_requested == key) {
      return;
    }
    _requested = key;
    _bytes = null;
    unawaited(_load(key));
  }

  Future<void> _load(_SymbolKey key) async {
    final future = _inflight[key] ??= _render(key);
    final bytes = await future;
    await _inflight.remove(key);
    if (bytes == null) {
      return;
    }
    _cache[key] = bytes;
    if (!mounted || _requested != key) {
      return;
    }
    setState(() => _bytes = bytes);
  }
}

Future<Uint8List?> _render(_SymbolKey key) async {
  final argb = key.color;
  try {
    return await _channel.invokeMethod<Uint8List>('render', {
      'symbol': key.symbol,
      'pointSize': key.size,
      'scale': key.scale,
      'weight': key.weight,
      'red': ((argb >> 16) & 0xff) / 255,
      'green': ((argb >> 8) & 0xff) / 255,
      'blue': (argb & 0xff) / 255,
      'alpha': ((argb >> 24) & 0xff) / 255,
    });
  } on MissingPluginException {
    return null;
  } on PlatformException {
    return null;
  }
}
