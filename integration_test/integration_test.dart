import 'package:bob/chat/conversation.dart';
import 'package:bob/main.dart' as app;
import 'package:bob/main.dart';
import 'package:bob/settings.dart';
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
}
