import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:settings_ui/settings_ui.dart';

import '../handler/notification_handler.dart';
import '../handler/storage_handler.dart';
import '../util.dart';
import 'linked_settings_tile.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({Key? key}) : super(key: key);

  @override
  _NotificationSettingsState createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  @override
  Widget build(BuildContext context) {
    return SettingsList(
      applicationType: ApplicationType.material,
      platform: DevicePlatform.iOS,
      shrinkWrap: false,
      sections: [
        SettingsSection(
          title: const Text('Willkommen'),
          tiles: [
            ...notificationTiles(UseCase.welcome),
          ],
        ),
        SettingsSection(
          title: const Text('Ankunft'),
          tiles: [
            ...notificationTiles(UseCase.travel),
          ],
        ),
        SettingsSection(
          title: const Text('Finanzen'),
          tiles: [
            ...notificationTiles(UseCase.finance),
          ],
        ),
        SettingsSection(
          title: const Text('Entertainment'),
          tiles: [
            ...notificationTiles(UseCase.entertainment),
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
    );
  }

  /// Returns a list of [SettingTile] containing two tiles needed for the handling
  /// of notifications. They're the same for every use case: A boolean switch
  /// and a time picker
  List<AbstractSettingsTile> notificationTiles(UseCase useCase) {
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

    Time notificationTime = StorageHandler.getValue(timeKey);

    return [
      LinkedSettingsTile(
        title: "Benachrichtigungen",
        settingKey: notificationKey,
        type: LinkedTileType.toggle,
        onChange: (value) => StorageHandler.updateNotifications(useCase, value),
      ),
      SettingsTile.navigation(
        value: Text("${notificationTime.toStorageString()} Uhr"),
        title: const Text("Uhrzeit"),
        onPressed: (_) {
          showTimePicker(
            context: context,
            initialTime: TimeOfDay(
              hour: notificationTime.hour,
              minute: notificationTime.minute,
            ),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  alwaysUse24HourFormat: true,
                ),
                child: Theme(
                  data: ThemeData.light().copyWith(
                    timePickerTheme: const TimePickerThemeData(
                      dialHandColor: CustomColors.blackBackground,
                      helpTextStyle: TextStyle(color: Colors.black),
                    ),
                  ),
                  child: child!,
                ),
              );
            },
          ).then(
            (time) {
              if (time != null) {
                NotificationHandler handler = NotificationHandler.instance;
                handler.removeNotification(useCase);
                StorageHandler.saveValue(timeKey, Time(time.hour, time.minute));
                handler.scheduleNotification(useCase);
                setState(() {});
              }
            },
          );
        },
      ),
    ];
  }
}
