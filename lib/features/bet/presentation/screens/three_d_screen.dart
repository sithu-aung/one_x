import 'package:flutter/material.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/bet/presentation/screens/number_selection_3d_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:one_x/features/bet/data/repositories/bet_repository.dart';
import 'package:one_x/core/utils/api_service.dart';
import 'package:one_x/core/services/storage_service.dart';
import 'package:one_x/features/bet/domain/models/winner_list_response.dart';
import 'package:intl/intl.dart';
import 'package:one_x/features/tickets/data/repositories/ticket_repository.dart';
import 'package:one_x/features/tickets/domain/models/three_d_live_result_response.dart';

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
  bool _isWinnersLoading = false;
  bool _isLiveResultsLoading = false;
  Map<String, dynamic> _apiData = {};
  String _currentResult = '--';
  List<dynamic> _activeSessions = [];

  // Winners data
  WinnerListResponse? _winnersData;

  // 3D Live Results data
  ThreeDLiveResultResponse? _liveResultsData;

  // Repositories
  late BetRepository _betRepository;
  late TicketRepository _ticketRepository;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return; // Skip if still animating

      // Get previous tab index to detect changes
      final prevIndex = _selectedTabIndex;
      final newIndex = _tabController.index;

      if (prevIndex != newIndex) {
        print('Tab changed from $prevIndex to $newIndex');

        setState(() {
          _selectedTabIndex = newIndex;

          // Reset loading states for the new tab to ensure fresh data fetch
          if (newIndex == 2) {
            _isWinnersLoading = false;
          } else if (newIndex == 3) {
            _isLiveResultsLoading = false;
          }
        });

        // Only fetch data when tab actually changes
        if (newIndex == 2) {
          print('Switching to Winners tab - triggering data fetch');
          // Slight delay to allow setState to complete before fetching
          Future.delayed(Duration(milliseconds: 50), () => _fetchWinnersData());
        } else if (newIndex == 3) {
          print('Switching to Live Results tab - triggering data fetch');
          // Slight delay to allow setState to complete before fetching
          Future.delayed(
            Duration(milliseconds: 50),
            () => _fetchLiveResultsData(),
          );
        }
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
    _setDefaultTimeSection();

    // Fetch data when the screen loads
    _fetchData();
    _fetchSessionStatus();
  }

  void _setDefaultTimeSection() {
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

  Future<void> _fetchSessionStatus() async {
    try {
      // Call 2D session status API as specified in requirements
      final dynamic response = await _betRepository.getActive2DSessions();
      print('API Response (2D session status): ${jsonEncode(response)}');

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
      print('Error fetching 2D session status: $e');
      // Show a snackbar with the error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load sessions: $e'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _fetchSessionStatus,
            ),
          ),
        );
      }
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _betRepository.get3DLiveResults();

      setState(() {
        _apiData = data;

        // Print response for debugging
        print('API Response: ${jsonEncode(_apiData)}');

        // Get the result from API response - improved extraction logic
        if (_apiData.containsKey('result_430') &&
            _apiData['result_430'] != null) {
          // Most common case - use result_430 for 4:30 PM result
          _currentResult = _apiData['result_430'].toString();
        } else if (_apiData.containsKey('result_12') &&
            _apiData['result_12'] != null) {
          // Fallback to 12:01 PM result
          _currentResult = _apiData['result_12'].toString();
        } else if (_apiData.containsKey('current_result') &&
            _apiData['current_result'] != null) {
          // Fallback to current_result field
          _currentResult = _apiData['current_result'].toString();
        } else {
          // If no result found, use placeholder
          _currentResult = '--';
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _currentResult = '--';
      });

      print('Error fetching 3D data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load 3D data: $e'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(label: 'Retry', onPressed: _fetchData),
          ),
        );
      }
    }
  }

  // Fetch winners data
  Future<void> _fetchWinnersData() async {
    print(
      'Starting to fetch 3D winners data, _isWinnersLoading=$_isWinnersLoading',
    );

    // If already loading, don't make duplicate requests
    if (_isWinnersLoading) {
      print('Already fetching 3D winners data, skipping duplicate request');
      return;
    }

    // Set loading state to true before making the API call
    if (mounted) {
      setState(() {
        _isWinnersLoading = true;
      });
    }

    try {
      print('Making API call to get 3D winners');
      final response = await _betRepository.get3DWinners();
      print(
        'Received 3D winners response: ${response.winners?.length ?? 0} winners, ${response.top3Lists?.length ?? 0} top3 entries',
      );

      // Only update state if widget is still mounted
      if (mounted) {
        setState(() {
          _winnersData = response;
          _isWinnersLoading = false;
        });
      }
    } catch (error) {
      print('Error fetching 3D winners data: $error');
      // Only update state if widget is still mounted
      if (mounted) {
        setState(() {
          // Initialize with empty lists to prevent null errors
          _winnersData = WinnerListResponse(winners: [], top3Lists: []);
          _isWinnersLoading = false;
        });

        // Show error message with retry option
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to load 3D winners data'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _fetchWinnersData,
            ),
          ),
        );
      }
    }
  }

  // Add fetch method for live results
  Future<void> _fetchLiveResultsData() async {
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
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('3D Lottery'),
        backgroundColor: AppTheme.appBarColor,
        foregroundColor: AppTheme.textColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondaryColor,
          tabs: const [
            Tab(text: 'Play Now'),
            Tab(text: 'Results'),
            Tab(text: 'Winners'),
            Tab(text: 'Live Results'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlayTab(),
          _buildResultsTab(),
          _buildWinnersTab(),
          _buildLiveResultsTab(),
        ],
      ),
    );
  }

  Widget _buildPlayTab() {
    return _buildFirstTabContent();
  }

  Widget _buildResultsTab() {
    return _buildSecondTabContent();
  }

  Widget _buildWinnersTab() {
    return _buildThirdTabContent();
  }

  Widget _buildFirstTabContent() {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([_fetchData(), _fetchSessionStatus()]);
      },
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
          Expanded(
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildTimeResultCard('12:01 PM', '12'),
                  _buildTimeResultCard('04:30 PM', '430'),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    // Calculate dynamic sizes based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final centerBlockWidth = screenWidth * 0.5;
    final sideBlockWidth = (screenWidth - centerBlockWidth) / 2;

    // Determine if we're in a white/light theme
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // Time section selection buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTimeSection = '12:01 PM';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color:
                            _selectedTimeSection == '12:01 PM'
                                ? AppTheme.primaryColor
                                : (isLightTheme
                                    ? Colors.grey.shade200
                                    : const Color(0xFF1E1E1E)),
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(8),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '12:01 PM',
                          style: TextStyle(
                            color:
                                _selectedTimeSection == '12:01 PM'
                                    ? Colors.white
                                    : AppTheme.textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTimeSection = '04:30 PM';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color:
                            _selectedTimeSection == '04:30 PM'
                                ? AppTheme.primaryColor
                                : (isLightTheme
                                    ? Colors.grey.shade200
                                    : const Color(0xFF1E1E1E)),
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(8),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '04:30 PM',
                          style: TextStyle(
                            color:
                                _selectedTimeSection == '04:30 PM'
                                    ? Colors.white
                                    : AppTheme.textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Hero section with 3D Result
          Stack(
            alignment: Alignment.center,
            children: [
              // Background image/graphic
              Container(
                width: double.infinity,
                height: 200,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.backgroundColor == Colors.white
                          ? const Color(0xFFF8F9FA)
                          : const Color(0xFF2A2A2A),
                      AppTheme.backgroundColor == Colors.white
                          ? const Color(0xFFF1F3F5)
                          : const Color(0xFF232323),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow:
                      isLightTheme
                          ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ]
                          : null,
                ),
                child: Stack(
                  children: [
                    // Left decorative element
                    Positioned(
                      top: 20,
                      left: 20,
                      child: Container(
                        width: sideBlockWidth,
                        height: 30,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppTheme.primaryColor.withOpacity(0.7),
                              AppTheme.primaryColor.withOpacity(0.5),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 3),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Right decorative element
                    Positioned(
                      top: 60,
                      right: 20,
                      child: Container(
                        width: sideBlockWidth,
                        height: 30,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppTheme.primaryColor.withOpacity(0.7),
                              AppTheme.primaryColor.withOpacity(0.5),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 3),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom decorative element (center)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: centerBlockWidth,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppTheme.primaryColor,
                                AppTheme.primaryColor.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.35),
                                offset: const Offset(0, 6),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Left bottom decorative element
                    Positioned(
                      bottom: 0,
                      left: 0,
                      width: sideBlockWidth,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppTheme.primaryColor.withOpacity(0.9),
                              AppTheme.primaryColor.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(0, 4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Right bottom decorative element
                    Positioned(
                      bottom: 0,
                      right: 0,
                      width: sideBlockWidth,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppTheme.primaryColor.withOpacity(0.9),
                              AppTheme.primaryColor.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(0, 4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Main content - 3D Result
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'LIVE 3D RESULT',
                            style: TextStyle(
                              color: AppTheme.textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedTimeSection,
                            style: TextStyle(
                              color: AppTheme.textSecondaryColor,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _isLoading
                              ? const CircularProgressIndicator()
                              : Text(
                                _currentResult == '--'
                                    ? 'COMING SOON'
                                    : _currentResult,
                                style: TextStyle(
                                  color:
                                      AppTheme.backgroundColor == Colors.white
                                          ? const Color(0xFFFFD700)
                                          : AppTheme.primaryColor,
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                ),
                              ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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
          _showTimeSectionDialog();
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

  void _showTimeSectionDialog() {
    // Find the matching session object for the current selection
    Map<String, dynamic> initialSessionObj = {};
    if (_activeSessions.isNotEmpty) {
      for (var session in _activeSessions) {
        if (session['session'] == _selectedTimeSection) {
          initialSessionObj = session;
          break;
        }
      }
    }

    // Variables to track selection state inside the dialog
    String dialogSelectedSection = _selectedTimeSection;
    Map<String, dynamic> selectedSessionObj = initialSessionObj;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppTheme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              titlePadding: const EdgeInsets.only(
                left: 20,
                right: 12,
                top: 20,
                bottom: 0,
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ထိုးမည် Section ရွေးပါ',
                    style: TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.textColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: AppTheme.textColor,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              content: Container(
                width: double.maxFinite,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      _activeSessions.isEmpty
                          ? Center(
                            child: Text(
                              'No active sessions available',
                              style: TextStyle(color: AppTheme.textColor),
                            ),
                          )
                          : Column(
                            children:
                                _activeSessions.map<Widget>((session) {
                                  String timeSection = session['session'] ?? '';
                                  bool isSelected =
                                      timeSection == dialogSelectedSection;

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        dialogSelectedSection = timeSection;
                                        selectedSessionObj = session;
                                        print(
                                          'Selected: $timeSection, session_name: ${session['session_name']}',
                                        );
                                      });
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isSelected
                                                ? AppTheme.primaryColor
                                                    .withOpacity(0.15)
                                                : AppTheme.cardExtraColor,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color:
                                              isSelected
                                                  ? AppTheme.primaryColor
                                                  : Colors.transparent,
                                          width: 2.0,
                                        ),
                                        boxShadow:
                                            isSelected
                                                ? [
                                                  BoxShadow(
                                                    color: AppTheme.primaryColor
                                                        .withOpacity(0.3),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ]
                                                : null,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                        horizontal: 16,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '$timeSection Section',
                                              style: TextStyle(
                                                color:
                                                    isSelected
                                                        ? AppTheme.primaryColor
                                                        : AppTheme.textColor,
                                                fontSize: 14,
                                                fontWeight:
                                                    isSelected
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                          if (isSelected)
                                            Icon(
                                              Icons.check_circle,
                                              color: AppTheme.primaryColor,
                                              size: 20,
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                      // Add padding at the bottom of the list
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.cardExtraColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'CANCEL',
                          style: TextStyle(
                            color: AppTheme.textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Update the actual selected time in the parent state
                          this.setState(() {
                            _selectedTimeSection = dialogSelectedSection;
                          });
                          Navigator.pop(context);

                          // Navigate to number selection screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => NumberSelection3DScreen(
                                    sessionName: dialogSelectedSection,
                                    sessionData: selectedSessionObj,
                                    type: '3D',
                                  ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'OK',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSecondTabContent() {
    return _selectedTabIndex == 1
        ? _buildHistoryTab()
        : const SizedBox.shrink();
  }

  Widget _buildThirdTabContent() {
    // Determine if we're in a white/light theme
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;

    // Calculate screen width for positioning
    final screenWidth = MediaQuery.of(context).size.width;
    final podiumWidth = screenWidth - 32; // Account for horizontal padding
    final centerBlockWidth = podiumWidth * 0.3; // Width for center block
    final sideBlockWidth =
        podiumWidth * 0.33; // Wider blocks for 2nd and 3rd place

    return _isWinnersLoading
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading winners...',
                style: TextStyle(color: AppTheme.textColor),
              ),
            ],
          ),
        )
        : RefreshIndicator(
          onRefresh: _fetchWinnersData,
          child: Column(
            children: [
              // Winners podium with 3 slots
              SizedBox(
                height: 280,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Stack(
                    fit: StackFit.expand,
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Podium base - 3D style with overlapping blocks
                      Positioned(
                        bottom: 0,
                        left: 10,
                        right: 10,
                        height: 80, // Explicitly set height for the base stack
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // 2nd place podium - left
                            Positioned(
                              bottom: 0,
                              left: 0,
                              width: sideBlockWidth,
                              height: 50,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(
                                        0xFF6c52c3,
                                      ), // Purple gradient start
                                      Color(0xFF5545a3), // Purple gradient end
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      offset: const Offset(0, 5),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    '2',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black38,
                                          offset: Offset(0, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // 1st place podium - middle (taller)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  width: centerBlockWidth,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(
                                          0xFF6c52c3,
                                        ), // Purple gradient start
                                        Color(
                                          0xFF5545a3,
                                        ), // Purple gradient end
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.35),
                                        offset: const Offset(0, 6),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      '1',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 42,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black38,
                                            offset: Offset(0, 2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // 3rd place podium - right
                            Positioned(
                              bottom: 0,
                              right: 0,
                              width: sideBlockWidth,
                              height: 50,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(
                                        0xFF6c52c3,
                                      ), // Purple gradient start
                                      Color(0xFF5545a3), // Purple gradient end
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      offset: const Offset(0, 4),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    '3',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black38,
                                          offset: Offset(0, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 2nd place winner - left
                      Positioned(
                        bottom: 50,
                        left: 15,
                        width: 105,
                        height: 130,
                        child: _buildWinnerCard(
                          rank: "2",
                          iconAsset: 'assets/images/ic_second.png',
                          isLightTheme: isLightTheme,
                          winner:
                              _winnersData?.top3Lists != null &&
                                      _winnersData!.top3Lists!.length > 1
                                  ? _winnersData!.top3Lists![1]
                                  : null,
                        ),
                      ),

                      // 1st place winner - middle
                      Positioned(
                        bottom: 80,
                        left: 0,
                        right: 0,
                        height: 130,
                        child: Center(
                          child: SizedBox(
                            width: 105,
                            height: 130,
                            child: _buildWinnerCard(
                              rank: "1",
                              iconAsset: 'assets/images/ic_first.png',
                              isLightTheme: isLightTheme,
                              winner:
                                  _winnersData?.top3Lists != null &&
                                          _winnersData!.top3Lists!.isNotEmpty
                                      ? _winnersData!.top3Lists![0]
                                      : null,
                            ),
                          ),
                        ),
                      ),

                      // 3rd place winner - right
                      Positioned(
                        bottom: 50,
                        right: 15,
                        width: 105,
                        height: 130,
                        child: _buildWinnerCard(
                          rank: "3",
                          iconAsset: 'assets/images/ic_third.png',
                          isLightTheme: isLightTheme,
                          winner:
                              _winnersData?.top3Lists != null &&
                                      _winnersData!.top3Lists!.length > 2
                                  ? _winnersData!.top3Lists![2]
                                  : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // List of winners
              Expanded(
                child:
                    _winnersData?.winners == null ||
                            _winnersData!.winners!.isEmpty
                        ? Center(
                          child: Text(
                            'No winners data available',
                            style: TextStyle(color: AppTheme.textColor),
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 16,
                          ),
                          itemCount: _winnersData!.winners!.length,
                          itemBuilder: (context, index) {
                            final winner = _winnersData!.winners![index];
                            return _buildWinnerListItem(
                              isLightTheme: isLightTheme,
                              winner: winner,
                            );
                          },
                        ),
              ),
            ],
          ),
        );
  }

  // Helper method to build each winner card on the podium
  Widget _buildWinnerCard({
    required String rank,
    required String iconAsset,
    required bool isLightTheme,
    UserListItem? winner,
  }) {
    return Container(
      width: 105,
      height: 130,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6c52c3), // Purple gradient start
            Color(0xFF5545a3), // Purple gradient end
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Star with rank number at top
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    rank,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Rainbow bar under the star
          Positioned(
            top: 34,
            left: 30,
            right: 30,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red,
                    Colors.orange,
                    Colors.yellow,
                    Colors.green,
                    Colors.blue,
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 42, 10, 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Name
                Text(
                  winner?.user?.username ?? 'Su Myat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Description - using winner number and prize amount
                Text(
                  winner?.winnerNumber != null && winner?.prizeAmount != null
                      ? 'Won ${winner!.prizeAmount} Ks on ${winner.winnerNumber}'
                      : 'Lorem ipsum dolor sit amet',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinnerListItem({
    required bool isLightTheme,
    required UserListItem winner,
  }) {
    // Format date if available
    String formattedDate = '';
    if (winner.createdAt != null) {
      try {
        final datetime = DateTime.parse(winner.createdAt!);
        formattedDate = DateFormat('E dd-MM-yyyy | hh:mm a').format(datetime);
      } catch (e) {
        formattedDate = winner.createdAt ?? '';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isLightTheme ? Colors.white : const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
        border:
            isLightTheme
                ? Border.all(color: Colors.grey.shade300, width: 1)
                : null,
        boxShadow:
            isLightTheme
                ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ]
                : null,
      ),
      child: Stack(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Row(
              children: [
                // Avatar/Profile Image
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey.shade600,
                  child: Icon(
                    Icons.person,
                    color: Colors.grey.shade300,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),

                // User details
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // User name
                      Text(
                        winner.user?.username ?? 'Nyein Nyein',
                        style: TextStyle(
                          color:
                              isLightTheme ? AppTheme.textColor : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // User ID
                      Text(
                        winner.user?.hiddenPhone ?? '09xxxxxxx123',
                        style: TextStyle(
                          color:
                              isLightTheme
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade400,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Date
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color:
                              isLightTheme
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade400,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                // Winner number
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isLightTheme
                            ? AppTheme.primaryColor.withOpacity(0.1)
                            : AppTheme.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        winner.winnerNumber ?? '123',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Number',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Prize amount
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${winner.prizeAmount ?? '1,000'} Ks',
                        style: TextStyle(
                          color:
                              isLightTheme
                                  ? AppTheme.accentColor
                                  : Colors.greenAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Prize',
                        style: TextStyle(
                          color:
                              isLightTheme
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade400,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    // Determine if we're in a white/light theme
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // History table would go here
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow:
                        isLightTheme
                            ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                            : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Results',
                        style: TextStyle(
                          color: AppTheme.textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildHistoryItem('Today', '12:01 PM', '348'),
                      _buildHistoryItem('Yesterday', '04:30 PM', '259'),
                      _buildHistoryItem('Yesterday', '12:01 PM', '687'),
                      _buildHistoryItem('05/31/2023', '04:30 PM', '321'),
                      _buildHistoryItem('05/31/2023', '12:01 PM', '475'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String date, String time, String result) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.textSecondaryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              date,
              style: TextStyle(color: AppTheme.textColor, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              time,
              style: TextStyle(color: AppTheme.textColor, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              result,
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeResultCard(String time, String timeKey) {
    // Convert timeKey to the corresponding keys in the API response
    String setKey = 'set_$timeKey';
    String valKey = 'val_$timeKey';
    String resultKey = 'result_$timeKey';

    // Extract values from API data
    String set = _isLoading ? '--' : (_apiData[setKey] ?? '--');
    String value = _isLoading ? '--' : (_apiData[valKey] ?? '--');
    String threed =
        _isLoading ? '--' : (_apiData[resultKey]?.toString() ?? '--');

    // Determine if we're in a white/light theme
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow:
            isLightTheme
                ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ]
                : null,
        border:
            isLightTheme
                ? Border.all(color: Colors.grey.shade300, width: 1)
                : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            child: Center(
              child: Text(
                time,
                style: TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 42),
            child: Divider(
              color: AppTheme.textSecondaryColor.withOpacity(0.4),
              thickness: 0.7,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Modern column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'SET',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        set,
                        style: TextStyle(
                          color: AppTheme.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Internet column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'VALUE',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: TextStyle(
                          color: AppTheme.textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // 3D column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '3D',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        threed,
                        style: TextStyle(
                          color:
                              threed == '--'
                                  ? Colors.blue
                                  : AppTheme.backgroundColor == Colors.white
                                  ? const Color(
                                    0xFFFFD700,
                                  ).withRed(255).withGreen(215).withBlue(0)
                                  : AppTheme.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildLiveResultsTab() {
    // If still loading, show progress indicator
    if (_isLiveResultsLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    // Get live results from the data
    final results = _liveResultsData?.results ?? [];

    // If no results available, show empty state
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 60,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No live results available',
              style: TextStyle(color: AppTheme.textColor, fontSize: 18),
            ),
          ],
        ),
      );
    }

    // Show latest number at the top
    final latestNumber =
        results.isNotEmpty ? results[0].number ?? '---' : '---';
    final latestDate =
        results.isNotEmpty
            ? results[0].formattedDate ?? 'Unknown date'
            : 'Unknown date';

    return RefreshIndicator(
      onRefresh: _fetchLiveResultsData,
      color: AppTheme.primaryColor,
      backgroundColor: AppTheme.cardColor,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.8),
                  AppTheme.primaryColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Latest Drawing',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  latestNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      latestDate,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  'Previous Results',
                  style: TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${results.length} drawings',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final result = results[index];
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
                        Column(
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
                              result.formattedDate ?? result.date ?? 'Unknown',
                              style: TextStyle(
                                color: AppTheme.textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
                            result.number ?? '---',
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
          ),
        ],
      ),
    );
  }
}
