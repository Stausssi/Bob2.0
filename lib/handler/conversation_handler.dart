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
    // TODO: Use real backend
    _connection.options.baseUrl = "http://193.196.52.233:80";
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
    try {
      Response<Map<String, dynamic>> response = await _connection.post(
        "/input",
        data: {
          "speech": question,
          "preferences": {},
        },
      );

      if (response.data != null) {
        return _parseBackendAnswer(response.data!);
      }
    } catch (e) {
      return null;
    }

    return null;
  }

  /// Parse the given response data and create a [BackendAnswer] object to make
  /// the response easier to handle
  BackendAnswer? _parseBackendAnswer(Map<String, dynamic> responseData) {
    try {
      // TODO: Undo temporary fix
      currentUseCase = useCaseFromString(responseData["use_case"][0]);

      return BackendAnswer(
        useCase: currentUseCase!,
        tts: responseData["tts"],
        furtherQuestions: (responseData["further_questions"] as List<dynamic>)
            .map((e) => e.toString())
            .toList(),
      );
    } catch (e) {
      return null;
    }
  }
}
