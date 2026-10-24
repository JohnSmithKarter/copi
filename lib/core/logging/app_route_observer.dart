import 'package:copi/core/logging/app_log.dart';
import 'package:flutter/widgets.dart';

/// Пишет в журнал открытие и закрытие экранов.
class AppRouteObserver extends NavigatorObserver {
  AppRouteObserver(this._log);

  final AppLog _log;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _log.info('Close ${_label(route)}');

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _log.info('Open ${_label(route)}');

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      _log.info('Open ${_label(newRoute)}');
    }
  }

  String _label(Route<dynamic> route) {
    final name = route.settings.name;
    if (name == Navigator.defaultRouteName) {
      return 'home';
    }
    return name ?? route.runtimeType.toString();
  }
}
