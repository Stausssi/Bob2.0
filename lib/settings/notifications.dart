import 'package:bob/Settings/settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:settings_ui/settings_ui.dart';

import '../handler/notification_handler.dart';
import '../handler/storage_handler.dart';
import '../util.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  _NotificationsState createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  Widget build(BuildContext context) {
    return SettingsList(
      applicationType: ApplicationType.material,
      platform: DevicePlatform.iOS,
      darkTheme: lightCupertinoSettingsTheme,
      shrinkWrap: false,
      sections: [
        SettingsSection(
          title: const Text('Willkommen'),
          tiles: <SettingsTile>[
            ...notificationTiles(UseCase.welcome),
          ],
        ),
        SettingsSection(
          title: const Text('Ankunft'),
          tiles: <SettingsTile>[
            ...notificationTiles(UseCase.travel),
          ],
        ),
        SettingsSection(
          title: const Text('Finanzen'),
          tiles: <SettingsTile>[
            ...notificationTiles(UseCase.finance),
          ],
        ),
        SettingsSection(
          title: const Text('Entertainment'),
          tiles: <SettingsTile>[
            ...notificationTiles(UseCase.entertainment),
          ],
        ),
      ],
    );
  }

  /// Returns a list of [SettingTile] containing two tiles needed for the handling
  /// of notifications. They're the same for every use case: A boolean switch
  /// and a time picker
  List<SettingsTile> notificationTiles(UseCase useCase) {
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

    bool notificationsEnabled = StorageHandler.getValue(notificationKey);
    Time notificationTime = StorageHandler.getValue(timeKey);

    return [
      SettingsTile.switchTile(
        initialValue: notificationsEnabled,
        title: const Text("Benachrichtigungen"),
        onToggle: (value) => setState(
          () => StorageHandler.updateNotifications(useCase, value),
        ),
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
