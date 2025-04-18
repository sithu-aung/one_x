import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/bet/domain/models/three_d_live_result_response.dart';
import 'package:one_x/features/bet/presentation/screens/number_selection_3d_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:one_x/features/bet/data/repositories/bet_repository.dart';
import 'package:one_x/core/utils/api_service.dart';
import 'package:one_x/core/services/storage_service.dart';
import 'package:one_x/features/bet/domain/models/winner_list_response.dart';
import 'package:intl/intl.dart';
import 'package:one_x/features/tickets/data/repositories/ticket_repository.dart';
import 'package:one_x/features/bet/presentation/widgets/bet_history_widget.dart';
import 'package:one_x/features/bet/presentation/widgets/bet_winners_widget.dart';
import 'package:one_x/features/bet/presentation/widgets/three_d_history_numbers_widget.dart';
import 'package:one_x/features/bet/presentation/widgets/three_d_bet_history_widget.dart';
import 'package:one_x/features/bet/presentation/providers/bet_providers.dart';
import 'package:one_x/features/bet/presentation/widgets/three_d_winners_widget.dart';

class ThreeDScreen extends StatefulWidget {
  const ThreeDScreen({super.key});

  @override
  State<ThreeDScreen> createState() => _ThreeDScreenState();
}

class _ThreeDScreenState extends State<ThreeDScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  String _selectedTimeSection = '04:30 PM';

  // API data
  bool _isLoading = true;
  final bool _isWinnersLoading = false;
  bool _isLiveResultsLoading = false;
  final Map<String, dynamic> _apiData = {};
  String _currentResult = '--';
  List<dynamic> _activeSessions = [];

  // Winners data
  WinnerListResponse? _winnersData;

  // 3D Live Results data
  ThreeDLiveResultResponse? _liveResultsData;

  // Repositories
  late BetRepository _betRepository;
  late TicketRepository _ticketRepository;

  // Add date selection variable
  String? _selectedDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return; // Skip if still animating

      setState(() {
        _selectedTabIndex = _tabController.index;
      });

      // Load data when switching to the first tab or live results tab
      if (_tabController.index == 0) {
        fetch3DLiveData();
      } else if (_tabController.index == 3) {
        fetchLiveResultsData();
      }
    });

    // Initialize repositories
    final storageService = StorageService();
    final apiService = ApiService(storageService: storageService);
    _betRepository = BetRepository(
      apiService: apiService,
      storageService: storageService,
    );
    _ticketRepository = TicketRepository(
      apiService: apiService,
      storageService: storageService,
    );

    // Initialize data to avoid null issues
    _winnersData = WinnerListResponse(top3Lists: [], winners: []);
    _liveResultsData = ThreeDLiveResultResponse(results: []);

    // Set selected time section based on current time
    setDefaultTimeSection();

    // Fetch data when the screen loads
    fetch3DLiveData();
    fetchSessionStatus();
  }

  void setDefaultTimeSection() {
    // Get current time
    final now = DateTime.now();
    // If current time is before 12:00 PM, set to morning session (12:01 PM)
    // Otherwise, set to evening session (04:30 PM)
    if (now.hour < 12) {
      _selectedTimeSection = '12:01 PM';
    } else {
      _selectedTimeSection = '04:30 PM';
    }
    print('Default time section set to: $_selectedTimeSection');
  }

  Future<void> fetchSessionStatus() async {
    try {
      final dynamic response = await _betRepository.getActive3DSessions();
      print('API Response: ${jsonEncode(response)}');

      // Extract sessions from the "session" key if it exists
      List<dynamic> sessions = [];

      if (response is Map) {
        // API returns an object with a "session" key
        if (response.containsKey('session')) {
          sessions = List<dynamic>.from(response['session'] ?? []);
          print(
            'Extracted ${sessions.length} sessions from response "session" key',
          );
        }
      } else if (response is List) {
        // Direct array response
        sessions = response;
        print('Response was already a list with ${sessions.length} sessions');
      } else if (response is String) {
        // Try to parse as JSON if it's a string
        try {
          final decoded = json.decode(response);
          if (decoded is Map && decoded.containsKey('session')) {
            sessions = List<dynamic>.from(decoded['session'] ?? []);
            print(
              'Parsed string response and found ${sessions.length} sessions',
            );
          }
        } catch (e) {
          print('Failed to parse string response: $e');
        }
      } else {
        print('Unexpected response format: ${response.runtimeType}');
      }

      // If no sessions are found, use hardcoded fallback data
      if (sessions.isEmpty) {
        print('Using hardcoded fallback session data');
        sessions = [
          {
            "id": 1,
            "play_timeKey": "85ec8f67-fc44-4fd8-94e8-1bd5c80cac61",
            "start_time": "00:00:00",
            "end_time": "08:50:00",
            "session_name": "80",
            "route": "100000",
            "hot_limit": "5",
            "status": false,
            "session": "09:00AM",
            "type": "3D",
          },
          {
            "id": 2,
            "play_timeKey": "e275f906-0799-4239-aa54-739b122bebe9",
            "start_time": "00:00:00",
            "end_time": "11:50:00",
            "session_name": "morning",
            "route": "play_morning_session",
            "hot_limit": "5",
            "status": true,
            "session": "12:01PM",
            "type": "3D",
          },
          {
            "id": 3,
            "play_timeKey": "f2348158-533b-4920-adf1-48339453f607",
            "start_time": "00:00:00",
            "end_time": "01:50:00",
            "session_name": "80",
            "route": "100000",
            "hot_limit": "5",
            "status": false,
            "session": "02:00PM",
            "type": "3D",
          },
          {
            "id": 4,
            "play_timeKey": "a92690b3-dd50-4854-86ed-a550aa29e873",
            "start_time": "06:33:00",
            "end_time": "22:34:00",
            "session_name": "evening",
            "route": "play_evening_session",
            "hot_limit": "5",
            "status": true,
            "session": "04:30PM",
            "type": "3D",
          },
        ];
      }

      // Debug raw data
      print('Sessions data: ${jsonEncode(sessions)}');

      // Check first session's status type if available
      if (sessions.isNotEmpty) {
        var firstSession = sessions[0];
        print('First session: ${jsonEncode(firstSession)}');
        if (firstSession.containsKey('status')) {
          print('Status type: ${firstSession['status'].runtimeType}');
          print('Status value: ${firstSession['status']}');
        }
      }

      setState(() {
        // More flexible filtering that handles different status formats
        _activeSessions =
            sessions.where((session) {
              if (!session.containsKey('status')) return false;

              var status = session['status'];

              // Handle different possible status formats
              bool isActive = false;

              if (status is bool) {
                isActive = status;
              } else if (status is String) {
                isActive = status.toLowerCase() == 'true';
              } else if (status is int) {
                isActive = status == 1;
              }

              if (session.containsKey('session')) {
                print(
                  'Session: ${session['session']}, Status: $status, IsActive: $isActive',
                );
              }

              return isActive;
            }).toList();

        print('Active Sessions Count: ${_activeSessions.length}');
        print('Active Sessions: ${jsonEncode(_activeSessions)}');

        // If still empty, show all sessions as fallback
        if (_activeSessions.isEmpty && sessions.isNotEmpty) {
          print(
            'WARNING: No active sessions after filtering. Using all sessions as fallback.',
          );
          _activeSessions = sessions;
        }
      });
    } catch (e) {
      print('Error fetching session status: $e');
      // Show a snackbar with the error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load sessions: $e'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: fetchSessionStatus,
            ),
          ),
        );
      }
    }
  }

  Future<void> fetch3DLiveData() async {
    print("Starting fetch3DLiveData API call");

    setState(() {
      _isLoading = true;
    });

    try {
      print(
        "Calling _ticketRepository.getThreeDLiveResults() to get 3D live data",
      );

      // Use ticketRepository which has the actual implementation for the API call
      final response = await _ticketRepository.getThreeDLiveResults();

      print("API response received: $response");
      print("Response type: ${response.runtimeType}");

      // Debug the response structure to understand what's in it
      if (response.results != null && response.results!.isNotEmpty) {
        print("Response contains ${response.results!.length} results");
        print("First result details:");
        var firstResult = response.results![0];
        print("  -> toString: ${firstResult.toString()}");
        print("  -> runtime type: ${firstResult.runtimeType}");

        // Print all properties to see what we have
        print("  Properties available:");
        try {
          print("  -> number: ${firstResult.result}");
        } catch (e) {
          print("  -> number not available");
        }
        try {
          print("  -> date: ${firstResult.datetime}");
        } catch (e) {
          print("  -> date not available");
        }
        try {
          print("  -> updatedAt: ${firstResult.datetime}");
        } catch (e) {
          print("  -> updatedAt not available");
        }

        // Check all results for non-null values
        for (int i = 0; i < response.results!.length; i++) {
          var result = response.results![i];
          print("Result $i number: ${result.result}");
          if (result.result != null && result.result!.isNotEmpty) {
            // Found a good result to use
            setState(() {
              _currentResult = result.result!;
              print("Found good number result: $_currentResult");
            });
            break;
          }
        }
      } else {
        print("No results available in the response");
      }

      // Store the response for later use
      setState(() {
        _liveResultsData = response;

        if (_currentResult.isEmpty) {
          _currentResult = '--';
          print("Setting default value for current result");
        }

        _isLoading = false;
      });
    } catch (e) {
      print("Error in fetch3DLiveData: $e");
      setState(() {
        _currentResult = '--';
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load 3D live results: $e'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(label: 'Retry', onPressed: fetch3DLiveData),
          ),
        );
      }
    }
  }

  // Add fetch method for live results
  Future<void> fetchLiveResultsData() async {
    if (_isLiveResultsLoading) return; // Prevent duplicate fetches

    setState(() {
      _isLiveResultsLoading = true;
    });

    try {
      print('Fetching 3D live results data...');
      final response = await _ticketRepository.getThreeDLiveResults();

      // Update state with new data
      setState(() {
        _liveResultsData = response;
        _isLiveResultsLoading = false;
      });

      print(
        '3D live results fetched successfully with ${response.results?.length ?? 0} results',
      );
    } catch (e) {
      print('Error fetching 3D live results: $e');
      setState(() {
        _isLiveResultsLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundColor,
          title: Text('3D', style: TextStyle(color: AppTheme.textColor)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppTheme.textColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  buildFirstTabContent(),
                  const ThreeDHistoryWidget(),
                  const ThreeDWinnersWidget(),
                  _buildLiveResultsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Container(
              height: 36,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color:
                    _selectedTabIndex == 0
                        ? AppTheme.primaryColor
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border:
                    _selectedTabIndex == 0
                        ? null
                        : Border.all(color: AppTheme.primaryColor, width: 1),
              ),
              child: TextButton.icon(
                icon: Image.asset(
                  'assets/images/2D_list.png',
                  width: 16,
                  height: 16,
                  color:
                      _selectedTabIndex == 0
                          ? Colors.white
                          : AppTheme.backgroundColor == Colors.white
                          ? AppTheme.primaryColor
                          : AppTheme.textColor,
                ),
                label: Text(
                  'ထီထိုးရန်',
                  style: TextStyle(
                    color:
                        _selectedTabIndex == 0
                            ? Colors.white
                            : AppTheme.backgroundColor == Colors.white
                            ? Colors.black
                            : AppTheme.textColor,
                    fontSize: 13,
                    fontFamily: 'Pyidaungsu',
                    letterSpacing: 0.3,
                    height: 1.4,
                    leadingDistribution: TextLeadingDistribution.even,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                ),
                onPressed: () {
                  _tabController.animateTo(0);
                },
              ),
            ),
            SizedBox(width: 12),
            Container(
              height: 36,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color:
                    _selectedTabIndex == 1
                        ? AppTheme.primaryColor
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border:
                    _selectedTabIndex == 1
                        ? null
                        : Border.all(color: AppTheme.primaryColor, width: 1),
              ),
              child: TextButton.icon(
                icon: Icon(
                  Icons.card_giftcard,
                  color:
                      _selectedTabIndex == 1
                          ? Colors.white
                          : AppTheme.backgroundColor == Colors.white
                          ? AppTheme.primaryColor
                          : AppTheme.textColor,
                  size: 16,
                ),
                label: Text(
                  '3D ကံစမ်းမှတ်တမ်း',
                  style: TextStyle(
                    color:
                        _selectedTabIndex == 1
                            ? Colors.white
                            : AppTheme.backgroundColor == Colors.white
                            ? Colors.black
                            : AppTheme.textColor,
                    fontSize: 12,
                    fontFamily: 'Pyidaungsu',
                    letterSpacing: 0.3,
                    height: 1.4,
                    leadingDistribution: TextLeadingDistribution.even,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                ),
                onPressed: () {
                  _tabController.animateTo(1);
                },
              ),
            ),
            SizedBox(width: 12),
            Container(
              height: 36,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color:
                    _selectedTabIndex == 2
                        ? AppTheme.primaryColor
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border:
                    _selectedTabIndex == 2
                        ? null
                        : Border.all(color: AppTheme.primaryColor, width: 1),
              ),
              child: TextButton.icon(
                icon: Icon(
                  Icons.star,
                  color:
                      _selectedTabIndex == 2
                          ? Colors.white
                          : AppTheme.backgroundColor == Colors.white
                          ? AppTheme.primaryColor
                          : AppTheme.textColor,
                  size: 14,
                ),
                label: Text(
                  'ကံထူးရှင်များ',
                  style: TextStyle(
                    color:
                        _selectedTabIndex == 2
                            ? Colors.white
                            : AppTheme.backgroundColor == Colors.white
                            ? Colors.black
                            : AppTheme.textColor,
                    fontSize: 12,
                    fontFamily: 'Pyidaungsu',
                    letterSpacing: 0.3,
                    height: 1.4,
                    leadingDistribution: TextLeadingDistribution.even,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                ),
                onPressed: () {
                  _tabController.animateTo(2);
                },
              ),
            ),
            SizedBox(width: 12),
            Container(
              height: 36,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color:
                    _selectedTabIndex == 3
                        ? AppTheme.primaryColor
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border:
                    _selectedTabIndex == 3
                        ? null
                        : Border.all(color: AppTheme.primaryColor, width: 1),
              ),
              child: TextButton.icon(
                icon: Icon(
                  Icons.format_list_numbered,
                  color:
                      _selectedTabIndex == 3
                          ? Colors.white
                          : AppTheme.backgroundColor == Colors.white
                          ? AppTheme.primaryColor
                          : AppTheme.textColor,
                  size: 14,
                ),
                label: Text(
                  '3D ပေါက်ဂဏန်းများ',
                  style: TextStyle(
                    color:
                        _selectedTabIndex == 3
                            ? Colors.white
                            : AppTheme.backgroundColor == Colors.white
                            ? Colors.black
                            : AppTheme.textColor,
                    fontSize: 12,
                    fontFamily: 'Pyidaungsu',
                    letterSpacing: 0.3,
                    height: 1.4,
                    leadingDistribution: TextLeadingDistribution.even,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                ),
                onPressed: () {
                  _tabController.animateTo(3);
                },
              ),
            ),
            SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget buildFirstTabContent() {
    return _buildFirstTabContent();
  }

  Widget _buildFirstTabContent() {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([fetch3DLiveData(), fetchSessionStatus()]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildResultsSection(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Divider(
                color: AppTheme.textColor.withOpacity(0.1),
                height: 1,
                thickness: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            // Display live results if available
            if (_liveResultsData?.results != null &&
                _liveResultsData!.results!.length > 1)
              _buildLiveResultsList(),
            const SizedBox(height: 16),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    // Get updatedAt from the first result if available
    String updatedAt = '';
    if (_liveResultsData?.results != null &&
        _liveResultsData!.results!.isNotEmpty) {
      updatedAt =
          _liveResultsData!.results![0].datetime ??
          DateTime.now().toString().substring(0, 16);
    } else {
      updatedAt = DateTime.now().toString().substring(0, 16);
    }

    // Show the current result that was found
    return Column(
      children: [
        const SizedBox(height: 20),
        _isLoading
            ? CircularProgressIndicator(color: AppTheme.primaryColor)
            : Text(
              _currentResult,
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w900,
                color:
                    AppTheme.backgroundColor == Colors.white
                        ? const Color(0xFFFFD700)
                        : AppTheme.primaryColor,
              ),
            ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 16),
            const SizedBox(width: 4),
            Text(
              _isLoading ? 'Loading...' : 'Updated at: $updatedAt',
              style: TextStyle(color: AppTheme.textColor, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildLiveResultsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Text(
              'Recent Results',
              style: TextStyle(
                color: AppTheme.textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount:
                _liveResultsData!.results!.length > 1
                    ? _liveResultsData!.results!.length - 1
                    : 0, // Skip the first item as it's already shown at the top
            itemBuilder: (context, index) {
              // Add 1 to index to skip the first result
              final result = _liveResultsData!.results![index + 1];
              return _buildLiveResultItem(result);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLiveResultItem(Results result) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: AppTheme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date',
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result.datetime ?? 'Unknown',
                    style: TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                result.result ?? '---',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final bottomPadding = isIOS ? MediaQuery.of(context).padding.bottom : 0;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 8 + bottomPadding.toDouble(),
      ),
      child: ElevatedButton(
        onPressed: () {
          // Navigate directly to number selection screen using the first active session
          if (_activeSessions.isEmpty) {
            // Show error if no active sessions
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No active sessions available'),
                duration: const Duration(seconds: 3),
              ),
            );
            return;
          }

          // Get the first active session
          final selectedSession = _activeSessions[0];

          // Navigate to number selection screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => NumberSelection3DScreen(
                    sessionName: selectedSession['session_name'] ?? '',
                    sessionData: selectedSession,
                  ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          minimumSize: const Size(double.infinity, 45),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.3),
        ),
        child: Text(
          'ထိုးမည်',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildLiveResultsTab() {
    return RefreshIndicator(
      onRefresh: fetchLiveResultsData,
      child:
          _isLiveResultsLoading
              ? Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              )
              : _liveResultsData?.results == null ||
                  _liveResultsData!.results!.isEmpty
              ? Center(
                child: Text(
                  'No results available',
                  style: TextStyle(color: AppTheme.textColor),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _liveResultsData!.results!.length,
                itemBuilder: (context, index) {
                  final result = _liveResultsData!.results![index];
                  // Format date (if available)
                  String formattedDate = 'Unknown Date';
                  if (result.datetime != null && result.datetime!.isNotEmpty) {
                    try {
                      final DateTime date = DateTime.parse(result.datetime!);
                      formattedDate = DateFormat('yyyy-MM-dd').format(date);
                    } catch (e) {
                      formattedDate = result.datetime!;
                    }
                  }

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    color: AppTheme.cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date',
                                  style: TextStyle(
                                    color: AppTheme.textSecondaryColor,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    color: AppTheme.textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              result.result ?? '---',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
