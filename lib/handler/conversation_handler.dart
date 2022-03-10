/// Handles the communication between app and backend
class ConversationHandler {
  // Private constructor
  ConversationHandler._();

  /// The instance of this handler
  static ConversationHandler? _instance;

  /// Retrieve the instance of this singleton
  static ConversationHandler get instance {
    _instance ??= ConversationHandler._();

    return _instance!;
  }

  /// Allow other components to get the instance by calling the constructor of this
  /// handler
  factory ConversationHandler() => instance;

  /// Ask the backend a question
  void askQuestion(String question) async {}

  /// Send the answer of the user to the backend
  void sendAnswer(String answer) async {}
}
