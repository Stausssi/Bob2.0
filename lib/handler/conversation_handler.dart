import 'dart:math';

import 'package:dio/dio.dart';

import '../util.dart';

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

  /// Base Object for http request
  late final Dio _connection;

  UseCase? _currentUseCase;

  void _initConnection() {
    _connection = Dio();
    _connection.options.baseUrl = "193.196.54.254";
    _connection.options.connectTimeout = 5000;
    _connection.options.receiveTimeout = 2000;
    _connection.options.responseType = ResponseType.json;
  }

  /// Ask the backend a question
  Future<BackendAnswer?> askQuestion(String question) async {
    /// Response is expected to have the following format:
    /// {
    ///   useCase: useCase,
    ///   tts: "text_to_read",
    ///   further_questions: ["question 1", ..., "question n"]
    /// }
    // Response<Map<String, dynamic>> response = await _connection.get(
    //   "/question",
    //   queryParameters: {
    //     "question": question,
    //   },
    // );

    // For now, use static data
    Response<Map<String, dynamic>> response = Response(
      data: {
        "useCase": "finance",
        "tts": "This is a dummy answer with 3 further questions",
        "further_questions": [
          "Question 1",
          "Question 2",
          "Question 3",
        ]
      },
      requestOptions: RequestOptions(path: 'abc'),
    );

    // TODO: remove randomness
    if (response.data != null && Random().nextBool()) {
      return _parseBackendAnswer(response.data!);
    }

    return null;
  }

  /// Send the answer of the user to the backend
  Future<BackendAnswer?> sendAnswer(String answer) async {
    Response<Map<String, dynamic>> response = await _connection.post(
      "/answer",
      data: {
        "useCase": _currentUseCase,
        "answer": answer,
      },
    );

    if (response.data != null) {
      return _parseBackendAnswer(response.data!);
    }

    return null;
  }

  BackendAnswer? _parseBackendAnswer(Map<String, dynamic> responseData) {
    _currentUseCase = useCaseFromString(responseData["useCase"]);

    return BackendAnswer(
        useCase: _currentUseCase!,
        tts: responseData["tts"],
        furtherQuestions: responseData["further_questions"]);
  }
}
