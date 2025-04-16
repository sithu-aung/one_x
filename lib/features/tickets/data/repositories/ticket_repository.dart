import 'package:one_x/core/constants/app_constants.dart';
import 'package:one_x/core/services/storage_service.dart';
import 'package:one_x/core/utils/api_service.dart';
import 'package:one_x/features/bet/domain/models/three_d_live_result_response.dart';
import 'package:one_x/features/tickets/domain/models/winning_record_list_response.dart';

class TicketRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  TicketRepository({
    required ApiService apiService,
    required StorageService storageService,
  }) : _apiService = apiService,
       _storageService = storageService;

  /// Fetch winning records
  Future<WinningRecordListResponse> getWinningRecords({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Format dates in the required format (YYYY-MM-DD)
      final startDateFormatted = _formatDate(startDate);
      final endDateFormatted = _formatDate(endDate);

      // Prepare request body
      final body = {
        'type': type,
        'start_date': startDateFormatted,
        'end_date': endDateFormatted,
      };

      // Call API with POST method and body
      final response = await _apiService.post(
        '/api/user/winning_record',
        body: body,
      );

      // Parse response
      final result = WinningRecordListResponse.fromJson(response);

      // Initialize empty list if null to avoid errors elsewhere
      result.winningRecord ??= [];

      return result;
    } catch (error) {
      print('TicketRepository: Error in getWinningRecords: $error');

      // Return empty model to avoid null errors
      return WinningRecordListResponse(winningRecord: []);
    }
  }

  /// Fetch 3D live results
  Future<ThreeDLiveResultResponse> getThreeDLiveResults() async {
    try {
      // Call API with GET method
      final response = await _apiService.get('/api/user/play-3d/live');

      // Parse response
      final result = ThreeDLiveResultResponse.fromJson(response);

      // Initialize empty list if null to avoid errors elsewhere
      result.results ??= [];

      return result;
    } catch (error) {
      print('TicketRepository: Error in getThreeDLiveResults: $error');

      // Return empty model to avoid null errors
      return ThreeDLiveResultResponse(results: []);
    }
  }

  // Helper method to format date as required by API
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
