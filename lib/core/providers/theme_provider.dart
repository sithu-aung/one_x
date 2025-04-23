import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/core/utils/secure_storage.dart';

// Global key for app restart when theme changes
final GlobalKey<NavigatorState> appKey = GlobalKey<NavigatorState>();

// Theme state
class ThemeState {
  final ThemeType currentTheme;
  final bool isLoading;
  final UniqueKey restartKey; // Add key for forcing rebuilds

  ThemeState({
    required this.currentTheme,
    this.isLoading = false,
    UniqueKey? restartKey,
  }) : restartKey = restartKey ?? UniqueKey();

  ThemeState copyWith({
    ThemeType? currentTheme,
    bool? isLoading,
    bool forceRestart = false,
  }) {
    return ThemeState(
      currentTheme: currentTheme ?? this.currentTheme,
      isLoading: isLoading ?? this.isLoading,
      restartKey: forceRestart ? UniqueKey() : restartKey,
    );
  }
}

// Theme notifier
class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(ThemeState(currentTheme: ThemeType.whiteIndigo));

  // Load saved theme from secure storage
  Future<void> loadSavedTheme() async {
    state = state.copyWith(isLoading: true);
    try {
      final savedTheme = await SecureStorage.getTheme();
      if (savedTheme != null) {
        final themeType = _stringToThemeType(savedTheme);
        _updateTheme(
          themeType,
          forceRestart: false,
        ); // Don't restart on initial load
      }
    } catch (e) {
      // If there's an error, keep using the default theme
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Convert string to ThemeType enum
  ThemeType _stringToThemeType(String themeTypeString) {
    return ThemeType.values.firstWhere(
      (type) => type.toString() == 'ThemeType.$themeTypeString',
      orElse: () => ThemeType.whiteIndigo,
    );
  }

  // Set theme
  Future<void> setTheme(ThemeType themeType) async {
    if (themeType == state.currentTheme) return;

    _updateTheme(
      themeType,
      forceRestart: true,
    ); // Force restart when theme changes

    // Save to secure storage
    try {
      await SecureStorage.saveTheme(themeType.toString().split('.').last);
    } catch (e) {
      // Handle error
    }
  }

  // Update theme in AppTheme class and state
  void _updateTheme(ThemeType themeType, {required bool forceRestart}) {
    AppTheme.setTheme(themeType);
    state = state.copyWith(currentTheme: themeType, forceRestart: forceRestart);
  }
}

// Provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});
