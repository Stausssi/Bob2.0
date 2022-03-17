import 'package:bob/conversation.dart';
import 'package:bob/main.dart';
import 'package:flutter/material.dart';
import 'package:bob/constants.dart';
import 'package:settings_ui/settings_ui.dart';


/// Themes

const lightCupertinoSettingsTheme = SettingsThemeData(
  trailingTextColor: Colors.grey,
  settingsListBackground: Colors.black,
  settingsSectionBackground: Colors.white10,
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
        return SettingsList(
        applicationType: ApplicationType.cupertino,
        platform: DevicePlatform.iOS,
        /// hä ?
        darkTheme: lightCupertinoSettingsTheme,
        shrinkWrap: false,
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
                      builder: (_) => const UserSettings(),
                    ),
                  )
                },
              ),
              SettingsTile.navigation(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Preferences')
              ),
              SettingsTile.navigation(
                  leading: const Icon(Icons.language),
                  title: const Text('Integrations')
              )
            ],
          ),
        ],
      );
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
      /// hä ?
      darkTheme: lightCupertinoSettingsTheme,
      sections: [
        SettingsSection(
          title: const Text('Basic Settings'),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: const Icon(Icons.perm_identity),
              title: const Text('Test'),
              onPressed: (context) => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Settings()
                  ),
                )
              },
            ),
          ],
        ),
      ],
    );
  }
}




