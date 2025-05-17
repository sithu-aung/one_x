class AppConstants {
  // Base URL
  static const String baseUrl = 'http://13.212.81.56';

  ///'http://18.142.250.172';

  // API Endpoints - Auth
  static const String loginEndpoint = '/api/login';
  static const String registerEndpoint = '/api/register';
  static const String forgotPasswordEndpoint = '/api/forgot-password';
  static const String logoutEndpoint = '/api/logout';
  static const String healthCheck = '/api/health-check';
  static const String userProfile = '/api/profile';
  static const String updateProfile = '/api/profile';

  // API Endpoints - Home
  static const String homeEndpoint = '/api';
  static const String providerEndpoint = '/api/api-provider';

  // API Endpoints - Notifications
  static const String notificationsEndpoint = '/api/notification';
  static const String readNotificationEndpoint = '/api/notifications/{id}/read';

  // API Endpoints - SlipManagement
  static const String showSlipEndpoint = '/api/user/show_slip/{id}';

  // API Endpoints - Transaction/Payment
  static const String walletHistoryEndpoint = '/api/user/wallet-history';
  static const String transactionDetailEndpoint = '/api/user/transaction/{id}';
  static const String cancelTransactionEndpoint =
      '/api/user/transaction/cancel/{id}';
  static const String storeDepositEndpoint = '/api/user/store-deposit';
  static const String storeWithdrawEndpoint = '/api/user/store-withdraw';

  // API Endpoints - ThreeD Game
  static const String threeDPlayEndpoint = '/api/user/play';
  static const String threeDHistoryEndpoint = '/api/user/history/three';
  static const String threeDWinningNumsEndpoint =
      '/api/user/history/three_history';
  static const String threeDPlay3DEndpoint = '/api/user/play-3d';
  static const String threeDPlayManualEndpoint = '/api/user/play-three-manual';
  static const String threeDPlayCopyPasteEndpoint =
      '/api/user/play-3d/copypaste';
  static const String threeDCopyPasteEndpoint = '/api/user/play-3d/copy-paste';
  static const String threeDCopyPasteEveningEndpoint =
      '/api/user/play-3d/copy-paste/evening';
  static const String threeDConfirmStoreEndpoint =
      '/api/user/play-3d/confirm/store';
  static const String threeDHistoryDailyRecordEndpoint =
      '/api/user/history/daily/record';
  static const String threeDHistoryDailyEndpoint =
      '/api/user/history/three/daily';
  static const String threeDHistoryMonthlyEndpoint =
      '/api/user/history/three/monthly';
  static const String threeDHistoryFirstHalfMonthlyEndpoint =
      '/api/user/history/three/first-half-monthly';
  static const String threeDHistorySecondHalfMonthlyEndpoint =
      '/api/user/history/three/second-half-monthly';
  static const String checkThreeDAvailabilityEndpoint =
      '/api/user/check-threed-availability';

  // API Endpoints - TwoD Game
  static const String twoDSessionStatusEndpoint =
      '/api/user/play-2d/session-status';
  static const String twoDConfirmStoreEndpoint =
      '/api/user/play-2d/confirm/store';
  static const String twoDCalendarEndpoint = '/api/user/two/calendar';
  static const String twoDHistoryEndpoint = '/api/user/play-2d/history';
  static const String twoDPlayMorningSessionEndpoint =
      '/api/user/play-2d/play_morning_session';
  static const String twoDPlayMorningManualEndpoint =
      '/api/user/play-2d/play_morning_manual';
  static const String twoDPlayEveningSessionEndpoint =
      '/api/user/play-2d/play_evening_session';
  static const String twoDPlayEveningManualEndpoint =
      '/api/user/play-2d/play_evening_manual';
  static const String twoDCopyPasteEndpoint = '/api/user/copy-paste';
  static const String twoDCopyPasteEveningEndpoint =
      '/api/user/copy-paste/evening';
  static const String twoDConfirmEndpoint = '/api/user/play-2d/confirm';
  static const String twoDEveningConfirmEndpoint = '/api/user/evening/confirm';
  static const String twoDHolidayEndpoint = '/api/user/play-2d/holiday';
  static const String twoDWinnersEndpoint = '/api/user/play-2d/winners';
  static const String twoDTapeHotEndpoint = '/api/user/play-2d/tape-hot';

  // API Endpoints - ThreeD Game
  static const String threeDPlayMorningSessionEndpoint =
      '/api/user/play-3d/play_morning_session';
  static const String threeDPlayMorningManualEndpoint =
      '/api/user/play-3d/play_morning_manual';
  static const String threeDPlayEveningSessionEndpoint =
      '/api/user/play-3d/play_evening_session';
  static const String threeDPlayEveningManualEndpoint =
      '/api/user/play-3d/play_evening_manual';
  static const String threeDMorningConfirmEndpoint =
      '/api/user/morning/confirm';
  static const String threeDEveningConfirmEndpoint =
      '/api/user/evening/confirm';
  static const String threeDHolidayEndpoint = '/api/user/play-3d/holiday';
  static const String threeDWinnersEndpoint = '/api/user/play-3d/winners';

  // API Endpoints - Dream Numbers
  static const String twoDDreamEndpoint = '/api/user/play-2d/2d-dream';
  static const String threeDDreamEndpoint = '/api/user/play-3d/3d-dream';

  // Preferences keys
  static const String rememberMeKey = 'remember_me';
  static const String isDarkModeKey = 'is_dark_mode';
  static const String hasSeenOnboardingKey = 'has_seen_onboarding';

  // Validation regex
  static final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  static final RegExp passwordRegex = RegExp(r'^.{6,}$');

  // Error messages
  static const String networkErrorMessage =
      'Network error. Please check your internet connection.';
  static const String unknownErrorMessage =
      'An unknown error occurred. Please try again.';
  static const String invalidCredentialsMessage = 'Invalid email or password.';

  // App Version
  static const String appVersion = '1.1.8';
}
