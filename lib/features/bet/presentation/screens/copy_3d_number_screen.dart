import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/bet/presentation/screens/bet_slip_screen.dart';
import 'package:one_x/features/bet/presentation/screens/amount_entry_screen.dart';
import 'package:one_x/features/bet/presentation/screens/number_selection_3d_screen.dart';
import 'package:one_x/features/bet/presentation/screens/type_three_d_screen.dart';
import 'package:one_x/features/home/presentation/providers/home_provider.dart';
import 'package:one_x/features/threed/presentation/providers/threed_provider.dart';
import 'package:one_x/features/bet/data/repositories/bet_repository.dart';
import 'package:one_x/core/utils/api_service.dart';
import 'package:one_x/core/services/storage_service.dart';
import 'package:one_x/core/constants/app_constants.dart';
import 'package:one_x/features/threed/data/models/threed_models.dart';
import 'package:one_x/features/bet/domain/models/play_session.dart';
import 'package:one_x/features/bet/domain/models/available_response.dart';
import 'package:one_x/features/bet/presentation/providers/bet_provider.dart';
import '../screens/amount_entry_screen.dart';
import 'dart:convert';
import 'dart:async';

class Copy3DNumberScreen extends ConsumerStatefulWidget {
  final String sessionName;
  final Map<String, dynamic> sessionData;

  const Copy3DNumberScreen({
    super.key,
    required this.sessionName,
    required this.sessionData,
  });

  @override
  ConsumerState<Copy3DNumberScreen> createState() => _Copy3DNumberScreenState();
}

class _Copy3DNumberScreenState extends ConsumerState<Copy3DNumberScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  bool _isLoadingCountdown = true;
  late ScaffoldMessengerState _scaffoldMessenger;

  // Countdown timer
  late Timer _countdownTimer;
  late int _remainingSeconds = 90; // Default to 1:30 until API data is loaded

  // Data storage
  final List<Map<String, dynamic>> _parsedNumbers = [];
  double _totalAmount = 0;

  // Format countdown from seconds to dd:hh:mm:ss
  String _formatCountdown(int seconds) {
    int days = seconds ~/ (24 * 3600);
    seconds = seconds % (24 * 3600);
    int hours = seconds ~/ 3600;
    seconds = seconds % 3600;
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;

    return '${days.toString().padLeft(2, '0')}:${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _countdownTimer.cancel();
          // You could add a callback here when the countdown reaches zero
          // For example, show a message or navigate away
        }
      });
    });
  }

  Future<void> _fetchCountdownData() async {
    setState(() {
      _isLoadingCountdown = true;
    });

    try {
      // Get the BetRepository from the provider
      final repository = ref.read(betRepositoryProvider);

      // Call the check3DAvailability API
      final AvailableResponse response = await repository.check3DAvailability();

      // Update the countdown with the value from the API
      setState(() {
        _remainingSeconds =
            response.countdown ?? 90; // Default to 90 seconds if null
        _isLoadingCountdown = false;
      });

      // Start the countdown timer
      _startCountdown();
    } catch (e) {
      print('Error fetching countdown data: $e');
      setState(() {
        _isLoadingCountdown = false;
        // Still start the timer with default value if API fails
        _startCountdown();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  void initState() {
    super.initState();
    // Add listener to update UI when text changes
    _textController.addListener(_onTextChanged);

    // Fetch countdown data from API
    _fetchCountdownData();
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    // Cancel the timer to prevent memory leaks
    if (mounted) {
      _countdownTimer.cancel();
    }
    super.dispose();
  }

  void _onTextChanged() {
    // Force a rebuild to update button state
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final homeDataValue = ref.watch(homeDataProvider);

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
            Text('3D ထိုးမည်', style: TextStyle(color: AppTheme.textColor)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child:
                _isLoadingCountdown
                    ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryColor,
                        ),
                      ),
                    )
                    : Text(
                      'အရောင်းပိတ်ချိန် - ${_formatCountdown(_remainingSeconds)}',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 13,
                      ),
                    ),
          ),
        ],
      ),
      body: SafeArea(
        child: homeDataValue.when(
          data:
              (homeData) => Column(
                children: [
                  _buildBalanceBar(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          _buildInputSection(),
                          Expanded(child: _buildInfoText()),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomButton(),
                ],
              ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (error, stack) => Center(
                child: Text(
                  'Error loading user data: $error',
                  style: TextStyle(color: AppTheme.textColor),
                ),
              ),
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
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => NumberSelection3DScreen(
                            sessionName: widget.sessionName,
                            sessionData: widget.sessionData,
                            countdown: _remainingSeconds,
                            type: '3D',
                          ),
                    ),
                  );
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
                    'ၐဏန်းရွေးထိုးရန်',
                    style: TextStyle(color: AppTheme.textColor, fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap:
                    () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => TypeThreeDScreen(
                              sessionName: widget.sessionName,
                              selectedTimeSection:
                                  widget.sessionData['session_name'],
                            ),
                      ),
                    ),
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    // Determine if we're in a white/light theme
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;

    return Container(
      width: double.infinity,
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
        border: isLightTheme ? Border.all(color: Colors.grey.shade300) : null,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _textController,
              style: TextStyle(color: AppTheme.textColor, fontSize: 16),
              maxLines: 10,
              decoration: InputDecoration(
                hintText: '123 = 1000\n456 = 2000\n789 = 5000',
                hintStyle: TextStyle(
                  color: AppTheme.textSecondaryColor.withOpacity(0.5),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: AppTheme.textSecondaryColor,
              ),
              onPressed: () {
                setState(() {
                  _textController.clear();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoText() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'သတိပြုရန်',
            style: TextStyle(
              color: AppTheme.textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ထိုးဂဏန်းများနှင့် ထိုးငွေများကို အောက်ပါ ပုံစံများဖြင့် ရေးသားပေးပါ။',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            'မြန်မာဂဏန်း (၀-၉) နှင့် အာရဗီဂဏန်း (0-9) နှစ်မျိုးလုံး အသုံးပြုနိုင်ပါသည်။',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Text(
            '### ထိုးဂဏန်းများကြားတွင် ခွဲခြားရန် အမှတ်အသားများ',
            style: TextStyle(
              color: AppTheme.textColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '- ထိုးဂဏန်း တလုံးနှင့်တလုံးကြားတွင် အောက်ပါအမှတ်အသားများထည့်ပါ။',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '  - . (full stop)',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '  - (space)',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '  - * (star)',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '  - , (comma)',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '  - / (slash)',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '  - | (pipe)',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Text(
            '### ထိုးငွေပမာဏဖော်ပြရန် အမှတ်အသားများ',
            style: TextStyle(
              color: AppTheme.textColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '- ဂဏန်းနှင့် ထိုးငွေကြားတွင် အောက်ပါအမှတ်အသားများထည့်ပါ။',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '  - = (equals)',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '  - - (hyphen)',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '  - : (colon)',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Text(
            '### ဥပမာများ',
            style: TextStyle(
              color: AppTheme.textColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '123=1000, 456=2000, 789=3000',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '123 456 789 - 1000',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '123:1000\n456:2000\n789:3000',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _textController.text.isNotEmpty
                  ? AppTheme.primaryColor
                  : Colors.grey.shade600,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: _textController.text.isNotEmpty ? _processCopyPaste : null,
        child:
            _isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : const Text(
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

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  void _processCopyPaste() async {
    // Show loading indicator
    setState(() {
      _isLoading = true;
    });

    try {
      // Parse the text input
      await _parseInput();

      print('Parsed numbers: ${_parsedNumbers.length}');
      for (var entry in _parsedNumbers) {
        print('Number: ${entry['number']}, Amount: ${entry['amount']}');
      }

      // If parsing was successful, navigate to amount entry screen
      if (_parsedNumbers.isNotEmpty) {
        final userData = ref.read(homeDataProvider).value?.user;
        if (userData == null) {
          throw Exception('User data not available');
        }

        // Create a map of number:amount and deduplicate numbers
        Map<String, int> numberAmounts = {};

        for (var data in _parsedNumbers) {
          String number = data['number'] as String;
          int amount = data['amount'] as int;

          // For the map, we'll combine amounts for the same number
          if (numberAmounts.containsKey(number)) {
            numberAmounts[number] = numberAmounts[number]! + amount;
            print('Combined amount for $number: ${numberAmounts[number]}');
          } else {
            numberAmounts[number] = amount;
          }
        }

        // Create a deduplicated list of numbers
        List<String> uniqueNumbers = numberAmounts.keys.toList();

        print(
          'Deduplicated numbers list (${uniqueNumbers.length}): $uniqueNumbers',
        );
        print(
          'Final numberAmounts map (${numberAmounts.length}): $numberAmounts',
        );

        setState(() {
          _isLoading = false;
        });

        // Navigate to amount entry screen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => AmountEntryScreen(
                    selectedNumbers: uniqueNumbers,
                    betType: '3D နံပါတ်',
                    sessionName: widget.sessionName,
                    userName: userData.username,
                    userId: userData.id,
                    type: '3D',
                    numberAmounts: numberAmounts,
                  ),
            ),
          );
        }
      }
    } catch (e) {
      // Show error message
      _scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _parseInput() async {
    final input = _textController.text.trim();
    if (input.isEmpty) {
      throw Exception('နံပါတ်များ ထည့်သွင်းပေးပါ');
    }

    try {
      // Clear previous data
      _parsedNumbers.clear();
      _totalAmount = 0;

      print('Processing input text: ${_textController.text}');

      // Store parsed results directly in a list to preserve all entries including duplicates
      List<Map<String, dynamic>> result = [];

      // Split by newlines for regular processing
      final lines = input.split('\n');
      print('Parsing ${lines.length} lines of input');

      for (var line in lines) {
        line = line.trim();
        if (line.isEmpty) continue;

        print('Processing line: $line');

        // Check for R formula pattern first
        if (_processRPattern(line, result)) {
          continue; // Skip regular processing for this line
        }

        // Check for direct formula pattern first (e.g., "အပူး500", "AP700", "1ထိပ်1000")
        // Handle specific formula formats before generic line processing
        if (_processFormulaLine(line, result)) {
          continue; // Skip regular processing for this line
        }

        // Improved separator logic - check for =, -, : separators
        final RegExp amountSeparator = RegExp(r'[=\-:]');

        // Check if any separator exists in the line
        if (amountSeparator.hasMatch(line)) {
          // Get the last part after the separator
          final parts = line.split(amountSeparator);

          if (parts.length >= 2) {
            // Last part is assumed to be the amount
            final amountStr = parts.last.trim();

            // Extract the number part
            final numbersPart =
                line.substring(0, line.lastIndexOf(amountStr) - 1).trim();
            // Remove any trailing separators that might have been left
            final cleanNumbersPart = numbersPart.replaceAll(
              RegExp(r'[=\-:]+$'),
              '',
            );

            print('Numbers part: $cleanNumbersPart, Amount part: $amountStr');

            // Convert amount from Myanmar to Arabic digits if needed
            final normalizedAmountStr = _normalizeNumber(amountStr);
            int? amount;

            try {
              amount = int.parse(normalizedAmountStr.replaceAll(',', ''));
              print('Parsed amount: $amount');
            } catch (e) {
              print('Failed to parse amount: $amountStr');
              continue;
            }

            // Process the numbers part with separators
            _processNumbersWithAmount(cleanNumbersPart, amount, result);
          }
        }
        // Check for space separator format - e.g., "123 456 789 2000"
        else if (line.contains(' ')) {
          final parts = line.split(' ');

          // Check if last part could be an amount
          if (parts.length >= 2) {
            final lastPart = parts.last.trim();
            // Try to convert to a number to see if it's an amount
            final normalizedLastPart = _normalizeNumber(lastPart);
            int? amount;

            try {
              amount = int.parse(normalizedLastPart.replaceAll(',', ''));
              print('Last part seems to be an amount: $amount');

              // Reconstruct the numbers part (all except the last part)
              final numbersPart = parts.sublist(0, parts.length - 1).join(' ');

              // Process the numbers with this amount
              _processNumbersWithAmount(numbersPart, amount, result);
              continue; // Skip to next line
            } catch (e) {
              print(
                'Last part is not an amount: $lastPart, treating all as numbers',
              );
              // If last part is not an amount, process the entire line as numbers with default amount
            }
          }

          // If we get here, assume equal amounts for all numbers
          _processNumbersWithEqualAmounts(line, result);
        }
        // No recognized separator, check if there's a mix of numbers and amounts
        else {
          // Try to parse the whole line as a single number
          _processSingleNumberOrFormula(line, result);
        }
      }

      // Update the parsed numbers
      _parsedNumbers.addAll(result);
      for (var entry in result) {
        _totalAmount += (entry['amount'] as int).toDouble();
      }

      if (_parsedNumbers.isEmpty) {
        throw Exception('နံပါတ်များကို မှန်ကန်စွာ ထည့်သွင်းပေးပါ');
      }
    } catch (e) {
      throw Exception('ကော်ပီကူးထိုးရာတွင် အမှားရှိနေပါသည်: ${e.toString()}');
    }
  }

  // New helper method to process R pattern
  bool _processRPattern(String line, List<Map<String, dynamic>> result) {
    // Check for R formula pattern (e.g., "123R500")
    final rPattern = RegExp(r'^([0-9๐-๙၀-၉]+)([Rr@])([0-9๐-๙၀-၉]+)$');

    if (rPattern.hasMatch(line)) {
      final match = rPattern.firstMatch(line);
      if (match != null) {
        final numberStr = _normalizeNumber(match.group(1) ?? "");
        final amountStr = _normalizeNumber(match.group(3) ?? "");

        try {
          final amount = int.parse(amountStr.replaceAll(',', ''));

          // If it's a valid 3D number, process it with the reverse formula
          if (_isValid3DNumber(numberStr)) {
            final paddedNumber = _padTo3Digits(numberStr);
            _processReverseFormula(paddedNumber, amount, result);
            return true;
          }
        } catch (e) {
          print('Failed to parse amount from R formula: $e');
        }
      }
    }

    // Check for multiple numbers with R formula (e.g., "123.456R500")
    final multiNumberRPattern = RegExp(r'^(.+?)([Rr@])([0-9๐-๙၀-၉]+)$');

    if (multiNumberRPattern.hasMatch(line)) {
      final match = multiNumberRPattern.firstMatch(line);
      if (match != null) {
        final numbersPart = match.group(1) ?? "";
        final amountStr = _normalizeNumber(match.group(3) ?? "");

        // Check if numbers part contains separators
        if (numbersPart.contains('.') ||
            numbersPart.contains(',') ||
            numbersPart.contains('*') ||
            numbersPart.contains('/') ||
            numbersPart.contains('|') ||
            numbersPart.contains(' ')) {
          try {
            final amount = int.parse(amountStr.replaceAll(',', ''));

            // Split by separators and process each number
            final RegExp numberSeparator = RegExp(r'[.,*/|\s]+');
            final numberStrings = numbersPart.split(numberSeparator);

            for (final numStr in numberStrings) {
              if (numStr.trim().isEmpty) continue;

              String normalizedNumber = _normalizeNumber(numStr.trim());
              normalizedNumber = normalizedNumber.replaceAll(
                RegExp(r'[^0-9]'),
                '',
              );

              if (_isValid3DNumber(normalizedNumber)) {
                final paddedNumber = _padTo3Digits(normalizedNumber);
                _processReverseFormula(paddedNumber, amount, result);
              }
            }

            return true;
          } catch (e) {
            print('Failed to parse amount from multi-number R formula: $e');
          }
        }
      }
    }

    return false;
  }

  // New helper method to process numbers with an amount
  void _processNumbersWithAmount(
    String numbersPart,
    int amount,
    List<Map<String, dynamic>> result,
  ) {
    // Split the numbers by common separators
    final RegExp numberSeparator = RegExp(r'[.,*/|\s]+');
    final numberStrings = numbersPart.split(numberSeparator);

    print(
      'Processing numbers with amount $amount: ${numberStrings.length} numbers found',
    );

    for (final numStr in numberStrings) {
      if (numStr.trim().isEmpty) continue;

      String normalizedNumber = _normalizeNumber(numStr.trim());
      normalizedNumber = normalizedNumber.replaceAll(RegExp(r'[^0-9]'), '');

      if (_isValid3DNumber(normalizedNumber)) {
        final paddedNumber = _padTo3Digits(normalizedNumber);
        result.add({'number': paddedNumber, 'amount': amount});
        print('Added number $paddedNumber with amount $amount');
      }
    }
  }

  // New helper method to process numbers with equal amounts
  void _processNumbersWithEqualAmounts(
    String line,
    List<Map<String, dynamic>> result,
  ) {
    // Check if we can find an amount in the line
    int? amount;
    final amountMatch = RegExp(r'([0-9๐-๙,]+)$').firstMatch(line);

    if (amountMatch != null) {
      final amountStr = _normalizeNumber(amountMatch.group(1) ?? "");
      try {
        amount = int.parse(amountStr.replaceAll(',', ''));
        print('Found amount at end of line: $amount');

        // Remove the amount part from the line for number processing
        line = line.substring(0, line.lastIndexOf(amountStr)).trim();
      } catch (e) {
        print('Failed to parse amount at end of line, using default');
        amount = 100; // Default amount if not found
      }
    } else {
      amount = 100; // Default amount if no amount is found
    }

    // Process the remaining line as numbers
    final RegExp numberSeparator = RegExp(r'[.,*/|\s]+');
    final numberStrings = line.split(numberSeparator);

    for (final numStr in numberStrings) {
      if (numStr.trim().isEmpty) continue;

      String normalizedNumber = _normalizeNumber(numStr.trim());
      normalizedNumber = normalizedNumber.replaceAll(RegExp(r'[^0-9]'), '');

      if (_isValid3DNumber(normalizedNumber)) {
        final paddedNumber = _padTo3Digits(normalizedNumber);
        result.add({'number': paddedNumber, 'amount': amount});
        print('Added number $paddedNumber with equal amount $amount');
      }
    }
  }

  // New helper method to process a single number or formula
  void _processSingleNumberOrFormula(
    String line,
    List<Map<String, dynamic>> result,
  ) {
    // Check if there's a formula indicator
    if (_hasFormula(line)) {
      print('Formula detected in single item: $line');
      // Use the existing formula processing
      _processFormulaLine(line, result);
      return;
    }

    // Try to normalize and validate as a 3D number
    String normalizedNumber = _normalizeNumber(line);
    normalizedNumber = normalizedNumber.replaceAll(RegExp(r'[^0-9]'), '');

    if (_isValid3DNumber(normalizedNumber)) {
      final paddedNumber = _padTo3Digits(normalizedNumber);
      // Use default amount since none was specified
      result.add({'number': paddedNumber, 'amount': 100});
      print('Added single number $paddedNumber with default amount 100');
    }
  }

  // Check if a line contains a formula and process it if found
  bool _processFormulaLine(String line, List<Map<String, dynamic>> result) {
    // Formula patterns - updated to properly include Myanmar digits ၀-၉
    final headPattern = RegExp(
      r'^([0-9๐-๙၀-၉]+)(T|ထိပ်|ထိပ်စီး|ရှေ့)([0-9๐-๙၀-၉]+)$',
    );
    final middlePattern = RegExp(r'^([0-9๐-๙၀-၉]+)(M|အလယ်)([0-9๐-๙၀-၉]+)$');
    final tailPattern = RegExp(
      r'^([0-9๐-๙၀-၉]+)(N|နောက်|နောက်ပိတ်|ပိတ်)([0-9๐-๙၀-၉]+)$',
    );
    final allPairsPattern = RegExp(r'^(AP|ap|အပူး|ပူး)([0-9๐-๙၀-၉]+)$');
    final evenPairsPattern = RegExp(r'^(SP|sp|စုံပူး|စပ)([0-9๐-๙၀-၉]+)$');
    final oddPairsPattern = RegExp(r'^(MP|mp|မပူး|မပ)([0-9๐-๙၀-၉]+)$');

    print('Checking formula pattern for: $line');

    RegExpMatch? match;
    String formulaType = "";
    String digit = "";
    int amount = 0;

    // Check each formula pattern
    if ((match = headPattern.firstMatch(line)) != null) {
      formulaType = "HEAD";
      digit = _normalizeNumber(match!.group(1) ?? "");
      String amountStr = match.group(3) ?? "0";
      amount = int.parse(_normalizeNumber(amountStr).replaceAll(',', ''));
      print(
        'Matched HEAD pattern: digit=$digit, amount=$amount, raw amount=$amountStr',
      );
    } else if ((match = middlePattern.firstMatch(line)) != null) {
      formulaType = "MIDDLE";
      digit = _normalizeNumber(match!.group(1) ?? "");
      String amountStr = match.group(3) ?? "0";
      amount = int.parse(_normalizeNumber(amountStr).replaceAll(',', ''));
      print(
        'Matched MIDDLE pattern: digit=$digit, amount=$amount, raw amount=$amountStr',
      );
    } else if ((match = tailPattern.firstMatch(line)) != null) {
      formulaType = "TAIL";
      digit = _normalizeNumber(match!.group(1) ?? "");
      String amountStr = match.group(3) ?? "0";
      amount = int.parse(_normalizeNumber(amountStr).replaceAll(',', ''));
      print(
        'Matched TAIL pattern: digit=$digit, amount=$amount, raw amount=$amountStr',
      );
    } else if ((match = allPairsPattern.firstMatch(line)) != null) {
      formulaType = "AP";
      String amountStr = match!.group(2) ?? "0";
      amount = int.parse(_normalizeNumber(amountStr).replaceAll(',', ''));
      print('Matched ALL PAIRS pattern: amount=$amount, raw amount=$amountStr');
    } else if ((match = evenPairsPattern.firstMatch(line)) != null) {
      formulaType = "SP";
      String amountStr = match!.group(2) ?? "0";
      amount = int.parse(_normalizeNumber(amountStr).replaceAll(',', ''));
      print(
        'Matched EVEN PAIRS pattern: amount=$amount, raw amount=$amountStr',
      );
    } else if ((match = oddPairsPattern.firstMatch(line)) != null) {
      formulaType = "MP";
      String amountStr = match!.group(2) ?? "0";
      amount = int.parse(_normalizeNumber(amountStr).replaceAll(',', ''));
      print('Matched ODD PAIRS pattern: amount=$amount, raw amount=$amountStr');
    }

    if (formulaType.isNotEmpty) {
      try {
        // Apply the formula to get the numbers
        final numbers = _applyFormula(formulaType, digit);
        print(
          'Generated ${numbers.length} numbers from formula $formulaType: $numbers',
        );

        // Add each generated number with the specified amount
        for (final num in numbers) {
          result.add({'number': num, 'amount': amount});
          print('Added number from formula: $num with amount: $amount');
        }
        return true; // Formula was processed
      } catch (e) {
        print('Error processing formula: $e');
      }
    }

    return false; // No formula was processed
  }

  // Apply formula to generate numbers
  List<String> _applyFormula(String formulaType, String digit) {
    List<String> numbers = [];

    switch (formulaType) {
      case "HEAD":
        // Generate all 3D numbers starting with the specified digit
        if (digit.length == 1 && RegExp(r'[0-9]').hasMatch(digit)) {
          for (int i = 0; i <= 9; i++) {
            for (int j = 0; j <= 9; j++) {
              numbers.add('$digit$i$j');
            }
          }
        }
        break;

      case "MIDDLE":
        // Generate all 3D numbers with the specified middle digit
        if (digit.length == 1 && RegExp(r'[0-9]').hasMatch(digit)) {
          for (int i = 0; i <= 9; i++) {
            for (int j = 0; j <= 9; j++) {
              numbers.add('$i$digit$j');
            }
          }
        }
        break;

      case "TAIL":
        // Generate all 3D numbers ending with the specified digit
        if (digit.length == 1 && RegExp(r'[0-9]').hasMatch(digit)) {
          for (int i = 0; i <= 9; i++) {
            for (int j = 0; j <= 9; j++) {
              numbers.add('$i$j$digit');
            }
          }
        }
        break;

      case "AP":
        // Generate all 3D numbers with the same digits (000, 111, ..., 999)
        for (int i = 0; i <= 9; i++) {
          numbers.add('$i$i$i');
        }
        break;

      case "SP":
        // Generate all 3D numbers with the same even digits (000, 222, ..., 888)
        for (int i = 0; i <= 8; i += 2) {
          numbers.add('$i$i$i');
        }
        break;

      case "MP":
        // Generate all 3D numbers with the same odd digits (111, 333, ..., 999)
        for (int i = 1; i <= 9; i += 2) {
          numbers.add('$i$i$i');
        }
        break;
    }

    return numbers;
  }

  // Helper method to pad numbers to 3 digits
  String _padTo3Digits(String number) {
    if (number.length == 1) {
      return '00$number'; // Pad single digit to 3 digits (e.g., "5" -> "005")
    } else if (number.length == 2) {
      return '0$number'; // Pad double digit to 3 digits (e.g., "45" -> "045")
    }
    return number; // Already 3 or more digits
  }

  // Check if text contains a formula pattern
  bool _hasFormula(String text) {
    // More comprehensive pattern checking for formulas
    return RegExp(
      r'[Rr@]|' // R formula indicators
      r'[0-9๐-๙၀-၉]+(T|ထိပ်|ထိပ်စီး|ရှေ့)|' // Head/Top formula indicators
      r'[0-9๐-๙၀-၉]+(M|အလယ်)|' // Middle formula indicators
      r'[0-9๐-๙၀-၉]+(N|နောက်|နောက်ပိတ်|ပိတ်)|' // Tail formula indicators
      r'AP|ap|အပူး|ပူး|' // All pairs formula indicators
      r'SP|sp|စုံပူး|စပ|' // Even pairs formula indicators
      r'MP|mp|မပူး|မပ', // Odd pairs formula indicators
    ).hasMatch(text);
  }

  // Helper method to process reverse formula and generate all permutations
  void _processReverseFormula(
    String numberStr,
    int amount,
    List<Map<String, dynamic>> result,
  ) {
    // Remove any remaining non-digit characters
    final cleanNumberStr = numberStr.replaceAll(RegExp(r'[^0-9]'), '');

    // Validate it's a 3-digit number
    if (_isValid3DNumber(cleanNumberStr)) {
      // Generate all permutations of the 3 digits
      final List<String> permutations = _generatePermutations(cleanNumberStr);

      print(
        'Generated ${permutations.length} permutations from $cleanNumberStr: $permutations',
      );

      // Add all permutations with the specified amount
      for (final perm in permutations) {
        result.add({'number': perm, 'amount': amount});
        print('Added permutation: $perm with amount: $amount');
      }
    }
  }

  // Generate all permutations of a 3-digit number
  List<String> _generatePermutations(String number) {
    if (number.length != 3) return [number];

    Set<String> permutations = {};

    // Get the three digits
    String a = number[0];
    String b = number[1];
    String c = number[2];

    // Add all possible permutations
    permutations.add('$a$b$c'); // Original
    permutations.add('$a$c$b');
    permutations.add('$b$a$c');
    permutations.add('$b$c$a');
    permutations.add('$c$a$b');
    permutations.add('$c$b$a');

    return permutations.toList();
  }

  void _addNumber(String number, int amount) {
    _parsedNumbers.add({'number': number, 'amount': amount});
    _totalAmount += amount;
  }

  String _normalizeNumber(String input) {
    if (input.isEmpty) {
      return input;
    }

    print('Normalizing number: $input');

    // Convert Myanmar digits to Arabic digits
    const myanmarDigits = '၀၁၂၃၄၅၆၇၈၉';
    const arabicDigits = '0123456789';

    String result = input;
    for (int i = 0; i < myanmarDigits.length; i++) {
      result = result.replaceAll(myanmarDigits[i], arabicDigits[i]);
    }

    print('After normalization: $result');
    return result;
  }

  bool _isValid3DNumber(String number) {
    // First check if it's already a valid 3-digit number
    if (number.length == 3 && int.tryParse(number) != null) {
      return true;
    }

    // For handling partial inputs with 1 or 2 digits
    if ((number.length == 1 || number.length == 2) &&
        int.tryParse(number) != null) {
      // We'll allow partial inputs with 1 or 2 digits but log a warning
      print(
        'Warning: Partial 3D number detected ($number), ideally should be 3 digits',
      );
      return true;
    }

    return false;
  }
}
