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
          ConversationList(key: Key("${getLastConversationDate()}_list")),
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
                  ).whenComplete(() => setState(() {}));
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
    List<String> previousConversations = StorageHandler.getValue(
      SettingKeys.previousConversations,
    );
    List<String> previousDates = StorageHandler.getValue(
      SettingKeys.previousConversationDates,
    );

    List<Widget> listContents = [
      const Text(
        "Recent Conversations",
        style: TextStyle(fontWeight: FontWeight.bold),
      )
    ];

    if (previousConversations.length != previousDates.length) {
      StorageHandler.resetKey(SettingKeys.previousConversations);
      StorageHandler.resetKey(SettingKeys.previousConversationDates);
      listContents = [
        const Text(
          "Something went wrong while retrieving your last conversations.",
        )
      ];
    } else {
      if (previousConversations.isEmpty) {
        listContents = [
          const Text("Your recent conversations will be listed here")
        ];
      } else {
        int count = 0;
        for (String useCase in previousConversations) {
          ColoredBubble conversationWidget = ColoredBubble(
            padding: 10,
            margin: 0,
            child: Row(
              children: [
                // On the left, show a picture of the use case
                Flexible(
                  child: CircleAvatar(
                    foregroundImage: Image(
                      image: AssetImage("assets/useCases/$useCase.png"),
                    ).image,
                    backgroundColor: Colors.transparent,
                    radius: 25,
                  ),
                ),
                const Padding(padding: EdgeInsets.all(6)),
                // Show the use case of the conversation and the time difference
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      useCase.capitalize(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      DateTime.now()
                          .difference(DateTime.parse(previousDates[count]))
                          .toFancyString(),
                      style: GoogleFonts.actor(
                        color: Colors.black38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                )
              ],
            ),
            color: Colors.white,
          );

          // Add the widget and a small padding
          listContents.add(conversationWidget);
          count++;
        }
      }
    }

    return Flexible(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
        // Show all items in a list separated by padding
        child: ListView.separated(
          shrinkWrap: true,
          itemBuilder: (_, index) {
            return listContents[index];
          },
          separatorBuilder: (_, __) => const Padding(
            padding: EdgeInsets.all(6),
          ),
          itemCount: listContents.length,
          // We don't need scrolling, item extent is limited by the StorageHandler
          physics: const NeverScrollableScrollPhysics(),
        ),
      ),
    );
  }
}

extension DurationString on Duration {
  /// Returns the duration as string following the schema "X Y ago", where X is
  /// a number and Y is either days, hours or minutes.
  ///
  /// In extreme cases (> 30 days or < 1 minute) a special String is returned:
  /// "a long time ago" or "just now" respectively
  String toFancyString() {
    // Handle a duration which is longer than a day
    Duration difference = abs();

    if (difference.inDays > 0) {
      if (difference.inDays > 30) {
        return "a long time ago";
      }

      if (difference.inDays == 1) {
        return "1 day ago";
      }

      return "${difference.inDays} days ago";
    }

    // Handle 1d > duration >= 1h
    if (difference.inHours > 0) {
      if (difference.inHours == 1) {
        return "1 hour ago";
      }

      return "${difference.inHours} hours ago";
    }

    // Handle small durations (1h > duration >= 1m)
    if (difference.inMinutes > 0) {
      if (difference.inMinutes == 1) {
        return "1 minute ago";
      }

      return "${difference.inMinutes} minutes ago";
    }

    return "just now";
  }
}
