import 'package:bob/handler/storage_handler.dart';
import 'package:bob/settings/linked_settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

import '../handler/storage_handler.dart';
import '../util.dart';

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
          title: Text(UseCase.welcome.getGermanName()),
          tiles: [
            ..._generateChoiceTiles(
              SettingKeys.newsCategories,
              newsCategories,
              Icons.newspaper,
            ),
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
        SettingsSection(
          title: Text(UseCase.travel.getGermanName()),
          tiles: const [
            LinkedSettingsTile(
              leading: Icon(Icons.home),
              title: "Standort Zuhause",
              settingKey: SettingKeys.homeLocation,
              type: LinkedTileType.location,
            ),
            LinkedSettingsTile(
              leading: Icon(Icons.work),
              title: "Standort Arbeit",
              settingKey: SettingKeys.workingLocation,
              type: LinkedTileType.location,
            ),
            LinkedSettingsTile(
              leading: Icon(Icons.drive_eta),
              title: "Anfahrtstyp",
              settingKey: SettingKeys.preferredVehicle,
              type: LinkedTileType.dropdown,
            ),
            LinkedSettingsTile(
              leading: Icon(Icons.local_gas_station),
              title: "Kraftstofftyp",
              settingKey: SettingKeys.gasolineType,
              type: LinkedTileType.dropdown,
            )
          ],
        ),

        /// Finances
        SettingsSection(
          title: Text(UseCase.finance.getGermanName()),
          tiles: const [
            LinkedSettingsTile(
              leading: Icon(Icons.currency_bitcoin),
              title: "Public Binance Key",
              settingKey: SettingKeys.publicBinanceApiKey,
              type: LinkedTileType.text,
            ),
            LinkedSettingsTile(
              leading: Icon(Icons.currency_bitcoin),
              title: "Private Binance Key",
              settingKey: SettingKeys.privateBinanceApiKey,
              type: LinkedTileType.text,
            ),
            LinkedSettingsTile(
              leading: Icon(Icons.insert_chart_outlined),
              title: "Stock Index",
              settingKey: SettingKeys.stockIndex,
              type: LinkedTileType.text,
            ),
            LinkedSettingsTile(
              leading: Icon(Icons.attach_money),
              title: "Ticker",
              settingKey: SettingKeys.stockList,
              type: LinkedTileType.multilineText,
            )
          ],
        ),

        /// Entertainment
        SettingsSection(
          title: Text(UseCase.entertainment.getGermanName()),
          tiles: [
            ..._generateChoiceTiles(
              SettingKeys.movieGenres,
              movieGenres,
              Icons.movie_outlined,
            ),
            const LinkedSettingsTile(
              leading: Icon(Icons.sports_soccer_outlined),
              title: "Fußball Verein",
              settingKey: SettingKeys.footballClub,
              type: LinkedTileType.text,
            ),
          ],
        ),

        /// Reset
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
    );
  }

  /// Generates multiple setting tiles representing a multiselect of all given [choices].
  /// It will be saved as a [List<String>] in the local storage with the key
  /// [settingsKey]
  List<AbstractSettingsTile> _generateChoiceTiles(
    String settingsKey,
    List<String> choices,
    IconData icon,
  ) {
    return choices
        .map(
          (choice) => SettingsTile.switchTile(
            title: Text(choice),
            leading: Icon(icon),
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
