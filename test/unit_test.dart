import 'package:bob/handler/storage_handler.dart';
import 'package:bob/util.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  // Test util-class
  group("Utility functions (util.dart)", () {
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
  });
}
