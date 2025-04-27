import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/bet/presentation/screens/amount_entry_screen.dart';
import 'package:one_x/features/bet/presentation/screens/copy_number_screen.dart';
import 'package:one_x/features/bet/presentation/screens/quick_select_screen.dart';
import 'package:one_x/features/bet/data/repositories/bet_repository.dart';
import 'package:one_x/core/utils/api_service.dart';
import 'package:one_x/core/services/storage_service.dart';
import 'package:one_x/features/bet/domain/models/play_session.dart';
import 'package:one_x/features/bet/presentation/screens/type_two_d_screen.dart';
import 'dart:convert';
import 'package:one_x/features/home/presentation/providers/home_provider.dart';
import 'package:one_x/features/home/data/models/home_model.dart';
import 'package:one_x/features/bet/presentation/providers/bet_provider.dart';
import 'package:one_x/features/auth/presentation/providers/auth_provider.dart';
import 'package:one_x/features/bet/presentation/screens/dream_number_screen.dart';
import 'package:one_x/features/bet/presentation/screens/tape_hot_selection_dialog.dart';
import 'dart:async';
import 'package:one_x/features/bet/domain/models/two_d_session_status_list_response.dart';

class NumberSelectionScreen extends ConsumerStatefulWidget {
  final String selectedTimeSection;
  final String sessionName;

  const NumberSelectionScreen({
    super.key,
    required this.selectedTimeSection,
    required this.sessionName,
  });

  @override
  ConsumerState<NumberSelectionScreen> createState() =>
      _NumberSelectionScreenState();
}

class _NumberSelectionScreenState extends ConsumerState<NumberSelectionScreen> {
  Set<String> selectedNumbers = {};
  final TextEditingController _amountController = TextEditingController();
  int _amount = 0;
  final int _minAmount = 100; // Minimum bet amount

  // Countdown timer
  Timer? _countdownTimer;
  int _remainingSeconds = 0; // Initialize with default value

  // API data
  bool _isLoading = true;
  Map<String, dynamic> _apiData = {};
  Map<String, dynamic> _twoDigitsData = {};
  Map<String, dynamic> _userRemainingAmounts = {};
  Set<String> unavailableNumbers = {};
  Map<String, Map<String, dynamic>> numberIndicators = {};

  // Tape and Hot numbers data
  bool _isTapeHotLoading = true;
  List<String> _tapeNumbers = [];
  List<String> _hotNumbers = [];

  // Marquee scroll controller
  final ScrollController _marqueeScrollController = ScrollController();
  bool _isScrolling = false; // Non-final variable

  // Format countdown from seconds to dd:hh:mm:ss
  String _formatCountdown(int seconds) {
    int days = seconds ~/ (24 * 3600);
    seconds = seconds % (24 * 3600);
    int hours = seconds ~/ 3600;
    seconds = seconds % 3600;
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;

    // Build the string conditionally
    String result = '';

    // Only add days if non-zero
    if (days > 0) {
      result += '${days.toString()}:';
    }

    // Only add hours if days or hours are non-zero
    if (days > 0 || hours > 0) {
      result += '${hours.toString().padLeft(2, '0')}:';
    }

    // Always show at least minutes and seconds
    result +=
        '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';

    return result;
  }

  void _startCountdown() {
    _countdownTimer?.cancel(); // Cancel any existing timer
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _countdownTimer?.cancel();
          // You could add a callback here when the countdown reaches zero
          // For example, show a message or navigate away
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialize with empty selection
    selectedNumbers = {};
    // Initialize amount controller with empty value
    _amountController.text = '';
    _amount = 0;

    // Start by fetching session list
    _fetchSessionList();

    // Prefetch tape and hot numbers
    _fetchTapeHotData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _marqueeScrollController.dispose();
    if (_countdownTimer != null && _countdownTimer!.isActive) {
      _countdownTimer!.cancel();
    }
    super.dispose();
  }

  Future<void> _fetchSessionList() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(betRepositoryProvider);
      final TwoDSessionStatusListResponse response =
          await repository.getActive2DSessions();

      if (response.session != null && response.session!.isNotEmpty) {
        // Look for the session matching our selectedTimeSection
        Session? selectedSession;
        for (var session in response.session!) {
          if (session.sessionName == widget.sessionName) {
            selectedSession = session;
            break;
          }
        }

        if (selectedSession != null) {
          // Set the countdown from the session data
          _remainingSeconds =
              selectedSession.countdown ?? 0; // Default to 1 hour if null

          // Start the countdown timer
          _startCountdown();

          // Now fetch digit data based on this session
          _fetchDigitData();
        } else {
          // If we can't find matching session, still fetch digit data with a default countdown
          _remainingSeconds = 3600; // Default to 1 hour
          _startCountdown();
          _fetchDigitData();
        }
      } else {
        // No sessions available, still fetch digit data with a default countdown
        _remainingSeconds = 3600; // Default to 1 hour
        _startCountdown();
        _fetchDigitData();
      }
    } catch (e) {
      print('Error fetching session list: $e');
      // Set a default countdown and continue
      _remainingSeconds = 3600; // Default to 1 hour
      _startCountdown();
      _fetchDigitData();
    }
  }

  Future<void> _fetchDigitData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(betRepositoryProvider);
      PlaySessionResponse data;

      // Use appropriate repository methods based on session name
      if (widget.sessionName == 'morning') {
        Map<String, dynamic> session = {"session": "morning"};
        data = await repository.getMorningSessionPlayData(session);
        print('Fetched morning session data');
      } else if (widget.sessionName == 'evening') {
        Map<String, dynamic> session = {"session": "evening"};
        data = await repository.getEveningSessionPlayData(session);
        print('Fetched evening session data');
      } else {
        // Default fallback uses manual play data
        data = await repository.getManualPlayData(widget.sessionName);
        print('Fetched manual play data for: ${widget.sessionName}');
      }

      setState(() {
        // Store data in a map format for backward compatibility
        _apiData = {
          'twoDigits': {},
          'userRemainingAmounts': [],
          'playTime': data.playTime?.toJson() ?? {},
        };

        // Process two digits data
        if (data.twoDigits != null && data.twoDigits!.isNotEmpty) {
          final Map<String, dynamic> digitsMap = {};

          for (var digit in data.twoDigits!) {
            if (digit.permanentNumber != null) {
              // Ensure percentage is an integer - convert if necessary
              int percentage = 0;
              if (digit.percentage is int) {
                percentage = digit.percentage ?? 0;
              } else if (digit.percentage is String) {
                percentage = int.tryParse(digit.percentage.toString()) ?? 0;
              } else if (digit.percentage != null) {
                // Convert any other type to string first then parse
                percentage = int.tryParse(digit.percentage.toString()) ?? 0;
              }

              digitsMap[digit.permanentNumber!] = {
                'percentage': percentage,
                'is_tape': digit.isTape,
                'is_hot': digit.isHot,
                'status': digit.status,
              };
            }
          }

          _twoDigitsData = digitsMap;
          _apiData['twoDigits'] = digitsMap;

          // Create user remaining amounts format for compatibility
          final Map<String, dynamic> userAmounts = {};
          for (var digit in data.twoDigits!) {
            if (digit.permanentNumber != null) {
              userAmounts[digit.permanentNumber!] = {
                'percentage': digit.percentage,
                'is_tape': digit.isTape,
                'is_hot': digit.isHot,
                'status': digit.status,
              };
            }
          }
          _userRemainingAmounts = userAmounts;
          _apiData['userRemainingAmounts'] = [userAmounts];
        }

        // Process digit data into UI format
        _processDigitData();

        _isLoading = false;
      });

      print('API data loaded successfully');
    } catch (e) {
      print('Error fetching digit data: $e');

      if (mounted) {
        setState(() {
          _apiData = {'twoDigits': {}, 'userRemainingAmounts': []};
          _isLoading = false;
        });

        // Only show error message if it's not an ApiException
        // (ApiExceptions are already handled by the API service)
        if (e is! ApiException) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load digit data: $e'),
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: _fetchDigitData,
              ),
            ),
          );
        }
      }
    }
  }

  void _processDigitData() {
    // Clear existing data
    unavailableNumbers = {};
    numberIndicators = {};

    // Process directly from _twoDigitsData which contains processed percentage information
    _twoDigitsData.forEach((digitKey, digitData) {
      // Get percentage value directly from API (don't reverse it)
      // API percentage means "used percentage", not "available percentage"
      final dynamic rawPercentage = digitData['percentage'];
      int apiPercentage = 0;

      // Handle different types of percentage values
      if (rawPercentage is int) {
        apiPercentage = rawPercentage;
      } else if (rawPercentage is String) {
        apiPercentage = int.tryParse(rawPercentage) ?? 0;
      } else if (rawPercentage != null) {
        apiPercentage = int.tryParse(rawPercentage.toString()) ?? 0;
      }

      // Use the API percentage directly for UI display
      final uiPercentage = apiPercentage;

      // Debug output to verify percentages
      if (digitKey == '00' || digitKey == '01' || digitKey == '02') {
        print(
          'Digit $digitKey: API percentage = $apiPercentage, UI percentage = $uiPercentage',
        );
      }

      final isTape = digitData['is_tape'] == 'active';
      final isHot = digitData['is_hot'] == 'active';
      final status = digitData['status'];

      // Determine if number is unavailable
      if (status == 'inactive' || uiPercentage >= 100) {
        unavailableNumbers.add(digitKey);
      }

      // Set progress color based on UI percentage (used percentage)
      // Updated color coding: 0-50% green, 51-90% orange, 91-99% red, 100% grey
      Color progressColor;
      if (uiPercentage <= 50) {
        progressColor = Colors.green;
      } else if (uiPercentage <= 90) {
        progressColor = Colors.orange;
      } else if (uiPercentage < 100) {
        progressColor = Colors.red;
      } else {
        progressColor = Colors.grey;
      }

      // Store in indicators map
      numberIndicators[digitKey] = {
        'color': progressColor,
        'progress': uiPercentage / 100, // Convert to 0-1 scale
        'is_tape': isTape,
        'is_hot': isHot,
      };
    });

    // Also check inactive digits from API
    if (_apiData.containsKey('inactiveDigit') &&
        _apiData['inactiveDigit'] is String &&
        _apiData['inactiveDigit'].isNotEmpty) {
      final inactiveDigitsStr = _apiData['inactiveDigit'];
      try {
        final inactiveDigitsList = inactiveDigitsStr.split(',');
        unavailableNumbers.addAll(inactiveDigitsList);
      } catch (e) {
        print('Failed to parse inactiveDigits: $e');
      }
    }

    print('Processed ${numberIndicators.length} digits with indicators');
    print('${unavailableNumbers.length} unavailable numbers');
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppTheme.backgroundColor,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.arrow_back, color: AppTheme.textColor),
            ),
            const SizedBox(width: 4),
            Text('2D ထိုးမည်', style: TextStyle(color: AppTheme.textColor)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              'အရောင်းပိတ်ချိန် - ${_formatCountdown(_remainingSeconds)}',
              style: TextStyle(color: AppTheme.primaryColor, fontSize: 13),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child:
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    _buildBalanceBar(),
                    _buildSectionHeader(),
                    _buildColorLegend(),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: _buildNumberGrid(),
                        ),
                      ),
                    ),
                    _buildActionButtons(),
                    _buildBottomButtons(),
                  ],
                ),
      ),
    );
  }

  Widget _buildBalanceBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Consumer(
              builder: (context, ref, _) {
                final homeData = ref.watch(homeDataProvider);
                return homeData.when(
                  data: (data) {
                    final balance = data.user.balance;
                    return Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          color: AppTheme.textColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_formatAmount(balance)} Ks.',
                          style: TextStyle(
                            color: AppTheme.textColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    );
                  },
                  loading:
                      () => Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: AppTheme.textColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                  error:
                      (_, __) => Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: AppTheme.textColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Error loading balance',
                            style: TextStyle(
                              color: AppTheme.textColor,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                );
              },
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  await Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => TypeTwoDScreen(
                            sessionName: widget.sessionName,
                            selectedTimeSection: widget.selectedTimeSection,
                          ),
                    ),
                  );
                  _fetchDigitData();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.primaryColor),
                  ),
                  child: Text(
                    'ၐဏန်းရိုက်ထိုးရန်',
                    style: TextStyle(color: AppTheme.textColor, fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  await Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => CopyNumberScreen(
                            sessionName:
                                widget.sessionName == "morning" ||
                                        widget.sessionName == "evening"
                                    ? widget.sessionName
                                    : "morning", // Use "morning" as a fallback
                            selectedTimeSection: widget.selectedTimeSection,
                          ),
                    ),
                  );
                  _fetchDigitData();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.primaryColor),
                  ),
                  child: Text(
                    'ကော်ပီကူးထိုးရန်',
                    style: TextStyle(color: AppTheme.textColor, fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${_getCurrentFormattedDate()} | ${widget.selectedTimeSection}',
              style: TextStyle(
                color: AppTheme.textColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _showColorLegendDialog(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, color: AppTheme.textColor, size: 18),
                const SizedBox(width: 4),
                Text(
                  'Color ရှင်းလင်းချက်',
                  style: TextStyle(color: AppTheme.textColor, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showColorLegendDialog() {
    // Determine if we're in a white/light theme
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;
    final Color dialogBgColor =
        isLightTheme ? Colors.white : AppTheme.cardColor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: dialogBgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.textColor),
                    const SizedBox(width: 8),
                    Text(
                      'Color ရှင်းလင်းချက်',
                      style: TextStyle(
                        color: AppTheme.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.close, color: AppTheme.textColor),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildColorLegendItem(
                  text: 'ထိုးငွေ 0% - 50% ',
                  progressColor: Colors.green,
                  progressValue: 0.5,
                  isLightTheme: isLightTheme,
                ),
                _buildColorLegendItem(
                  text: 'ထိုးငွေ 51% - 90% ',
                  progressColor: Colors.orange,
                  progressValue: 0.9,
                  isLightTheme: isLightTheme,
                ),
                _buildColorLegendItem(
                  text: 'ထိုးငွေ 91% - 99% ',
                  progressColor: Colors.red,
                  progressValue: 0.99,
                  isLightTheme: isLightTheme,
                ),
                _buildColorLegendItem(
                  text: 'ထိုးငွေ 100% (ဂဏန်းထိုး၍မရပါ)',
                  isUnavailable: true,
                  progressColor: Colors.grey,
                  progressValue: 1.0,
                  isLightTheme: isLightTheme,
                ),
                _buildColorLegendItem(
                  text: 'အရောင်းပိတ်ထားသည်',
                  isUnavailable: true,
                  progressColor: Colors.grey,
                  progressValue: 1.0,
                  isLightTheme: isLightTheme,
                ),
                _buildColorLegendItem(
                  text: 'Hot Number',
                  dotColor: Colors.red,
                  isLightTheme: isLightTheme,
                ),
                _buildColorLegendItem(
                  text: 'Tape Number',
                  dotColor: Colors.yellow,
                  isLightTheme: isLightTheme,
                ),
                _buildColorLegendItem(
                  text: 'ရွေးချယ်ထားသည်',
                  isLightTheme: isLightTheme,
                  backgroundColor: AppTheme.primaryColor,
                  textColor: Colors.white,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorLegendItem({
    Color? dotColor,
    Color? progressColor,
    double progressValue = 0,
    required String text,
    bool isUnavailable = false,
    required bool isLightTheme,
    Color? backgroundColor,
    Color? textColor,
  }) {
    // Number box background color based on theme
    final Color bgColor =
        backgroundColor ??
        (isLightTheme
            ? Colors.white
            : isUnavailable
            ? Colors.grey.withOpacity(0.3)
            : AppTheme.cardExtraColor);

    // Text color should provide good contrast with the background
    final Color txtColor =
        textColor ??
        (isLightTheme
            ? isUnavailable
                ? Colors.grey.shade700
                : AppTheme.textColor
            : AppTheme.textColor);

    // Border color based on theme
    Color borderColor =
        isLightTheme
            ? Colors.grey.shade400
            : Colors.grey.shade800.withOpacity(0.5);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Number box preview (styled like actual number buttons)
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor, width: 1),
              boxShadow:
                  isLightTheme
                      ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 1,
                          offset: const Offset(0, 1),
                        ),
                      ]
                      : null,
            ),
            child: Stack(
              children: [
                // Center content (number or dot)
                if (dotColor != null)
                  Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                else
                  Center(
                    child: Text(
                      '*',
                      style: TextStyle(
                        color: txtColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                // Progress indicator at bottom
                if (progressColor != null || isUnavailable)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 6,
                        right: 6,
                        bottom: 4,
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(6),
                          bottomRight: Radius.circular(6),
                        ),
                        child: LinearProgressIndicator(
                          value: isUnavailable ? 1.0 : progressValue,
                          minHeight: 4,
                          backgroundColor: Colors.transparent,
                          color: isUnavailable ? Colors.grey : progressColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Description text
          Text(text, style: TextStyle(color: AppTheme.textColor, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildColorLegend() {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // This would be where color indicators go, if needed
        ],
      ),
    );
  }

  Widget _buildNumberGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        childAspectRatio: 1.0,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 100,
      itemBuilder: (context, index) {
        final numberStr = index < 10 ? '0$index' : '$index';
        final isSelected = selectedNumbers.contains(numberStr);
        final isUnavailable = unavailableNumbers.contains(numberStr);
        final indicatorData = numberIndicators[numberStr];

        return _buildNumberItem(
          number: numberStr,
          isSelected: isSelected,
          isUnavailable: isUnavailable,
          indicatorData: indicatorData,
        );
      },
    );
  }

  Widget _buildNumberItem({
    required String number,
    required bool isSelected,
    required bool isUnavailable,
    Map<String, dynamic>? indicatorData,
  }) {
    // Determine if we're in a white/light theme
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;

    // Select background color based on theme and selection state
    Color backgroundColor =
        isSelected
            ? AppTheme.primaryColor
            : (isUnavailable
                ? (isLightTheme
                    ? Colors.grey.shade300
                    : Colors.grey.withOpacity(0.3))
                : (isLightTheme ? Colors.white : AppTheme.cardExtraColor));

    // Text color should contrast with background
    Color textColor =
        isSelected
            ? Colors.white
            : (isUnavailable && isLightTheme
                ? Colors.grey.shade700
                : AppTheme.textColor);

    // Border color should be subtle for the current theme
    Color borderColor =
        isLightTheme
            ? Colors.grey.shade400
            : Colors.grey.shade800.withOpacity(0.5);

    // Extract indicator data
    final bool isHot = indicatorData != null && indicatorData['is_hot'] == true;
    final bool isTape =
        indicatorData != null && indicatorData['is_tape'] == true;
    final double progressValue =
        indicatorData != null ? (indicatorData['progress'] ?? 0.0) : 0.0;
    final Color progressColor =
        indicatorData != null
            ? (indicatorData['color'] ?? Colors.green)
            : Colors.green;

    return GestureDetector(
      onTap:
          isUnavailable
              ? null
              : () {
                setState(() {
                  if (isSelected) {
                    selectedNumbers.remove(number);
                  } else {
                    selectedNumbers.add(number);
                  }
                });
              },
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1),
          boxShadow:
              isLightTheme
                  ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 1,
                      offset: const Offset(0, 1),
                    ),
                  ]
                  : null,
        ),
        child: Stack(
          children: [
            // Center content (number)
            Center(
              child: Text(
                number,
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Hot indicator (red dot top right)
            if (isHot && !isSelected)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

            // Tape indicator (yellow dot top right, positioned to left of hot if both exist)
            if (isTape && !isSelected)
              Positioned(
                top: 4,
                right: isHot ? 16 : 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

            // Progress indicator at bottom - always show for all states except selected
            if (!isSelected)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 6, right: 6, bottom: 6),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(6),
                      bottomRight: Radius.circular(6),
                    ),
                    child: LinearProgressIndicator(
                      value: isUnavailable ? 1.0 : progressValue,
                      minHeight: 4,
                      backgroundColor: Colors.grey.withOpacity(0.15),
                      color: isUnavailable ? Colors.grey : progressColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildActionButton('အမြန် ရွေးရန်'),
                const SizedBox(width: 8),
                _buildActionButton('ထိပ်စီး ဂဏန်း'),
                const SizedBox(width: 8),
                _buildActionButton('အိပ်မက် ဂဏန်း'),
                const SizedBox(width: 8),
                _buildActionButton('R - ပတ်လည်'),
              ],
            ),
          ),
          // Add text marquee for tape and hot numbers
          if (!_isTapeHotLoading &&
              (_tapeNumbers.isNotEmpty || _hotNumbers.isNotEmpty))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _buildTapeHotMarquee(),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text) {
    // Determine if we're in a white/light theme
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;

    return GestureDetector(
      onTap: () async {
        if (text == 'အမြန် ရွေးရန်') {
          // Navigate to QuickSelectScreen and pass currently selected numbers from quick select
          final previousQuickSelectNumbers =
              selectedNumbers
                  .where((number) => _isFromQuickSelect(number))
                  .toList();

          final result = await Navigator.push<List<String>>(
            context,
            MaterialPageRoute(
              builder:
                  (context) => QuickSelectScreen(
                    previouslySelectedNumbers: previousQuickSelectNumbers,
                  ),
            ),
          );

          // If we got results back, handle them
          if (result != null) {
            setState(() {
              // First, remove any numbers that were previously from quick select
              selectedNumbers.removeWhere(
                (number) => _isFromQuickSelect(number),
              );

              // Then add the new selection
              if (result.isNotEmpty) {
                selectedNumbers.addAll(result);
              }
            });
          }
        } else if (text == 'ထိပ်စီး ဂဏန်း') {
          // Fetch and show tape-hot data
          _showTapeHotDialog();
        } else if (text == 'အိပ်မက် ဂဏန်း') {
          // Navigate to DreamNumberScreen
          final result = await Navigator.push<List<String>>(
            context,
            MaterialPageRoute(builder: (context) => const DreamNumberScreen()),
          );

          // If we got results back, add them to selected numbers
          if (result != null && result.isNotEmpty) {
            setState(() {
              // Add the dream numbers to selection if they're valid and not unavailable
              for (var number in result) {
                if (number.length == 2 &&
                    !unavailableNumbers.contains(number)) {
                  selectedNumbers.add(number);
                }
              }
            });
          }
        } else if (text == 'R - ပတ်လည်') {
          // Handle reverse button click
          if (selectedNumbers.isEmpty) {
            // Show alert if no numbers are selected
            _showAlertDialog('ကျေးဇူးပြု၍ အနည်းဆုံး ဂဏန်းတစ်လုံး ရွေးချယ်ပါ။');
          } else {
            // Add reversed numbers for all selected numbers
            setState(() {
              Set<String> reversedNumbers = {};

              for (var number in selectedNumbers.toList()) {
                // Create reversed number (e.g., "01" becomes "10")
                String reversedNumber = number.split('').reversed.join();

                // Only add if it's not already selected and is a valid 2-digit number
                if (!selectedNumbers.contains(reversedNumber) &&
                    reversedNumber.length == 2 &&
                    !unavailableNumbers.contains(reversedNumber)) {
                  reversedNumbers.add(reversedNumber);
                }
              }

              // Add all reversed numbers to selection
              selectedNumbers.addAll(reversedNumbers);
            });
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isLightTheme ? Colors.white : AppTheme.cardExtraColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isLightTheme
                    ? Colors.grey.shade400
                    : Colors.grey.shade800.withOpacity(0.5),
          ),
          boxShadow:
              isLightTheme
                  ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 1,
                      offset: const Offset(0, 1),
                    ),
                  ]
                  : null,
        ),
        child: Text(
          text,
          style: TextStyle(color: AppTheme.textColor, fontSize: 13),
        ),
      ),
    );
  }

  // Method to show Tape and Hot numbers dialog
  Future<void> _showTapeHotDialog() async {
    // Use already fetched data instead of fetching again
    if (_isTapeHotLoading) {
      // If still loading, show loading dialog
      setState(() {
        _isLoading = true;
      });

      // Wait for data to be loaded
      await _fetchTapeHotData();

      setState(() {
        _isLoading = false;
      });
    }

    if (!mounted) return;

    // Show dialog with tape and hot numbers
    final result = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return TapeHotSelectionDialog(
          tapeNumbers: _tapeNumbers,
          hotNumbers: _hotNumbers,
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        // Add the selected tape/hot numbers to the main selection
        for (var number in result) {
          if (!selectedNumbers.contains(number) &&
              !unavailableNumbers.contains(number)) {
            selectedNumbers.add(number);
          }
        }
      });
    }
  }

  // Helper method to show alert dialog
  void _showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Text(
            'Alert',
            style: TextStyle(
              color: AppTheme.textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(message, style: TextStyle(color: AppTheme.textColor)),
          actions: <Widget>[
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Helper method to determine if a number came from quick select
  // This is a simplified implementation; in a real app, you might want to
  // track this information more precisely
  bool _isFromQuickSelect(String number) {
    // Assumption: quick select options are always grouped in specific patterns
    // This is a simplified check - for a real implementation, you would need
    // to track the source of each number more precisely

    // For now, we'll just assume all numbers are potentially from quick select
    return true;
  }

  Widget _buildBottomButtons() {
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;

    // Calculate total amount
    final int totalAmount = selectedNumbers.length * _amount;

    return Container(
      decoration: BoxDecoration(
        color: isLightTheme ? Colors.white : AppTheme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selection count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${selectedNumbers.length} ကွက်',
                style: TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Pyidaungsu',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Amount entry field
          Container(
            decoration: BoxDecoration(
              color:
                  isLightTheme ? Colors.grey.shade100 : AppTheme.cardExtraColor,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Amount label with minimum
                Text(
                  'ထိုးငွေ (Min - $_minAmount ကျပ်)',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 14,
                    fontFamily: 'Pyidaungsu',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 12,
                      ),
                      isDense: true,
                      hintText: 'Enter amount',
                      hintStyle: TextStyle(
                        color: AppTheme.textSecondaryColor.withOpacity(0.5),
                      ),
                    ),
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _amount = int.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Total amount
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'စုစုပေါင်း - ',
                style: TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 14,
                  fontFamily: 'Pyidaungsu',
                ),
              ),
              Text(
                '$totalAmount ကျပ်',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Pyidaungsu',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Buttons
          Row(
            children: [
              // Clear button (grey)
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedNumbers.clear();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isLightTheme ? Colors.grey.shade200 : Color(0xFF3A3A3A),
                    minimumSize: const Size(double.infinity, 45),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'ဖျက်မည်',
                    style: TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Pyidaungsu',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Next button (primary color)
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () async {
                    if (selectedNumbers.isNotEmpty) {
                      // Get home data from provider
                      final homeData = ref.read(homeDataProvider);

                      // Only proceed if home data is available
                      if (homeData is AsyncData) {
                        // Get user data from the response
                        final User user = homeData.value!.user;

                        await Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => AmountEntryScreen(
                                  selectedNumbers: selectedNumbers.toList(),
                                  initialAmount: _amount,
                                  sessionName: widget.sessionName,
                                  userName: user.username,
                                  userId: user.id,
                                ),
                          ),
                        );
                        _fetchDigitData();
                      } else {
                        // Show message if data is not available
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'User data is not available. Please try again.',
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        selectedNumbers.isEmpty
                            ? Colors.grey
                            : AppTheme.primaryColor,
                    minimumSize: const Size(double.infinity, 45),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.3),
                  ),
                  child: Text(
                    'နောက်တစ်ဆင့်',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Pyidaungsu',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCurrentFormattedDate() {
    final now = DateTime.now();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = now.day.toString().padLeft(2, '0');
    final month = months[now.month - 1];
    final year = now.year.toString();

    return '$day-$month-$year';
  }

  // Method to fetch Tape and Hot numbers
  Future<void> _fetchTapeHotData() async {
    try {
      final repository = ref.read(betRepositoryProvider);
      final tapeHotData = await repository.get2DTapeHotList();

      if (mounted) {
        setState(() {
          _tapeNumbers =
              tapeHotData.isTape
                  ?.map((tape) => tape.permanentNumber ?? "")
                  .whereType<String>()
                  .toList() ??
              [];

          _hotNumbers =
              tapeHotData.isHot
                  ?.map((hot) => hot.permanentNumber ?? "")
                  .whereType<String>()
                  .toList() ??
              [];

          _isTapeHotLoading = false;
        });

        print('Tape numbers: ${_tapeNumbers.join(", ")}');
        print('Hot numbers: ${_hotNumbers.join(", ")}');
      }
    } catch (e) {
      print('Error fetching tape and hot numbers: $e');
      if (mounted) {
        setState(() {
          _tapeNumbers = [];
          _hotNumbers = [];
          _isTapeHotLoading = false;
        });
      }
    }
  }

  // Widget to build a text marquee for tape and hot numbers
  Widget _buildTapeHotMarquee() {
    // Determine if we're in a white/light theme for color adjustments
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;

    // Use a darker shade of yellow for light theme to improve visibility
    final Color tapeColor =
        isLightTheme ? Colors.amber.shade800 : Colors.yellow;

    final tapeText =
        _tapeNumbers.isNotEmpty
            ? 'ထိပ်စီး - ${_buildColoredNumbersText(_tapeNumbers, tapeColor)}'
            : '';

    final hotText =
        _hotNumbers.isNotEmpty
            ? 'ဟော့ - ${_buildColoredNumbersText(_hotNumbers, Colors.red)}'
            : '';

    final List<Widget> textWidgets = [
      if (tapeText.isNotEmpty)
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'ထိပ်စီး - ',
                style: TextStyle(color: AppTheme.textColor, fontSize: 12),
              ),
              ...buildColoredNumbersSpans(_tapeNumbers, tapeColor),
            ],
          ),
        ),
      if (hotText.isNotEmpty && tapeText.isNotEmpty)
        Text(
          '     |     ',
          style: TextStyle(color: AppTheme.textColor, fontSize: 12),
        ),
      if (hotText.isNotEmpty)
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'ဟော့ - ',
                style: TextStyle(color: AppTheme.textColor, fontSize: 12),
              ),
              ...buildColoredNumbersSpans(_hotNumbers, Colors.red),
            ],
          ),
        ),
    ];

    if (textWidgets.isEmpty) {
      return const SizedBox.shrink();
    }

    // Start auto-scrolling with animation after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isScrolling && _marqueeScrollController.hasClients) {
        _startMarqueeAnimation();
      }
    });

    return Container(
      width: double.infinity,
      height: 24,
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics:
            const NeverScrollableScrollPhysics(), // Disable manual scrolling
        controller: _marqueeScrollController,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              // Adding extra space at beginning for continuous scrolling effect
              SizedBox(width: MediaQuery.of(context).size.width * 0.5),
              Row(children: textWidgets),
              // Adding the same text again for continuous scrolling effect
              SizedBox(width: MediaQuery.of(context).size.width * 0.5),
              Row(children: textWidgets),
              SizedBox(width: MediaQuery.of(context).size.width * 0.5),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create colored number text
  String _buildColoredNumbersText(List<String> numbers, Color color) {
    return numbers.join(", ");
  }

  // Helper method to build TextSpans with colored numbers
  List<TextSpan> buildColoredNumbersSpans(List<String> numbers, Color color) {
    List<TextSpan> spans = [];

    for (int i = 0; i < numbers.length; i++) {
      // Add the number with the specified color
      spans.add(
        TextSpan(
          text: numbers[i],
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      // Add comma with the same color if not the last item
      if (i < numbers.length - 1) {
        spans.add(
          TextSpan(
            text: ", ",
            style: TextStyle(
              color: color, // Same color as the numbers
              fontSize: 12,
            ),
          ),
        );
      }
    }

    return spans;
  }

  // Method to start auto-scrolling animation for marquee
  void _startMarqueeAnimation() {
    if (!mounted || !_marqueeScrollController.hasClients) return;

    _isScrolling = true;

    // Get total scroll extent
    final double maxExtent = _marqueeScrollController.position.maxScrollExtent;

    // Define animation duration based on content length - faster speed
    final int duration = 18000; // 18 seconds for full cycle (was 25 seconds)

    // Animate to end
    _marqueeScrollController
        .animateTo(
          maxExtent,
          duration: Duration(milliseconds: duration),
          curve: Curves.linear,
        )
        .then((_) {
          // When animation completes, jump back to start and repeat
          if (mounted) {
            _marqueeScrollController.jumpTo(0);
            _isScrolling = false;
            // Start the animation again
            _startMarqueeAnimation();
          }
        });
  }
}
