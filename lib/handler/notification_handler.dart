import 'dart:math';

import 'package:bob/handler/storage_handler.dart';
import 'package:bob/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../chat/conversation.dart';
import '../util.dart';

class NotificationHandler {
  // Private constructor
  NotificationHandler._();

  /// The instance of this handler
  static NotificationHandler? _instance;

  /// Retrieve the instance of this singleton
  static NotificationHandler get instance {
    _instance ??= NotificationHandler._();

    return _instance!;
  }

  /// Allow other components to get the instance by calling the constructor of this
  /// handler
  factory NotificationHandler() => instance;

  /// Whether the plugin is ready to use
  bool _initialized = false;

  /// The notification package instance
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// The UseCase the app was opened with. [null] if it wasn't opened via a notification
  Future<UseCase?> get launchUseCase async {
    // Check whether a notification launched the app -> Open conversation
    final NotificationAppLaunchDetails? appLaunchDetails =
        await _plugin.getNotificationAppLaunchDetails();

    if ((appLaunchDetails?.didNotificationLaunchApp ?? false) &&
        appLaunchDetails?.payload != null) {
      return useCaseFromString(appLaunchDetails!.payload!);
    }

    return null;
  }

  /// Android has to know these details, they are not really important.
  late final AndroidNotificationDetails _androidDetails;
  late final NotificationDetails _details;

  /// Maps a [UseCase] to an integer to provide unique IDs for each [UseCase]
  static const Map<UseCase, int> _idMapping = {
    UseCase.finance: 0,
    UseCase.entertainment: 1,
    UseCase.travel: 2,
    UseCase.welcome: 3,
  };

  /// Maps a string representing the title of the notification to each [UseCase]
  static const Map<UseCase, String> _titleMapping = {
    UseCase.finance: "Finanzen",
    UseCase.entertainment: "Unterhaltung",
    UseCase.travel: "Arbeitsweg",
    UseCase.welcome: "Guten Morgen!",
  };

  /// Inits the handler by calling the plugin. It has to be called before any
  /// notifications are scheduled.
  ///
  /// if [_initialized] is still false after this method, something went wrong.
  Future<void> init() async {
    if (!_initialized) {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('app_icon');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      _initialized = await _plugin.initialize(
            initializationSettings,
            onSelectNotification: _onSelectNotification,
          ) ??
          false;

      if (_initialized) {
        _androidDetails = const AndroidNotificationDetails(
          'ASWEBOB2',
          'Bob 2.0 notification channel',
          channelDescription:
              'Sends notification triggering interactive dialogs',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'ticker',
        );

        _details = NotificationDetails(android: _androidDetails);

        // Load timezones
        tz.initializeTimeZones();
        tz.setLocalLocation(tz.getLocation("Europe/Berlin"));

        print("Notifications ready: $_initialized");
        print("current time: ${tz.TZDateTime.now(tz.local)}");
      }
    }
  }

  /// This is called once a notification was clicked
  void _onSelectNotification(String? payload) {
    if (payload != null) {
      UseCase useCase = useCaseFromString(payload);
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => Conversation(startUseCase: useCase),
        ),
      );
    }
  }

  /// Displays a test notification in 5 seconds time and also at the schedule time for
  /// a random UseCase
  void testNotifications() {
    scheduleNotification(
      UseCase.values[Random().nextInt(4)],
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
    );

    scheduleNotification(
      UseCase.values[Random().nextInt(4)],
    );
  }

  /// Schedule a notification for the [UseCase useCase]. The date is specified
  /// by the valued stored in local storage
  ///
  /// The notification will repeat daily.
  Future<void> scheduleNotification(
    UseCase useCase, [
    tz.TZDateTime? date,
  ]) async {
    late tz.TZDateTime scheduledDate;

    if (date == null) {
      Time useCaseTime = StorageHandler.getUseCaseTime(useCase);
      tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        useCaseTime.hour,
        useCaseTime.minute,
        useCaseTime.second,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
    } else {
      scheduledDate = date;
    }

    print(
      "Scheduled notification for ${useCase.name} for ${scheduledDate.toIso8601String()}",
    );

    await _plugin.zonedSchedule(
      _idMapping[useCase]!,
      _titleMapping[useCase]!,
      "Klicke auf diese Nachricht, um die Routine zu starten!",
      scheduledDate,
      _details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      // Repeat daily
      matchDateTimeComponents: DateTimeComponents.time,
      payload: useCase.name,
    );
  }

  /// Remove a schedule notification to update the time of the daily repeat
  ///
  /// if [useCase] is [null], every notification will be cancelled
  void removeNotification(UseCase? useCase) {
    if (useCase != null) {
      _plugin.cancel(_idMapping[useCase]!);
    } else {
      _plugin.cancelAll();
    }
  }
}
