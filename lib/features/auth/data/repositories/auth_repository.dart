import 'package:one_x/core/constants/app_constants.dart';
import 'package:one_x/core/services/storage_service.dart';
import 'package:one_x/core/utils/api_service.dart';
import 'package:one_x/features/auth/domain/models/user.dart';

class AuthRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthRepository({
    required ApiService apiService,
    required StorageService storageService,
  }) : _apiService = apiService,
       _storageService = storageService;

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _storageService.getAuthToken();
    return token != null;
  }

  // Check if user has seen onboarding
  Future<bool> hasSeenOnboarding() async {
    return await _storageService.hasSeenOnboarding();
  }

  // Set onboarding as completed
  Future<void> setOnboardingComplete() async {
    await _storageService.setOnboardingComplete();
  }

  // Login user
  Future<Map<String, dynamic>> login(String login, String password) async {
    try {
      final response = await _apiService.publicPost(
        AppConstants.loginEndpoint,
        body: {'login': login, 'password': password},
        returnStatusCode: true, // Request to get status code
      );

      // Check for success status code
      if (response['statusCode'] >= 200 && response['statusCode'] < 300) {
        // Save auth token on success
        await _storageService.saveAuthToken(response['data']['token']);

        // Return success result
        return {'success': true, 'statusCode': response['statusCode']};
      }

      // Return error result with status code
      return {
        'success': false,
        'statusCode': response['statusCode'],
        'message': response['data']?['message'] ?? 'Invalid credentials',
      };
    } catch (e) {
      // Handle network or other errors
      return {
        'success': false,
        'statusCode': 0,
        'message': 'Network error: Unable to connect to server',
      };
    }
  }

  // Register user
  Future<void> register({
    required String name,
    required String phone,
    required String dateOfBirth,
    required bool policy,
    required String password,
    required String passwordConfirmation,
    String? referral,
  }) async {
    await _apiService.publicPost(
      AppConstants.registerEndpoint,
      body: {
        'name': name,
        'phone': phone,
        'date_of_birth': dateOfBirth,
        'policy': policy ? 1 : 0,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'referral': referral ?? '',
      },
    );

    // Backend returns success message only, not auth data
    // User needs to login after registration
  }

  // Health check - get user profile
  Future<User?> healthCheck() async {
    // We no longer store user data locally
    return null;
  }

  // Get user profile
  Future<User> getUserProfile() async {
    final response = await _apiService.get(AppConstants.userProfile);
    return User.fromJson(response['patient']);
  }

  // Update user profile
  Future<User> updateUserProfile(Map<String, dynamic> userData) async {
    final response = await _apiService.put(
      AppConstants.updateProfile,
      body: userData,
    );

    final updatedUser = User.fromJson(response['patient']);

    // No longer save user model data

    return updatedUser;
  }

  // Logout user
  Future<void> logout() async {
    // Only clear local storage, do not call logout API
    await _storageService.clearAllData();
  }
}
