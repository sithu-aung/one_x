import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/bet/presentation/screens/amount_entry_screen.dart';
import 'package:one_x/features/bet/presentation/screens/quick_select_screen.dart';
import 'package:one_x/features/bet/data/repositories/bet_repository.dart';
import 'package:one_x/core/utils/api_service.dart';
import 'package:one_x/core/services/storage_service.dart';
import 'package:one_x/features/bet/domain/models/play_session.dart';
import 'package:one_x/features/bet/presentation/screens/type_three_d_screen.dart';
import 'dart:convert';
import 'dart:math' show min;
import 'package:one_x/features/home/presentation/providers/home_provider.dart';
import 'package:one_x/features/home/data/models/home_model.dart';
import 'package:one_x/features/bet/presentation/providers/bet_provider.dart';
import 'package:one_x/features/auth/presentation/providers/auth_provider.dart';
import 'package:one_x/features/bet/presentation/screens/copy_3d_number_screen.dart';
import 'package:one_x/features/bet/presentation/screens/dream_number_screen.dart';

class NumberSelection3DScreen extends ConsumerStatefulWidget {
  final String sessionName;
  final Map<String, dynamic> sessionData;
  final String type;

  const NumberSelection3DScreen({
    super.key,
    required this.sessionName,
    required this.sessionData,
    this.type = '3D',
  });

  @override
  ConsumerState<NumberSelection3DScreen> createState() =>
      _NumberSelection3DScreenState();
}

class _NumberSelection3DScreenState
    extends ConsumerState<NumberSelection3DScreen> {
  Set<String> selectedNumbers = {};
  final TextEditingController _amountController = TextEditingController();
  int _amount = 0;
  final int _minAmount = 100; // Minimum bet amount

  // API data
  bool _isLoading = true;
  Map<String, dynamic> _apiData = {};
  Map<String, dynamic> _threeDigitsData = {};
  Map<String, dynamic> _userRemainingAmounts = {};
  Set<String> unavailableNumbers = {};
  Map<String, Map<String, dynamic>> numberIndicators = {};

  @override
  void initState() {
    super.initState();
    // Initialize with empty selection
    selectedNumbers = {};
    // Initialize amount controller with empty value
    _amountController.text = '';
    _amount = 0;

    // Fetch digit data based on session name
    _fetchDigitData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _fetchDigitData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(betRepositoryProvider);
      PlaySessionResponse data;

      // Call the API with GET method specifically targeting play-3d endpoint
      print('Calling api/user/play-3d endpoint...');
      data = await repository.get3DPlayData({});
      print('Response received from api/user/play-3d: ${data.toJson()}');

      setState(() {
        // Store data in a map format for backward compatibility
        _apiData = {
          'threeDigits': {},
          'userRemainingAmounts': [],
          'playTime': data.playTime?.toJson() ?? {},
        };

        // Process three digits data - prioritize threeDigits over twoDigits if available
        List<TwoDigits> digitsToProcess = [];

        if (data.threeDigits != null && data.threeDigits!.isNotEmpty) {
          digitsToProcess = data.threeDigits!;
          print(
            'Using threeDigits from response with ${digitsToProcess.length} items',
          );

          // Log the first few digits for debugging
          if (digitsToProcess.isNotEmpty) {
            print('Sample threeDigits data:');
            for (int i = 0; i < min(5, digitsToProcess.length); i++) {
              print('  - ${digitsToProcess[i].toJson()}');
            }
          }
        } else if (data.twoDigits != null && data.twoDigits!.isNotEmpty) {
          digitsToProcess = data.twoDigits!;
          print(
            'Using twoDigits from response with ${digitsToProcess.length} items (threeDigits was empty)',
          );
        } else {
          print(
            'WARNING: Both threeDigits and twoDigits are empty in the response',
          );
        }

        if (digitsToProcess.isNotEmpty) {
          final Map<String, dynamic> digitsMap = {};
          for (var digit in digitsToProcess) {
            if (digit.permanentNumber != null) {
              // Ensure percentage is an integer - convert if necessary
              int percentage = 0;
              if (digit.percentage is int) {
                percentage = digit.percentage ?? 0;
              } else if (digit.percentage is String) {
                percentage = int.tryParse(digit.percentage.toString()) ?? 0;
              }

              // Log for each digit to trace the mapping
              print(
                'Processing digit: ${digit.permanentNumber} with percentage: $percentage, status: ${digit.status}',
              );

              digitsMap[digit.permanentNumber!] = {
                'percentage': percentage,
                'is_tape': digit.isTape,
                'is_hot': digit.isHot,
                'status': digit.status,
              };
            } else {
              print(
                'WARNING: Found digit with null permanentNumber: ${digit.toJson()}',
              );
            }
          }
          _threeDigitsData = digitsMap;
          _apiData['threeDigits'] = digitsMap;

          // Create user remaining amounts format for compatibility
          final Map<String, dynamic> userAmounts = {};
          for (var digit in digitsToProcess) {
            if (digit.permanentNumber != null) {
              // Ensure percentage is an integer - convert if necessary
              int percentage = 0;
              if (digit.percentage is int) {
                percentage = digit.percentage ?? 0;
              } else if (digit.percentage is String) {
                percentage = int.tryParse(digit.percentage.toString()) ?? 0;
              }

              userAmounts[digit.permanentNumber!] = {
                'percentage': percentage,
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

      print(
        'API data loaded successfully. Processed ${_threeDigitsData.length} digit entries.',
      );
    } catch (e) {
      print('ERROR fetching 3D digit data: $e');
      print('Stack trace: ${e is Exception ? e.toString() : ""}');

      if (mounted) {
        setState(() {
          _apiData = {'threeDigits': {}, 'userRemainingAmounts': []};
          _isLoading = false;
        });

        // Only show error message if it's not an ApiException
        // (ApiExceptions are already handled by the API service)
        if (e is! ApiException) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load 3D digit data: $e'),
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
    print('Processing digit data for UI display...');

    // Clear existing data
    unavailableNumbers = {};
    numberIndicators = {};

    // Process directly from _threeDigitsData which contains processed percentage information
    _threeDigitsData.forEach((digitKey, digitData) {
      // Get percentage value directly from API
      // API percentage means "used percentage", not available percentage
      final dynamic rawPercentage = digitData['percentage'];
      int apiPercentage = 0;

      // Handle different types of percentage values
      if (rawPercentage is int) {
        apiPercentage = rawPercentage;
      } else if (rawPercentage is double) {
        apiPercentage = rawPercentage.round().toInt();
      } else if (rawPercentage is String) {
        apiPercentage = int.tryParse(rawPercentage) ?? 0;
      } else if (rawPercentage != null) {
        apiPercentage = int.tryParse(rawPercentage.toString()) ?? 0;
      }

      // Use API percentage directly (no reversal needed)
      final uiPercentage = apiPercentage;

      final status = digitData['status'];

      // Determine if number is unavailable
      if (status == 'inactive') {
        unavailableNumbers.add(digitKey);
      }

      // Set progress color based on UI percentage (used percentage)
      Color progressColor;
      if (uiPercentage <= 50) {
        progressColor = Colors.green;
      } else if (uiPercentage <= 90) {
        progressColor = Colors.orange;
      } else {
        progressColor = Colors.red;
      }

      // Store in indicators map (without tape or hot flags since 3D doesn't have these)
      numberIndicators[digitKey] = {
        'color': progressColor,
        'progress': uiPercentage / 100, // Convert to 0-1 scale
      };

      // Add detailed logging for important digits
      if (uiPercentage > 80 || status == 'inactive') {
        print(
          'High usage digit: $digitKey, API%: $apiPercentage, UI%: $uiPercentage, Status: $status',
        );
      }
    });

    // Also check inactive digits from API
    if (_apiData.containsKey('inactiveDigit') &&
        _apiData['inactiveDigit'] is String &&
        _apiData['inactiveDigit'].isNotEmpty) {
      final inactiveDigitsStr = _apiData['inactiveDigit'];
      try {
        final List<dynamic> inactiveDigits = json.decode(inactiveDigitsStr);
        print(
          'Found ${inactiveDigits.length} inactive digits from inactiveDigit field',
        );
        for (final digit in inactiveDigits) {
          if (digit is String) {
            unavailableNumbers.add(digit);
          }
        }
      } catch (e) {
        print('Failed to parse inactiveDigits: $e');
      }
    }

    print('Processed ${numberIndicators.length} digits with indicators');
    print('${unavailableNumbers.length} unavailable numbers');

    // Log some stats about the processed data
    int highUsageCount = 0;
    numberIndicators.forEach((key, value) {
      if (value['progress'] > 0.9) highUsageCount++;
    });
    print('Statistics: $highUsageCount digits have >90% usage');
  }

  // Check if a number was from quick select
  bool _isFromQuickSelect(String number) {
    // This is simplified; in a real app you'd maintain source tracking
    return false;
  }

  // Helper to format amount with commas
  String _formatAmount(int amount) {
    if (amount == 0) return '0';
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  void _showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: Text('Alert', style: TextStyle(color: AppTheme.textColor)),
          content: Text(message, style: TextStyle(color: AppTheme.textColor)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use HomeState from Riverpod to get wallet balance
    final homeDataValue = ref.watch(homeDataProvider);
    final walletBalance = homeDataValue.when(
      data: (data) => data.user.balance,
      loading: () => 0,
      error: (_, __) => 0,
    );
    final formattedBalance = _formatAmount(walletBalance);

    // Calculate total bet amount
    final int totalAmount = selectedNumbers.length * _amount;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.arrow_back, color: AppTheme.textColor),
            ),
            const SizedBox(width: 16),
            Text('3D ထိုးမည်', style: TextStyle(color: AppTheme.textColor)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              'အရောင်းပိတ်ရန် - 01:30',
              style: TextStyle(color: AppTheme.primaryColor, fontSize: 13),
            ),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  _buildBalanceBar(formattedBalance),
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
    );
  }

  Widget _buildBalanceBar(String formattedBalance) {
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Balance display
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: AppTheme.textColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '$formattedBalance Ks.',
                  style: TextStyle(color: AppTheme.textColor, fontSize: 13),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Manual input button
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => TypeThreeDScreen(
                        sessionName: widget.sessionName,
                        selectedTimeSection: widget.sessionData['session_name'],
                      ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      isLightTheme
                          ? Colors.grey.shade300
                          : Colors.grey.shade700,
                ),
              ),
              child: Text(
                'ၐဏန်းရိုက်ထိုးရန်',
                style: TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 12,
                  fontFamily: 'Pyidaungsu',
                ),
              ),
            ),
          ),

          // Copy-paste button
          GestureDetector(
            onTap:
                () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => Copy3DNumberScreen(
                          sessionName:
                              widget.sessionData['session_name'] == "morning" ||
                                      widget.sessionData['session_name'] ==
                                          "evening"
                                  ? widget.sessionData['session_name']
                                  : "morning", // Use "morning" as a fallback
                          sessionData: widget.sessionData,
                        ),
                  ),
                ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      isLightTheme
                          ? Colors.grey.shade300
                          : Colors.grey.shade700,
                ),
              ),
              child: Text(
                'ကော်ပီကူးထိုးရန်',
                style: TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 12,
                  fontFamily: 'Pyidaungsu',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '3D နံပါတ်များ',
            style: TextStyle(
              color: AppTheme.textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Pyidaungsu',
            ),
          ),
          Row(
            children: [
              // Add color legend button
              GestureDetector(
                onTap: () => _showColorLegendDialog(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.primaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'အညွှန်း',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${selectedNumbers.length} ရွေးချယ်ပြီး',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 14,
                  fontFamily: 'Pyidaungsu',
                ),
              ),
            ],
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
                  text: 'ထိုးငွေ 91% - 100% ',
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
            : AppTheme.cardColor);

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
                // Center content (number)
                Center(
                  child: Text(
                    '123',
                    style: TextStyle(
                      color: txtColor,
                      fontSize: 16,
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
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: AppTheme.textColor, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorLegend() {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Color indicators for legends if needed
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildActionButton('အမြန် ရွေးရန်'),
            const SizedBox(width: 8),
            _buildActionButton('အိမ်မက်'),
            const SizedBox(width: 8),
            _buildActionButton('R ပတ်လည်'),
          ],
        ),
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
      itemCount: 1000, // Show all 3D numbers (000-999)
      itemBuilder: (context, index) {
        final numberStr = index.toString().padLeft(3, '0');
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
    // Determine status colors
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;
    final double progressValue =
        indicatorData != null ? (indicatorData['progress'] ?? 0.0) : 0.0;
    final Color progressColor =
        indicatorData != null
            ? (indicatorData['color'] ?? Colors.green)
            : Colors.green;

    // Set colors based on selection state
    // Number box background color based on theme
    Color backgroundColor =
        isSelected
            ? AppTheme.primaryColor
            : (isUnavailable
                ? (isLightTheme
                    ? Colors.grey.shade300
                    : Colors.grey.withOpacity(0.3))
                : (isLightTheme ? Colors.white : AppTheme.cardColor));

    // Border color based on theme and state
    Color borderColor =
        isSelected
            ? AppTheme.primaryColor
            : (isLightTheme
                ? Colors.grey.shade400
                : Colors.grey.shade800.withOpacity(0.5));

    // Text color based on theme and state
    Color textColor =
        isSelected
            ? Colors.white
            : (isUnavailable && isLightTheme
                ? Colors.grey.shade700
                : AppTheme.textColor);

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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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

  Widget _buildActionButton(String text) {
    // Determine if we're in a white/light theme
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;

    return GestureDetector(
      onTap: () async {
        if (text == 'အမြန် ရွေးရန်') {
          // Show 3D quick select dialog with three options
          _showQuickSelectOptionsDialog();
        } else if (text == 'အိမ်မက်') {
          // Navigate to DreamNumberScreen
          final result = await Navigator.push<List<String>>(
            context,
            MaterialPageRoute(
              builder: (context) => const DreamNumberScreen(type: '3D'),
            ),
          );

          // If we got results back, add them to selected numbers
          if (result != null && result.isNotEmpty) {
            setState(() {
              // Add the dream numbers to selection if they're valid and not unavailable
              for (var number in result) {
                if (number.length == 3 &&
                    !unavailableNumbers.contains(number)) {
                  selectedNumbers.add(number);
                }
              }
            });
          }
        } else if (text == 'R ပတ်လည်') {
          // Handle reverse button click
          if (selectedNumbers.isEmpty) {
            // Show alert if no numbers are selected
            _showAlertDialog('ကျေးဇူးပြု၍ အနည်းဆုံး ဂဏန်းတစ်လုံး ရွေးချယ်ပါ။');
          } else {
            // Add reversed numbers for all selected numbers
            setState(() {
              Set<String> reversedNumbers = {};

              for (var number in selectedNumbers.toList()) {
                // Create reversed number (e.g., "123" becomes "321")
                String reversedNumber = number.split('').reversed.join();

                // Only add if it's not already selected and is a valid 3-digit number
                if (!selectedNumbers.contains(reversedNumber) &&
                    reversedNumber.length == 3 &&
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
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ]
                  : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: AppTheme.textColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Pyidaungsu',
          ),
        ),
      ),
    );
  }

  void _showQuickSelectOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppTheme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Single and Double size',
                  style: TextStyle(
                    color: AppTheme.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Three options for quick select
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickSelectOption('အပူး', Colors.red, () {
                      // Select all same numbers (000, 111, 222, etc.)
                      final sameDigitNumbers = <String>[];
                      for (int i = 0; i <= 9; i++) {
                        final sameDigit = '$i$i$i';
                        sameDigitNumbers.add(sameDigit);
                      }
                      setState(() {
                        selectedNumbers.addAll(sameDigitNumbers);
                      });
                      Navigator.pop(context);
                    }),

                    _buildQuickSelectOption('စုံပူး', Colors.green, () {
                      // Select all even same numbers (000, 222, 444, 666, 888)
                      final evenNumbers = <String>[];
                      for (int i = 0; i <= 9; i += 2) {
                        // 0, 2, 4, 6, 8
                        final digit = '$i$i$i';
                        evenNumbers.add(digit);
                      }
                      setState(() {
                        selectedNumbers.addAll(evenNumbers);
                      });
                      Navigator.pop(context);
                    }),

                    _buildQuickSelectOption('မပူး', Colors.blue, () {
                      // Select all odd same numbers (111, 333, 555, 777, 999)
                      final oddNumbers = <String>[];
                      for (int i = 1; i <= 9; i += 2) {
                        // 1, 3, 5, 7, 9
                        final digit = '$i$i$i';
                        oddNumbers.add(digit);
                      }
                      setState(() {
                        selectedNumbers.addAll(oddNumbers);
                      });
                      Navigator.pop(context);
                    }),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickSelectOption(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Pyidaungsu',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    // Calculate total amount
    final int totalAmount = selectedNumbers.length * _amount;

    // Determine if we're in a white/light theme
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLightTheme ? Colors.white : AppTheme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Amount input field
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color:
                  isLightTheme
                      ? Colors.grey.shade100
                      : Colors.grey.shade800.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              // Remove the border completely
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    style: TextStyle(color: AppTheme.textColor, fontSize: 16),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'ထိုးငွေ (Min - $_minAmount ကျပ်)',
                      hintStyle: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 14,
                        fontFamily: 'Pyidaungsu',
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _amount = int.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
                if (_amount > 0)
                  IconButton(
                    icon: Icon(Icons.clear, color: AppTheme.textSecondaryColor),
                    onPressed: () {
                      setState(() {
                        _amountController.clear();
                        _amount = 0;
                      });
                    },
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Total amount display
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'စုစုပေါင်း: ${_formatAmount(totalAmount)} ကျပ်',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Pyidaungsu',
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Bottom buttons
          Row(
            children: [
              // Cancel button
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedNumbers.clear();
                      _amountController.clear();
                      _amount = 0;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'ဖျက်မည်',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Pyidaungsu',
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Next button - only disabled if no numbers are selected
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed:
                      selectedNumbers.isEmpty
                          ? null
                          : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => AmountEntryScreen(
                                      selectedNumbers: selectedNumbers.toList(),
                                      sessionName: widget.sessionName,
                                      betType: '3D နံပါတ်',
                                      initialAmount: _amount,
                                      type: '3D',
                                    ),
                              ),
                            );
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBackgroundColor: AppTheme.primaryColor.withOpacity(
                      0.5,
                    ),
                  ),
                  child: const Text(
                    'ဆက်လုပ်မည်',
                    style: TextStyle(
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
}
