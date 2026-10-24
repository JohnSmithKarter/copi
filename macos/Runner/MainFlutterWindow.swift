import Cocoa
import FlutterMacOS

/// Высота шапки во Flutter. Кнопки окна стоят по её вертикальному центру.
private let windowBarHeight: CGFloat = 52

class MainFlutterWindow: NSWindow {
  private var windowChannel: FlutterMethodChannel?
  private var symbolChannel: FlutterMethodChannel?
  private let hitRouter = WindowHitRouter(frame: .zero)
  private let vibrancy = BackgroundBlurView()
  private var placementScheduled = false

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    flutterViewController.backgroundColor = .clear
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    isOpaque = false
    backgroundColor = .clear
    ignoresMouseEvents = false
    styleMask.insert(.fullSizeContentView)
    titlebarAppearsTransparent = true
    titleVisibility = .hidden
    titlebarSeparatorStyle = .none
    allowTransparency(through: flutterViewController.view)
    installVibrancy(behind: flutterViewController.view)

    // Ниже этого шапка и две колонки редактора уже тесно.
    let minimumContentSize = NSSize(width: 1024, height: 705)
    contentMinSize = minimumContentSize
    let content = contentRect(forFrameRect: frame)
    if content.width < minimumContentSize.width || content.height < minimumContentSize.height {
      var fitted = content
      fitted.size.width = max(content.width, minimumContentSize.width)
      fitted.size.height = max(content.height, minimumContentSize.height)
      setFrame(frameRect(forContentRect: fitted), display: true)
    }

    RegisterGeneratedPlugins(registry: flutterViewController)
    BookmarkCoordinator.shared.attach(
      messenger: flutterViewController.engine.binaryMessenger,
      window: self
    )
    let messenger = flutterViewController.engine.binaryMessenger
    attachWindowChannel(messenger: messenger)
    symbolChannel = attachSymbolChannel(messenger: messenger)

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(layoutChrome),
      name: NSWindow.didResizeNotification,
      object: self
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(layoutChrome),
      name: NSWindow.didExitFullScreenNotification,
      object: self
    )

    super.awakeFromNib()
    installHitRouter()
    scheduleButtonPlacement()
  }

  private func attachWindowChannel(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "copi/window", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "startDrag":
        if let event = NSApp.currentEvent {
          self?.performDrag(with: event)
        }
        result(nil)
      case "setAppearance":
        self?.applyAppearance(dark: (call.arguments as? String) != "light")
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    windowChannel = channel
  }

  private func installHitRouter() {
    guard let frameView = contentView?.superview else {
      return
    }
    if hitRouter.superview === frameView {
      return
    }
    hitRouter.frame = frameView.bounds
    hitRouter.autoresizingMask = [.width, .height]
    frameView.addSubview(hitRouter, positioned: .above, relativeTo: nil)
  }

  private func installVibrancy(behind content: NSView) {
    guard let frameView = content.superview, vibrancy.superview == nil else {
      return
    }
    vibrancy.frame = content.frame
    vibrancy.autoresizingMask = [.width, .height]
    vibrancy.blendingMode = .behindWindow
    vibrancy.state = .followsWindowActiveState
    vibrancy.material = .hudWindow
    vibrancy.isEmphasized = true
    let appearance = NSAppearance(named: .darkAqua)
    self.appearance = appearance
    vibrancy.appearance = appearance
    frameView.addSubview(vibrancy, positioned: .below, relativeTo: content)
  }

  private func applyAppearance(dark _: Bool) {
    let appearance = NSAppearance(named: .darkAqua)
    self.appearance = appearance
    vibrancy.appearance = appearance
    vibrancy.material = .hudWindow
    vibrancy.isEmphasized = true
  }

  @objc private func layoutChrome() {
    if let content = contentView {
      vibrancy.frame = content.frame
    }
    scheduleButtonPlacement()
  }

  fileprivate func scheduleButtonPlacement() {
    placeWindowButtons()
    guard !placementScheduled else {
      return
    }
    placementScheduled = true
    DispatchQueue.main.async { [weak self] in
      self?.placementScheduled = false
      self?.placeWindowButtons()
    }
  }

  private func placeWindowButtons() {
    guard !styleMask.contains(.fullScreen), let content = contentView else {
      return
    }
    let buttons = [
      NSWindow.ButtonType.closeButton,
      .miniaturizeButton,
      .zoomButton,
    ].compactMap { standardWindowButton($0) }
    guard let host = buttons.first?.superview else {
      return
    }
    host.wantsLayer = true
    host.layer?.masksToBounds = false

    let close = buttons[0]
    let buttonHeight = close.bounds.height
    let hostTop = host.convert(NSPoint(x: 0, y: host.bounds.maxY), to: nil).y
    let windowTop = content.convert(NSPoint(x: 0, y: content.bounds.maxY), to: nil).y
    let y = host.bounds.height - (windowBarHeight / 2) - (buttonHeight / 2) + (windowTop - hostTop)

    // Кнопки стоят по центру шапки, поэтому сверху уже есть зазор.
    // Слева делаем ровно такой же, не меняя расстояние между кнопками.
    let inset = (windowBarHeight - buttonHeight) / 2
    let hostLeft = host.convert(NSPoint(x: 0, y: 0), to: nil).x
    let windowLeft = content.convert(NSPoint(x: content.bounds.minX, y: 0), to: nil).x
    let dx = inset + windowLeft - hostLeft - close.frame.origin.x
    for button in buttons {
      let origin = NSPoint(x: button.frame.origin.x + dx, y: y)
      if abs(origin.x - button.frame.origin.x) > 0.5 || abs(origin.y - button.frame.origin.y) > 0.5 {
        button.setFrameOrigin(origin)
      }
    }
  }
}

/// Щелчки в шапке доходят до Flutter. Кнопки окна и края для изменения размера остаются своими.
private final class WindowHitRouter: NSView {
  override func hitTest(_ point: NSPoint) -> NSView? {
    guard let window, let host = superview else {
      return nil
    }
    let edge: CGFloat = 6
    let bounds = host.bounds
    if point.x < edge || point.y < edge || point.x > bounds.width - edge || point.y > bounds.height - edge {
      return nil
    }
    let types: [NSWindow.ButtonType] = [.closeButton, .miniaturizeButton, .zoomButton]
    for type in types {
      guard let button = window.standardWindowButton(type) else {
        continue
      }
      let frame = button.convert(button.bounds, to: host).insetBy(dx: -4, dy: -6)
      if frame.contains(point) {
        return button
      }
    }
    guard let content = window.contentView else {
      return nil
    }
    if let hit = content.hitTest(point) {
      return hit
    }
    // Прозрачный FlutterView сам отказывается от щелчка. Отдаём его ему.
    return content.frame.contains(point) ? content : nil
  }

  override func layout() {
    super.layout()
    (window as? MainFlutterWindow)?.scheduleButtonPlacement()
  }
}

/// Размытие рабочего стола. Само по себе щелчки не забирает.
private final class BackgroundBlurView: NSVisualEffectView {
  override func hitTest(_ point: NSPoint) -> NSView? { nil }
}

/// FlutterView всегда отвечает, что он непрозрачный. Иначе размытие за окном не видно.
private var didAllowTransparency = false

private func allowTransparency(through view: NSView) {
  view.wantsLayer = true
  view.layer?.isOpaque = false
  view.layer?.backgroundColor = NSColor.clear.cgColor
  guard !didAllowTransparency else {
    return
  }
  didAllowTransparency = true
  guard let viewClass = object_getClass(view) else {
    return
  }
  let selector = #selector(getter: NSView.isOpaque)
  guard let method = class_getInstanceMethod(viewClass, selector) else {
    return
  }
  let block: @convention(block) (AnyObject) -> Bool = { _ in false }
  let implementation = imp_implementationWithBlock(block)
  class_replaceMethod(viewClass, selector, implementation, method_getTypeEncoding(method))
}
