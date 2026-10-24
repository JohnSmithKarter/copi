import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}

/// Канал `copi/bookmarks`. Живёт всё время процесса и держит открытые папки.
final class BookmarkCoordinator: NSObject {
  static let shared = BookmarkCoordinator()

  private var scopes: [String: ScopedFolder] = [:]
  private weak var window: NSWindow?
  private var channel: FlutterMethodChannel?
  private var volumeChannel: FlutterEventChannel?
  private var volumeEvents: FlutterEventSink?
  private var watchingVolumes = false

  func attach(messenger: FlutterBinaryMessenger, window: NSWindow) {
    self.window = window
    let channel = FlutterMethodChannel(name: "copi/bookmarks", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      BookmarkCoordinator.shared.handle(call, result: result)
    }
    self.channel = channel
    let volumes = FlutterEventChannel(name: "copi/volumes", binaryMessenger: messenger)
    volumes.setStreamHandler(self)
    volumeChannel = volumes
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any]
    switch call.method {
    case "pickFolder":
      pickFolder(directory: args?["directory"] as? String, result: result)
    case "bookmarkForPath":
      bookmarkForPath(path: args?["path"] as? String ?? "", result: result)
    case "startAccess":
      startAccess(bookmark: args?["bookmark"] as? String ?? "", result: result)
    case "stopAccess":
      stopAccess(bookmark: args?["bookmark"] as? String ?? "")
      result(nil)
    case "mountedVolumes":
      mountedVolumes(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func pickFolder(directory: String?, result: @escaping FlutterResult) {
    DispatchQueue.main.async { [self] in
      guard let window = self.window else {
        result(
          FlutterError(
            code: "bookmark",
            message: "Application window is not available",
            details: nil
          )
        )
        return
      }
      let panel = NSOpenPanel()
      panel.canChooseFiles = false
      panel.canChooseDirectories = true
      panel.allowsMultipleSelection = false
      panel.canCreateDirectories = false
      panel.prompt = "Allow"
      if let directory, !directory.isEmpty {
        panel.directoryURL = URL(fileURLWithPath: directory)
      }
      if #available(macOS 14.0, *) {
        NSApp.activate()
      } else {
        NSApp.activate(ignoringOtherApps: true)
      }
      panel.beginSheetModal(for: window) { response in
        guard response == .OK, let url = panel.url else {
          result(nil)
          return
        }
        self.bookmark(url: url, result: result)
      }
    }
  }

  private func bookmark(url: URL, result: @escaping FlutterResult) {
    let started = url.startAccessingSecurityScopedResource()
    defer {
      if started {
        url.stopAccessingSecurityScopedResource()
      }
    }
    guard started else {
      result(
        FlutterError(
          code: "bookmark",
          message: "The system did not grant access to the selected folder",
          details: nil
        )
      )
      return
    }
    do {
      let data = try url.bookmarkData(
        options: [.withSecurityScope],
        includingResourceValuesForKeys: nil,
        relativeTo: nil
      )
      result([
        "path": url.path,
        "bookmark": data.base64EncodedString(),
      ])
    } catch {
      result(
        FlutterError(
          code: "bookmark",
          message: error.localizedDescription,
          details: nil
        )
      )
    }
  }

  private func bookmarkForPath(path: String, result: @escaping FlutterResult) {
    do {
      let url = scopedURL(for: path)
      let data = try url.bookmarkData(
        options: [.withSecurityScope],
        includingResourceValuesForKeys: nil,
        relativeTo: nil
      )
      result(data.base64EncodedString())
    } catch {
      result(
        FlutterError(
          code: "bookmark",
          message: error.localizedDescription,
          details: nil
        )
      )
    }
  }

  /// Дочерний URL, собранный от уже открытой папки, сохраняет её область доступа.
  private func scopedURL(for path: String) -> URL {
    let target = URL(fileURLWithPath: path).standardizedFileURL
    for scope in scopes.values {
      let base = scope.url.standardizedFileURL
      let basePath = base.path
      if target.path == basePath {
        return base
      }
      let prefix = basePath.hasSuffix("/") ? basePath : basePath + "/"
      if target.path.hasPrefix(prefix) {
        let relative = String(target.path.dropFirst(prefix.count))
        let parts = relative.split(separator: "/").map(String.init)
        return parts.reduce(base) { partial, part in
          partial.appendingPathComponent(part, isDirectory: true)
        }
      }
    }
    return target
  }

  private func startAccess(bookmark: String, result: @escaping FlutterResult) {
    if let existing = scopes[bookmark] {
      scopes[bookmark] = ScopedFolder(url: existing.url, count: existing.count + 1)
      result(existing.url.path)
      return
    }
    guard let data = Data(base64Encoded: bookmark) else {
      result(FlutterError(code: "bookmark", message: "invalid bookmark", details: nil))
      return
    }
    do {
      var stale = false
      let url = try URL(
        resolvingBookmarkData: data,
        options: [.withSecurityScope],
        relativeTo: nil,
        bookmarkDataIsStale: &stale
      )
      guard url.startAccessingSecurityScopedResource() else {
        result(FlutterError(code: "bookmark", message: "access denied", details: nil))
        return
      }
      scopes[bookmark] = ScopedFolder(url: url, count: 1)
      result(url.path)
    } catch {
      result(
        FlutterError(
          code: "bookmark",
          message: error.localizedDescription,
          details: nil
        )
      )
    }
  }

  private func stopAccess(bookmark: String) {
    guard var scope = scopes[bookmark] else {
      return
    }
    scope.count -= 1
    if scope.count <= 0 {
      scope.url.stopAccessingSecurityScopedResource()
      scopes.removeValue(forKey: bookmark)
    } else {
      scopes[bookmark] = scope
    }
  }

  private func mountedVolumes(result: @escaping FlutterResult) {
    let keys: Set<URLResourceKey> = [
      .volumeNameKey,
      .volumeIsInternalKey,
      .volumeIsEjectableKey,
      .volumeIsRemovableKey,
    ]
    let urls = FileManager.default.mountedVolumeURLs(
      includingResourceValuesForKeys: Array(keys),
      options: [.skipHiddenVolumes]
    ) ?? []
    var payload: [[String: Any]] = []
    for url in urls {
      let values = try? url.resourceValues(forKeys: keys)
      let path = url.path
      if path.isEmpty || path == "/" {
        continue
      }
      let name = values?.volumeName ?? url.lastPathComponent
      if name.isEmpty {
        continue
      }
      payload.append([
        "name": name,
        "path": path,
        "internal": values?.volumeIsInternal ?? false,
        "ejectable": values?.volumeIsEjectable ?? false,
        "removable": values?.volumeIsRemovable ?? false,
      ])
    }
    result(payload)
  }
}

extension BookmarkCoordinator: FlutterStreamHandler {
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    volumeEvents = events
    guard !watchingVolumes else {
      return nil
    }
    watchingVolumes = true
    let center = NSWorkspace.shared.notificationCenter
    center.addObserver(
      self,
      selector: #selector(volumesChanged(_:)),
      name: NSWorkspace.didMountNotification,
      object: nil
    )
    center.addObserver(
      self,
      selector: #selector(volumesChanged(_:)),
      name: NSWorkspace.didUnmountNotification,
      object: nil
    )
    center.addObserver(
      self,
      selector: #selector(volumesChanged(_:)),
      name: NSWorkspace.didRenameVolumeNotification,
      object: nil
    )
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    volumeEvents = nil
    return nil
  }

  @objc private func volumesChanged(_ notification: Notification) {
    volumeEvents?("changed")
  }
}

private struct ScopedFolder {
  var url: URL
  var count: Int
}
