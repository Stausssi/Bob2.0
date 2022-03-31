import 'package:bob/handler/notification_handler.dart';
import 'package:bob/handler/storage_handler.dart';
import 'package:bob/settings.dart';
import 'package:bob/util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'chat/conversation.dart';
import 'home/home_widget.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
UseCase? startupUseCase;

void main() async {
  await StorageHandler.init();
  NotificationHandler notificationHandler = NotificationHandler();
  await notificationHandler.init();

  startupUseCase = await notificationHandler.launchUseCase;

  runApp(const BobApp());
}

class BobApp extends StatelessWidget {
  const BobApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bob 2.0',
      theme: ThemeData(
        textTheme: GoogleFonts.assistantTextTheme(),
      ),
      themeMode: ThemeMode.light,
      home: const MainPage(title: 'Bob 2.0 - Your PDA'),
      navigatorKey: navigatorKey,
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _openConversation();
  }

  void _openConversation() async {
    if (startupUseCase != null) {
      await Future.delayed(const Duration(milliseconds: 1000));

      _onItemTap(1, startupUseCase);
      startupUseCase = null;
    }
  }

  void _onItemTap(int index, [UseCase? startUseCase]) {
    index == 1
        ? Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Conversation(startUseCase: startUseCase),
            ),
          ).whenComplete(() => setState(() {}))
        : setState(() {
            _pageIndex = index;
          });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      // One item is the home page
      HomeWidget(key: Key("${getLastConversationDate()}-parent")),
      // This container is representing the "Conversation" tab.
      // !! DO NOT REMOVE !!
      Container(),
      // One item is the settings page
      const Settings()
    ];

    return Scaffold(
      // appBar: null,
      body: Stack(
        children: [
          FractionallySizedBox(
            alignment: Alignment.topCenter,
            heightFactor: 0.4,
            widthFactor: 1,
            child: Container(
              decoration:
                  const BoxDecoration(color: CustomColors.blackBackground),
            ),
          ),
          pages[_pageIndex],
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pageIndex,
        onTap: (index) => _onItemTap(index),
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black26,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            label: "Konversation",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: "Einstellungen",
          ),
        ],
      ),
    );
  }
}
