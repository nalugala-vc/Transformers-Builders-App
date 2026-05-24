import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_locale_storage.dart';

/// Loaded in [main] before [runApp]; avoids platform-channel races on macOS.
Locale bootstrapLocale = const Locale('en');

/// Reads saved locale — safe to call after [WidgetsFlutterBinding.ensureInitialized].
Future<Locale> loadBootstrapLocale() async {
  final code = await readSavedLanguageCode();
  return localeForCode(code ?? 'en');
}

/// Persisted app locale (`en`, `fr`, `sw`).
final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => bootstrapLocale;

  Future<void> setLanguageCode(String code) async {
    final locale = localeForCode(code);
    bootstrapLocale = locale;
    state = locale;
    await writeLanguageCode(locale.languageCode);
  }
}

Locale localeForCode(String code) => switch (code) {
      'fr' => const Locale('fr'),
      'sw' => const Locale('sw'),
      _ => const Locale('en'),
    };

/// Supported language codes for the profile picker.
const supportedLanguageCodes = ['en', 'fr', 'sw'];
