import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'core/app_routes.dart';
import 'core/config/routes.dart';
import 'core/config/theme.dart';
import 'shared/prefs/appearance.dart';

class AIGatewayApp extends StatelessWidget {
  const AIGatewayApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AppearanceSp.instance;

    return ValueListenableBuilder(
      valueListenable: repository.themeNotifier,
      builder: (context, settings, _) {
        return DynamicColorBuilder(
          builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
            final bool useDynamic = settings.dynamicColor;

            final ColorScheme lightScheme = (useDynamic && lightDynamic != null)
                ? lightDynamic.harmonized()
                : ColorScheme.fromSeed(
                    seedColor: Color(settings.primaryColor),
                    brightness: Brightness.light,
                  ).copyWith(
                    secondary: Color(settings.secondaryColor),
                    surface: Color(settings.surfaceColor),
                  );

            final ColorScheme darkScheme = (useDynamic && darkDynamic != null)
                ? darkDynamic.harmonized()
                : ColorScheme.fromSeed(
                    seedColor: Color(settings.primaryColor),
                    brightness: Brightness.dark,
                  ).copyWith(
                    secondary: Color(settings.secondaryColor),
                    surface: Color(settings.surfaceColor),
                  );

            // Apply custom text colors if they are set (not default values)
            final Color customTextColor = Color(settings.textColor);
            final Color customTextHintColor = Color(settings.textHintColor);

            final TextTheme customLightTextTheme = TextTheme(
              bodyLarge: TextStyle(color: customTextColor),
              bodyMedium: TextStyle(color: customTextColor),
              bodySmall: TextStyle(color: customTextColor),
              labelLarge: TextStyle(color: customTextColor),
              labelMedium: TextStyle(color: customTextColor),
              labelSmall: TextStyle(color: customTextColor),
              titleLarge: TextStyle(color: customTextColor),
              titleMedium: TextStyle(color: customTextColor),
              titleSmall: TextStyle(color: customTextColor),
              headlineLarge: TextStyle(color: customTextColor),
              headlineMedium: TextStyle(color: customTextColor),
              headlineSmall: TextStyle(color: customTextColor),
              displayLarge: TextStyle(color: customTextColor),
              displayMedium: TextStyle(color: customTextColor),
              displaySmall: TextStyle(color: customTextColor),
            ).apply(bodyColor: customTextColor, displayColor: customTextColor);

            final TextTheme customDarkTextTheme = TextTheme(
              bodyLarge: TextStyle(color: customTextColor),
              bodyMedium: TextStyle(color: customTextColor),
              bodySmall: TextStyle(color: customTextColor),
              labelLarge: TextStyle(color: customTextColor),
              labelMedium: TextStyle(color: customTextColor),
              labelSmall: TextStyle(color: customTextColor),
              titleLarge: TextStyle(color: customTextColor),
              titleMedium: TextStyle(color: customTextColor),
              titleSmall: TextStyle(color: customTextColor),
              headlineLarge: TextStyle(color: customTextColor),
              headlineMedium: TextStyle(color: customTextColor),
              headlineSmall: TextStyle(color: customTextColor),
              displayLarge: TextStyle(color: customTextColor),
              displayMedium: TextStyle(color: customTextColor),
              displaySmall: TextStyle(color: customTextColor),
            ).apply(bodyColor: customTextColor, displayColor: customTextColor);

            // Update hint colors in the theme
            final InputDecorationTheme lightInputDecorationTheme =
                InputDecorationTheme(
                  hintStyle: TextStyle(color: customTextHintColor),
                );

            final InputDecorationTheme darkInputDecorationTheme =
                InputDecorationTheme(
                  hintStyle: TextStyle(color: customTextHintColor),
                );

            // Main background colors
            final Color lightMainBg = Colors.white;
            final Color darkMainBg = settings.superDarkMode
                ? Colors.black
                : const Color(0xFF121212);

            // Utilities for secondary background calculation

            Color deriveSecondaryBg(
              Brightness br,
              ColorScheme scheme,
              Color mainBg,
            ) {
              return scheme.secondaryContainer;
            }

            // Light palette surfaces
            final Color lightSecondaryBg = deriveSecondaryBg(
              Brightness.light,
              lightScheme,
              lightMainBg,
            );
            final BorderSide lightBorderSide = BorderSide(
              color: customTextHintColor,
              width: 1,
            );

            // Dark palette surfaces
            final Color darkSecondaryBg = deriveSecondaryBg(
              Brightness.dark,
              darkScheme,
              darkMainBg,
            );
            final BorderSide darkBorderSide = BorderSide(
              color: customTextHintColor,
              width: 1,
            );

            return MaterialApp(
              title: 'AI Gateway',
              debugShowCheckedModeBanner: false,
              themeMode: settings.themeMode,
              theme: ThemeData(
                colorScheme: lightScheme,
                useMaterial3: true,
                textTheme: customLightTextTheme,
                inputDecorationTheme: lightInputDecorationTheme,
                scaffoldBackgroundColor: lightMainBg,
                appBarTheme: const AppBarTheme(
                  systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.dark,
                    systemNavigationBarColor: Colors.transparent,
                    systemNavigationBarDividerColor: Colors.transparent,
                    systemNavigationBarIconBrightness: Brightness.dark,
                  ),
                ),
                dialogTheme: DialogThemeData(
                  backgroundColor: lightSecondaryBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: lightBorderSide,
                  ),
                ),
                drawerTheme: DrawerThemeData(
                  backgroundColor: lightSecondaryBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    side: lightBorderSide,
                  ),
                ),
                navigationDrawerTheme: NavigationDrawerThemeData(
                  backgroundColor: lightSecondaryBg,
                ),
                extensions: <ThemeExtension<dynamic>>[
                  SecondarySurface(
                    backgroundColor: lightSecondaryBg,
                    borderSide: lightBorderSide,
                  ),
                ],
              ),
              darkTheme: ThemeData(
                colorScheme: darkScheme,
                useMaterial3: true,
                textTheme: customDarkTextTheme,
                inputDecorationTheme: darkInputDecorationTheme,
                scaffoldBackgroundColor: darkMainBg,
                appBarTheme: const AppBarTheme(
                  systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.light,
                    systemNavigationBarColor: Colors.transparent,
                    systemNavigationBarDividerColor: Colors.transparent,
                    systemNavigationBarIconBrightness: Brightness.light,
                  ),
                ),
                dialogTheme: DialogThemeData(
                  backgroundColor: darkSecondaryBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: darkBorderSide,
                  ),
                ),
                drawerTheme: DrawerThemeData(
                  backgroundColor: darkSecondaryBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    side: darkBorderSide,
                  ),
                ),
                navigationDrawerTheme: NavigationDrawerThemeData(
                  backgroundColor: darkSecondaryBg,
                ),
                extensions: <ThemeExtension<dynamic>>[
                  SecondarySurface(
                    backgroundColor: darkSecondaryBg,
                    borderSide: darkBorderSide,
                  ),
                ],
              ),
              onGenerateRoute: generateRoute,
              initialRoute: AppRoutes.chat,
            );
          },
        );
      },
    );
  }
}
