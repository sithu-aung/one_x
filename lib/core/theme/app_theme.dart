import 'package:flutter/material.dart';

enum ThemeType {
  blackRed,
  whiteBlue,
  darkGreen,
  purpleGold,
  darkPurple,
  whitePurple,
  darkIndigo,
  whiteIndigo,
}

class ThemeConfig {
  final String name;
  final ThemeType type;
  final Color primaryColor;
  final Color accentColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color darkGrayColor;
  final Color lightGrayColor;
  final Color textColor;
  final Color textSecondaryColor;
  final Color cardColor;
  final Color cardExtraColor;

  const ThemeConfig({
    required this.name,
    required this.type,
    required this.primaryColor,
    required this.accentColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.darkGrayColor,
    required this.lightGrayColor,
    required this.textColor,
    required this.textSecondaryColor,
    required this.cardColor,
    required this.cardExtraColor,
  });

  // Predefined themes
  static const ThemeConfig blackRed = ThemeConfig(
    name: 'Black & Red',
    type: ThemeType.blackRed,
    primaryColor: Color(0xFFFF0B00), // Red
    accentColor: Color(0xFF22B2DA), // Light Blue
    secondaryColor: Color(0xFF157F1F), // Green
    backgroundColor: Color(0xFF000000), // Black
    darkGrayColor: Color(0xFF2A2B2F),
    lightGrayColor: Color(0xFFF5F5F5),
    textColor: Colors.white,
    textSecondaryColor: Color(0xFFAAAAAA),
    cardColor: Color(0xFF1C1C24),
    cardExtraColor: Color(0xFF292932),
  );

  static const ThemeConfig whiteBlue = ThemeConfig(
    name: 'White & Blue',
    type: ThemeType.whiteBlue,
    primaryColor: Color(0xFF1565C0), // Blue
    accentColor: Color(0xFF42A5F5), // Light Blue
    secondaryColor: Color(0xFF4CAF50), // Green
    backgroundColor: Colors.white, // White
    darkGrayColor: Color(0xFFEEEEEE),
    lightGrayColor: Color(0xFFF5F5F5),
    textColor: Color(0xFF212121), // Dark text for light background
    textSecondaryColor: Color(0xFF757575),
    cardColor: Colors.white,
    cardExtraColor: Color(0xFFEDEDED),
  );

  static const ThemeConfig darkGreen = ThemeConfig(
    name: 'Dark & Green',
    type: ThemeType.darkGreen,
    primaryColor: Color(0xFF4CAF50), // Green
    accentColor: Color(0xFF8BC34A), // Light Green
    secondaryColor: Color(0xFF009688), // Teal
    backgroundColor: Color(0xFF121212), // Dark
    darkGrayColor: Color(0xFF2A2B2F),
    lightGrayColor: Color(0xFFF5F5F5),
    textColor: Colors.white,
    textSecondaryColor: Color(0xFFAAAAAA),
    cardColor: Color(0xFF1D1D1D),
    cardExtraColor: Color(0xFF292929),
  );

  static const ThemeConfig purpleGold = ThemeConfig(
    name: 'Purple & Gold',
    type: ThemeType.purpleGold,
    primaryColor: Color(0xFFFFD700), // Gold
    accentColor: Color(0xFFFFC107), // Amber
    secondaryColor: Color(0xFF9C27B0), // Purple
    backgroundColor: Color(0xFF311B92), // Deep Purple
    darkGrayColor: Color(0xFF4527A0),
    lightGrayColor: Color(0xFFF5F5F5),
    textColor: Colors.white,
    textSecondaryColor: Color(0xFFD1C4E9),
    cardColor: Color(0xFF4527A0),
    cardExtraColor: Color(0xFF512DA8),
  );

  static const ThemeConfig darkPurple = ThemeConfig(
    name: 'Dark & Purple',
    type: ThemeType.darkPurple,
    primaryColor: Color(0xFF9C27B0), // Purple
    accentColor: Color(0xFFE040FB), // Light Purple
    secondaryColor: Color(0xFF7B1FA2), // Dark Purple
    backgroundColor: Color(0xFF121212), // Dark
    darkGrayColor: Color(0xFF2A2B2F),
    lightGrayColor: Color(0xFFF5F5F5),
    textColor: Colors.white,
    textSecondaryColor: Color(0xFFE1BEE7),
    cardColor: Color(0xFF1D1D1D),
    cardExtraColor: Color(0xFF292929),
  );

  static const ThemeConfig whitePurple = ThemeConfig(
    name: 'White & Purple',
    type: ThemeType.whitePurple,
    primaryColor: Color(0xFF9C27B0), // Purple
    accentColor: Color(0xFFBA68C8), // Light Purple
    secondaryColor: Color(0xFF673AB7), // Deep Purple
    backgroundColor: Colors.white, // White
    darkGrayColor: Color(0xFFEEEEEE),
    lightGrayColor: Color(0xFFF5F5F5),
    textColor: Color(0xFF212121), // Dark text for light background
    textSecondaryColor: Color(0xFF757575),
    cardColor: Colors.white,
    cardExtraColor: Color(0xFFEDEDED),
  );

  static const ThemeConfig darkIndigo = ThemeConfig(
    name: 'Dark & Indigo',
    type: ThemeType.darkIndigo,
    primaryColor: Color(0xFF7C4DFF), // Indigo
    accentColor: Color(0xFF9575CD), // Light Indigo
    secondaryColor: Color(0xFF5E35B1), // Deep Indigo
    backgroundColor: Color(0xFF121212), // Dark
    darkGrayColor: Color(0xFF2A2B2F),
    lightGrayColor: Color(0xFFF5F5F5),
    textColor: Colors.white,
    textSecondaryColor: Color(0xFFD1C4E9),
    cardColor: Color(0xFF1D1D1D),
    cardExtraColor: Color(0xFF292929),
  );

  static const ThemeConfig whiteIndigo = ThemeConfig(
    name: 'White & Indigo',
    type: ThemeType.whiteIndigo,
    primaryColor: Color(0xFF7C4DFF), // Indigo
    accentColor: Color(0xFFB39DDB), // Light Indigo
    secondaryColor: Color(0xFF5E35B1), // Deep Indigo
    backgroundColor: Colors.white, // White
    darkGrayColor: Color(0xFFEEEEEE),
    lightGrayColor: Color(0xFFF5F5F5),
    textColor: Color(0xFF212121), // Dark text for light background
    textSecondaryColor: Color(0xFF757575),
    cardColor: Colors.white, // White
    cardExtraColor: Color(0xFFEDEDED), // Light gray
  );

  static const List<ThemeConfig> availableThemes = [
    blackRed,
    whiteBlue,
    darkGreen,
    purpleGold,
    darkPurple,
    whitePurple,
    darkIndigo,
    whiteIndigo,
  ];
}

class AppTheme {
  // Current theme configuration
  static ThemeConfig currentTheme = ThemeConfig.whiteIndigo;

  // Get current theme colors directly
  static Color get primaryColor => currentTheme.primaryColor;
  static Color get accentColor => currentTheme.accentColor;
  static Color get secondaryColor => currentTheme.secondaryColor;
  static Color get backgroundColor => currentTheme.backgroundColor;
  static Color get darkGrayColor => currentTheme.darkGrayColor;
  static Color get lightGrayColor => currentTheme.lightGrayColor;
  static Color get textColor => currentTheme.textColor;
  static Color get textSecondaryColor => currentTheme.textSecondaryColor;
  static Color get cardColor => currentTheme.cardColor;
  static Color get cardExtraColor => currentTheme.cardExtraColor;

  // Create Burmese text style
  static TextStyle burmeseTextStyle({
    double fontSize = 14.0,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double letterSpacing = 0.3,
    double height = 1.4,
  }) {
    return TextStyle(
      fontFamily: 'Pyidaungsu',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? textColor,
      letterSpacing: letterSpacing,
      height: height,
      leadingDistribution: TextLeadingDistribution.even,
    );
  }

  // Change the current theme
  static void setTheme(ThemeType themeType) {
    switch (themeType) {
      case ThemeType.blackRed:
        currentTheme = ThemeConfig.blackRed;
        break;
      case ThemeType.whiteBlue:
        currentTheme = ThemeConfig.whiteBlue;
        break;
      case ThemeType.darkGreen:
        currentTheme = ThemeConfig.darkGreen;
        break;
      case ThemeType.purpleGold:
        currentTheme = ThemeConfig.purpleGold;
        break;
      case ThemeType.darkPurple:
        currentTheme = ThemeConfig.darkPurple;
        break;
      case ThemeType.whitePurple:
        currentTheme = ThemeConfig.whitePurple;
        break;
      case ThemeType.darkIndigo:
        currentTheme = ThemeConfig.darkIndigo;
        break;
      case ThemeType.whiteIndigo:
        currentTheme = ThemeConfig.whiteIndigo;
        break;
    }
  }

  // Get gradient colors for buttons based on current theme
  static List<Color> get buttonGradientColors {
    // Use consistent gradients for all themes based on whether they're light or dark
    final bool isDarkTheme =
        currentTheme.backgroundColor.computeLuminance() < 0.5;

    if (isDarkTheme) {
      // Dark mode gradient for all dark themes
      return [const Color(0xFF342E45), const Color(0xFF5A546B)];
    } else {
      // Light mode gradient for all light themes
      return [Colors.white, Colors.white];
    }
  }

  // Get button text color based on current theme
  static Color get buttonTextColor {
    // Use black text for light themes, white text for dark themes
    final bool isDarkTheme =
        currentTheme.backgroundColor.computeLuminance() < 0.5;
    return isDarkTheme ? Colors.white : Colors.black;
  }

  // Get secondary button text color (with opacity) based on current theme
  static Color get buttonSecondaryTextColor {
    // Use black text with opacity for light themes, white text with opacity for dark themes
    final bool isDarkTheme =
        currentTheme.backgroundColor.computeLuminance() < 0.5;
    return isDarkTheme
        ? Colors.white.withOpacity(0.8)
        : Colors.black.withOpacity(0.8);
  }

  // Get appropriate text color based on background color
  static Color getTextColorForBackground(Color backgroundColor) {
    // If the background is dark, use white text; if light, use black text
    return backgroundColor.computeLuminance() < 0.5
        ? Colors.white
        : Colors.black;
  }

  // Create theme data based on current theme configuration
  static ThemeData lightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: darkGrayColor,
      ),
      fontFamily: 'Roboto',
      fontFamilyFallback: const ['Pyidaungsu'],
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      cardTheme: CardTheme(
        color: cardColor,
        elevation: currentTheme.backgroundColor == Colors.white ? 8 : 0,
        shadowColor: Colors.black.withOpacity(0.2),
        margin: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1.0),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: textColor,
          fontFamily: 'Roboto',
          fontFamilyFallback: const ['Pyidaungsu'],
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: textColor,
          fontFamily: 'Roboto',
          fontFamilyFallback: const ['Pyidaungsu'],
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: textColor,
          fontFamily: 'Roboto',
          fontFamilyFallback: const ['Pyidaungsu'],
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: textColor,
          fontFamily: 'Roboto',
          fontFamilyFallback: const ['Pyidaungsu'],
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: textColor,
          fontFamily: 'Roboto',
          fontFamilyFallback: const ['Pyidaungsu'],
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: textColor,
          fontFamily: 'Roboto',
          fontFamilyFallback: const ['Pyidaungsu'],
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: textColor,
          fontFamily: 'Roboto',
          fontFamilyFallback: const ['Pyidaungsu'],
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: textColor,
          fontFamily: 'Roboto',
          fontFamilyFallback: const ['Pyidaungsu'],
        ),
        titleSmall: TextStyle(
          color: textColor,
          fontFamily: 'Roboto',
          fontFamilyFallback: const ['Pyidaungsu'],
        ),
        bodyLarge: TextStyle(
          color: textColor,
          fontFamily: 'Roboto',
          fontFamilyFallback: const ['Pyidaungsu'],
        ),
        bodyMedium: TextStyle(
          color: textColor,
          fontFamily: 'Roboto',
          fontFamilyFallback: const ['Pyidaungsu'],
        ),
        bodySmall: TextStyle(
          color: textColor,
          fontFamily: 'Roboto',
          fontFamilyFallback: const ['Pyidaungsu'],
        ),
        labelLarge: TextStyle(
          color: textColor,
          fontFamily: 'Roboto',
          fontFamilyFallback: const ['Pyidaungsu'],
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          color: textColor,
          fontFamily: 'Roboto',
          fontFamilyFallback: const ['Pyidaungsu'],
        ),
        labelSmall: TextStyle(
          color: textColor,
          fontFamily: 'Roboto',
          fontFamilyFallback: const ['Pyidaungsu'],
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkGrayColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentColor, width: 1),
        ),
        hintStyle: TextStyle(
          color: textSecondaryColor,
          fontSize: 14,
          fontFamily: 'Roboto',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textColor,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return lightGrayColor;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}
