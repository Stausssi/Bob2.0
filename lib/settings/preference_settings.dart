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
          title: const Text('Willkommen'),
          tiles: [
            ..._generateChoiceTiles(SettingKeys.newsCategories, newsCategories),
            const LinkedSettingsTile(
              leading: Icon(Icons.sunny),
              title: "Wetter Standort",
              settingKey: SettingKeys.weatherLocation,
              type: LinkedTileType.location,
            ),
            const LinkedSettingsTile(
              leading: Icon(Icons.calendar_month),
              title: "Stundenplan",
              settingKey: SettingKeys.raplaLink,
              type: LinkedTileType.text,
            )
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

  /// Generates multiple setting tiles representing a multiselect of all given [choices].
  /// It will be saved as a [List<String>] in the local storage with the key
  /// [settingsKey]
  List<AbstractSettingsTile> _generateChoiceTiles(
    String settingsKey,
    List<String> choices,
  ) {
    return choices
        .map(
          (choice) => SettingsTile.switchTile(
            title: Text(choice),
            leading: const Icon(Icons.newspaper),
            initialValue: StorageHandler.getValue<List<String>>(settingsKey)
                .contains(choice),
            onToggle: (selected) {
              StorageHandler.updateList(
                settingsKey,
                choice,
                selected,
              );
              setState(() {});
            },
          ),
        )
        .toList();
  }
}
