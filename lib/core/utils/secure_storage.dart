import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Keys
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';
  static const String _themeKey = 'app_theme';

  // Save auth token
  static Future<void> saveAuthToken(String token) async {
    await _storage.write(key: _authTokenKey, value: token);
  }

  // Get auth token
  static Future<String?> getAuthToken() async {
    return await _storage.read(key: _authTokenKey);
  }

  // Save refresh token
  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  // Get refresh token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  // Save user ID
  static Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  // Get user ID
  static Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  // Save username
  static Future<void> saveUsername(String username) async {
    await _storage.write(key: _usernameKey, value: username);
  }

  // Get username
  static Future<String?> getUsername() async {
    return await _storage.read(key: _usernameKey);
  }

  // Save theme
  static Future<void> saveTheme(String themeName) async {
    await _storage.write(key: _themeKey, value: themeName);
  }

  // Get theme
  static Future<String?> getTheme() async {
    return await _storage.read(key: _themeKey);
  }

  // Clear all credentials (for logout)
  static Future<void> clearAllCredentials() async {
    await _storage.deleteAll();
  }
}
