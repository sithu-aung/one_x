import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/features/auth/presentation/providers/auth_provider.dart';
import 'package:one_x/features/twod/data/models/twod_models.dart';
import 'package:one_x/features/twod/data/repositories/twod_repository.dart';

// TwoDRepository provider
final twoDRepositoryProvider = Provider<TwoDRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return TwoDRepository(apiService: apiService, storageService: storageService);
});

// TwoD Session Status provider
final twoDSessionStatusProvider = FutureProvider<TwoDSessionStatus>((
  ref,
) async {
  final repository = ref.watch(twoDRepositoryProvider);
  return repository.getSessionStatus();
});

// TwoD Calendar provider
final twoDCalendarProvider = FutureProvider<TwoDCalendar>((ref) async {
  final repository = ref.watch(twoDRepositoryProvider);
  return repository.getCalendar();
});

// TwoD History provider
final twoDHistoryProvider = FutureProvider<TwoDHistory>((ref) async {
  final repository = ref.watch(twoDRepositoryProvider);
  return repository.getHistory();
});

// TwoD Morning Session Play Data provider
final twoDMorningSessionPlayDataProvider = FutureProvider<TwoDSessionPlayData>((
  ref,
) async {
  final repository = ref.watch(twoDRepositoryProvider);
  return repository.getMorningSessionPlayData();
});

// TwoD Morning Manual Play Data provider
final twoDMorningManualPlayDataProvider = FutureProvider<TwoDSessionPlayData>((
  ref,
) async {
  final repository = ref.watch(twoDRepositoryProvider);
  return repository.getMorningManualPlayData();
});

// TwoD Evening Session Play Data provider
final twoDEveningSessionPlayDataProvider = FutureProvider<TwoDSessionPlayData>((
  ref,
) async {
  final repository = ref.watch(twoDRepositoryProvider);
  return repository.getEveningSessionPlayData();
});

// TwoD Evening Manual Play Data provider
final twoDEveningManualPlayDataProvider = FutureProvider<TwoDSessionPlayData>((
  ref,
) async {
  final repository = ref.watch(twoDRepositoryProvider);
  return repository.getEveningManualPlayData();
});

// TwoD Morning Copy Paste Data provider
final twoDMorningCopyPasteDataProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final repository = ref.watch(twoDRepositoryProvider);
  return repository.getMorningCopyPasteData();
});

// TwoD Evening Copy Paste Data provider
final twoDEveningCopyPasteDataProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final repository = ref.watch(twoDRepositoryProvider);
  return repository.getEveningCopyPasteData();
});

// TwoD Morning Confirm Data provider
final twoDConfirmDataProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final repository = ref.watch(twoDRepositoryProvider);
  return repository.getConfirmData();
});

// TwoD Evening Confirm Data provider
final twoDEveningConfirmDataProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final repository = ref.watch(twoDRepositoryProvider);
  return repository.getEveningConfirmData();
});

// TwoD Holiday Data provider
final twoDHolidayDataProvider = FutureProvider<TwoDHoliday>((ref) async {
  final repository = ref.watch(twoDRepositoryProvider);
  return repository.getHolidayData();
});

// TwoD Winners Data provider
final twoDWinnersDataProvider = FutureProvider<TwoDWinners>((ref) async {
  final repository = ref.watch(twoDRepositoryProvider);
  return repository.getWinnersData();
});

// TwoD Submit provider - This is a family provider that takes a submit request
final twoDSubmitProvider =
    FutureProvider.family<TwoDSubmitResponse, TwoDSubmitRequest>((
      ref,
      request,
    ) async {
      final repository = ref.watch(twoDRepositoryProvider);
      return repository.submit2DBet(request);
    });
