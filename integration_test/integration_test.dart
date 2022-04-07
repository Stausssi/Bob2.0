import 'package:bob/Settings/settings.dart';
import 'package:bob/chat/conversation.dart';
import 'package:bob/chat/microphone_circle.dart';
import 'package:bob/handler/notification_handler.dart';
import 'package:bob/handler/storage_handler.dart';
import 'package:bob/main.dart' as app;
import 'package:bob/main.dart';
import 'package:bob/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized()
      as IntegrationTestWidgetsFlutterBinding;

  group("End-to-end App Test", () {
    testWidgets("Bottom Navigation", (WidgetTester tester) async {
      app.main();
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

      // Wait for 2 seconds to allow the user to confirm the permission prompts
      await binding.delayed(const Duration(seconds: 2));
    });

    testWidgets("Conversation list", (WidgetTester tester) async {
      await StorageHandler.init();
      // Add a full conversation
      StorageHandler.addConversation(UseCase.welcome.name);

      app.main();
      await tester.pumpAndSettle();

      // Check whether the notification from before is rendered
      expect(
        find.text("Guten Morgen"),
        findsOneWidget,
      );
      expect(
        find.text("Gerade eben"),
        findsOneWidget,
      );
    });

    testWidgets("Invalid conversation length", (WidgetTester tester) async {
      await StorageHandler.init();
      // Remove one value from the storage -> should result in an error
      StorageHandler.resetKey(SettingKeys.previousConversationDates);

      app.main();
      await tester.pumpAndSettle();

      expect(
        find.text("Die letzten Konversationen konnten nicht geladen werden."),
        findsOneWidget,
      );
    });

    testWidgets("Chat message with text", (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Check whether the conversation screen opens, if you press the help
      await tester.tap(find.text("Klicke hier für Unterstützung"));
      await tester.pumpAndSettle();

      expect(find.byType(Conversation), findsOneWidget);

      await tester.tap(find.text("Ich möchte schreiben"));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), "Guten Morgen");
      await tester.pump();
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      expect(find.text("Guten Morgen"), findsOneWidget);

      // Test voice
      await tester.tap(find.byType(MicrophoneCircle));
      await tester.pump();
      await tester.tap(find.text("Zuhören stoppen"));
      await tester.pump();
    });
  });

  group("Notifications", () {
    test("Scheduling", () async {
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

    test("Toggling", () async {
      // First, remove all
      for (UseCase u in UseCase.values) {
        StorageHandler.updateNotifications(u, false);
      }

      // Then, add all and check whether the notification was scheduled
      int notificationCount = 0;
      for (UseCase u in UseCase.values) {
        StorageHandler.updateNotifications(u, true);

        // The count should increase by one
        notificationCount += 1;
        expect(
          (await NotificationHandler().pendingNotifications).length,
          notificationCount,
        );
      }
    });
  });
}
