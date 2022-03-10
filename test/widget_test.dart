import 'package:bob/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Navigation bar test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BobApp());

    // Verify that our navigation bar is displaying correctly
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Conversation'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
