import 'dart:math';

import 'package:dio/dio.dart';

import '../util.dart';

/// Handles the communication between app and backend
class ConversationHandler {
  // Private constructor
  ConversationHandler._() {
    _initConnection();
  }

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

  /// The [UseCase] returned in the answer of the backend
  UseCase? currentUseCase;

  /// Connect to the backend
  void _initConnection() {
    _connection = Dio();
    _connection.options.baseUrl = "193.196.54.254";
    _connection.options.connectTimeout = 5000;
    _connection.options.receiveTimeout = 2000;
    _connection.options.responseType = ResponseType.json;
  }

  /// Ask the backend a question.
  ///
  /// The response is expected to have the following format:
  ///
  /// ```
  /// {
  ///   useCase: useCase,
  ///   tts: "text_to_read",
  ///   further_questions: ["question 1", ..., "question n"]
  /// }
  /// ```
  Future<BackendAnswer?> askQuestion(String question) async {
    // Response<Map<String, dynamic>> response = await _connection.get(
    //   "/question",
    //   queryParameters: {
    //     "useCase": currentUseCase,
    //     "question": question,
    //   },
    // );

    // For now, use static data
    // TODO: Use real backend response
    Response<Map<String, dynamic>> response = Response(
      data: {
        "useCase": UseCase.values[Random().nextInt(4)].name,
        "tts": "Das ist eine Demo-Antwort mit drei weiteren Fragen",
        "further_questions": [
          "Frage 1",
          "Frage 2",
          "Frage 3",
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

  /// Send the [answer] of the user to the backend.
  ///
  /// [answer] is either the message parsed by STT or a text message input
  /// TODO: Remove this and integrate this functionality into [askQuestion]
  Future<BackendAnswer?> sendAnswer(String answer) async {
    Response<Map<String, dynamic>> response = await _connection.post(
      "/answer",
      data: {
        "useCase": currentUseCase,
        "answer": answer,
      },
    );

    if (response.data != null) {
      return _parseBackendAnswer(response.data!);
    }

    return null;
  }

  /// Parse the given response data and create a [BackendAnswer] object to make
  /// the response easier to handle
  BackendAnswer? _parseBackendAnswer(Map<String, dynamic> responseData) {
    currentUseCase = useCaseFromString(responseData["useCase"]);

    return BackendAnswer(
        useCase: currentUseCase!,
        tts: responseData["tts"],
        furtherQuestions: responseData["further_questions"]);
  }
}
