import 'package:bob/handler/storage_handler.dart';
import 'package:bob/util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../chat/conversation.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
            child: Row(
              children: [
                CircleAvatar(
                  foregroundImage: const Image(
                    image: AssetImage("assets/user.png"),
                  ).image,
                  radius: 30,
                  backgroundColor: CustomColors.avatarBackground,
                ),
                const Padding(padding: EdgeInsets.all(6)),
                Text(
                  "Hey ${StorageHandler.getValue(SettingKeys.userName)}",
                  style: GoogleFonts.aBeeZee(
                    fontSize: 20,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ColoredBubble(
                  child: _buildCounterWidget(
                    StorageHandler.getValue(SettingKeys.conversationCount),
                    "Conversations",
                  ),
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: ColoredBubble(
                  child: _buildCounterWidget(
                    StorageHandler.getValue(SettingKeys.messageCount),
                    "Messages",
                  ),
                  color: Colors.white,
                ),
              ),
            ],
          ),
          ColoredBubble(
            child: _buildConversationStarter(context),
            color: CustomColors.purpleForeground,
            padding: 0,
          ),
          const ConversationList(),
        ],
      ),
    );
  }

  Widget _buildCounterWidget(int count, String description) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: GoogleFonts.aBeeZee(
            fontSize: 24,
            fontStyle: FontStyle.italic,
            color: CustomColors.blackBackground,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          description,
          style: GoogleFonts.assistant(
            fontSize: 14,
            color: Colors.black38,
          ),
          textAlign: TextAlign.center,
        )
      ],
    );
  }

  Widget _buildConversationStarter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Start Conversation",
            style: GoogleFonts.assistant(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.left,
          ),
          const Padding(padding: EdgeInsets.all(6)),
          Row(
            children: [
              Flexible(
                child: CircleAvatar(
                  foregroundImage: const Image(
                    image: AssetImage("assets/bob_head.png"),
                  ).image,
                  backgroundColor: Colors.white10,
                  radius: 25,
                ),
              ),
              const Padding(padding: EdgeInsets.all(6)),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const Conversation(),
                    ),
                  ).whenComplete(() {
                    setState(() {});
                  });
                },
                child: Text(
                  "Request assistance from Bob 2.0",
                  style: GoogleFonts.assistant(
                    color: CustomColors.blackBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                  padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
                  shape: MaterialStateProperty.all(
                    const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class ColoredBubble extends StatelessWidget {
  const ColoredBubble({
    required this.child,
    required this.color,
    this.margin = 15,
    this.padding = 25,
    Key? key,
  }) : super(key: key);

  final Widget child;
  final Color color;
  final double padding;
  final double margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(margin),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
      ),
      child: child,
    );
  }
}

class ConversationList extends StatelessWidget {
  const ConversationList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> columnChildren = [
      const Text(
        "Recent Conversations",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const Padding(padding: EdgeInsets.all(6)),
    ];

    columnChildren.addAll(_buildConversationWidgets());

    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: columnChildren,
      ),
    );
  }

  List<Widget> _buildConversationWidgets() {
    List<String> previousConversations = StorageHandler.getValue(
      SettingKeys.previousConversations,
    );
    List<String> previousDates = StorageHandler.getValue(
      SettingKeys.previousConversationDates,
    );

    if (previousConversations.length != previousDates.length) {
      StorageHandler.resetKey(SettingKeys.previousConversations);
      StorageHandler.resetKey(SettingKeys.previousConversationDates);
      return [
        const Text(
          "Something went wrong while retrieving your last conversations.",
        )
      ];
    }

    if (previousConversations.isEmpty) {
      return [const Text("Your recent conversations will be listed here")];
    }

    List<Widget> conversationBubbles = [];

    int count = 0;
    for (String useCase in previousConversations) {
      ColoredBubble conversationWidget = ColoredBubble(
        padding: 10,
        margin: 0,
        child: Row(
          children: [
            Flexible(
              child: CircleAvatar(
                foregroundImage: const Image(
                  image: AssetImage("assets/bob_head.png"),
                ).image,
                backgroundColor: CustomColors.purpleForeground,
                radius: 25,
              ),
            ),
            const Padding(padding: EdgeInsets.all(6)),
            Column(
              children: [
                Text(
                  useCase,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  DateTime.parse(previousDates[count])
                      .difference(DateTime.now())
                      .toString(),
                ),
              ],
            )
          ],
        ),
        color: Colors.white,
      );

      // Add the widget and a small padding
      conversationBubbles.add(conversationWidget);
      conversationBubbles.add(const Padding(padding: EdgeInsets.all(6)));
      count++;
    }

    return conversationBubbles;
  }
}
