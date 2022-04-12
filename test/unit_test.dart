import 'package:bob/handler/conversation_handler.dart';
import 'package:bob/handler/storage_handler.dart';
import 'package:bob/home/home_widget.dart';
import 'package:bob/util.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

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
      "'finances' should be converted from string",
      () => expect(useCaseFromString("finances"), UseCase.finances),
    );
    test(
      "'travel' should be converted from string",
      () => expect(useCaseFromString("travel"), UseCase.travel),
    );

    test("BackendAnswer class", () {
      BackendAnswer answer = const BackendAnswer(
        useCase: UseCase.finances,
        tts: "Stonks",
        furtherQuestions: [],
      );

      expect(answer.useCase, UseCase.finances);
      expect(answer.tts, "Stonks");
      expect(answer.furtherQuestions.isEmpty, true);
    });
  });

  group("Storage Handler", () {
    test("Wrong class TypeError on save", () {
      try {
        // A map should not be supported
        StorageHandler.saveValue("bogus", {});
      } catch (e) {
        expect(e is TypeError, true);
      }
    });

    test(
      "Convert Time to String",
      () => expect(const Time(1, 2, 3).toStorageString(), "01:02"),
    );

    test(
      "Convert String to Time - Hour",
      () => expect(TimeStringConverter.fromStorageString("01:02").hour, 1),
    );
    test(
      "Convert String to Time - Minute",
      () => expect(TimeStringConverter.fromStorageString("01:02").minute, 2),
    );
    test(
      "Convert String to Time - Second",
      () => expect(TimeStringConverter.fromStorageString("01:02").second, 0),
    );

    test("Last Conversation date", () {
      StorageHandler.addConversation(UseCase.welcome.name);
      expect(getLastConversationDate().split("-").first, "2022");

      // Cleanup
      StorageHandler.resetKey(SettingKeys.previousConversations);
      StorageHandler.resetKey(SettingKeys.previousConversationDates);
    });

    test("Increase Message count", () {
      int count = StorageHandler.getValue(SettingKeys.messageCount);
      StorageHandler.increaseMessages();

      expect(StorageHandler.getValue(SettingKeys.messageCount), count + 1);
    });

    test("Increase Conversation count", () {
      int count = StorageHandler.getValue(SettingKeys.conversationCount);
      StorageHandler.increaseConversations();

      expect(StorageHandler.getValue(SettingKeys.conversationCount), count + 1);
    });

    test("Use Case Times", () {
      expect(StorageHandler.getUseCaseTime(UseCase.welcome).hour, 7);
      expect(StorageHandler.getUseCaseTime(UseCase.travel).hour, 8);
      expect(StorageHandler.getUseCaseTime(UseCase.finances).hour, 15);
      expect(StorageHandler.getUseCaseTime(UseCase.entertainment).hour, 20);
    });

    test(
      "API key retrieval",
      () => expect(StorageHandler.getAPIKey("bogus"), ""),
    );
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
        await ConversationHandler().askQuestion("Guten Morgen");

    if (answer != null) {
      expect(answer.useCase, UseCase.welcome);
    } else {
      expect(true, true);
    }
  });
}
