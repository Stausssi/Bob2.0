import 'package:bob/Settings/settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class Preferences extends StatefulWidget {
  const Preferences({Key? key}) : super(key: key);

  @override
  _PreferencesState createState() => _PreferencesState();
}

class _PreferencesState extends State<Preferences> {
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
