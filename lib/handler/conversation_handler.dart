class ConversationHandler {
  static ConversationHandler? _instance;
  ConversationHandler._();

  static ConversationHandler get instance {
    _instance ??= ConversationHandler._();

    return _instance!;
  }

  factory ConversationHandler() => instance;

  void askQuestion(String question) async {}

  void sendAnswer(String answer) async {}
}
