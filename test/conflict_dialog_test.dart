import 'package:copi/core/i18n/strings.g.dart';
import 'package:copi/features/sync/domain/conflict_decision.dart';
import 'package:copi/features/sync/presentation/conflict_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('keep both can apply to every later file', (tester) async {
    LocaleSettings.setLocaleSync(AppLocale.en);
    Future<ConflictDecision?>? pending;
    await tester.pumpWidget(
      TranslationProvider(
        child: CupertinoApp(
          home: Builder(
            builder: (context) => CupertinoButton(
              onPressed: () {
                pending = showConflictDialog(
                  context,
                  relativePath: 'album/photo.jpg',
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Same name'), findsOneWidget);
    expect(find.textContaining('album/photo.jpg'), findsOneWidget);

    await tester.tap(find.text('Apply to all'));
    await tester.pump();
    await tester.tap(find.text('Keep both'));
    await tester.pumpAndSettle();

    final decision = await pending;
    expect(decision?.action, ConflictAction.keepBoth);
    expect(decision?.applyToAll, isTrue);
  });
}
