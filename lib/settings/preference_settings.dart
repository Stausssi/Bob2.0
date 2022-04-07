import 'package:bob/Settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class PreferenceSettings extends StatefulWidget {
  const PreferenceSettings({Key? key}) : super(key: key);

  @override
  _PreferenceSettingsState createState() => _PreferenceSettingsState();
}

class _PreferenceSettingsState extends State<PreferenceSettings> {
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
          title: const Text('Basic settings'),
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
