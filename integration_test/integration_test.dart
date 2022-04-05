import 'package:bob/chat/conversation.dart';
import 'package:bob/handler/notification_handler.dart';
import 'package:bob/main.dart' as app;
import 'package:bob/main.dart';
import 'package:bob/settings.dart';
import 'package:bob/util.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  app.main();

  testWidgets("Navigation tests", (WidgetTester tester) async {
    await tester.pumpAndSettle();

    // Go to settings
    await tester.tap(find.text("Einstellungen"));
    await tester.pumpAndSettle();
    expect(find.byType(Settings), findsOneWidget);

    // Go back home
    await tester.tap(find.text("Home"));
    await tester.pumpAndSettle();
    expect(find.byType(MainPage), findsOneWidget);

    // Open Conversations
    await tester.tap(find.text("Konversation"));
    await tester.pumpAndSettle();

    expect(find.byType(Conversation), findsOneWidget);
  });

  test("Notification Handler", () async {
    NotificationHandler handler = NotificationHandler();

    // No launch use case
    expect(await handler.launchUseCase, null);

    // No pending notifications
    var pending = await handler.pendingNotifications;
    int pendingLength = pending.length;

    // Schedule notification
    handler.testNotifications();
    pending = await handler.pendingNotifications;
    expect(pending.length, pendingLength + 1);

    // Remove again
    handler.removeNotification();
    pending = await handler.pendingNotifications;
    expect(pending.length, 0);

    // And schedule another one
    handler.scheduleNotification(UseCase.welcome);
    pending = await handler.pendingNotifications;
    expect(pending.length, 1);

    // Remove again
    handler.removeNotification(UseCase.welcome);
    pending = await handler.pendingNotifications;
    expect(pending.length, 0);
  });

  // app.main();
  //
  // testWidgets("HomePage button checks", (WidgetTester tester) async {
  //   await tester.pumpAndSettle();
  //
  //   // Check whether the conversation screen opens, if you press the help
  //   await tester.tap(find.text("Klicke hier für Unterstützung"));
  //   await tester.pumpAndSettle();
  //
  //   expect(find.byType(Conversation), findsOneWidget);
  // });
}
