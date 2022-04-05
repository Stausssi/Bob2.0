import 'package:bob/handler/convers_handler.dart';
import 'package:bob/home/home_widget.dart';
import 'package:bob/util.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  setUp(() async {
    await StorageHandler.init();
  });

  // Test util-class
  group("Utility (util.dart)", () {
    // useCaseFromString()
    test(
      "'welcome' should be converted from string",
      () => expect(useCaseFromString("welcome"), UseCase.welcome),
    );
    test(
      "'entertainment' should be converted from string",
      () => expect(useCaseFromString("entertainment"), UseCase.entertainment),
    );
    test(
      "'finance' should be converted from string",
      () => expect(useCaseFromString("finance"), UseCase.finance),
    );
    test(
      "'travel' should be converted from string",
      () => expect(useCaseFromString("travel"), UseCase.travel),
    );

    test("BackendAnswer class", () {
      BackendAnswer answer = const BackendAnswer(
        useCase: UseCase.finance,
        tts: "Stonks",
        furtherQuestions: [],
      );

      expect(answer.useCase, UseCase.finance);
      expect(answer.tts, "Stonks");
      expect(answer.furtherQuestions.isEmpty, true);
    });
  });

  group("Storage Handler", () {
    test(
      "Convert Time to String",
      () => expect(const Time(1, 2, 3).toStorageString(), "1:2:3"),
    );

    test(
      "Convert String to Time - Hour",
      () => expect(TimeStringConverter.fromStorageString("1:2:3").hour, 1),
    );
    test(
      "Convert String to Time - Minute",
      () => expect(TimeStringConverter.fromStorageString("1:2:3").minute, 2),
    );
    test(
      "Convert String to Time - Second",
      () => expect(TimeStringConverter.fromStorageString("1:2:3").second, 3),
    );

    test("Last Conversation date", () {
      StorageHandler.addConversation(UseCase.welcome.name);
      expect(getLastConversationDate().split("-").first, "2022");

      // Cleanup
      StorageHandler.resetKey(SettingKeys.previousConversations);
      StorageHandler.resetKey(SettingKeys.previousConversationDates);
    });
  });

  test("Duration Beautifier Extension", () {
    // 01.01.2022 is the base
    DateTime baseTime = DateTime(2022);

    expect(
      baseTime.difference(DateTime(2021)).toFancyString(),
      "Vor langer Zeit",
    );
    expect(
      baseTime.difference(DateTime(2022, 1, 2)).toFancyString(),
      "Gestern",
    );
    expect(
      baseTime.difference(DateTime(2022, 1, 3)).toFancyString(),
      "Vor 2 Tagen",
    );
    expect(
      baseTime.difference(DateTime(2022, 1, 1, 1)).toFancyString(),
      "Vor 1 Stunde",
    );
    expect(
      baseTime.difference(DateTime(2022, 1, 1, 2)).toFancyString(),
      "Vor 2 Stunden",
    );
    expect(
      baseTime.difference(DateTime(2022, 1, 1, 0, 1)).toFancyString(),
      "Vor 1 Minute",
    );
    expect(
      baseTime.difference(DateTime(2022, 1, 1, 0, 2)).toFancyString(),
      "Vor 2 Minuten",
    );
    expect(
      baseTime.difference(DateTime(2022, 1, 1, 0, 0, 1)).toFancyString(),
      "Gerade eben",
    );
  });

  test("Conversation Handler", () async {
    BackendAnswer? answer =
        await ConversationHandler().askQuestion("willkommen");

    expect(answer != null, true);
    expect(answer!.useCase, UseCase.welcome);
  });
}
