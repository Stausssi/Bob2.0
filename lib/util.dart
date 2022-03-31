import 'dart:ui';

import 'handler/storage_handler.dart';

/// Design colors used all across the application
class CustomColors {
  static const Color blackBackground = Color.fromRGBO(33, 34, 38, 1);
  static const Color purpleForeground = Color.fromRGBO(93, 95, 239, 1);
  static const Color avatarBackground = Color.fromRGBO(255, 214, 220, 1);
}

/// Contains a value for each of the supported use cases
enum UseCase {
  /// Greets the user every morning with an overview about the day
  welcome,

  /// Recommends movies etc. to the user in the evening
  entertainment,

  /// Displays an overview about the financial status and depots of the user
  finance,

  /// Tells the user the best way to get to the next meeting
  travel
}

/// Returns the [UseCase] with the name [value].
///
/// "finance" => [UseCase.finance], etc.
UseCase useCaseFromString(String value) {
  return UseCase.values.firstWhere(
    (element) => element.name == value,
  );
}

/// Static data placeholder to simplify handling the response of the backend
class BackendAnswer {
  const BackendAnswer({
    required this.useCase,
    required this.tts,
    required this.furtherQuestions,
  });

  /// The identified [UseCase]
  final UseCase useCase;

  /// The text to read and display in the conversation widget
  final String tts;

  /// A list of follow up questions the user can ask by either talking or clicking
  /// a supplied button in the chat widget
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
