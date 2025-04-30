import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:one_x/core/constants/app_constants.dart';
import 'package:one_x/core/services/storage_service.dart';
import 'package:one_x/core/utils/api_service.dart';
import 'package:one_x/features/bet/domain/models/play_session.dart';
import 'package:one_x/features/bet/domain/models/dream_list.dart';
import 'package:one_x/features/bet/domain/models/play_history_list_response.dart';
import 'package:one_x/features/bet/domain/models/two_d_session_status_list_response.dart';
import 'package:one_x/features/bet/domain/models/winner_list_response.dart';
import 'package:one_x/features/bet/domain/models/two_d_history_response.dart';
import 'package:one_x/features/bet/domain/models/holiday_list_response.dart';
import 'package:one_x/features/bet/domain/models/tape_hot_list_response.dart';
import 'package:one_x/features/bet/domain/models/available_response.dart';
import 'package:one_x/features/bet/domain/models/check_amount_response.dart';

class BetRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  BetRepository({
    required ApiService apiService,
    required StorageService storageService,
  }) : _apiService = apiService,
       _storageService = storageService;

  /// Get 2D live results
  Future<Map<String, dynamic>> get2DLiveResults() async {
    try {
      // Direct HTTP call for external API
      final response = await http.get(
        Uri.parse('https://luke.2dboss.com/api/luke/twod-result-live'),
      );

      print("Live Result - ${response.toString()}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> &&
            data['result'] == 1 &&
            data['message'] == 'success' &&
            data['data'] is Map<String, dynamic>) {
          return data['data'];
        } else {
          throw Exception(
            'API returned unexpected format or unsuccessful result',
          );
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching 2D live results: $e');
      // Return empty map instead of throwing to prevent app crashes
      return {};
    }
  }

  /// Get 2D session status
  Future<TwoDSessionStatusListResponse> get2DSessionStatus() async {
    try {
      final response = await _apiService.post(
        AppConstants.twoDSessionStatusEndpoint,
      );

      if (response != null) {
        return TwoDSessionStatusListResponse.fromJson(response);
      } else {
        print('API response was null for 2D session status');
        return TwoDSessionStatusListResponse(
          available: false,
          information: '',
          session: [],
        );
      }
    } catch (e) {
      print('Error fetching 2D session status: $e');
      return TwoDSessionStatusListResponse(
        available: false,
        information: '',
        session: [],
      );
    }
  }

  /// Get 3D session status
  Future<List<dynamic>> get3DSessionStatus() async {
    try {
      // Using 3D-specific endpoint once available
      final response = await _apiService.post(
        AppConstants.threeDHolidayEndpoint,
      );

      if (response != null) {
        if (response['session'] != null && response['session'] is List) {
          final sessions = response['session'] as List;
          if (sessions.isEmpty) {
            print('API returned empty 3D session list');
          }
          return sessions;
        } else {
          print(
            'API response missing "session" list field: ${response.toString().substring(0, min(100, response.toString().length))}...',
          );
          return [];
        }
      } else {
        print('API response was null for 3D session status');
        return [];
      }
    } catch (e) {
      print('Error fetching 3D session status: $e');
      return [];
    }
  }

  /// Get active 2D sessions
  Future<TwoDSessionStatusListResponse> getActive2DSessions() async {
    try {
      final response = await get2DSessionStatus();
      return response;
    } catch (e) {
      print('Error fetching active 2D sessions: $e');
      throw Exception('Failed to load active 2D sessions: $e');
    }
  }

  /// Get active 3D sessions
  Future<List<dynamic>> getActive3DSessions() async {
    try {
      final sessions = await get3DSessionStatus();
      return sessions.where((session) => session['status'] == 1).toList();
    } catch (e) {
      print('Error fetching active 3D sessions: $e');
      throw Exception('Failed to load active 3D sessions: $e');
    }
  }

  // Add new method to fetch data from a specific 2D session endpoint
  Future<Map<String, dynamic>> get2DSessionData(String endpoint) async {
    try {
      final response = await _apiService.get(endpoint);
      return response;
    } catch (error) {
      print('Error in get2DSessionData: $error');
      rethrow;
    }
  }

  // Add new method to fetch data from a specific 3D session endpoint
  Future<Map<String, dynamic>> get3DSessionData(String endpoint) async {
    try {
      final response = await _apiService.get(endpoint);
      return response;
    } catch (error) {
      print('Error in get3DSessionData: $error');
      rethrow;
    }
  }

  /// Confirm and store 2D bet placement
  Future<Map<String, dynamic>> confirm2DBetPlacement(
    Map<String, dynamic> betData,
  ) async {
    try {
      final response = await _apiService.post(
        AppConstants.twoDConfirmStoreEndpoint,
        body: betData,
      );
      return response;
    } catch (error) {
      print('Error in confirm2DBetPlacement: $error');
      // Errors have already been handled by the ApiService and displayed as SnackBar
      if (error is ApiException) {
        // Return a map with the error to avoid showing redundant messages
        return {
          'error': true,
          'message': error.message,
          'errors': error.errors,
        };
      }
      rethrow;
    }
  }

  /// Confirm and store 3D bet placement
  Future<Map<String, dynamic>> confirm3DBetPlacement(
    Map<String, dynamic> betData,
  ) async {
    try {
      final response = await _apiService.post(
        AppConstants.threeDConfirmStoreEndpoint,
        body: betData,
      );
      return response;
    } catch (error) {
      print('Error in confirm3DBetPlacement: $error');
      // Errors have already been handled by the ApiService and displayed as SnackBar
      if (error is ApiException) {
        // Return a map with the error to avoid showing redundant messages
        return {
          'error': true,
          'message': error.message,
          'errors': error.errors,
        };
      }
      rethrow;
    }
  }

  /// Get morning session play data
  Future<PlaySessionResponse> getMorningSessionPlayData(
    Map<String, dynamic> sessionData,
  ) async {
    try {
      final response = await _apiService.post(
        AppConstants.twoDPlayMorningSessionEndpoint,
        body: sessionData,
      );
      return PlaySessionResponse.fromJson(response);
    } catch (error) {
      print('Error in getMorningSessionPlayData: $error');
      // Errors are already handled by ApiService with SnackBar
      // Return empty model to avoid null errors
      return PlaySessionResponse(twoDigits: [], totalBetAmount: "0");
    }
  }

  /// Get 3D play data from the unified endpoint
  Future<PlaySessionResponse> get3DPlayData(
    Map<String, dynamic> sessionData,
  ) async {
    try {
      // Use the unified endpoint for all 3D session data with GET method
      final response = await _apiService.get(AppConstants.threeDPlay3DEndpoint);
      return PlaySessionResponse.fromJson(response);
    } catch (error) {
      print('Error in get3DPlayData: $error');
      // Errors are already handled by ApiService with SnackBar
      // Return empty model to avoid null errors
      return PlaySessionResponse(twoDigits: [], totalBetAmount: "0");
    }
  }

  /// Get morning session 3D play data
  Future<PlaySessionResponse> getMorningSession3DPlayData(
    Map<String, dynamic> sessionData,
  ) async {
    // Now simply use the unified endpoint with the existing session data
    return get3DPlayData(sessionData);
  }

  /// Get evening session play data
  Future<PlaySessionResponse> getEveningSessionPlayData(
    Map<String, dynamic> sessionData,
  ) async {
    try {
      final response = await _apiService.post(
        AppConstants.twoDPlayEveningSessionEndpoint,
        body: sessionData,
      );
      return PlaySessionResponse.fromJson(response);
    } catch (error) {
      print('Error in getEveningSessionPlayData: $error');
      // Errors are already handled by ApiService with SnackBar
      // Return empty model to avoid null errors
      return PlaySessionResponse(twoDigits: [], totalBetAmount: "0");
    }
  }

  /// Get evening session 3D play data
  Future<PlaySessionResponse> getEveningSession3DPlayData(
    Map<String, dynamic> sessionData,
  ) async {
    // Now simply use the unified endpoint with the existing session data
    return get3DPlayData(sessionData);
  }

  /// Get manual play data based on session
  Future<PlaySessionResponse> getManualPlayData(String sessionName) async {
    final endpoint =
        sessionName == 'morning'
            ? AppConstants.twoDPlayMorningManualEndpoint
            : AppConstants.twoDPlayEveningManualEndpoint;

    try {
      final response = await _apiService.get(endpoint);
      return PlaySessionResponse.fromJson(response);
    } catch (error) {
      print('Error in getManualPlayData: $error');
      // Errors are already handled by ApiService with SnackBar
      // Return empty model to avoid null errors
      return PlaySessionResponse(twoDigits: [], totalBetAmount: "0");
    }
  }

  /// Get manual 3D play data based on session
  Future<PlaySessionResponse> getManual3DPlayData(String sessionName) async {
    try {
      // Use the appropriate manual endpoint based on session name
      final endpoint =
          sessionName == 'morning'
              ? AppConstants.threeDPlayMorningManualEndpoint
              : AppConstants.threeDPlayEveningManualEndpoint;

      final response = await _apiService.get(endpoint);
      return PlaySessionResponse.fromJson(response);
    } catch (error) {
      print('Error in getManual3DPlayData: $error');
      // Errors are already handled by ApiService with SnackBar
      // Return empty model to avoid null errors
      return PlaySessionResponse(twoDigits: [], totalBetAmount: "0");
    }
  }

  /// Get slip details by invoice ID
  Future<Map<String, dynamic>> getSlipDetails(int invoiceId) async {
    try {
      final endpoint = AppConstants.showSlipEndpoint.replaceFirst(
        '{id}',
        invoiceId.toString(),
      );
      final response = await _apiService.get(endpoint);
      return response;
    } catch (error) {
      print('Error in getSlipDetails: $error');
      // Errors are already handled by ApiService with SnackBar
      // Return error information in a structured way
      return {'error': true, 'message': error.toString()};
    }
  }

  /// Process invoice data from bet confirmation
  Map<String, dynamic> processInvoiceData(Map<String, dynamic> response) {
    try {
      if (response.containsKey('invoice')) {
        return response['invoice'];
      }
      return {};
    } catch (error) {
      print('Error processing invoice data: $error');
      return {};
    }
  }

  /// Process 3D copy paste numbers
  Future<Map<String, dynamic>> process3DCopyPasteNumbers(
    Map<String, dynamic> numberData,
    bool isEvening,
  ) async {
    try {
      // Use the appropriate endpoint based on whether it's evening or morning session
      final endpoint =
          isEvening
              ? AppConstants.threeDCopyPasteEveningEndpoint
              : AppConstants.threeDCopyPasteEndpoint;

      final response = await _apiService.post(endpoint, body: numberData);
      return response;
    } catch (error) {
      print('Error in process3DCopyPasteNumbers: $error');
      // Errors are already handled by ApiService with SnackBar
      if (error is ApiException) {
        return {
          'error': true,
          'message': error.message,
          'errors': error.errors,
        };
      }
      rethrow;
    }
  }

  /// Get 2D dream numbers
  Future<DreamListResponse> get2DDreamNumbers() async {
    try {
      final response = await _apiService.get(AppConstants.twoDDreamEndpoint);
      return DreamListResponse.fromJson(response);
    } catch (error) {
      print('Error in get2DDreamNumbers: $error');
      // Errors are already handled by ApiService with SnackBar
      // Return empty model to avoid null errors
      return DreamListResponse(dreams: []);
    }
  }

  /// Get 3D dream numbers
  Future<DreamListResponse> get3DDreamNumbers() async {
    try {
      final response = await _apiService.get(AppConstants.threeDDreamEndpoint);
      return DreamListResponse.fromJson(response);
    } catch (error) {
      print('Error in get3DDreamNumbers: $error');
      // Errors are already handled by ApiService with SnackBar
      // Return empty model to avoid null errors
      return DreamListResponse(dreams: []);
    }
  }

  /// Get tape-hot list for 2D
  Future<TapeHotListResponse> get2DTapeHotList() async {
    try {
      final response = await _apiService.get(AppConstants.twoDTapeHotEndpoint);
      return TapeHotListResponse.fromJson(response);
    } catch (error) {
      print('Error in get2DTapeHotList: $error');
      // Errors are already handled by ApiService with SnackBar
      // Return empty model to avoid null errors
      return TapeHotListResponse(isTape: [], isHot: []);
    }
  }

  /// Get daily play history records for 3D
  Future<PlayHistoryListResponse> getDailyPlayHistory() async {
    try {
      print('BetRepository: Fetching 3D daily play history');
      final response = await _apiService.get(
        AppConstants.threeDHistoryDailyRecordEndpoint,
      );
      return PlayHistoryListResponse.fromJson(response);
    } catch (error) {
      print('Error in getDailyPlayHistory: $error');
      // Return empty model to avoid null errors
      return PlayHistoryListResponse(histories: []);
    }
  }

  /// Get 2D play history records
  Future<PlayHistoryListResponse> get2DPlayHistory() async {
    try {
      print('BetRepository: Fetching 2D play history');
      // Updated to use the daily record endpoint as requested
      final response = await _apiService.get(
        AppConstants
            .threeDHistoryDailyRecordEndpoint, // Using the api/user/history/daily/record endpoint
      );
      return PlayHistoryListResponse.fromJson(response);
    } catch (error) {
      print('Error in get2DPlayHistory: $error');
      // Return empty model to avoid null errors
      return PlayHistoryListResponse(histories: []);
    }
  }

  /// Get 2D winners data
  Future<WinnerListResponse> get2DWinners() async {
    try {
      print('BetRepository: Starting get2DWinners API call');
      // Changed from GET to POST method as requested
      final response = await _apiService.post(AppConstants.twoDWinnersEndpoint);
      print(
        'BetRepository: API response received: ${response.toString().substring(0, min(100, response.toString().length))}...',
      );

      // Create a response object
      final result = WinnerListResponse.fromJson(response);

      // Debug the parsed result
      print(
        'BetRepository: Parsed response - Top3: ${result.top3Lists?.length ?? 0}, Winners: ${result.winners?.length ?? 0}',
      );

      // Initialize empty lists if they're null to avoid errors elsewhere
      result.top3Lists ??= [];
      result.winners ??= [];

      return result;
    } catch (error) {
      print('BetRepository: Error in get2DWinners: $error');

      // Return empty model to avoid null errors
      return WinnerListResponse(top3Lists: [], winners: []);
    }
  }

  /// Get 3D winners data
  Future<WinnerListResponse> get3DWinners() async {
    try {
      print('BetRepository: Starting get3DWinners API call');
      // Changed from GET to POST method for consistency
      final response = await _apiService.post(
        AppConstants.threeDWinnersEndpoint,
      );
      print(
        'BetRepository: API response received: ${response.toString().substring(0, min(100, response.toString().length))}...',
      );

      // Create a response object
      final result = WinnerListResponse.fromJson(response);

      // Debug the parsed result
      print(
        'BetRepository: Parsed response - Top3: ${result.top3Lists?.length ?? 0}, Winners: ${result.winners?.length ?? 0}',
      );

      // Initialize empty lists if they're null to avoid errors elsewhere
      result.top3Lists ??= [];
      result.winners ??= [];

      return result;
    } catch (error) {
      print('BetRepository: Error in get3DWinners: $error');

      // Return empty model to avoid null errors
      return WinnerListResponse(top3Lists: [], winners: []);
    }
  }

  /// Get 3D winners data with date filter
  Future<WinnerListResponse> get3DWinnersByDate(String date) async {
    try {
      print(
        'BetRepository: Starting get3DWinnersByDate API call for date: $date',
      );
      // Use POST method with date parameter
      final response = await _apiService.post(
        AppConstants.threeDWinnersEndpoint,
        body: {"select_date": date},
      );
      print(
        'BetRepository: API response received: ${response.toString().substring(0, min(100, response.toString().length))}...',
      );

      // Create a response object
      final result = WinnerListResponse.fromJson(response);

      // Debug the parsed result
      print(
        'BetRepository: Parsed response - Top3: ${result.top3Lists?.length ?? 0}, Winners: ${result.winners?.length ?? 0}',
      );

      // Initialize empty lists if they're null to avoid errors elsewhere
      result.top3Lists ??= [];
      result.winners ??= [];

      return result;
    } catch (error) {
      print('BetRepository: Error in get3DWinnersByDate: $error');

      // Return empty model to avoid null errors
      return WinnerListResponse(top3Lists: [], winners: []);
    }
  }

  /// Get 2D winning number history data
  Future<TowDHistoryResponse> get2DHistoryNumbers() async {
    try {
      print('BetRepository: Starting get2DHistoryNumbers API call');
      final response = await _apiService.get(AppConstants.twoDHistoryEndpoint);
      print('BetRepository: 2D History API response received');

      // Create a response object
      final result = TowDHistoryResponse.fromJson(response);

      // Debug the parsed result
      print(
        'BetRepository: Parsed 2D history - Items: ${result.data?.length ?? 0}',
      );

      // Initialize empty list if it's null to avoid errors elsewhere
      result.data ??= [];

      return result;
    } catch (error) {
      print('BetRepository: Error in get2DHistoryNumbers: $error');

      // Return empty model to avoid null errors
      return TowDHistoryResponse(data: []);
    }
  }

  /// Get 2D holidays data
  Future<HolidayListResponse> get2DHolidays() async {
    try {
      print('BetRepository: Starting get2DHolidays API call');
      final response = await _apiService.get(AppConstants.twoDHolidayEndpoint);
      print('BetRepository: 2D Holidays API response received');

      // Create a response object
      final result = HolidayListResponse.fromJson(response);

      // Debug the parsed result
      print(
        'BetRepository: Parsed 2D holidays - Items: ${result.holidays?.length ?? 0}',
      );

      // Initialize empty list if it's null to avoid errors elsewhere
      result.holidays ??= [];

      return result;
    } catch (error) {
      print('BetRepository: Error in get2DHolidays: $error');

      // Return empty model to avoid null errors
      return HolidayListResponse(holidays: []);
    }
  }

  // Get 2D history
  Future<dynamic> get2DHistory() async {
    try {
      final response = await _apiService.get('/api/2d-result');
      return response;
    } catch (error) {
      print('Error fetching 2D history: $error');
      rethrow;
    }
  }

  // Get 3D history
  Future<dynamic> get3DHistory() async {
    try {
      final response = await _apiService.get('/api/3d-result');
      return response;
    } catch (error) {
      print('Error fetching 3D history: $error');
      rethrow;
    }
  }

  // Get 3D holidays
  Future<dynamic> get3DHolidays() async {
    try {
      final response = await _apiService.get('/api/3d-holidays');
      return response;
    } catch (error) {
      print('Error fetching 3D holidays: $error');
      rethrow;
    }
  }

  /// Get 3D play history records
  Future<PlayHistoryListResponse> get3DPlayHistory() async {
    try {
      print('BetRepository: Fetching 3D play history');
      final response = await _apiService.get(
        AppConstants.threeDHistoryDailyEndpoint,
      );
      return PlayHistoryListResponse.fromJson(response);
    } catch (error) {
      print('Error in get3DPlayHistory: $error');
      // Return empty model to avoid null errors
      return PlayHistoryListResponse(histories: []);
    }
  }

  /// Check 3D availability
  Future<AvailableResponse> check3DAvailability() async {
    try {
      final response = await _apiService.get(
        AppConstants.checkThreeDAvailabilityEndpoint,
      );
      return AvailableResponse.fromJson(response);
    } catch (error) {
      print('Error in check3DAvailability: $error');
      // Return empty model to avoid null errors
      return AvailableResponse(available: false);
    }
  }

  /// Check bet amounts for morning session
  Future<CheckAmountResponse> checkBetAmounts(
    Map<String, dynamic> betData,
  ) async {
    try {
      final response = await _apiService.post(
        AppConstants.twoDConfirmEndpoint,
        body: betData,
      );
      return CheckAmountResponse.fromJson(response);
    } catch (error) {
      print('Error in checkBetAmounts: $error');
      // Return empty response object to avoid null errors
      return CheckAmountResponse(
        information: error.toString(),
        selections: [],
      );
    }
  }
}
