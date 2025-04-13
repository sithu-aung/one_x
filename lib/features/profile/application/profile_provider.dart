import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/core/constants/app_constants.dart';
import 'package:one_x/core/utils/api_service.dart';
import 'package:one_x/core/services/storage_service.dart';
import 'package:one_x/features/profile/domain/models/policy.dart';
import 'package:one_x/features/profile/domain/models/faq_list_response.dart';

// Profile Repository
class ProfileRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  ProfileRepository({
    required ApiService apiService,
    required StorageService storageService,
  }) : _apiService = apiService,
       _storageService = storageService;

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
