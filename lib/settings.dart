import 'package:bob/handler/notification_handler.dart';
import 'package:bob/util.dart';
import 'package:flutter/material.dart';
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
                "Settings",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white),
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
                        color: Colors.white),
                    child: const Text("Here you can change my settings!"),
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
              title: const Text('Basic Settings'),
              tiles: <SettingsTile>[
                SettingsTile.navigation(
                  leading: const Icon(Icons.perm_identity),
                  title: const Text('User Settings'),
                  onPressed: (context) => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SettingsSubmenu(
                                title: "User Settings",
                                settings: UserSettings(),
                              )),
                    ),
                  },
                ),
                SettingsTile.navigation(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Preferences'),
                  onPressed: (context) => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SettingsSubmenu(
                                title: "Customize Usecases",
                                settings: Preferences(),
                              )),
                    ),
                  },
                ),
                SettingsTile.navigation(
                  leading: const Icon(Icons.language),
                  title: const Text('Integrations'),
                  onPressed: (context) => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SettingsSubmenu(
                                title: "Integrations",
                                settings: Integrations(),
                              )),
                    ),
                  },
                )
              ],
            ),
            SettingsSection(
              title: const Text("Debug"),
              tiles: [
                SettingsTile(
                  title: const Text("Send notification"),
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
          title: const Text('Welcome Dialog'),
          tiles: <SettingsTile>[
            SettingsTile.switchTile(
              initialValue: true,
              title: const Text('Test2'),
              onPressed: (context) => {},
              onToggle: (bool value) {},
            ),
          ],
        ),
      ],
    );
  }
}

class Integrations extends StatefulWidget {
  const Integrations({Key? key}) : super(key: key);

  @override
  _IntegrationsState createState() => _IntegrationsState();
}

class _IntegrationsState extends State<Integrations> {
  @override
  bool button = false;

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
