import 'package:one_x/core/constants/app_constants.dart';
import 'package:one_x/core/services/storage_service.dart';
import 'package:one_x/core/utils/api_service.dart';
import 'package:one_x/features/threed/data/models/threed_models.dart';

class ThreeDRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  ThreeDRepository({
    required ApiService apiService,
    required StorageService storageService,
  }) : _apiService = apiService,
       _storageService = storageService;

  /// Get 3D play information
  Future<ThreeDPlayInfo> getPlayInfo() async {
    try {
      final response = await _apiService.get(AppConstants.threeDPlayEndpoint);
      return ThreeDPlayInfo.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load 3D play info: $e');
    }
  }

  /// Get 3D history
  Future<ThreeDHistory> getHistory() async {
    try {
      final response = await _apiService.get(
        AppConstants.threeDHistoryEndpoint,
      );
      return ThreeDHistory.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load 3D history: $e');
    }
  }

  /// Get 3D winning numbers
  Future<ThreeDWinningNumbers> getWinningNumbers() async {
    try {
      final response = await _apiService.get(
        AppConstants.threeDWinningNumsEndpoint,
      );
      return ThreeDWinningNumbers.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load 3D winning numbers: $e');
    }
  }

  /// Get 3D main play page data
  Future<ThreeDPlayData> get3DPlay() async {
    try {
      final response = await _apiService.get(AppConstants.threeDPlay3DEndpoint);
      return ThreeDPlayData.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load 3D play data: $e');
    }
  }

  /// Get 3D manual play page data
  Future<ThreeDManualPlayData> get3DManualPlay() async {
    try {
      final response = await _apiService.get(
        AppConstants.threeDPlayManualEndpoint,
      );
      return ThreeDManualPlayData.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load 3D manual play data: $e');
    }
  }

  /// Get 3D copy-paste play page data
  Future<ThreeDCopyPasteData> get3DCopyPaste() async {
    try {
      final response = await _apiService.get(
        AppConstants.threeDPlayCopyPasteEndpoint,
      );
      return ThreeDCopyPasteData.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load 3D copy-paste data: $e');
    }
  }

  /// Submit 3D bet
  Future<ThreeDSubmitResponse> submit3DBet(ThreeDSubmitRequest request) async {
    try {
      final response = await _apiService.post(
        AppConstants.threeDConfirmStoreEndpoint,
        body: request.toJson(),
      );
      return ThreeDSubmitResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to submit 3D bet: $e');
    }
  }

  /// Get 3D daily history records
  Future<ThreeDDailyHistory> getDailyHistory() async {
    try {
      final response = await _apiService.get(
        AppConstants.threeDHistoryDailyEndpoint,
      );
      return ThreeDDailyHistory.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load 3D daily history: $e');
    }
  }

  /// Get 3D daily record details
  Future<ThreeDDailyRecord> getDailyRecord() async {
    try {
      final response = await _apiService.get(
        AppConstants.threeDHistoryDailyRecordEndpoint,
      );
      return ThreeDDailyRecord.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load 3D daily record: $e');
    }
  }

  /// Get 3D monthly history
  Future<ThreeDMonthlyHistory> getMonthlyHistory() async {
    try {
      final response = await _apiService.get(
        AppConstants.threeDHistoryMonthlyEndpoint,
      );
      return ThreeDMonthlyHistory.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load 3D monthly history: $e');
    }
  }

  /// Get 3D first half month history
  Future<ThreeDHalfMonthlyHistory> getFirstHalfMonthHistory() async {
    try {
      final response = await _apiService.get(
        AppConstants.threeDHistoryFirstHalfMonthlyEndpoint,
      );
      return ThreeDHalfMonthlyHistory.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load 3D first half month history: $e');
    }
  }

  /// Get 3D second half month history
  Future<ThreeDHalfMonthlyHistory> getSecondHalfMonthHistory() async {
    try {
      final response = await _apiService.get(
        AppConstants.threeDHistorySecondHalfMonthlyEndpoint,
      );
      return ThreeDHalfMonthlyHistory.fromJson(response);
    } catch (e) {
      throw Exception('Failed to load 3D second half month history: $e');
    }
  }
}
