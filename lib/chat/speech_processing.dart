import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// States the [SpeechProcessing] class can be in.
enum _SpeechProcessingState { listening, speaking, idle }

/// Handles TTS and STT (Speech to text) functionality
class SpeechProcessing {
  /// Handles TTS and STT (Speech to text) functionality
  ///
  /// [onReady] will be called after both TTS and STT have been initialized
  SpeechProcessing({void Function()? onReady}) {
    _init(onReady);
  }

  _SpeechProcessingState _state = _SpeechProcessingState.idle;

  /// The TTS instance (package: flutter_tts)
  late final FlutterTts _flutterTTS;
  bool _ttsReady = false;

  /// The STT instance (package: speech_to_text)
  late final SpeechToText _speechToText;
  bool _sttReady = false;
  Function()? _onTimeout;

  /// Whether both TTS and STT are ready
  bool get isReady => _ttsReady && _sttReady;

  /// Whether STT is currently listening
  bool get isListening => _state == _SpeechProcessingState.listening;

  /// Whether TTS is talking
  bool get isSpeaking => _state == _SpeechProcessingState.speaking;

  /// Init both TTS and STT and call [onReady] afterwards
  void _init(Function()? onReady) async {
    await _initTTS();
    await _initSTT();

    if (onReady != null) {
      onReady();
    }
  }

  /// Init the TTS system
  Future _initTTS() async {
    _flutterTTS = FlutterTts();

    await _flutterTTS.setLanguage("de-DE");

    await _flutterTTS.setSpeechRate(0.6);
    await _flutterTTS.setVolume(1.0);
    await _flutterTTS.setPitch(1.0);

    // TODO: Are platform handlers necessary? <https://pub.dev/packages/flutter_tts/example>
    _ttsReady = true;
  }

  /// Init the STT system
  Future _initSTT() async {
    _speechToText = SpeechToText();

    await _speechToText.initialize(
      onError: (e) {
        if (e.errorMsg != "error_speech_timeout") {
          print("Holy we're fucked: $e");
        } else {
          if (_onTimeout != null) {
            _onTimeout!();
          } else {
            print("No timeout handler provided");
          }
        }
      },
    );

    _sttReady = true;
  }

  /// Read the given out loud with TTS
  void read(String text) async {
    assert(isReady);

    _state = _SpeechProcessingState.speaking;

    if ((await _flutterTTS.speak(text)) != 1) {
      print("something went wrong while trying to speak!");
    }

    _state = _SpeechProcessingState.idle;
  }

  /// Start listening to the microphone of the user.
  ///
  /// Calls [onResult] with the understood text.
  void listen(Function(String) onResult, {Function()? onTimeout}) {
    assert(isReady);

    _state = _SpeechProcessingState.listening;

    _speechToText.listen(
      onResult: (result) {
        print("result is in: $result");

        if (result.finalResult) {
          onResult(result.recognizedWords);

          _state = _SpeechProcessingState.idle;
        }
      },
      partialResults: false,
      localeId: "de_DE",
    );

    if (onTimeout != null) {
      _onTimeout = onTimeout;
    }
  }

  /// Stop listening to the microphone of the user
  void stopListening() async {
    _state = _SpeechProcessingState.idle;

    await _speechToText.stop();
  }
}
