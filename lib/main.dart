import 'package:bob/util.dart';
import 'package:flutter/material.dart';

import 'chat/conversation.dart';

void main() {
  runApp(const BobApp());
}

class BobApp extends StatelessWidget {
  const BobApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bob 2.0',
      theme: ThemeData.light(),
      home: const MainPage(title: 'Bob 2.0 - Your PDA'),
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
  List<Widget> pages = [
    // One item is the home page
    Container(),
    // This container is representing the "Conversation" tab.
    // DO NOT REMOVE
    Container(),
    // One item is the settings page
    Container()
  ];
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
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
        onTap: (index) => index == 1
            ? Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const Conversation(),
                ),
              )
            : setState(() {
                _pageIndex = index;
              }),
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
            label: "Conversation",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
