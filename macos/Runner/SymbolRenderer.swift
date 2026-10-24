import Cocoa
import FlutterMacOS

/// Канал `copi/symbols`. Рисует SF Symbol в PNG, чтобы Flutter показал системный значок.
func attachSymbolChannel(messenger: FlutterBinaryMessenger) -> FlutterMethodChannel {
  let channel = FlutterMethodChannel(name: "copi/symbols", binaryMessenger: messenger)
  channel.setMethodCallHandler { call, result in
    guard call.method == "render",
          let args = call.arguments as? [String: Any],
          let symbol = args["symbol"] as? String,
          let pointSize = args["pointSize"] as? Double,
          let scale = args["scale"] as? Double
    else {
      result(FlutterMethodNotImplemented)
      return
    }
    let png = renderSymbol(
      name: symbol,
      pointSize: CGFloat(pointSize),
      scale: CGFloat(scale),
      color: NSColor(
        srgbRed: args["red"] as? Double ?? 0,
        green: args["green"] as? Double ?? 0,
        blue: args["blue"] as? Double ?? 0,
        alpha: args["alpha"] as? Double ?? 1
      ),
      weight: symbolWeight(args["weight"] as? String)
    )
    if let png {
      result(FlutterStandardTypedData(bytes: png))
    } else {
      result(
        FlutterError(
          code: "symbol",
          message: "SF Symbol \(symbol) is unavailable",
          details: nil
        )
      )
    }
  }
  return channel
}

private func symbolWeight(_ name: String?) -> NSFont.Weight {
  switch name {
  case "regular":
    return .regular
  case "semibold":
    return .semibold
  case "bold":
    return .bold
  default:
    return .medium
  }
}

private func renderSymbol(
  name: String,
  pointSize: CGFloat,
  scale: CGFloat,
  color: NSColor,
  weight: NSFont.Weight
) -> Data? {
  guard pointSize > 0, scale > 0 else {
    return nil
  }
  let configuration = NSImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
    .applying(NSImage.SymbolConfiguration(paletteColors: [color]))
  guard let symbol = NSImage(systemSymbolName: name, accessibilityDescription: nil)?
    .withSymbolConfiguration(configuration)
  else {
    return nil
  }
  symbol.isTemplate = false

  let pixels = max(1, Int((pointSize * scale).rounded()))
  guard let rep = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: pixels,
    pixelsHigh: pixels,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
  ) else {
    return nil
  }
  rep.size = NSSize(width: pointSize, height: pointSize)

  var draw = symbol.size
  if draw.width > pointSize || draw.height > pointSize {
    let fit = min(pointSize / draw.width, pointSize / draw.height)
    draw = NSSize(width: draw.width * fit, height: draw.height * fit)
  }
  let origin = NSPoint(x: (pointSize - draw.width) / 2, y: (pointSize - draw.height) / 2)

  NSGraphicsContext.saveGraphicsState()
  defer { NSGraphicsContext.restoreGraphicsState() }
  guard let context = NSGraphicsContext(bitmapImageRep: rep) else {
    return nil
  }
  NSGraphicsContext.current = context
  context.imageInterpolation = .high
  symbol.draw(
    in: NSRect(origin: origin, size: draw),
    from: .zero,
    operation: .sourceOver,
    fraction: 1
  )
  return rep.representation(using: .png, properties: [:])
}
