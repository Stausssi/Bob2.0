import 'package:bob/handler/notification_handler.dart';
import 'package:bob/handler/storage_handler.dart';
import 'package:bob/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:settings_ui/settings_ui.dart';

/// Themes

const lightCupertinoSettingsTheme = SettingsThemeData(
  trailingTextColor: Colors.grey,
  settingsListBackground: Colors.transparent,
  settingsSectionBackground: Colors.transparent,
  dividerColor: Colors.white12,
  tileHighlightColor: Colors.white24,
  titleTextColor: Colors.white,
  leadingIconsColor: Colors.white70,
  tileDescriptionTextColor: Colors.white10,
  settingsTileTextColor: Colors.white,
  inactiveTitleColor: Colors.red,
  inactiveSubtitleColor: Colors.red,
);

/// ----------------------

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

          /// hä ?
          darkTheme: lightCupertinoSettingsTheme,
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
                        builder: (_) => const SettingsSubmenu(
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
                          settings: Preferences(),
                        ),
                      ),
                    ),
                  },
                ),
                SettingsTile.navigation(
                  leading: const Icon(Icons.language),
                  title: const Text('Integrationen verwalten'),
                  onPressed: (context) => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsSubmenu(
                          title: "Integrationen verwalten",
                          settings: Integrations(),
                        ),
                      ),
                    ),
                  },
                )
              ],
            ),
            SettingsSection(
              title: const Text("Debug"),
              tiles: [
                SettingsTile(
                  title: const Text("Benachrichtigung senden"),
                  onPressed: (_) => NotificationHandler().testNotifications(),
                )
              ],
            )
          ],
        ),
      ],
    ));
  }
}

class SettingsSubmenu extends StatefulWidget {
  const SettingsSubmenu({required this.title, required this.settings, Key? key})
      : super(key: key);

  final String title;
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
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: CustomColors.blackBackground,
          shadowColor: Colors.transparent,
          toolbarHeight: 100,
        ),
        body: widget.settings);
  }
}

class UserSettings extends StatefulWidget {
  const UserSettings({Key? key}) : super(key: key);

  @override
  _UserSettingsState createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {
  @override
  Widget build(BuildContext context) {
    // TODO: Hier input für User name
    return SettingsList(
      applicationType: ApplicationType.material,
      platform: DevicePlatform.iOS,
      darkTheme: lightCupertinoSettingsTheme,
      shrinkWrap: false,
      sections: [
        SettingsSection(
          title: const Text('Allgemeine Einstellungen'),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: const Icon(Icons.perm_identity),
              title: const Text('Test1'),
              onPressed: (context) => {},
            ),
          ],
        ),
      ],
    );
  }
}

class Preferences extends StatefulWidget {
  const Preferences({Key? key}) : super(key: key);

  @override
  _PreferencesState createState() => _PreferencesState();
}

class _PreferencesState extends State<Preferences> {
  @override
  Widget build(BuildContext context) {
    return SettingsList(
      applicationType: ApplicationType.material,
      platform: DevicePlatform.iOS,
      darkTheme: lightCupertinoSettingsTheme,
      shrinkWrap: false,
      sections: [
        SettingsSection(
          title: const Text('Willkommen'),
          tiles: <SettingsTile>[
            ...notificationTiles(UseCase.welcome),
          ],
        ),
        SettingsSection(
          title: const Text('Ankunft'),
          tiles: <SettingsTile>[
            ...notificationTiles(UseCase.travel),
          ],
        ),
        SettingsSection(
          title: const Text('Finanzen'),
          tiles: <SettingsTile>[
            ...notificationTiles(UseCase.finance),
          ],
        ),
        SettingsSection(
          title: const Text('Entertainment'),
          tiles: <SettingsTile>[
            ...notificationTiles(UseCase.entertainment),
          ],
        ),
      ],
    );
  }

  /// Returns a list of [SettingTile] containing two tiles needed for the handling
  /// of notifications. They're the same for every use case: A boolean switch
  /// and a time picker
  ///
  /// TODO: Auslagern in eines Einstellungs-Menü?
  List<SettingsTile> notificationTiles(UseCase useCase) {
    late String notificationKey;
    late String timeKey;

    switch (useCase) {
      case UseCase.welcome:
        notificationKey = SettingKeys.welcomeNotification;
        timeKey = SettingKeys.welcomeTime;
        break;
      case UseCase.travel:
        notificationKey = SettingKeys.travelNotification;
        timeKey = SettingKeys.travelTime;
        break;
      case UseCase.finance:
        notificationKey = SettingKeys.financeNotification;
        timeKey = SettingKeys.financeTime;
        break;
      case UseCase.entertainment:
        notificationKey = SettingKeys.entertainmentNotification;
        timeKey = SettingKeys.entertainmentTime;
        break;
    }

    bool notificationsEnabled = StorageHandler.getValue(notificationKey);
    Time notificationTime = StorageHandler.getValue(timeKey);

    return [
      SettingsTile.switchTile(
        initialValue: notificationsEnabled,
        title: const Text("Benachrichtigungen"),
        onToggle: (value) => setState(
          () => StorageHandler.updateNotifications(useCase, value),
        ),
      ),
      SettingsTile.navigation(
        // TODO: Beautify String
        value: Text("${notificationTime.toStorageString()} Uhr"),
        title: const Text("Uhrzeit"),
        // TODO: Time picker
        onPressed: (_) => print("TODO: Implement time picker"),
      ),
    ];
  }
}

class Integrations extends StatefulWidget {
  const Integrations({Key? key}) : super(key: key);

  @override
  _IntegrationsState createState() => _IntegrationsState();
}

class _IntegrationsState extends State<Integrations> {
  bool button = false;

  @override
  Widget build(BuildContext context) {
    return SettingsList(
      applicationType: ApplicationType.material,
      platform: DevicePlatform.iOS,
      darkTheme: lightCupertinoSettingsTheme,
      shrinkWrap: false,
      sections: [
        SettingsSection(
          title: const Text('Basic Settings'),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: const Icon(Icons.perm_identity),
              title: const Text('Test3'),
              onPressed: (context) => {},
            ),
          ],
        ),
      ],
    );
  }
}
