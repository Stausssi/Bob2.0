import 'package:bob/Settings/settings.dart';
import 'package:bob/api_keys.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_search_flutter/mapbox_search_flutter.dart';
import 'package:settings_ui/settings_ui.dart';

import '../util.dart';

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
        /// Welcome
        SettingsSection(
          title: const Text('Welcome'),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: const Icon(Icons.perm_identity),
              title: const Text('Test3'),
              onPressed: (context) => {},
            ),
            SettingsTile.navigation(
              leading: const Icon(Icons.perm_identity),
              title: const Text('Test3'),
              onPressed: (context) => {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      appBar: AppBar(
                        title: const Text(
                          "Select your Location",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white),
                        ),
                        centerTitle: true,
                        backgroundColor: CustomColors.blackBackground,
                        shadowColor: Colors.transparent,
                        toolbarHeight: 100,
                      ),
                      body: MapBoxPlaceSearchWidget(
                        popOnSelect: true,
                        apiKey: ApiKeys.mapBox,
                        searchHint: 'Your Hint here',
                        onSelected: (place) {
                          // data
                          print(place.center); // das ist gut
                          print(place.placeName);
                          print(place.addressNumber);
                        },
                        context: context,
                      ),
                    ),
                  ),
                ),
              },
            ),
          ],
        ),

        /// Travel
        SettingsSection(
          title: const Text('Travel'),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: const Icon(Icons.perm_identity),
              title: const Text('Test3'),
              onPressed: (context) => {},
            ),
          ],
        ),

        /// Finances
        SettingsSection(
          title: const Text('Finances'),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: const Icon(Icons.perm_identity),
              title: const Text('Test3'),
              onPressed: (context) => {},
            ),
          ],
        ),

        /// Entertainment
        SettingsSection(
          title: const Text('Entertainment'),
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
