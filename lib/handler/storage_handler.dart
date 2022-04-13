import 'dart:convert';

import 'package:bob/handler/notification_handler.dart';
import 'package:bob/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageHandler {
  const StorageHandler._();

  /// Handles the communication with the device storage
  static late SharedPreferences _preferences;

  /// Specifies how many conversations should be shown in the list on the home page
  static const int _maxConversationCount = 3;

  /// Contains all api keys
  static late Map<String, dynamic> _apiKeys;

  /// Initialize the handler
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    _preferences = await SharedPreferences.getInstance();

    // Load keys from JSON
    _apiKeys = jsonDecode(
      await rootBundle.loadString("assets/api_keys.json"),
    );
  }

  /// Tries retrieving the value of the class [T] with the given [key].
  ///
  /// If the [key] is not present, it returns the given [defaultValue].
  /// Usually, they [key] is a member of the class [SettingKeys]. This way, it
  /// is ensured, that a [defaultValue] exists.
  static T getValue<T>(String key, [T? defaultValue]) {
    // Get the persistent default value if none is given
    defaultValue = defaultValue ?? _defaultValues[key] as T;

    if (_preferences.get(key) != null) {
      // Lists, Time and Places need special treatment
      if (defaultValue is List) {
        return _preferences.getStringList(key) as T;
      } else if (defaultValue is Time) {
        return TimeStringConverter.fromStorageString(
          _preferences.getString(key)!,
        ) as T;
      } else if (defaultValue is MapBoxPlace) {
        return MapBoxPlace.fromRawJson(_preferences.getString(key)!) as T;
      }
      // No special treatment needed
      return _preferences.get(key) as T;
    } else {
      // This is an unknown key, save it and return the default value
      saveValue(key, defaultValue);
      return defaultValue as T;
    }
  }

  /// Persists the [value] of a given [key] to local storage.
  ///
  /// Throws [TypeError] if the class [T] is unknown.
  static void saveValue<T>(String key, T value) {
    // Use a special method depending on the class of the value
    // Color and MirrorLayout have to be converted back to a string
    if (value is String) {
      _preferences.setString(key, value);
    } else if (value is int) {
      _preferences.setInt(key, value);
    } else if (value is bool) {
      _preferences.setBool(key, value);
    } else if (value is double) {
      _preferences.setDouble(key, value);
    } else if (value is List<String>) {
      _preferences.setStringList(key, value);
    } else if (value is Time) {
      _preferences.setString(key, value.toStorageString());
    } else if (value is MapBoxPlace) {
      _preferences.setString(key, value.toRawJson());
    } else {
      // Unknown class T of value
      throw TypeError();
    }
  }

  /// Removes the given key from local storage
  static void resetKey(String key) {
    _preferences.remove(key);
  }

  /// Increase the number of conversations
  ///
  /// Needed for the statistics on the home page
  static void increaseConversations() {
    saveValue(
      SettingKeys.conversationCount,
      getValue(SettingKeys.conversationCount) + 1,
    );
  }

  /// Increase the number of messages
  ///
  /// Needed for the statistics on the home page
  static void increaseMessages() {
    saveValue(
      SettingKeys.messageCount,
      getValue(SettingKeys.messageCount) + 1,
    );
  }

  /// Save the use case of a conversation for the "Recent conversations" list
  static void addConversation(String useCase) {
    // Save conversation in list
    List<String> previousConversations =
        getValue(SettingKeys.previousConversations);
    List<String> previousDates =
        getValue(SettingKeys.previousConversationDates);

    previousConversations.insert(0, useCase);
    previousDates.insert(0, DateTime.now().toIso8601String());

    // Trim the list to only contain as much elements as needed
    previousConversations =
        previousConversations.take(_maxConversationCount).toList();
    previousDates = previousDates.take(_maxConversationCount).toList();

    // Save them
    saveValue(SettingKeys.previousConversations, previousConversations);
    saveValue(SettingKeys.previousConversationDates, previousDates);
  }

  /// Returns the time the [useCase] should be scheduled at
  static Time getUseCaseTime(UseCase useCase) {
    switch (useCase) {
      case UseCase.welcome:
        return getValue(SettingKeys.welcomeTime);
      case UseCase.travel:
        return getValue(SettingKeys.travelTime);
      case UseCase.finances:
        return getValue(SettingKeys.financeTime);
      case UseCase.entertainment:
        return getValue(SettingKeys.entertainmentTime);
    }
  }

  /// (Re)schedule notifications for the given [useCase]
  ///
  /// if [value] is true, notifications are scheduled
  static void updateNotifications(UseCase useCase, bool value) {
    // Schedule / Remove notifications depending on values
    if (value) {
      NotificationHandler().scheduleNotification(useCase);
    } else {
      NotificationHandler().removeNotification(useCase);
    }
  }

  /// Returns the api key with the given [key] located in "assets/api_keys.json"
  ///
  /// An empty String ("") is returned, if there is no api key present with the
  /// given identifier
  static String getAPIKey(String key) {
    return _apiKeys[key] ?? "";
  }

  /// Updates the [List<String>] with the given [settingsKey] by either adding or
  /// removing the given [String value] from the list. If [selected] is true, the
  /// element will be added to the list, removed otherwise
  static void updateList(String settingsKey, String value, bool selected) {
    List<String> currentValues = getValue(settingsKey);

    if (selected) {
      currentValues.add(value);
    } else {
      currentValues.remove(value);
    }

    saveValue(settingsKey, currentValues);
  }

  /// Resets all keys with a default value in [_defaultValues]
  static void reset() {
    for (String key in _defaultValues.keys) {
      resetKey(key);
    }
  }

  /// Creates the preference-map for the backend request
  static Map<String, dynamic> getPreferences() {
    return Map.fromEntries(
      SettingKeys.preferenceKeys.map(
        (key) {
          dynamic value = getValue(key);

          // MapBoxPlace will pass their latitude and longitude
          if (value is MapBoxPlace) {
            value = value.placeName;
          }

          return MapEntry(key, value);
        },
      ),
    );
  }
}

/// Contains a string representing a unique key for every value saved in local
/// device storage
class SettingKeys {
  const SettingKeys._();

  static const String userName = "userName";
  static const String previousConversations = "prevConversations";
  static const String previousConversationDates = "prevConvDate";
  static const String messageCount = "messageCount";
  static const String conversationCount = "conversationCount";

  static const String welcomeNotification = "welcomeNotification";
  static const String welcomeTime = "welcomeTime";

  static const String travelNotification = "travelNotification";
  static const String travelTime = "travelTime";

  static const String financeNotification = "financeNotification";
  static const String financeTime = "financeTime";

  static const String entertainmentNotification = "entertainmentNotification";
  static const String entertainmentTime = "entertainmentTime";

  /// Welcome settings
  static const String raplaLink = "raplaLink";
  static const String newsCategories = "newsCategories";
  static const String weatherLocation = "weatherLocation";

  /// Travel settings
  static const String homeLocation = "homeLocation";
  static const String workingLocation = "workingLocation";
  static const String preferredVehicle = "preferredVehicle";
  static const String gasolineType = "gasolineType";

  /// Finance settings
  static const String publicBinanceApiKey = "publicBinanceApiKey";
  static const String privateBinanceApiKey = "privateBinanceApiKey";
  static const String stockIndex = "stockIndex";
  static const String stockList = "stockList";

  /// Entertainment settings
  static const String movieGenres = "movieGenres";
  static const String footballClub = "footballClub";

  /// All keys associated with a use case preference
  static List<String> get preferenceKeys => [
        userName,

        // Welcome
        raplaLink, newsCategories, weatherLocation,

        // Travel
        homeLocation, workingLocation, gasolineType,

        // Finance
        publicBinanceApiKey, privateBinanceApiKey, stockIndex, stockList,

        // Entertainment
        movieGenres, footballClub
      ];
}

// Copied from searching "Stuttgart" in the search widget
MapBoxPlace get standardLocation => MapBoxPlace(
      id: "place.5443458428087800",
      type: FeatureType.FEATURE,
      placeType: [PlaceType.place],
      addressNumber: "-1",
      properties: Properties(shortCode: null, wikidata: "Q1022", address: null),
      text: "Stuttgart",
      placeName: "Stuttgart, Baden-Württemberg, Germany",
      bbox: [
        9.038606,
        48.692024,
        9.315827,
        48.866405,
      ],
      center: [9.1775, 48.77611],
      geometry: Geometry(
        type: GeometryType.POINT,
        coordinates: [9.1775, 48.77611],
      ),
      context: [
        Context(
          id: "region.8189097311210430",
          shortCode: "DE-BW",
          wikidata: "Q985",
          text: "Baden-Württemberg",
        ),
        Context(
          id: "country.10814856728480410",
          shortCode: "de",
          wikidata: "Q183",
          text: "Germany",
        ),
      ],
      matchingText: "",
      matchingPlaceName: "",
    );

/// Sets the default values of the persisted values. Needed if there is no value
/// in the local storage with the given [SettingKeys]
Map<String, dynamic> _defaultValues = {
  SettingKeys.userName: "Max Mustermann",
  SettingKeys.previousConversations: <String>[],
  SettingKeys.previousConversationDates: <String>[],
  SettingKeys.messageCount: 0,
  SettingKeys.conversationCount: 0,
  SettingKeys.welcomeNotification: true,
  SettingKeys.welcomeTime: const Time(7),
  SettingKeys.travelNotification: true,
  SettingKeys.travelTime: const Time(8),
  SettingKeys.financeNotification: true,
  SettingKeys.financeTime: const Time(15, 30),
  SettingKeys.entertainmentNotification: true,
  SettingKeys.entertainmentTime: const Time(20, 15),

  /// welcome settings
  SettingKeys.raplaLink:
      "https://rapla.dhbw-stuttgart.de/rapla?key=txB1FOi5xd1wUJBWuX8lJhGDUgtMSFmnKLgAG_NVMhBUYcX7OIFJ2of49CgyjVbV",
  SettingKeys.newsCategories: <String>["Deutschland", "Sport"],
  SettingKeys.weatherLocation: standardLocation,

  /// Travel settings
  SettingKeys.homeLocation: standardLocation,
  SettingKeys.workingLocation: standardLocation,
  SettingKeys.preferredVehicle: "Auto",
  SettingKeys.gasolineType: "Super",

  /// Finance settings
  SettingKeys.publicBinanceApiKey: StorageHandler.getAPIKey("pubBinance"),
  SettingKeys.privateBinanceApiKey: StorageHandler.getAPIKey("privBinance"),
  SettingKeys.stockIndex: "^gdaxi",
  SettingKeys.stockList: <String>["AAPL", "TSLA", "GME", "AMZN"],

  /// Entertainment settings
  SettingKeys.movieGenres: <String>["Action", "Sci-Fi", "Game-Show"],
  SettingKeys.footballClub: "VfB Stuttgart",
};

extension TimeStringConverter on Time {
  /// Converts a time to a readable format which can easily be stored in local storage
  String toStorageString() {
    String timeString = hour < 10 ? "0$hour" : "$hour";
    timeString += ":";
    timeString += minute < 10 ? "0$minute" : "$minute";
    return timeString;
  }

  /// Creates a time object from a given string
  static Time fromStorageString(String value) {
    List<String> parts = value.split(":");
    return Time(int.parse(parts[0]), int.parse(parts[1]));
  }
}

/// Choices for gasolineType
List<DropdownMenuItem<String>> get gasolineTypes => const [
      DropdownMenuItem(
        child: Text("Diesel"),
        value: "Diesel",
      ),
      DropdownMenuItem(
        child: Text("Super"),
        value: "Super",
      ),
      DropdownMenuItem(
        child: Text("Super E10"),
        value: "Super E10",
      ),
      DropdownMenuItem(
        child: Text("Salatöl"),
        value: "Salatöl",
      )
    ];

/// Choices for preferredVehicle
List<DropdownMenuItem<String>> get preferredVehicles => const [
      DropdownMenuItem(
        child: Text("Auto"),
        value: "Auto",
      ),
      DropdownMenuItem(
        child: Text("Bahn"),
        value: "Bahn",
      ),
      DropdownMenuItem(
        child: Text("Fahrrad"),
        value: "Fahrrad",
      ),
    ];

/// Each item in this list represents a news category the user can follow and be
/// notified for
List<String> get newsCategories => [
      "Sport",
      "Coronavirus",
      "Krieg",
      "Deutschland",
      "EU",
      "Welt",
    ];

/// Each item in this list represents a movie genre the user likes and wants to
/// be notified of
List<String> get movieGenres => [
      "Action",
      "Sci-Fi",
      "Romance",
      "Comedy",
      "Animation",
      "Game-Show",
      "Reality-TV",
      "Horror",
      "Thriller"
    ];
