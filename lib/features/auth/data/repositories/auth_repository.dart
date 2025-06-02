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
  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String dateOfBirth,
    required bool policy,
    required String password,
    required String passwordConfirmation,
    String? referral,
  }) async {
    try {
      print('=== REGISTER API CALL ===');
      print('Endpoint: ${AppConstants.registerEndpoint}');
      print('Request Body: {');
      print('  name: $name');
      print('  phone: $phone');
      print('  date_of_birth: $dateOfBirth');
      print('  policy: ${policy ? 1 : 0}');
      print('  referral: ${referral ?? ''}');
      print('  password: [HIDDEN]');
      print('  password_confirmation: [HIDDEN]');
      print('}');
      
      final response = await _apiService.publicPost(
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
        returnStatusCode: true,
      );

      print('=== REGISTER API RESPONSE ===');
      print('Status Code: ${response['statusCode']}');
      print('Response Data: ${response['data']}');
      
      // Check for success status code
      if (response['statusCode'] >= 200 && response['statusCode'] < 300) {
        // Check if response contains an error field (treat as error even with 200 status)
        if (response['data'] != null && response['data']['error'] != null) {
          final errorMessage = response['data']['error'];
          print('Registration Error (200 with error field): $errorMessage');
          
          return {
            'success': false,
            'statusCode': response['statusCode'],
            'message': errorMessage,
          };
        }
        
        final successMessage = response['data']?['message'] ?? 'Registration successful';
        print('Registration Success: $successMessage');
        
        return {
          'success': true,
          'statusCode': response['statusCode'],
          'message': successMessage,
        };
      }

      // Handle 422 validation errors specially
      if (response['statusCode'] == 422) {
        final errors = response['data']?['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          List<String> errorMessages = [];
          
          errors.forEach((field, messages) {
            if (messages is List && messages.isNotEmpty) {
              // Add all messages for this field
              for (var message in messages) {
                errorMessages.add(message.toString());
              }
            } else if (messages is String) {
              errorMessages.add(messages);
            }
          });
          
          final combinedMessage = errorMessages.join('\n');
          print('Validation Errors: $combinedMessage');
          
          return {
            'success': false,
            'statusCode': response['statusCode'],
            'message': combinedMessage,
          };
        }
      }

      // Return error result with status code
      final errorMessage = response['data']?['message'] ?? 'Registration failed';
      print('Registration Error: $errorMessage');
      
      return {
        'success': false,
        'statusCode': response['statusCode'],
        'message': errorMessage,
      };
    } catch (e) {
      print('=== REGISTER API EXCEPTION ===');
      print('Exception Type: ${e.runtimeType}');
      print('Exception: $e');
      
      // Re-throw to preserve error details for the provider
      rethrow;
    }
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
