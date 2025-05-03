import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/bet/domain/models/two_d_session_status_list_response.dart';
import 'package:one_x/features/bet/presentation/screens/number_selection_screen.dart';
import 'dart:convert';
import 'package:one_x/features/bet/data/repositories/bet_repository.dart';
import 'package:one_x/core/utils/api_service.dart';
import 'package:one_x/core/services/storage_service.dart';
import 'package:one_x/features/bet/presentation/screens/not_available_screen.dart';
import 'package:one_x/features/bet/presentation/widgets/bet_history_widget.dart';
import 'package:one_x/features/bet/presentation/widgets/bet_winners_widget.dart';
import 'package:one_x/features/bet/presentation/widgets/two_d_history_numbers_widget.dart';
import 'package:one_x/features/bet/presentation/widgets/two_d_holidays_widget.dart';

class TwoDScreen extends StatefulWidget {
  const TwoDScreen({super.key});

  @override
  State<TwoDScreen> createState() => _TwoDScreenState();
}

class _TwoDScreenState extends State<TwoDScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  String _selectedTimeSection = '04:30 PM';

  // API data
  bool _isLoading = true;
  Map<String, dynamic> _apiData = {};
  String _currentResult = '--';
  List<Session> _activeSessions = [];

  // Repository
  late BetRepository _betRepository;

  @override
  void initState() {
    super.initState();
    // Explicitly create a new TabController with length 5
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return; // Skip if still animating

      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });

    // Initialize repository directly
    final storageService = StorageService();
    final apiService = ApiService(storageService: storageService);
    _betRepository = BetRepository(
      apiService: apiService,
      storageService: storageService,
    );

    // Set selected time section based on current time
    setDefaultTimeSection();

    // Fetch data when the screen loads
    fetchData();
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
      final TwoDSessionStatusListResponse response =
          await _betRepository.getActive2DSessions();

      if (response.available ?? false) {
        setState(() {
          _activeSessions = response.session ?? [];
        });
        showTimeSectionDialog();
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => NotAvailableScreen(
                  information: response.information,
                  title: '2D',
                ),
          ),
        );
      }
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

  Future<void> fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _betRepository.get2DLiveResults();

      setState(() {
        _apiData = data;

        // Print response for debugging
        print('API Response: ${jsonEncode(_apiData)}');

        // Get the result from API response - improved extraction logic
        if (_apiData.containsKey('result_430') &&
            _apiData['result_430'] != null) {
          // Most common case - use result_430 for 4:30 PM result
          _currentResult = _apiData['result_430'].toString();
        } else if (_apiData.containsKey('live') &&
            _apiData['live'] != null &&
            _apiData['live'].toString().isNotEmpty) {
          // Use live result if available
          _currentResult = _apiData['live'].toString();
        } else if (_apiData.containsKey('results') &&
            _apiData['results'] is List &&
            (_apiData['results'] as List).isNotEmpty) {
          // Get the last index of results array if it exists
          var lastResult = (_apiData['results'] as List).last;
          // Ensure it's converted to string properly
          _currentResult = lastResult?.toString() ?? '--';
        } else {
          // Check for any key that might contain the current result
          var possibleKeys = [
            'current_2d',
            'current_result',
            'twod',
            'today_result',
          ];
          for (var key in possibleKeys) {
            if (_apiData.containsKey(key) && _apiData[key] != null) {
              _currentResult = _apiData[key].toString();
              break;
            }
          }

          // If still not found, set default
          if (_currentResult.isEmpty) {
            _currentResult = '--';
          }
        }

        // Ensure the result is properly formatted
        if (_currentResult == 'null' || _currentResult.isEmpty) {
          _currentResult = '--';
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        // Set default value in case of error
        _currentResult = '--';
        _isLoading = false;
      });
      print('Error fetching data: $e');

      // Show a snackbar with the error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load 2D results: $e'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(label: 'Retry', onPressed: fetchData),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundColor,
          title: Text('2D', style: TextStyle(color: AppTheme.textColor)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppTheme.textColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    buildFirstTabContent(),
                    const BetHistoryWidget(),
                    const BetWinnersWidget(),
                    const TwoDHistoryNumbersWidget(),
                    const TwoDHolidaysWidget(),
                  ],
                ),
              ),
            ],
          ),
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
                  '2D ကံစမ်းမှတ်တမ်း',
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
                  '2D ပေါက်ဂဏန်းများ',
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
            Container(
              height: 36,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color:
                    _selectedTabIndex == 4
                        ? AppTheme.primaryColor
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border:
                    _selectedTabIndex == 4
                        ? null
                        : Border.all(color: AppTheme.primaryColor, width: 1),
              ),
              child: TextButton.icon(
                icon: Icon(
                  Icons.calendar_today,
                  color:
                      _selectedTabIndex == 4
                          ? Colors.white
                          : AppTheme.backgroundColor == Colors.white
                          ? AppTheme.primaryColor
                          : AppTheme.textColor,
                  size: 14,
                ),
                label: Text(
                  '2D Holidays',
                  style: TextStyle(
                    color:
                        _selectedTabIndex == 4
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
                  _tabController.animateTo(4);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFirstTabContent() {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([fetchData()]);
      },
      child: Column(
        children: [
          buildResultsSection(),
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
                  buildTimeResultCard('12:01 AM', '1200'),
                  buildTimeResultCard('04:30 PM', '430'),
                  buildModernInternetCard('09:30 AM', '930'),
                  buildModernInternetCard('02:00 PM', '200'),
                ],
              ),
            ),
          ),
          buildBottomBar(),
        ],
      ),
    );
  }

  Widget buildResultsSection() {
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
                        ? const Color(
                          0xFFFFD700,
                        ).withRed(255).withGreen(215).withBlue(0)
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
              _isLoading
                  ? 'Loading...'
                  : 'Updated: ${_apiData['date'] ?? ''} ${_apiData['current_time'] ?? ''}',
              style: TextStyle(color: AppTheme.textColor, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget buildTimeResultCard(String time, String timeKey) {
    // Convert timeKey to the corresponding keys in the API response
    String setKey = 'set_$timeKey';
    String valKey = 'val_$timeKey';
    String resultKey = 'result_$timeKey';

    // Extract values from API data
    String set = _isLoading ? '--' : (_apiData[setKey] ?? '--');
    String value = _isLoading ? '--' : (_apiData[valKey] ?? '--');
    String twod = _isLoading ? '--' : (_apiData[resultKey]?.toString() ?? '--');

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
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              children: [
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
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
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
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '2D',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        twod,
                        style: TextStyle(
                          color:
                              twod == '--'
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

  Widget buildModernInternetCard(String time, String timeKey) {
    // Extract values from API data
    String modern = _isLoading ? '--' : (_apiData['modern_$timeKey'] ?? '--');
    String internet =
        _isLoading ? '--' : (_apiData['internet_$timeKey'] ?? '--');

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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Row(
          children: [
            // Time column
            Expanded(
              child: Text(
                time,
                style: TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Modern column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'MODERN',
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    modern,
                    style: TextStyle(
                      color:
                          modern == '--'
                              ? Colors.blue
                              : AppTheme.backgroundColor == Colors.white
                              ? const Color(
                                0xFFFFD700,
                              ).withRed(255).withGreen(215).withBlue(0)
                              : AppTheme.primaryColor,
                      fontSize: 16, // Increased to match 2D digits
                      fontWeight:
                          FontWeight.w900, // Extra bold to match 2D digits
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
                    'INTERNET',
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    internet,
                    style: TextStyle(
                      color:
                          internet == '--'
                              ? Colors.blue
                              : AppTheme.backgroundColor == Colors.white
                              ? const Color(
                                0xFFFFD700,
                              ).withRed(255).withGreen(215).withBlue(0)
                              : AppTheme.primaryColor,
                      fontSize: 16, // Increased to match 2D digits
                      fontWeight:
                          FontWeight.w900, // Extra bold to match 2D digits
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBottomBar() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
      child: ElevatedButton(
        onPressed: () async {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder:
          //         (context) => NumberSelectionScreen(
          //           selectedTimeSection: _selectedTimeSection,
          //           sessionName: 'morning',
          //         ),
          //   ),
          // );
          await fetchSessionStatus();
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

  void showTimeSectionDialog() {
    // Find the matching session object for the current selection
    Session? initialSessionObj;
    if (_activeSessions.isNotEmpty) {
      for (var session in _activeSessions) {
        if (session.session == _selectedTimeSection) {
          initialSessionObj = session;
          break;
        }
      }
    }

    // Variables to track selection state inside the dialog
    String dialogSelectedSection = _selectedTimeSection;
    Session? selectedSessionObj = initialSessionObj;

    // Flag to check if a valid selection exists
    bool isValidSelectionMade = initialSessionObj != null;

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
                                  String timeSection = session.session ?? '';
                                  bool isSelected =
                                      timeSection == dialogSelectedSection;

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        dialogSelectedSection = timeSection;
                                        selectedSessionObj = session;
                                        isValidSelectionMade = true;
                                        print(
                                          'Selected: $timeSection, session_name: ${session.sessionName}',
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
                        onPressed:
                            isValidSelectionMade
                                ? () {
                                  // Update the actual selected time in the parent state
                                  this.setState(() {
                                    _selectedTimeSection =
                                        dialogSelectedSection;
                                  });
                                  Navigator.pop(context);

                                  // Get the session_name from the selected session
                                  String sessionName =
                                      selectedSessionObj?.sessionName ?? '';

                                  // Navigate to number selection screen with session_name
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => NumberSelectionScreen(
                                            selectedTimeSection:
                                                _selectedTimeSection,
                                            sessionName: sessionName,
                                          ),
                                    ),
                                  );
                                }
                                : null, // Disable the button if no valid selection
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          disabledBackgroundColor: AppTheme.primaryColor
                              .withOpacity(0.5),
                          disabledForegroundColor: Colors.white.withOpacity(
                            0.7,
                          ),
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
}
