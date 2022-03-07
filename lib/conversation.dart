import 'package:bob/constants.dart';
import 'package:bob/microphone_circle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as chat_types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:uuid/uuid.dart';

class Conversation extends StatefulWidget {
  const Conversation({Key? key}) : super(key: key);

  @override
  _ConversationState createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  final thisUser = const chat_types.User(id: "not_bob");
  final bob = const chat_types.User(id: "bob");

  final List<chat_types.Message> _messages = [];
  final Uuid uuidGen = const Uuid();

  final _speechToText = SpeechToText();

  String loadingText = "Please wait while we're enabling your microphone...";

  @override
  void initState() {
    super.initState();

    _messages.add(chat_types.TextMessage(
      author: bob,
      id: uuidGen.v1(),
      text: "Bob sent this message!",
    ));

    _messages.add(chat_types.TextMessage(
      author: thisUser,
      id: uuidGen.v1(),
      text: "I sent this message!",
    ));

    _speechToText.initialize(
      onError: (e) {
        if (e.errorMsg == "error_speech_timeout") {
          setState(() {
            loadingText = "";
          });
        } else {
          print("Holy we're fucked: $e");
        }
      },
    ).then(
      (_) => setState(() {
        loadingText = "";
      }),
    );
  }

  void _startListening() async {
    setState(() {
      loadingText = "We're listening...";
    });

    await _speechToText.listen(
      onResult: (result) => sendMessage(result.recognizedWords),
      partialResults: false,
      localeId: "de_DE",
    );
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      loadingText = "";
    });
  }

  void sendMessage(String text) {
    if (text.isNotEmpty) {
      setState(() {
        _messages.insert(
            0,
            chat_types.TextMessage(
              author: thisUser,
              id: uuidGen.v1(),
              text: text,
            ));
      });

      setState(() {
        loadingText = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Conversation"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shadowColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          Chat(
            customBottomWidget: InputWidget(
              micCallback: _startListening,
              onSendMessage: sendMessage,
            ),
            messages: _messages,
            user: thisUser,
            onSendPressed: (_) => null,
          ),
          if (loadingText.isNotEmpty)
            Container(
              // padding: const EdgeInsets.all(120),
              decoration: const BoxDecoration(
                color: Colors.white38,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 125),
                    child: LoadingIndicator(
                      indicatorType: Indicator.lineScaleParty,
                      colors: [
                        Colors.red,
                        Colors.orange,
                        Colors.yellow,
                        Colors.green,
                        Colors.blue,
                        Colors.indigo,
                        Colors.purple,
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      loadingText,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (_speechToText.isListening)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 125),
                      child: ElevatedButton(
                        onPressed: _stopListening,
                        child: const Text(
                          "Stop listening",
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class InputWidget extends StatefulWidget {
  const InputWidget(
      {Key? key, required this.micCallback, required this.onSendMessage})
      : super(key: key);

  final Function(String) onSendMessage;
  final Function() micCallback;

  @override
  State<StatefulWidget> createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> {
  bool showExtendedInput = false;
  bool showSendButton = false;
  String message = "";
  final TextEditingController _controller = TextEditingController();
  void onTextChanged(String text) {
    setState(() {
      message = text;
    });
  }

  void sendMessage(String messageText) {
    widget.onSendMessage(messageText);
    _controller.clear();
    setState(() {
      message = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showExtendedInput) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: CustomColors.blackBackground,
        ),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(4),
                  hintText: "Enter your message",
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: IconButton(
                    onPressed: () => sendMessage(message),
                    icon: const Icon(
                      Icons.send,
                      color: CustomColors.blackBackground,
                    ),
                  ),
                ),
                autofocus: true,
                textAlignVertical: TextAlignVertical.center,
                onChanged: onTextChanged,
                onSubmitted: sendMessage,
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            MicrophoneCircle(
              clickCallback: () {
                setState(() => showExtendedInput = false);
                widget.micCallback();
              },
              size: 30,
            ),
          ],
        ),
      );
    } else {
      return Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: 33,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                height: 50,
                child: Container(
                  decoration: const BoxDecoration(
                    color: CustomColors.blackBackground,
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => setState(() {
                        showExtendedInput = true;
                      }),
                      child: const Text("Write instead"),
                      style: TextButton.styleFrom(
                        primary: Colors.white54,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Align(
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: MicrophoneCircle(
                clickCallback: widget.micCallback,
              ),
            ),
          ),
        ],
      );
    }
  }
}
