import 'package:bob/chat/microphone_circle.dart';
import 'package:bob/chat/speech_processing.dart';
import 'package:bob/handler/conversation_handler.dart';
import 'package:bob/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as chat_types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:uuid/uuid.dart';

class Conversation extends StatefulWidget {
  const Conversation({Key? key}) : super(key: key);

  @override
  _ConversationState createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  ConversationHandler conversationHandler = ConversationHandler();

  // Users to display messages accordingly
  final _thisUser = const chat_types.User(id: "not_bob");
  final _bobUser = const chat_types.User(id: "bob");

  final List<chat_types.Message> _messages = [];

  // Needed for the generation of identifiers of messages
  final Uuid _uuidGen = const Uuid();

  late final SpeechProcessing _speechProcessing;

  // The text to display on the loading screen
  String loadingText = "Please wait while we're enabling your microphone...";

  @override
  void initState() {
    super.initState();

    // Add dummy messages
    _messages.add(chat_types.TextMessage(
      author: _bobUser,
      id: _uuidGen.v1(),
      text: "Bob sent this message!",
    ));

    _messages.add(chat_types.TextMessage(
      author: _thisUser,
      id: _uuidGen.v1(),
      text: "I sent this message!",
    ));

    // Get the speech processing instance
    _speechProcessing = SpeechProcessing(onReady: _onSpeechReady);
  }

  /// (Re)sets the loading screen to the given [text], or "" if [text] is null
  void _setLoadingText([String? text]) {
    text ??= "";

    setState(() {
      loadingText = text!;
    });
  }

  /// Callback for [SpeechProcessing] to call once TTS and STT are initialized
  void _onSpeechReady() {
    _setLoadingText();

    _speechProcessing.read("Hallo hier ist TTS");
  }

  /// Prompt STT to listen to the user
  void _startListening() {
    _setLoadingText("We're listening...");

    _speechProcessing.listen(
      (String result) {
        sendMessage(result);
        _setLoadingText();
      },
      onTimeout: _setLoadingText,
    );
  }

  /// Stop STT listen
  void _stopListening() {
    _speechProcessing.stopListening();
    _setLoadingText();
  }

  /// Parse the voice / text input of the user and request an answer from the backend
  void sendMessage(String text) async {
    // Add the message of the user to the chat history
    chat_types.Message? userMessage = chat_types.TextMessage(
      author: _thisUser,
      id: _uuidGen.v1(),
      text: text,
    );

    if (text.isNotEmpty) {
      setState(() {
        _messages.insert(0, userMessage);
      });
    }

    final backendAnswer = await conversationHandler.askQuestion(text);

    String response = "Sorry, Bob couldn't find an answer to that question :(";
    if (backendAnswer != null) {
      response = backendAnswer.tts;
    }

    // Read the text ...
    _speechProcessing.read(response);

    // ... and display it
    setState(() {
      _messages.insert(
        0,
        chat_types.TextMessage(
          author: _bobUser,
          id: _uuidGen.v1(),
          text: response,
          repliedMessage: userMessage,
          metadata: {"questions": backendAnswer?.furtherQuestions},
        ),
      );
    });
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
            user: _thisUser,
            onSendPressed: (_) => print("send pressed and ignored"),
            textMessageBuilder: (message,
                {required int messageWidth, required bool showName}) {
              List<Widget> messageContents = [
                Text(
                  message.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ];

              if (message.metadata != null && message.metadata!.isNotEmpty) {
                for (String question in message.metadata!["questions"]) {
                  messageContents.add(
                    ElevatedButton(
                      onPressed: () => print("Question $question selected!"),
                      child: Text(question),
                    ),
                  );
                }
              }
              return Container(
                // width: messageWidth.toDouble(),
                decoration: const BoxDecoration(
                  color: CustomColors.blackBackground,
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: messageContents,
                ),
              );
            },
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
                  if (_speechProcessing.isListening)
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

/// The input layout to show on the bottom of the chat
class InputWidget extends StatefulWidget {
  const InputWidget({
    Key? key,
    required this.micCallback,
    required this.onSendMessage,
  }) : super(key: key);

  /// Called once the user presses the "send" button
  final Function(String) onSendMessage;

  /// Called once the mic button is clicked
  final Function() micCallback;

  @override
  State<StatefulWidget> createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> {
  final TextEditingController _controller = TextEditingController();

  // Whether the text input field should be shown
  bool _showExtendedInput = false;

  // bool _showSendButton = false;

  // The message in the text input box
  String _message = "";

  /// Called on every letter change
  void onTextChanged(String text) {
    setState(() {
      _message = text;
    });
  }

  /// Send a chat message
  void sendMessage(String messageText) {
    widget.onSendMessage(messageText);

    // Clear and reset the text input field
    _controller.clear();
    setState(() {
      _message = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showExtendedInput) {
      // Create a widget with a text box
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
                    onPressed: () => sendMessage(_message),
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
                setState(() => _showExtendedInput = false);
                widget.micCallback();
              },
              size: 30,
            ),
          ],
        ),
      );
    } else {
      // Create the mic overlay
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
                        _showExtendedInput = true;
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
