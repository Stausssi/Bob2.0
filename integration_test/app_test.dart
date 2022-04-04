import 'package:bob/chat/conversation.dart';
import 'package:bob/main.dart' as app;
import 'package:bob/main.dart';
import 'package:bob/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() async {
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

  testWidgets("Conversation test", (WidgetTester tester) async {
    await tester.pumpAndSettle();

    // We now should be in the conversation screen
    // expect(
    //   find.text("Bob ist bereit deine Fragen zu beantworten!"),
    //   findsOneWidget,
    // );

    await tester.tap(find.text("Ich möchte schreiben"));
    await tester.pumpAndSettle();

    // Write a message
    await tester.enterText(
      find.byType(TextField),
      "Diese Nachricht wurde vom Test formuliert",
    );
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    expect(
      find.text("Diese Nachricht wurde vom Test formuliert"),
      findsOneWidget,
    );
  });
}
