import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/features/bet/data/repositories/bet_repository.dart';
import 'package:one_x/features/bet/domain/models/play_history_list_response.dart';
import 'package:one_x/features/bet/domain/models/winner_list_response.dart';
import 'package:one_x/core/utils/api_service.dart';
import 'package:one_x/core/services/storage_service.dart';
import 'package:one_x/features/bet/domain/models/two_d_history_response.dart';
import 'package:one_x/features/bet/domain/models/holiday_list_response.dart';

// Repository provider
final betRepositoryProvider = Provider<BetRepository>((ref) {
  final storageService = StorageService();
  final apiService = ApiService(storageService: storageService);
  return BetRepository(apiService: apiService, storageService: storageService);
});

// State for 2D history data
enum TwoDHistoryState { initial, loading, loaded, error }

// 2D history notifier
class TwoDHistoryNotifier
    extends StateNotifier<AsyncValue<PlayHistoryListResponse>> {
  final BetRepository repository;

  TwoDHistoryNotifier({required this.repository})
    : super(const AsyncValue.loading()) {
    getPlayHistory();
  }

  Future<void> getPlayHistory() async {
    try {
      state = const AsyncValue.loading();
      final response = await repository.get2DPlayHistory();
      state = AsyncValue.data(response);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// 2D history provider
final twoDHistoryProvider = StateNotifierProvider<
  TwoDHistoryNotifier,
  AsyncValue<PlayHistoryListResponse>
>((ref) {
  final repository = ref.watch(betRepositoryProvider);
  return TwoDHistoryNotifier(repository: repository);
});

// 2D winners notifier
class TwoDWinnersNotifier
    extends StateNotifier<AsyncValue<WinnerListResponse>> {
  final BetRepository repository;

  TwoDWinnersNotifier({required this.repository})
    : super(const AsyncValue.loading()) {
    getWinners();
  }

  Future<void> getWinners() async {
    try {
      state = const AsyncValue.loading();
      final response = await repository.get2DWinners();
      state = AsyncValue.data(response);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// 2D winners provider
final twoDWinnersProvider =
    StateNotifierProvider<TwoDWinnersNotifier, AsyncValue<WinnerListResponse>>((
      ref,
    ) {
      final repository = ref.watch(betRepositoryProvider);
      return TwoDWinnersNotifier(repository: repository);
    });

// 2D history winning numbers notifier
class TwoDHistoryNumbersNotifier
    extends StateNotifier<AsyncValue<TowDHistoryResponse>> {
  final BetRepository repository;

  TwoDHistoryNumbersNotifier({required this.repository})
    : super(const AsyncValue.loading()) {
    getHistoryNumbers();
  }

  Future<void> getHistoryNumbers() async {
    try {
      state = const AsyncValue.loading();
      final response = await repository.get2DHistoryNumbers();
      state = AsyncValue.data(response);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// 2D history winning numbers provider
final twoDHistoryNumbersProvider = StateNotifierProvider<
  TwoDHistoryNumbersNotifier,
  AsyncValue<TowDHistoryResponse>
>((ref) {
  final repository = ref.watch(betRepositoryProvider);
  return TwoDHistoryNumbersNotifier(repository: repository);
});

// 2D holidays notifier
class TwoDHolidaysNotifier
    extends StateNotifier<AsyncValue<HolidayListResponse>> {
  final BetRepository repository;

  TwoDHolidaysNotifier({required this.repository})
    : super(const AsyncValue.loading()) {
    getHolidays();
  }

  Future<void> getHolidays() async {
    try {
      state = const AsyncValue.loading();
      final response = await repository.get2DHolidays();
      state = AsyncValue.data(response);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// 2D holidays provider
final twoDHolidaysProvider = StateNotifierProvider<
  TwoDHolidaysNotifier,
  AsyncValue<HolidayListResponse>
>((ref) {
  final repository = ref.watch(betRepositoryProvider);
  return TwoDHolidaysNotifier(repository: repository);
});

// 3D history notifier
class ThreeDHistoryNotifier
    extends StateNotifier<AsyncValue<PlayHistoryListResponse>> {
  final BetRepository repository;

  ThreeDHistoryNotifier({required this.repository})
    : super(const AsyncValue.loading()) {
    getPlayHistory();
  }

  Future<void> getPlayHistory() async {
    try {
      state = const AsyncValue.loading();
      final response = await repository.get3DPlayHistory();
      state = AsyncValue.data(response);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// 3D history provider
final threeDHistoryProvider = StateNotifierProvider<
  ThreeDHistoryNotifier,
  AsyncValue<PlayHistoryListResponse>
>((ref) {
  final repository = ref.watch(betRepositoryProvider);
  return ThreeDHistoryNotifier(repository: repository);
});

// 3D winners notifier
class ThreeDWinnersNotifier
    extends StateNotifier<AsyncValue<WinnerListResponse>> {
  final BetRepository repository;
  String? selectedDate;

  ThreeDWinnersNotifier({required this.repository})
    : super(const AsyncValue.loading()) {
    getWinners();
  }

  Future<void> getWinners() async {
    try {
      state = const AsyncValue.loading();
      final response = await repository.get3DWinners();
      state = AsyncValue.data(response);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> getWinnersByDate(String date) async {
    try {
      selectedDate = date;
      state = const AsyncValue.loading();
      final response = await repository.get3DWinnersByDate(date);
      state = AsyncValue.data(response);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// 3D winners provider
final threeDWinnersProvider = StateNotifierProvider<
  ThreeDWinnersNotifier,
  AsyncValue<WinnerListResponse>
>((ref) {
  final repository = ref.watch(betRepositoryProvider);
  return ThreeDWinnersNotifier(repository: repository);
});
