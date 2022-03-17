import 'dart:ui';

import 'handler/storage_handler.dart';

class CustomColors {
  static const Color blackBackground = Color.fromRGBO(33, 34, 38, 1);
  static const Color purpleForeground = Color.fromRGBO(93, 95, 239, 1);
  static const Color avatarBackground = Color.fromRGBO(255, 214, 220, 1);
}

enum UseCase { welcome, entertainment, finance, travel }

UseCase useCaseFromString(String value) {
  return UseCase.values.firstWhere(
    (element) => element.name == value,
  );
}

class BackendAnswer {
  const BackendAnswer({
    required this.useCase,
    required this.tts,
    required this.furtherQuestions,
  });

  final UseCase useCase;

  final String tts;

  final List<String> furtherQuestions;
}

/// Returns the date of the last conversation as an ISO8601 String
String getLastConversationDate() {
  String date = DateTime.now().toIso8601String();
  List<String> previousDates =
      StorageHandler.getValue(SettingKeys.previousConversationDates);

  if (previousDates.isNotEmpty) {
    date = previousDates.first;
  }

  return date;
}

extension StringCapitalize on String {
  /// Converts the first letter of the string to upper case
  String capitalize() {
    return "${substring(0, 1).toUpperCase()}${substring(1)}";
  }
}
