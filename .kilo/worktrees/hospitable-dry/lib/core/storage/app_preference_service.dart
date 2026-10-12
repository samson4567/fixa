import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AppPreferenceService {
  SharedPreferences? _preferences;

  Future<void> init() async {
    if (_preferences != null) {
      return;
    }

    _preferences = await SharedPreferences.getInstance();
  }

  Future<void> saveValue<T>(String key, T value) async {
    final preferences = _requirePreferences();

    try {
      if (value is String) {
        await preferences.setString(key, value);
      } else if (value is int) {
        await preferences.setInt(key, value);
      } else if (value is bool) {
        await preferences.setBool(key, value);
      } else if (value is double) {
        await preferences.setDouble(key, value);
      } else {
        throw UnsupportedError(
          'Unsupported preference type for key "$key": ${value.runtimeType}',
        );
      }
    } catch (e) {
      debugPrint('Error saving preference "$key": $e');
      rethrow;
    }
  }

  T? getValue<T>(String key) {
    final preferences = _requirePreferences();

    try {
      if (T == String) {
        return preferences.getString(key) as T?;
      } else if (T == int) {
        return preferences.getInt(key) as T?;
      } else if (T == bool) {
        return preferences.getBool(key) as T?;
      } else if (T == double) {
        return preferences.getDouble(key) as T?;
      } else {
        throw UnsupportedError(
          'Unsupported preference type requested for key "$key": $T',
        );
      }
    } catch (e) {
      debugPrint('Error getting preference "$key": $e');
      rethrow;
    }
  }

  Future<void> removeValue(String key) async {
    final preferences = _requirePreferences();

    try {
      await preferences.remove(key);
    } catch (e) {
      debugPrint('Error removing preference "$key": $e');
      rethrow;
    }
  }

  Future<void> removeValuesWithPrefix(String prefix) async {
    final preferences = _requirePreferences();

    try {
      final keysToRemove = preferences
          .getKeys()
          .where((key) => key.startsWith(prefix))
          .toList(growable: false);
      for (final key in keysToRemove) {
        await preferences.remove(key);
      }
    } catch (e) {
      debugPrint('Error removing preferences with prefix "$prefix": $e');
      rethrow;
    }
  }

  Future<void> clearAll() async {
    final preferences = _requirePreferences();

    try {
      await preferences.clear();
    } catch (e) {
      debugPrint('Error clearing all preferences: $e');
      rethrow;
    }
  }

  SharedPreferences _requirePreferences() {
    final preferences = _preferences;
    if (preferences == null) {
      throw StateError(
        'AppPreferenceService used before init(). '
        'Ensure startup calls injector.init() first.',
      );
    }
    return preferences;
  }
}
