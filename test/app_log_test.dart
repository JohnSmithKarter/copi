import 'package:copi/core/logging/app_failure.dart';
import 'package:copi/core/logging/app_log.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talker/talker.dart';

void main() {
  test('errors are stored in the session log and rethrown', () {
    final talker = Talker(settings: TalkerSettings(useConsoleLogs: false));
    final log = AppLog(talker);

    log.info('Application started');
    expect(
      () => log.abort(AppFailureCode.bookmark, message: 'panel failed'),
      throwsA(
        isA<AppFailure>().having(
          (error) => error.code,
          'code',
          AppFailureCode.bookmark,
        ),
      ),
    );

    final messages = talker.history.map((entry) => entry.message).toList();
    expect(messages, contains('Application started'));
    expect(messages, contains('panel failed'));
  });
}
