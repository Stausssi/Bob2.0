import 'package:bob/chat/microphone_circle.dart';
import 'package:bob/handler/storage_handler.dart';
import 'package:bob/home/home_widget.dart';
import 'package:bob/main.dart';
import 'package:bob/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  setUp(() => GoogleFonts.config.allowRuntimeFetching = false);

  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized()
          as TestWidgetsFlutterBinding;

  await StorageHandler.init();
  // await NotificationHandler().init();

  testWidgets("Microphone circle icon test", (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MicrophoneCircle(clickCallback: () {}),
    ));

    expect(
      find.byIcon(Icons.mic),
      findsOneWidget,
    );
  });

  testWidgets('Navigation bar test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BobApp());
    await binding.setSurfaceSize(const Size(1080, 2340));

    // Verify that our navigation bar is displaying correctly
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Konversation'), findsOneWidget);
    expect(find.text('Einstellungen'), findsOneWidget);

    expect(find.byType(MainPage), findsOneWidget);

    await tester.tap(find.text("Home"));
    await tester.pumpAndSettle();
    expect(find.byType(MainPage), findsOneWidget);

    await tester.tap(find.text("Einstellungen"));
    await tester.pumpAndSettle();
    expect(find.byType(Settings), findsOneWidget);
  });

  testWidgets('HomePage test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BobApp());

    // A text saying "Hey {name}"
    expect(
      find.text("Hallo ${StorageHandler.getValue(SettingKeys.userName)}"),
      findsOneWidget,
    );

    // There should be 3 ColoredBubbles
    expect(find.byType(ColoredBubble), findsNWidgets(3));

    // A text saying "Konversationen"
    expect(
      find.text("Konversationen"),
      findsOneWidget,
    );

    // A text saying "Nachrichten"
    expect(
      find.text("Nachrichten"),
      findsOneWidget,
    );
  });

  testWidgets("Main counter test", (WidgetTester tester) async {
    StorageHandler.resetKey(SettingKeys.conversationCount);
    StorageHandler.resetKey(SettingKeys.messageCount);

    // Build our app and trigger a frame.
    await tester.pumpWidget(const BobApp());

    // 0 Conversations and 0 Messages
    expect(
      find.text("0"),
      findsNWidgets(2),
    );
  });

  testWidgets("Settings Test", (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BobApp());
    await binding.setSurfaceSize(const Size(1080, 2340));

    await tester.tap(find.text("Einstellungen"));
    await tester.pumpAndSettle();

    expect(find.text("Einstellungen"), findsWidgets);
    expect(find.text("Hier kannst du mich personalisieren!"), findsOneWidget);
    expect(
      find.image(
        Image.asset(
          "assets/bob.png",
          scale: 3,
        ).image,
      ),
      findsOneWidget,
    );
    expect(find.text("Allgemeine Einstellungen"), findsOneWidget);
    expect(find.text("Benutzereinstellungen"), findsOneWidget);
    expect(find.text("Präferenzen"), findsOneWidget);
    expect(find.text("Benachrichtigungen"), findsOneWidget);
  });
}
