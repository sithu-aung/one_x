import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/features/auth/presentation/providers/auth_provider.dart';
import 'package:one_x/features/home/data/models/home_model.dart';
import 'package:one_x/features/home/data/repositories/home_repository.dart';
import 'package:one_x/core/services/storage_service.dart';
import 'package:one_x/core/utils/api_service.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return HomeRepository(apiService: apiService, storageService: storageService);
});

final homeDataProvider = FutureProvider<HomeResponse>((ref) async {
  final homeRepository = ref.watch(homeRepositoryProvider);
  final authState = ref.watch(authProvider);

  if (authState.state != AuthState.authenticated) {
    throw Exception('User not authenticated');
  }

  return homeRepository.fetchHomeData();
});

// Provider for banners
final bannersProvider = Provider<List<Banner>>((ref) {
  final homeDataAsyncValue = ref.watch(homeDataProvider);

  return homeDataAsyncValue.when(
    data: (homeData) => homeData.banners,
    loading: () => [],
    error: (_, __) => [],
  );
});

// Provider for user data
final homeUserProvider = Provider<User?>((ref) {
  final homeDataAsyncValue = ref.watch(homeDataProvider);

  return homeDataAsyncValue.when(
    data: (homeData) => homeData.user,
    loading: () => null,
    error: (_, __) => null,
  );
});

// Provider for games list
final gamesProvider = Provider<List<Game>>((ref) {
  final homeDataAsyncValue = ref.watch(homeDataProvider);

  return homeDataAsyncValue.when(
    data: (homeData) => homeData.games,
    loading: () => [],
    error: (_, __) => [],
  );
});

// Provider that gives just active games
final activeGamesProvider = Provider<List<Game>>((ref) {
  final games = ref.watch(gamesProvider);

  return games.where((game) => game.isActive()).toList();
});
