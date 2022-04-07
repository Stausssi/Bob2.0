import 'package:bob/Settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

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
