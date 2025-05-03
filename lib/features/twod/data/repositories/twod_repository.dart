import 'package:one_x/core/constants/app_constants.dart';
import 'package:one_x/core/services/storage_service.dart';
import 'package:one_x/core/utils/api_service.dart';
import 'package:one_x/features/twod/data/models/twod_models.dart';

class TwoDRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  TwoDRepository({
    required ApiService apiService,
    required StorageService storageService,
  }) : _apiService = apiService,
       _storageService = storageService;

  /// Get 2D session status
  Future<TwoDSessionStatus> getSessionStatus() async {
    try {
      final response = await _apiService.post(
        AppConstants.twoDSessionStatusEndpoint,
      );
      return TwoDSessionStatus.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load 2D session status: $e');
    }
  }

  /// Submit 2D bet
  Future<TwoDSubmitResponse> submit2DBet(TwoDSubmitRequest request) async {
    try {
      final response = await _apiService.post(
        AppConstants.twoDConfirmStoreEndpoint,
        body: request.toJson(),
      );
      return TwoDSubmitResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to submit 2D bet: $e');
    }
  }

  /// Get 2D calendar
  Future<TwoDCalendar> getCalendar() async {
    try {
      final response = await _apiService.get(AppConstants.twoDCalendarEndpoint);
      return TwoDCalendar.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load 2D calendar: $e');
    }
  }

  /// Get 2D history
  Future<TwoDHistory> getHistory() async {
    try {
      final response = await _apiService.get(AppConstants.twoDHistoryEndpoint);
      return TwoDHistory.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load 2D history: $e');
    }
  }

  /// Get 2D morning session play data
  Future<TwoDSessionPlayData> getMorningSessionPlayData() async {
    try {
      final response = await _apiService.get(
        AppConstants.twoDPlayMorningSessionEndpoint,
      );
      return TwoDSessionPlayData.fromJson(response, 'morning');
    } catch (e) {
      throw Exception('Failed to load 2D morning session data: $e');
    }
  }

  /// Get 2D morning manual play data
  Future<TwoDSessionPlayData> getMorningManualPlayData() async {
    try {
      final response = await _apiService.get(
        AppConstants.twoDPlayMorningManualEndpoint,
      );
      return TwoDSessionPlayData.fromJson(response, 'morning');
    } catch (e) {
      throw Exception('Failed to load 2D morning manual data: $e');
    }
  }

  /// Get 2D evening session play data
  Future<TwoDSessionPlayData> getEveningSessionPlayData() async {
    try {
      final response = await _apiService.get(
        AppConstants.twoDPlayEveningSessionEndpoint,
      );
      return TwoDSessionPlayData.fromJson(response, 'evening');
    } catch (e) {
      throw Exception('Failed to load 2D evening session data: $e');
    }
  }

  /// Get 2D evening manual play data
  Future<TwoDSessionPlayData> getEveningManualPlayData() async {
    try {
      final response = await _apiService.get(
        AppConstants.twoDPlayEveningManualEndpoint,
      );
      return TwoDSessionPlayData.fromJson(response, 'evening');
    } catch (e) {
      throw Exception('Failed to load 2D evening manual data: $e');
    }
  }

  /// Get 2D morning copy-paste data
  Future<Map<String, dynamic>> getMorningCopyPasteData() async {
    try {
      return await _apiService.get(AppConstants.twoDCopyPasteEndpoint);
    } catch (e) {
      throw Exception('Failed to load 2D morning copy-paste data: $e');
    }
  }

  /// Get 2D evening copy-paste data
  Future<Map<String, dynamic>> getEveningCopyPasteData() async {
    try {
      return await _apiService.get(AppConstants.twoDCopyPasteEveningEndpoint);
    } catch (e) {
      throw Exception('Failed to load 2D evening copy-paste data: $e');
    }
  }

  /// Get 2D morning confirm data
  Future<Map<String, dynamic>> getConfirmData() async {
    try {
      return await _apiService.get(AppConstants.twoDConfirmEndpoint);
    } catch (e) {
      throw Exception('Failed to load 2D morning confirm data: $e');
    }
  }

  /// Get 2D evening confirm data
  Future<Map<String, dynamic>> getEveningConfirmData() async {
    try {
      return await _apiService.get(AppConstants.twoDEveningConfirmEndpoint);
    } catch (e) {
      throw Exception('Failed to load 2D evening confirm data: $e');
    }
  }

  /// Get 2D holiday data
  Future<TwoDHoliday> getHolidayData() async {
    try {
      final response = await _apiService.get(AppConstants.twoDHolidayEndpoint);
      return TwoDHoliday.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load 2D holiday data: $e');
    }
  }

  /// Get 2D winners data
  Future<TwoDWinners> getWinnersData() async {
    try {
      final response = await _apiService.get(AppConstants.twoDWinnersEndpoint);
      return TwoDWinners.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load 2D winners data: $e');
    }
  }
}
