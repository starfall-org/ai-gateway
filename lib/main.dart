import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'core/models/language_preferences.dart';
import 'core/storage/theme_repository.dart';
import 'core/storage/language_repository.dart';
import 'core/storage/app_preferences_repository.dart';
import 'core/services/custom_asset_loader.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();

  await ThemeRepository.init();

  await LanguageRepository.init();

  await AppPreferencesRepository.init();

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: SystemUiOverlay.values,
  );

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  Locale selectedLocale;
  try {
    final languageRepo = LanguageRepository.instance;
    final preferences = languageRepo.currentPreferences;

    if (preferences.autoDetectLanguage || preferences.languageCode == 'auto') {
      final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
      selectedLocale = _getSupportedLocale(deviceLocale);
    } else {
      selectedLocale = _getLocaleFromPreferences(preferences);
    }
  } catch (e) {
    debugPrint('Error loading language preferences: $e');
    selectedLocale = const Locale('en');
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('vi'),
        Locale('zh', 'CN'),
        Locale('zh', 'TW'),
        Locale('ja'),
        Locale('fr'),
        Locale('de'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      useOnlyLangCode: false,
      assetLoader: CustomAssetLoader(),
      startLocale: selectedLocale,
      child: const AIGatewayApp(),
    ),
  );
}

Locale _getSupportedLocale(Locale deviceLocale) {
  try {
    if (deviceLocale.languageCode.isEmpty) {
      return const Locale('en');
    }

    const supportedLocales = [
      Locale('en'),
      Locale('vi'),
      Locale('zh', 'CN'),
      Locale('zh', 'TW'),
      Locale('ja'),
      Locale('fr'),
      Locale('de'),
    ];

    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == deviceLocale.languageCode &&
          supportedLocale.countryCode == deviceLocale.countryCode) {
        return supportedLocale;
      }
    }

    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == deviceLocale.languageCode) {
        if (deviceLocale.languageCode == 'zh') {
          return const Locale('zh', 'CN');
        }
        return supportedLocale;
      }
    }

    return const Locale('en');
  } catch (e) {
    debugPrint('Error getting supported locale: $e');
    return const Locale('en');
  }
}

Locale _getLocaleFromPreferences(LanguagePreferences preferences) {
  try {
    if (preferences.languageCode.isEmpty) {
      return const Locale('en');
    }

    final supportedLanguages = ['en', 'vi', 'zh', 'ja', 'fr', 'de'];
    if (!supportedLanguages.contains(preferences.languageCode)) {
      return const Locale('en');
    }

    if (preferences.languageCode == 'zh') {
      if (preferences.countryCode != null &&
          (preferences.countryCode == 'CN' ||
              preferences.countryCode == 'TW')) {
        return Locale(preferences.languageCode, preferences.countryCode);
      } else {
        return const Locale('zh', 'CN'); // Default to simplified Chinese
      }
    }

    if (preferences.countryCode != null &&
        preferences.countryCode!.isNotEmpty) {
      return Locale(preferences.languageCode, preferences.countryCode);
    }

    return Locale(preferences.languageCode);
  } catch (e) {
    debugPrint('Error parsing locale from preferences: $e');
    return const Locale('en');
  }
}
