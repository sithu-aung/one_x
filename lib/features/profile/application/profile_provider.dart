import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/core/constants/app_constants.dart';
import 'package:one_x/core/utils/api_service.dart';
import 'package:one_x/core/services/storage_service.dart';
import 'package:one_x/features/profile/domain/models/policy.dart';
import 'package:one_x/features/profile/domain/models/faq_list_response.dart';
import 'package:one_x/features/profile/domain/models/profile_response.dart';
import 'package:one_x/features/profile/domain/models/contact_response.dart';

// Profile Repository
class ProfileRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  ProfileRepository({
    required ApiService apiService,
    required StorageService storageService,
  }) : _apiService = apiService,
       _storageService = storageService;

  // Get user profile
  Future<UserResponse> getUserProfile() async {
    try {
      final response = await _apiService.get('/api/user/profile');
      return UserResponse.fromJson(response);
    } catch (error) {
      print('Error fetching user profile: $error');
      rethrow;
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateUserProfile({
    required String username,
    required String phone,
    String? viberPhone,
    String? telegramAccount,
  }) async {
    try {
      final response = await _apiService.post(
        '/api/user/update-profile',
        body: {
          'username': username,
          'phone': phone,
          if (viberPhone != null) 'hidden_phone': viberPhone,
          if (telegramAccount != null) 'my_referral': telegramAccount,
        },
      );
      return response;
    } catch (error) {
      print('Error updating user profile: $error');
      rethrow;
    }
  }

  // Update user profile by ID
  Future<Map<String, dynamic>> updateUserProfileByID({
    required int userId,
    String? username,
    String? phone,
    String? viberPhone,
    String? telegramAccount,
    String? dateOfBirth,
    String? email,
    String? address,
    String? country,
  }) async {
    try {
      // Create request body with non-null values
      final Map<String, dynamic> requestBody = {};
      if (username != null) requestBody['username'] = username;
      if (phone != null) requestBody['phone'] = phone;
      if (viberPhone != null) requestBody['hidden_phone'] = viberPhone;
      if (telegramAccount != null) requestBody['my_referral'] = telegramAccount;
      if (dateOfBirth != null) requestBody['date_of_birth'] = dateOfBirth;
      if (email != null) requestBody['email'] = email;
      if (address != null) requestBody['address'] = address;
      if (country != null) requestBody['country'] = country;

      final response = await _apiService.post(
        '/api/user/profile/update/$userId',
        body: requestBody,
      );
      return response;
    } catch (error) {
      print('Error updating user profile by ID: $error');
      rethrow;
    }
  }

  // Change password
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiService.post(
        '/api/user/change-password',
        body: {
          'old_password': oldPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );
      return response;
    } catch (error) {
      print('Error changing password: $error');
      rethrow;
    }
  }

  // Update password directly
  Future<Map<String, dynamic>> updatePassword({
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.post(
        '/api/user/update/password/',
        body: {'new_password': newPassword},
      );
      return response;
    } catch (error) {
      print('Error updating password: $error');
      rethrow;
    }
  }

  // Update password with user key
  Future<Map<String, dynamic>> updatePasswordWithUserKey({
    required String newPassword,
  }) async {
    try {
      // First, get the user profile to obtain the userKey
      final userProfile = await getUserProfile();
      final userKey = userProfile.user?.userKey;

      if (userKey == null) {
        throw Exception('Unable to retrieve user key from profile');
      }

      // Then make the request with the userKey in the URL path
      final response = await _apiService.post(
        '/api/user/update/password/$userKey',
        body: {'new_password': newPassword},
      );
      return response;
    } catch (error) {
      print('Error updating password with user key: $error');
      rethrow;
    }
  }

  // Get terms and conditions
  Future<PolicyResponse> getTermsConditions() async {
    try {
      final response = await _apiService.get('/api/user/terms_condition');
      return PolicyResponse.fromJson(response);
    } catch (error) {
      print('Error fetching terms and conditions: $error');
      rethrow;
    }
  }

  // Get privacy policy
  Future<PolicyResponse> getPrivacyPolicy() async {
    try {
      final response = await _apiService.get('/api/user/policies');
      return PolicyResponse.fromJson(response);
    } catch (error) {
      print('Error fetching privacy policy: $error');
      rethrow;
    }
  }

  // Get FAQs
  Future<FAQListResponse> getFAQs() async {
    try {
      final response = await _apiService.get('/api/user/faq');
      return FAQListResponse.fromJson(response);
    } catch (error) {
      print('Error fetching FAQs: $error');
      rethrow;
    }
  }

  // Get contacts
  Future<ContactResponse> getContacts() async {
    try {
      final response = await _apiService.get('/api/user/contact');
      return ContactResponse.fromJson(response);
    } catch (error) {
      print('Error fetching contacts: $error');
      rethrow;
    }
  }

  // Get user responses - REMOVED as API doesn't exist
  // Future<UserResponse> getUserResponses() async {
  //   try {
  //     final response = await _apiService.get('/api/user/responses');
  //     return UserResponse.fromJson(response);
  //   } catch (error) {
  //     print('Error fetching user responses: $error');
  //     rethrow;
  //   }
  // }
}

// Profile Repository Provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return ProfileRepository(
    apiService: apiService,
    storageService: storageService,
  );
});

// API service provider
final apiServiceProvider = Provider<ApiService>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return ApiService(storageService: storageService);
});

// Storage service provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// User Profile Provider
final userProfileProvider = FutureProvider<UserResponse>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  try {
    return await repository.getUserProfile();
  } catch (e) {
    print('Error in userProfileProvider: $e');
    rethrow;
  }
});

// Update User Profile By ID Provider
final updateUserProfileByIDProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((
      ref,
      profileData,
    ) async {
      final repository = ref.watch(profileRepositoryProvider);
      try {
        final response = await repository.updateUserProfileByID(
          userId: profileData['userId'] as int,
          username: profileData['username'] as String?,
          phone: profileData['phone'] as String?,
          viberPhone: profileData['viber_phone'] as String?,
          telegramAccount: profileData['telegram_account'] as String?,
          dateOfBirth: profileData['date_of_birth'] as String?,
          email: profileData['email'] as String?,
          address: profileData['address'] as String?,
          country: profileData['country'] as String?,
        );
        // Refresh user profile after update
        ref.refresh(userProfileProvider);
        return response;
      } catch (e) {
        print('Error in updateUserProfileByIDProvider: $e');
        rethrow;
      }
    });

// Terms and Conditions Provider
final termsConditionsProvider = FutureProvider<PolicyResponse>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  try {
    return await repository.getTermsConditions();
  } catch (e) {
    print('Error in termsConditionsProvider: $e');
    rethrow;
  }
});

// Privacy Policy Provider
final privacyPolicyProvider = FutureProvider<PolicyResponse>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  try {
    return await repository.getPrivacyPolicy();
  } catch (e) {
    print('Error in privacyPolicyProvider: $e');
    rethrow;
  }
});

// Contacts Provider
final contactsProvider = FutureProvider<ContactResponse>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  try {
    return await repository.getContacts();
  } catch (e) {
    print('Error in contactsProvider: $e');
    rethrow;
  }
});

// User Responses Provider
// final userResponsesProvider = FutureProvider<UserResponse>((ref) async {
//   final repository = ref.watch(profileRepositoryProvider);
//   try {
//     return await repository.getUserResponses();
//   } catch (e) {
//     print('Error in userResponsesProvider: $e');
//     rethrow;
//   }
// });

// Update Profile Provider
final updateProfileProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((
      ref,
      profileData,
    ) async {
      final repository = ref.watch(profileRepositoryProvider);
      try {
        final response = await repository.updateUserProfile(
          username: profileData['username'] as String,
          phone: profileData['phone'] as String,
          viberPhone: profileData['viber_phone'] as String?,
          telegramAccount: profileData['telegram_account'] as String?,
        );
        // Refresh user profile after update
        ref.refresh(userProfileProvider);
        return response;
      } catch (e) {
        print('Error in updateProfileProvider: $e');
        rethrow;
      }
    });

// Change Password Provider
final changePasswordProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((
      ref,
      passwordData,
    ) async {
      final repository = ref.watch(profileRepositoryProvider);
      try {
        final response = await repository.changePassword(
          oldPassword: passwordData['old_password'] as String,
          newPassword: passwordData['new_password'] as String,
          confirmPassword: passwordData['confirm_password'] as String,
        );
        return response;
      } catch (e) {
        print('Error in changePasswordProvider: $e');
        rethrow;
      }
    });

// Direct Password Update Provider
final updatePasswordProvider = FutureProvider.family<
  Map<String, dynamic>,
  String
>((ref, newPassword) async {
  final repository = ref.watch(profileRepositoryProvider);
  try {
    final response = await repository.updatePassword(newPassword: newPassword);
    return response;
  } catch (e) {
    print('Error in updatePasswordProvider: $e');
    rethrow;
  }
});

// Password Update with UserKey Provider
final updatePasswordWithUserKeyProvider =
    FutureProvider.family<Map<String, dynamic>, String>((
      ref,
      newPassword,
    ) async {
      final repository = ref.watch(profileRepositoryProvider);
      try {
        final response = await repository.updatePasswordWithUserKey(
          newPassword: newPassword,
        );
        return response;
      } catch (e) {
        print('Error in updatePasswordWithUserKeyProvider: $e');
        rethrow;
      }
    });
