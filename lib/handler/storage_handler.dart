import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageHandler {
  const StorageHandler._();

  static late SharedPreferences _preferences;

  static const int _maxConversationCount = 3;

  /// Initialize the handler
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    _preferences = await SharedPreferences.getInstance();
  }

  /// Tries retrieving the value of the class [T] with the given [key].
  ///
  /// If the [key] is not present, it returns the given [defaultValue].
  /// Usually, they [key] is a member of the class [SettingKeys]. This way, it is
  /// ensured, that a [defaultValue] exists.
  static T getValue<T>(String key, [T? defaultValue]) {
    // Get the persistent default value if none is given
    defaultValue = defaultValue ?? _defaultValues[key] as T;

    if (_preferences.get(key) != null) {
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
    } else {
      // Unknown class T of value
      throw TypeError();
    }
  }

  static void resetKey(String key) {
    _preferences.remove(key);
  }

  static void increaseConversations() {
    saveValue(
      SettingKeys.conversationCount,
      getValue(SettingKeys.conversationCount) + 1,
    );
  }

  static void increaseMessages() {
    saveValue(
      SettingKeys.messageCount,
      getValue(SettingKeys.messageCount) + 1,
    );
  }

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
}

class SettingKeys {
  const SettingKeys._();

  static const String userName = "userName";
  static const String previousConversations = "prevConversations";
  static const String previousConversationDates = "prevConvDate";
  static const String messageCount = "messageCount";
  static const String conversationCount = "conversationCount";
}

Map<String, dynamic> _defaultValues = {
  SettingKeys.userName: "Max Mustermann",
  SettingKeys.previousConversations: <String>[],
  SettingKeys.previousConversationDates: <String>[],
  SettingKeys.messageCount: 0,
  SettingKeys.conversationCount: 0,
};
