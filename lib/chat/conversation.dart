import 'package:bob/chat/microphone_circle.dart';
import 'package:bob/chat/speech_processing.dart';
import 'package:bob/handler/conversation_handler.dart';
import 'package:bob/handler/storage_handler.dart';
import 'package:bob/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as chat_types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:uuid/uuid.dart';

/// Displays the chat between the user and Bob 2.0
class Conversation extends StatefulWidget {
  const Conversation({this.startUseCase, Key? key}) : super(key: key);

  final UseCase? startUseCase;

  @override
  _ConversationState createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  ConversationHandler conversationHandler = ConversationHandler();

  // Users to display messages accordingly
  final _thisUser = const chat_types.User(
    firstName: "You",
    id: "not_bob",
  );
  final _bobUser = chat_types.User(
    firstName: "Bob",
    lastName: "2.0",
    role: chat_types.Role.agent,
    imageUrl: "${ConversationHandler.instance.backendURL}/bob_head",
    id: "bob",
  );

  final List<chat_types.Message> _messages = [];

  // Needed for the generation of identifiers of messages
  final Uuid _uuidGen = const Uuid();

  late final SpeechProcessing _speechProcessing;

  // The text to display on the loading screen
  String loadingText = "Dein Mikrofon wird geladen...";

  bool _conversationSaved = false;
  UseCase? _useCase;

  @override
  void initState() {
    super.initState();

    // Get the speech processing instance
    _speechProcessing = SpeechProcessing(onReady: _onSpeechReady);
  }

  @override
  void dispose() {
    _speechProcessing.stopTalking();

    super.dispose();
  }

  /// (Re)sets the loading screen to the given [text], or "" if [text] is null
  void _setLoadingText([String? text]) {
    text ??= "";

    if (mounted) {
      setState(() {
        loadingText = text!;
      });
    }
  }

  /// Callback for [SpeechProcessing] to call once TTS and STT are initialized
  void _onSpeechReady() {
    _setLoadingText();

    // Send a start message to init a use case started by a notification
    // TODO: Text for every use case
    if (widget.startUseCase != null) {
      switch (widget.startUseCase!) {
        case UseCase.welcome:
          sendMessage("Guten Morgen Bob!");
          break;
        case UseCase.travel:
          sendMessage("Travel dialog");
          break;
        case UseCase.finances:
          sendMessage("Wie ist die aktuelle Marktsituation?");
          break;
        case UseCase.entertainment:
          sendMessage("Netflix&Chill");
          break;
      }
    }
  }

  /// Prompt STT to listen to the user
  void _startListening() {
    _setLoadingText("Ich höre...");

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

  void _addMessage(chat_types.Message message) {
    if (mounted) {
      setState(() {
        _messages.insert(0, message);
      });
    }
  }

  /// Parse the voice / text input of the user and request an answer from the backend
  void sendMessage(String text) async {
    // Add the message of the user to the chat history
    chat_types.Message? userMessage = chat_types.TextMessage(
      author: _thisUser,
      id: _uuidGen.v1(),
      text: text,
    );

    StorageHandler.increaseMessages();

    if (text.isNotEmpty) {
      // Increase conversation count once the first message is sent
      if (_messages.isEmpty) {
        StorageHandler.increaseConversations();
      }

      _addMessage(userMessage);
    }

    final backendAnswer = await conversationHandler.askQuestion(text);

    String response = "Sorry, auf diese Frage habe ich leider keine Antwort :(";
    bool hasFurtherQuestions = false;
    if (backendAnswer != null) {
      response = backendAnswer.tts;
      hasFurtherQuestions = backendAnswer.furtherQuestions.isNotEmpty;

      if (_useCase != conversationHandler.currentUseCase) {
        _conversationSaved = false;
        _useCase = conversationHandler.currentUseCase;
      }

      // Save the conversation if a use case was detected and is different from the one saved here
      if (!_conversationSaved) {
        StorageHandler.addConversation(
          conversationHandler.currentUseCase!.name,
        );
        _conversationSaved = true;

        // print("Saved conversation with usecase $_useCase");
      }
    }

    // Read the text ...
    _speechProcessing.read(response);

    // ... and display it
    chat_types.Message answer = chat_types.TextMessage(
      author: _bobUser,
      id: _uuidGen.v1(),
      text: response,
      repliedMessage: userMessage,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    StorageHandler.increaseMessages();

    _addMessage(answer);

    if (hasFurtherQuestions) {
      answer = chat_types.CustomMessage(
        author: _bobUser,
        id: _uuidGen.v1(),
        metadata: {"questions": backendAnswer?.furtherQuestions},
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      _addMessage(answer);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Konversation"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shadowColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          Chat(
            // showUserNames: true,
            showUserAvatars: true,
            customBottomWidget: InputWidget(
              micCallback: _startListening,
              onSendMessage: sendMessage,
            ),
            emptyState: Center(
              child: Text(
                "Bob ist bereit deine Fragen zu beantworten!",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            groupMessagesThreshold: 5000,
            messages: _messages,
            user: _thisUser,
            onSendPressed: (_) {},
            theme: const DefaultChatTheme(
              messageInsetsVertical: 12,
              primaryColor: CustomColors.purpleForeground,
            ),
            customMessageBuilder: _buildQuestionChoices,
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
                      padding: const EdgeInsets.symmetric(horizontal: 100),
                      child: ElevatedButton(
                        onPressed: _stopListening,
                        child: const Text(
                          "Zuhören stoppen",
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

  /// Builds a message box containing all questions contained in the [message] metadata.
  ///
  /// [messageWidth] is required by the chat framework
  Widget _buildQuestionChoices(message, {required int messageWidth}) {
    List<Widget> questionButtons = [
      const Text(
        "Weiterführende Fragen: ",
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.5,
        ),
      )
    ];

    // Display a list of possible further questions after the most
    // recent message if the author is bob and further questions are provided
    if (message.author == _bobUser) {
      if (message.metadata != null &&
          message.metadata!.containsKey("questions") &&
          message.metadata!["questions"] != null) {
        for (String question in message.metadata!["questions"]) {
          questionButtons.add(
            ElevatedButton(
              onPressed: () {
                // Remove this message
                _messages.remove(message);

                // Send the answer to the backend
                sendMessage(question);
              },
              child: Text(question),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Colors.white,
                ),
                foregroundColor: MaterialStateProperty.all(
                  Colors.black,
                ),
              ),
            ),
          );
        }
      }
    }

    return Container(
      padding: const EdgeInsets.only(
        left: 16,
        top: 8,
        bottom: 4,
        right: 8,
      ),
      decoration: const BoxDecoration(
        color: Colors.white60,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: questionButtons,
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
    messageText = messageText.trim();

    if (messageText.isNotEmpty) {
      widget.onSendMessage(messageText);

      // Clear and reset the text input field
      _controller.clear();
      setState(() {
        _message = "";
      });
    }
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
                  hintText: "Deine Nachricht hier",
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
                      child: const Text("Ich möchte schreiben"),
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
