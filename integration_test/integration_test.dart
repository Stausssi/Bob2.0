import 'package:bob/chat/conversation.dart';
import 'package:bob/chat/microphone_circle.dart';
import 'package:bob/handler/notification_handler.dart';
import 'package:bob/handler/storage_handler.dart';
import 'package:bob/main.dart' as app;
import 'package:bob/main.dart';
import 'package:bob/settings/linked_settings_tile.dart';
import 'package:bob/settings/settings.dart';
import 'package:bob/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mapbox_search/mapbox_search.dart';

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

    testWidgets("Change username", (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Default name is "Max Mustermann"
      expect(find.text("Hallo Max Mustermann"), findsOneWidget);

      // Navigate to settings
      await tester.tap(find.text("Einstellungen"));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Benutzereinstellungen"));
      await tester.pumpAndSettle();

      // Change the name
      await tester.enterText(find.byType(TextField), "Integration");
      // await tester.pump();

      // Navigate back home
      await tester.pageBack();
      // await tester.pageBack();
      await tester.pump();
      await tester.tap(find.text("Home"));
      await tester.pumpAndSettle();

      // await binding.delayed(const Duration(seconds: 1));
      // Username should be changed now
      expect(find.text("Hallo Integration"), findsOneWidget);
    });

    testWidgets("Preferences", (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.text("Einstellungen"));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Präferenzen"));
      await tester.pumpAndSettle();

      // Switch any news category
      int currentLength =
          StorageHandler.getValue<List<String>>(SettingKeys.newsCategories)
              .length;

      await tester.tap(find.byType(CupertinoSwitch).first);
      await tester.pumpAndSettle();

      // Length should change by 1
      expect(
        (StorageHandler.getValue<List<String>>(SettingKeys.newsCategories)
                    .length -
                currentLength)
            .abs(),
        1,
      );

      // Open the location picker
      await tester.tap(find.text("Wetter Standort"));
      await tester.pumpAndSettle();

      expect(find.byType(LocationPicker), findsOneWidget);

      await tester.enterText(find.byType(TextField), "Stuttgart");
      await tester.pumpAndSettle(const Duration(seconds: 1));
      // await binding.delayed();

      await tester.pumpAndSettle();
      await tester.tap(find.byType(MaterialButton).first);
      await tester.pumpAndSettle();

      expect(
        StorageHandler.getValue<MapBoxPlace>(SettingKeys.weatherLocation).text,
        "Stuttgart",
      );
    });

    testWidgets("Notification Settings", (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.text("Einstellungen"));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Benachrichtigungen"));
      await tester.pumpAndSettle();

      // There should be for switches (represented by LinkedSettingsTile)
      expect(find.byType(LinkedSettingsTile), findsNWidgets(4));

      // Turn notifications on/off for every use case
      List<String> keys = [
        SettingKeys.welcomeNotification,
        SettingKeys.travelNotification,
        SettingKeys.financeNotification,
        SettingKeys.entertainmentNotification
      ];

      for (int i = 0; i < 4; i++) {
        bool prevValue = StorageHandler.getValue(keys[i]);
        // Tap the switch, not the tile
        await tester.tap(find.byType(CupertinoSwitch).at(i));
        await tester.pumpAndSettle();
        await binding.delayed(const Duration(milliseconds: 200));
        expect(StorageHandler.getValue(keys[i]), !prevValue);
      }

      // And 4 clocks
      expect(find.text("Uhrzeit"), findsNWidgets(4));

      // An date picker dialog should open when pressing an "Uhrzeit" tile
      await tester.tap(find.text("Uhrzeit").first);
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsOneWidget);

      // TODO: Change time and check if it works
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

      // Remove all notifications
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
