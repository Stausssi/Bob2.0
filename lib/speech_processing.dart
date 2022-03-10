import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

enum _SpeechProcessingState { listening, speaking, idle }

class SpeechProcessing {
  static SpeechProcessing? _instance;
  SpeechProcessing._({Function()? onReady}) {
    _init(onReady);
  }

  factory SpeechProcessing({Function()? onReady}) {
    _instance ??= SpeechProcessing._(onReady: onReady);

    return _instance!;
  }

  _SpeechProcessingState _state = _SpeechProcessingState.idle;

  late final FlutterTts _flutterTTS;
  bool _ttsReady = false;

  late final SpeechToText _speechToText;
  bool _sttReady = false;

  bool get isReady => _ttsReady && _sttReady;
  bool get isListening => _state == _SpeechProcessingState.listening;
  bool get isSpeaking => _state == _SpeechProcessingState.speaking;

  void _init(Function()? onReady) async {
    await _initTTS();
    await _initSTT();

    if (onReady != null) {
      onReady();
    }
  }

  Future _initTTS() async {
    _flutterTTS = FlutterTts();

    await _flutterTTS.setLanguage("de-DE");

    await _flutterTTS.setSpeechRate(0.6);
    await _flutterTTS.setVolume(1.0);
    await _flutterTTS.setPitch(1.0);

    // TODO: Are platform handlers necessary? <https://pub.dev/packages/flutter_tts/example>
    _ttsReady = true;
  }

  Future _initSTT() async {
    _speechToText = SpeechToText();

    bool failed = false;
    await _speechToText.initialize(
      onError: (e) {
        if (e.errorMsg != "error_speech_timeout") {
          failed = true;
          print("Holy we're fucked: $e");
        }
      },
    );

    _sttReady = !failed;
  }

  void read(String text) async {
    _state = _SpeechProcessingState.speaking;

    if ((await _flutterTTS.speak(text)) != 1) {
      print("something went wrong while trying to speak!");
    }

    _state = _SpeechProcessingState.idle;
  }

  void listen(Function(String) onResult) {
    _state = _SpeechProcessingState.listening;

    _speechToText.listen(
      onResult: (result) {
        print("result is in: $result");

        if (result.finalResult) {
          onResult(result.recognizedWords);

          _state = _SpeechProcessingState.idle;
        }
      },
      localeId: "de_DE",
    );
  }

  void stopListening() async {
    _state = _SpeechProcessingState.idle;

    await _speechToText.stop();
  }
}
