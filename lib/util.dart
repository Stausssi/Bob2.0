import 'dart:ui';

class CustomColors {
  static const Color blackBackground = Color.fromRGBO(33, 34, 38, 1);
  static const Color purpleForeground = Color.fromRGBO(93, 95, 239, 1);
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
