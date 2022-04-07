import 'package:bob/handler/storage_handler.dart';
import 'package:bob/settings/linked_settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

import '../handler/storage_handler.dart';

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
      shrinkWrap: false,
      sections: [
        /// Welcome
        SettingsSection(
          title: const Text('Welcome'),
          tiles: [
            SettingsTile.navigation(
              leading: const Icon(Icons.perm_identity),
              title: const Text('Test3'),
              onPressed: (context) => {},
            ),
            const LinkedSettingsTile(
                leading: Icon(Icons.perm_identity),
                title: "Wetter Standort",
                settingKey: SettingKeys.weatherLocation,
                type: LinkedTileType.location)
          ],
        ),

        /// Travel
        const SettingsSection(
          title: Text('Travel'),
          tiles: [
            LinkedSettingsTile(
                leading: Icon(Icons.perm_identity),
                title: "Standort Zuhause",
                settingKey: SettingKeys.homeLocation,
                type: LinkedTileType.location),
            LinkedSettingsTile(
                leading: Icon(Icons.perm_identity),
                title: "Standort Arbeit",
                settingKey: SettingKeys.workingLocation,
                type: LinkedTileType.location),
            LinkedSettingsTile(
                title: "Anfahrtstyp",
                settingKey: SettingKeys.preferedVehicle,
                type: LinkedTileType.dropdown),
            LinkedSettingsTile(
                title: "Kraftstofftyp",
                settingKey: SettingKeys.gasolineType,
                type: LinkedTileType.dropdown)
          ],
        ),

        /// Finances
        const SettingsSection(
          title: Text('Finances'),
          tiles: [
            LinkedSettingsTile(
                title: "Binance API Key",
                settingKey: SettingKeys.binanceApiKey,
                type: LinkedTileType.text),
            LinkedSettingsTile(
                title: "Stock Index",
                settingKey: SettingKeys.stockIndex,
                type: LinkedTileType.text),
            LinkedSettingsTile(
                title: "Aktienliste",
                settingKey: SettingKeys.stockList,
                type: LinkedTileType.multilineText)
          ],
        ),

        /// Entertainment
        const SettingsSection(
          title: Text('Entertainment'),
          tiles: [
            LinkedSettingsTile(
                title: "Binance API Key",
                settingKey: SettingKeys.binanceApiKey,
                type: LinkedTileType.text),
          ],
        ),
      ],
    );
  }
}
