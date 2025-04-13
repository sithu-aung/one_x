import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Storage keys
  static const String _tokenKey = 'auth_token';
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';
  static const String _rememberMeKey = 'remember_me';

  // Auth token methods
  Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  // Remember me status methods
  Future<void> setRememberMeStatus(bool value) async {
    await _secureStorage.write(key: _rememberMeKey, value: value.toString());
  }

  Future<bool?> getRememberMeStatus() async {
    final value = await _secureStorage.read(key: _rememberMeKey);
    return value != null ? value == 'true' : null;
  }

  // Clear only auth-related data (useful for token expiration)
  Future<void> clearAuthData() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  // Onboarding methods
  Future<void> setOnboardingComplete() async {
    await _secureStorage.write(key: _hasSeenOnboardingKey, value: 'true');
  }

  Future<bool> hasSeenOnboarding() async {
    final value = await _secureStorage.read(key: _hasSeenOnboardingKey);
    return value == 'true';
  }

  // General purpose storage methods
  Future<void> write(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _secureStorage.read(key: key);
  }

  // Clear all data (for logout)
  Future<void> clearAllData() async {
    // Get the current onboarding status before clearing
    final hasSeenOnboarding = await this.hasSeenOnboarding();

    // Clear all data
    await _secureStorage.deleteAll();

    // Restore onboarding status if it was true
    if (hasSeenOnboarding) {
      await setOnboardingComplete();
    }
  }
}
