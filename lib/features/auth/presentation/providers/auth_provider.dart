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

  // Check onboarding status
  Future<bool> hasSeenOnboarding() async {
    return await _authRepository.hasSeenOnboarding();
  }

  // Set onboarding as completed
  Future<void> setOnboardingComplete() async {
    await _authRepository.setOnboardingComplete();
  }

  // Login
  Future<void> login(String username, String password, bool rememberMe) async {
    try {
      state = state.copyWith(state: AuthState.loading);

      // Login just saves the token now, no user data
      await _authRepository.login(username, password);

      // Save remember me status
      final storageService = StorageService();
      await storageService.setRememberMeStatus(rememberMe);

      // Set authenticated state without user data
      state = state.copyWith(state: AuthState.authenticated, user: null);
    } catch (e) {
      state = state.copyWith(
        state: AuthState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Register
  Future<void> register(RegisterFormData formData) async {
    try {
      state = state.copyWith(state: AuthState.loading);

      await _authRepository.register(
        name: formData.nameController.text,
        phone: formData.phoneController.text,
        dateOfBirth: formData.dateOfBirth,
        policy: formData.agreedToTerms,
        password: formData.passwordController.text,
        passwordConfirmation: formData.confirmPasswordController.text,
        referral: formData.referralController?.text,
      );

      // After successful registration, user needs to login
      state = state.copyWith(state: AuthState.unauthenticated);
    } catch (e) {
      state = state.copyWith(
        state: AuthState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      state = state.copyWith(state: AuthState.loading);

      await _authRepository.logout();

      state = state.copyWith(state: AuthState.unauthenticated, user: null);
    } catch (e) {
      state = state.copyWith(
        state: AuthState.error,
        errorMessage: e.toString(),
      );
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
