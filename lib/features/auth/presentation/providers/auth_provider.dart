import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/core/services/storage_service.dart';
import 'package:one_x/core/utils/api_service.dart';
import 'package:one_x/features/auth/data/repositories/auth_repository.dart';
import 'package:one_x/features/auth/domain/models/user.dart';

// Storage service provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// API service provider
final apiServiceProvider = Provider<ApiService>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return ApiService(storageService: storageService);
});

// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return AuthRepository(apiService: apiService, storageService: storageService);
});

// Auth state enum
enum AuthState { initial, authenticated, unauthenticated, loading, error }

// Auth state class
class AuthStateData {
  final AuthState state;
  final User? user;
  final String? errorMessage;

  AuthStateData({required this.state, this.user, this.errorMessage});

  AuthStateData copyWith({AuthState? state, User? user, String? errorMessage}) {
    return AuthStateData(
      state: state ?? this.state,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthStateData> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository)
    : super(AuthStateData(state: AuthState.initial));

  // Get remember me status
  Future<bool> getRememberMeStatus() async {
    final storageService = StorageService();
    return await storageService.getRememberMeStatus() ?? false;
  }

  // Check authentication status
  Future<void> checkAuth() async {
    try {
      final isLoggedIn = await _authRepository.isLoggedIn();

      if (isLoggedIn) {
        // We no longer store user data, just set authenticated state
        state = state.copyWith(state: AuthState.authenticated, user: null);
      } else {
        state = state.copyWith(state: AuthState.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(
        state: AuthState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Force set to authenticated state
  void setAuthenticated() {
    state = state.copyWith(
      state: AuthState.authenticated,
      user: null,
      errorMessage: null,
    );
  }

  // Force set to unauthenticated state (used for error recovery)
  void setUnauthenticated() {
    state = state.copyWith(
      state: AuthState.unauthenticated,
      user: null,
      errorMessage: null,
    );
  }

  // Check onboarding status
  Future<bool> hasSeenOnboarding() async {
    return await _authRepository.hasSeenOnboarding();
  }

  // Set onboarding as completed
  Future<void> setOnboardingComplete() async {
    await _authRepository.setOnboardingComplete();
  }

  // Login
  Future<Map<String, dynamic>> login(
    String username,
    String password,
    bool rememberMe,
  ) async {
    try {
      state = state.copyWith(state: AuthState.loading);

      // Login with the repository and get the result
      final result = await _authRepository.login(username, password);

      // Save remember me status
      final storageService = StorageService();
      await storageService.setRememberMeStatus(rememberMe);

      // If login was successful, update state
      if (result['success']) {
        state = state.copyWith(state: AuthState.authenticated, user: null);
      } else {
        // Don't update state to error since we're handling errors directly in UI
        // Just return to loading state
        state = state.copyWith(state: AuthState.unauthenticated);
      }

      // Return the result to UI
      return result;
    } catch (e) {
      // Revert to unauthenticated state
      state = state.copyWith(state: AuthState.unauthenticated);

      // Return error to UI
      return {'success': false, 'statusCode': 0, 'message': e.toString()};
    }
  }

  // Register
  Future<Map<String, dynamic>> register(RegisterFormData formData) async {
    print('=== AUTH PROVIDER REGISTER ===');
    try {
      state = state.copyWith(state: AuthState.loading, errorMessage: null);

      print('Calling repository register method...');
      final result = await _authRepository.register(
        name: formData.nameController.text,
        phone: formData.phoneController.text,
        dateOfBirth: formData.dateOfBirth,
        policy: formData.agreedToTerms,
        password: formData.passwordController.text,
        passwordConfirmation: formData.confirmPasswordController.text,
        referral: formData.referralController?.text,
      );

      print('Repository result: $result');

      if (result['success']) {
        // After successful registration, user needs to login
        state = state.copyWith(state: AuthState.unauthenticated, errorMessage: null);
        print('Registration successful, state updated to unauthenticated');
      } else {
        // Store the error message in state
        final errorMessage = result['message'];
        print('Registration failed with message: $errorMessage');
        state = state.copyWith(
          state: AuthState.error,
          errorMessage: errorMessage,
        );
      }

      return result;
    } catch (e) {
      print('=== AUTH PROVIDER REGISTER EXCEPTION ===');
      print('Exception Type: ${e.runtimeType}');
      print('Exception: $e');
      
      // Extract error message from ApiException if available
      String errorMessage = e.toString();
      if (e is ApiException) {
        print('ApiException detected');
        print('Status Code: ${e.statusCode}');
        print('Message: ${e.message}');
        print('Errors: ${e.errors}');
        
        errorMessage = e.message;
        
        // Parse validation errors for 422 responses
        if (e.statusCode == 422 && e.errors != null) {
          List<String> errorMessages = [];
          e.errors!.forEach((field, messages) {
            if (messages is List) {
              for (var message in messages) {
                errorMessages.add('$field: ${message.toString()}');
              }
            } else if (messages is String) {
              errorMessages.add('$field: $messages');
            }
          });
          if (errorMessages.isNotEmpty) {
            errorMessage = errorMessages.join('\n');
            print('Parsed validation errors: $errorMessage');
          }
        }
      }
      
      // Store the error message
      state = state.copyWith(
        state: AuthState.error,
        errorMessage: errorMessage,
      );
      
      print('Returning error result with message: $errorMessage');
      
      // Return error result
      return {
        'success': false,
        'statusCode': 0,
        'message': errorMessage,
      };
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // Unfocus any active text fields first
      FocusManager.instance.primaryFocus?.unfocus();

      state = state.copyWith(state: AuthState.loading);

      // Only clear local data, no API call
      await _authRepository.logout();

      state = state.copyWith(state: AuthState.unauthenticated, user: null);
    } catch (e) {
      // Even if logout fails, we should still log the user out locally
      state = state.copyWith(state: AuthState.unauthenticated, user: null);
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(
      state:
          state.state == AuthState.error
              ? AuthState.unauthenticated
              : state.state,
      errorMessage: null,
    );
  }
}

// Auth state provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthStateData>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

// Login form provider
class LoginFormData {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool rememberMe;

  LoginFormData({
    required this.usernameController,
    required this.passwordController,
    this.rememberMe = false,
  });

  LoginFormData copyWith({
    TextEditingController? usernameController,
    TextEditingController? passwordController,
    bool? rememberMe,
  }) {
    return LoginFormData(
      usernameController: usernameController ?? this.usernameController,
      passwordController: passwordController ?? this.passwordController,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }
}

// Login form notifier
class LoginFormNotifier extends StateNotifier<LoginFormData> {
  LoginFormNotifier()
    : super(
        LoginFormData(
          usernameController: TextEditingController(),
          passwordController: TextEditingController(),
          rememberMe: false,
        ),
      );

  void setRememberMe(bool value) {
    state = state.copyWith(rememberMe: value);
  }

  @override
  void dispose() {
    state.usernameController.dispose();
    state.passwordController.dispose();
    super.dispose();
  }
}

// Login form provider
final loginFormProvider =
    StateNotifierProvider<LoginFormNotifier, LoginFormData>((ref) {
      return LoginFormNotifier();
    });

// Register form provider
class RegisterFormData {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController? referralController;
  final String dateOfBirth;
  final bool agreedToTerms;

  RegisterFormData({
    required this.nameController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
    this.referralController,
    required this.dateOfBirth,
    required this.agreedToTerms,
  });

  RegisterFormData copyWith({
    TextEditingController? nameController,
    TextEditingController? phoneController,
    TextEditingController? passwordController,
    TextEditingController? confirmPasswordController,
    TextEditingController? referralController,
    String? dateOfBirth,
    bool? agreedToTerms,
  }) {
    return RegisterFormData(
      nameController: nameController ?? this.nameController,
      phoneController: phoneController ?? this.phoneController,
      passwordController: passwordController ?? this.passwordController,
      confirmPasswordController:
          confirmPasswordController ?? this.confirmPasswordController,
      referralController: referralController ?? this.referralController,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      agreedToTerms: agreedToTerms ?? this.agreedToTerms,
    );
  }
}

