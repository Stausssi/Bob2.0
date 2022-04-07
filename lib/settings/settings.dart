import 'package:bob/settings/preference_settings.dart';
import 'package:bob/settings/user_settings.dart';
import 'package:bob/util.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

import '../handler/storage_handler.dart';
import 'notification_settings.dart';

/// The main settings page of Bob 2.0
class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Padding(
              padding: EdgeInsets.fromLTRB(0, 40, 0, 10),
              child: Center(
                child: Text(
                  "Einstellungen",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              )),
          Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            topLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                        color: Colors.white,
                      ),
                      child: const Text("Hier kannst du mich personalisieren!"),
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      width: 140,
                    ),
                  ),
                ],
              ),
              Container(
                child: Center(
                  child: Image.asset(
                    "assets/bob.png",
                    scale: 3,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
              )
            ],
          ),
          SettingsList(
            applicationType: ApplicationType.cupertino,
            platform: DevicePlatform.iOS,
            shrinkWrap: true,
            sections: [
              SettingsSection(
                title: const Text('Allgemeine Einstellungen'),
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    leading: const Icon(Icons.perm_identity),
                    title: const Text('Benutzereinstellungen'),
                    onPressed: (context) => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SettingsSubmenu(
                            title: "Benutzereinstellungen",
                            settings: UserSettings(),
                          ),
                        ),
                      ),
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('Präferenzen'),
                    onPressed: (context) => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsSubmenu(
                            title: "Use-Cases personalisieren",
                            settings: PreferenceSettings(),
                          ),
                        ),
                      ),
                    },
                  ),
                  SettingsTile.navigation(
                    leading: const Icon(Icons.notifications_none_outlined),
                    title: const Text('Benachrichtigungen'),
                    onPressed: (context) => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsSubmenu(
                            title: "Benachrichtigungen",
                            settings: NotificationSettings(),
                          ),
                        ),
                      ),
                    },
                  )
                ],
              ),
              SettingsSection(
                title: const Text("App zurücksetzen"),
                tiles: [
                  SettingsTile(
                    title: const Text("Zurücksetzen"),
                    onPressed: (_) => StorageHandler.reset(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The [SettingsSubmenu] is opened, when a setting of the main settings page
/// is clicked.
///
class SettingsSubmenu extends StatefulWidget {
  const SettingsSubmenu({required this.title, required this.settings, Key? key})
      : super(key: key);

  /// The title of the widget
  final String title;

  /// child settings widget
  final Widget settings;

  @override
  _SettingsSubmenuState createState() => _SettingsSubmenuState();
}

class _SettingsSubmenuState extends State<SettingsSubmenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: CustomColors.blackBackground,
        shadowColor: Colors.transparent,
        toolbarHeight: 100,
      ),
      body: widget.settings,
    );
  }
}
