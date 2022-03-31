import 'package:bob/handler/storage_handler.dart';
import 'package:bob/util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../chat/conversation.dart';

/// Displays statistics and most recent conversations
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
                  "Hallo ${StorageHandler.getValue(SettingKeys.userName)}",
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
                    "Konversationen",
                  ),
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: ColoredBubble(
                  child: _buildCounterWidget(
                    StorageHandler.getValue(SettingKeys.messageCount),
                    "Nachrichten",
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

  /// Builds a rounded box containing a number ([count]) and a [description] what
  /// this count represents directly below
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

  /// Builds a colored box allowing the user to start a conversation with bob
  Widget _buildConversationStarter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Bob 2.0 ist bereit dir zu helfen",
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
                  "Klicke hier für Unterstützung",
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

/// A Box with rounded corners and a background color
class ColoredBubble extends StatelessWidget {
  const ColoredBubble({
    required this.child,
    required this.color,
    this.margin = 15,
    this.padding = 25,
    Key? key,
  }) : super(key: key);

  /// The [Widget] to display inside the box
  final Widget child;

  /// The background color of the box
  final Color color;

  /// The padding of the [child] widget
  final double padding;

  /// The margin of the box
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

/// Displays a list of conversations represented by an [Icon], [UseCase] and a
/// timestamp
class ConversationList extends StatelessWidget {
  const ConversationList({Key? key}) : super(key: key);

  /// Contains a german translation for each use case
  static const Map<UseCase, String> translationMap = {
    UseCase.finance: "Finanzen",
    UseCase.welcome: "Guten Morgen",
    UseCase.entertainment: "Unterhaltung",
    UseCase.travel: "Reisen"
  };

  @override
  Widget build(BuildContext context) {
    // Get the last X conversations and the corresponding dates
    List<String> previousConversations = StorageHandler.getValue(
      SettingKeys.previousConversations,
    );
    List<String> previousDates = StorageHandler.getValue(
      SettingKeys.previousConversationDates,
    );

    /// Every item contained in the list
    List<Widget> listContents = [
      const Text(
        "Letzte Konversationen",
        style: TextStyle(fontWeight: FontWeight.bold),
      )
    ];

    // An error occurred if conversation and dates are not of the same length
    if (previousConversations.length != previousDates.length) {
      StorageHandler.resetKey(SettingKeys.previousConversations);
      StorageHandler.resetKey(SettingKeys.previousConversationDates);
      listContents.add(
        const Text(
          "Die letzten Konversationen konnten nicht geladen werden.",
          style: TextStyle(
            color: Colors.black38,
          ),
        ),
      );
    } else {
      // There was no conversation with bob yet
      if (previousConversations.isEmpty) {
        listContents.add(
          const Text(
            "Deine Konversationen werden hier aufgelistet",
            style: TextStyle(
              color: Colors.black38,
            ),
          ),
        );
      } else {
        int count = 0;
        // Go over every conversation and create a widget with the corresponding icon,
        // UseCase name and timestamp
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
                      translationMap[useCaseFromString(useCase)]!,
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
        return "Vor langer Zeit";
      }

      if (difference.inDays == 1) {
        return "Gestern";
      }

      return "Vor ${difference.inDays} Tagen";
    }

    // Handle 1d > duration >= 1h
    if (difference.inHours > 0) {
      if (difference.inHours == 1) {
        return "Vor 1 Stunde";
      }

      return "Vor ${difference.inHours} Stunden";
    }

    // Handle small durations (1h > duration >= 1m)
    if (difference.inMinutes > 0) {
      if (difference.inMinutes == 1) {
        return "Vor 1 Minute";
      }

      return "Vor ${difference.inMinutes} Minuten";
    }

    return "Gerade eben";
  }
}
