import 'package:copi/core/logging/app_log.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker/talker.dart';

/// Общий журнал сессии. В [main] подменяется тем же экземпляром, что у наблюдателя.
final talkerProvider = Provider<Talker>((ref) => Talker());

/// Журнал и обработка ошибок ключевых сценариев.
final appLogProvider = Provider<AppLog>(
  (ref) => AppLog(ref.watch(talkerProvider)),
);
