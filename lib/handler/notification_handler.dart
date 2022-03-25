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

    return UseCase.finance;
  }

  late final AndroidNotificationDetails _androidDetails;
  late final NotificationDetails _details;

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

  /// Displays a test notification
  Future<void> displayNotification(UseCase useCase) async {
    await _plugin.show(
      0,
      'Test Notification',
      'Test Notification body',
      _details,
      payload: useCase.name,
    );
  }
}
