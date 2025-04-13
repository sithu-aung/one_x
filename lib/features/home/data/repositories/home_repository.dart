import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:one_x/core/constants/app_constants.dart';
import 'package:one_x/core/services/storage_service.dart';
import 'package:one_x/core/utils/api_service.dart';
import 'package:one_x/features/home/data/models/home_model.dart';

class HomeRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  static const String homeUserKey = 'home_user_data';
  static const String homeBannersKey = 'home_banners_data';
  static const String homeGamesKey = 'home_games_data';

  HomeRepository({
    required ApiService apiService,
    required StorageService storageService,
  }) : _apiService = apiService,
       _storageService = storageService;

  Future<HomeResponse> fetchHomeData() async {
    try {
      final response = await _apiService.get(AppConstants.homeEndpoint);
      final homeResponse = HomeResponse.fromJson(response);

      // Cache the response data
      _cacheHomeData(homeResponse);

      return homeResponse;
    } catch (e) {
      // Try cached data in case of network error
      final cachedResponse = await getCachedHomeData();
      if (cachedResponse != null) {
        return cachedResponse;
      }

      throw Exception('Error fetching home data: $e');
    }
  }

  // Cache home data for offline access
  Future<void> _cacheHomeData(HomeResponse homeResponse) async {
    try {
      // Cache user data
      final userJson = jsonEncode({
        'id': homeResponse.user.id,
        'userKey': homeResponse.user.userKey,
        'username': homeResponse.user.username,
        'balance': homeResponse.user.balance,
        'phone': homeResponse.user.phone,
        'hiddenPhone': homeResponse.user.hiddenPhone,
      });

      // Cache banners data
      final bannersJson = jsonEncode(
        homeResponse.banners
            .map(
              (banner) => {
                'id': banner.id,
                'imageLocation': banner.imageLocation,
              },
            )
            .toList(),
      );

      // Cache games data
      final gamesJson = jsonEncode(
        homeResponse.games
            .map((game) => {'game': game.game, 'status': game.status})
            .toList(),
      );

      await _storageService.write(homeUserKey, userJson);
      await _storageService.write(homeBannersKey, bannersJson);
      await _storageService.write(homeGamesKey, gamesJson);
    } catch (e) {
      debugPrint('Error caching home data: $e');
    }
  }

  // Get cached home data
  Future<HomeResponse?> getCachedHomeData() async {
    try {
      final userJson = await _storageService.read(homeUserKey);
      final bannersJson = await _storageService.read(homeBannersKey);
      final gamesJson = await _storageService.read(homeGamesKey);

      if (userJson != null && bannersJson != null && gamesJson != null) {
        final user = json.decode(userJson);
        final banners = json.decode(bannersJson) as List;
        final games = json.decode(gamesJson) as List;

        // Construct minimal home response from cached data
        return HomeResponse.fromJson({
          'user': user,
          'banners': banners,
          'games': games,
        });
      }

      return null;
    } catch (e) {
      debugPrint('Error retrieving cached home data: $e');
      return null;
    }
  }
}
