import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localePrefsKey = 'app_locale_code';

/// After a platform-channel failure (common on macOS hot restart), skip native prefs.
bool _nativePrefsUnavailable = false;

Future<SharedPreferences?> _prefsOrNull() async {
  if (_nativePrefsUnavailable) return null;
  try {
    return await SharedPreferences.getInstance().timeout(
      const Duration(seconds: 5),
    );
  } on PlatformException catch (e, st) {
    _nativePrefsUnavailable = true;
    if (kDebugMode) {
      debugPrint('SharedPreferences unavailable: $e\n$st');
    }
    return null;
  } catch (e, st) {
    _nativePrefsUnavailable = true;
    if (kDebugMode) {
      debugPrint('SharedPreferences unavailable: $e\n$st');
    }
    return null;
  }
}

/// Reads saved language code, or `null` if unavailable (caller uses default `en`).
Future<String?> readSavedLanguageCode() async {
  final prefs = await _prefsOrNull();
  if (prefs == null) return null;
  try {
    return prefs.getString(_localePrefsKey);
  } catch (e, st) {
    if (kDebugMode) {
      debugPrint('Could not read locale from prefs: $e\n$st');
    }
    return null;
  }
}

/// Persists language code; no-op when native prefs are unavailable.
Future<void> writeLanguageCode(String code) async {
  final prefs = await _prefsOrNull();
  if (prefs == null) return;
  try {
    await prefs.setString(_localePrefsKey, code);
  } catch (e, st) {
    if (kDebugMode) {
      debugPrint('Could not save locale to prefs: $e\n$st');
    }
  }
}
