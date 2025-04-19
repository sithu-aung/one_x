import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/bet/presentation/screens/bet_slip_screen.dart';
import 'package:one_x/features/bet/presentation/screens/amount_entry_screen.dart';
import 'package:one_x/features/home/presentation/providers/home_provider.dart';
import 'package:one_x/features/threed/presentation/providers/threed_provider.dart';
import 'package:one_x/features/bet/data/repositories/bet_repository.dart';
import 'package:one_x/core/utils/api_service.dart';
import 'package:one_x/core/services/storage_service.dart';
import 'package:one_x/core/constants/app_constants.dart';
import 'package:one_x/features/threed/data/models/threed_models.dart';
import '../screens/amount_entry_screen.dart';
import 'dart:convert';

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
  late ScaffoldMessengerState _scaffoldMessenger;

  // Data storage
  final List<Map<String, dynamic>> _parsedNumbers = [];
  double _totalAmount = 0;

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
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
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
        backgroundColor: AppTheme.backgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('3D ထိုးရန်', style: TextStyle(color: AppTheme.textColor)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              widget.sessionName,
              style: TextStyle(color: AppTheme.primaryColor, fontSize: 13),
            ),
          ),
        ],
      ),
      body: homeDataValue.when(
        data:
            (homeData) => Column(
              children: [
                _buildBalanceInfo(homeData.user.balance),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
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
    );
  }

  Widget _buildBalanceInfo(int balance) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
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
                  'Balance ${_formatAmount(balance)} Ks.',
                  style: TextStyle(color: AppTheme.textColor, fontSize: 13),
                ),
              ],
            ),
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

      // If parsing was successful, navigate to amount entry screen
      if (_parsedNumbers.isNotEmpty) {
        final userData = ref.read(homeDataProvider).value?.user;
        if (userData == null) {
          throw Exception('User data not available');
        }

        // Extract numbers and create a map of number:amount
        List<String> numbers = [];
        Map<String, int> numberAmounts = {};

        for (var data in _parsedNumbers) {
          String number = data['number'] as String;
          int amount = data['amount'] as int;
          numbers.add(number);
          numberAmounts[number] = amount;
        }

        setState(() {
          _isLoading = false;
        });

        // Navigate to amount entry screen
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => AmountEntryScreen(
                    selectedNumbers: numbers,
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

      // Split by newlines
      final lines = input.split('\n');

      for (var line in lines) {
        line = line.trim();
        if (line.isEmpty) continue;

        // First, separate the line by common amount separators (=, -, :)
        final RegExp amountSeparator = RegExp(r'[=\-:]');
        final parts = line.split(amountSeparator);

        if (parts.length >= 2) {
          // Last part is assumed to be the amount
          final amountStr = parts.last.trim();
          final numbersPart =
              line.substring(0, line.lastIndexOf(parts.last)).trim();

          // Convert amount from Myanmar to Arabic digits if needed
          final normalizedAmountStr = _normalizeNumber(amountStr);
          int? amount;

          try {
            amount = int.parse(normalizedAmountStr.replaceAll(',', ''));
          } catch (e) {
            print('Failed to parse amount: $amountStr');
            continue;
          }

          // Split numbers by various separators
          final RegExp numberSeparator = RegExp(r'[.,*/|\s]+');
          final numberStrings = numbersPart.split(numberSeparator);

          for (final numStr in numberStrings) {
            if (numStr.trim().isEmpty) continue;

            // Normalize the number (Myanmar to Arabic digits)
            final normalizedNumber = _normalizeNumber(numStr.trim());

            // Validate that it's a 3-digit number
            if (_isValid3DNumber(normalizedNumber)) {
              _addNumber(normalizedNumber, amount);
            }
          }
        }
      }

      if (_parsedNumbers.isEmpty) {
        throw Exception('နံပါတ်များကို မှန်ကန်စွာ ထည့်သွင်းပေးပါ');
      }
    } catch (e) {
      throw Exception('ကော်ပီကူးထိုးရာတွင် အမှားရှိနေပါသည်: ${e.toString()}');
    }
  }

  void _addNumber(String number, int amount) {
    _parsedNumbers.add({'number': number, 'amount': amount});
    _totalAmount += amount;
  }

  String _normalizeNumber(String input) {
    // Convert Myanmar digits to Arabic digits if needed
    const myanmarDigits = '၀၁၂၃၄၅၆၇၈၉';
    const arabicDigits = '0123456789';

    String result = input;
    for (int i = 0; i < myanmarDigits.length; i++) {
      result = result.replaceAll(myanmarDigits[i], arabicDigits[i]);
    }

    return result;
  }

  bool _isValid3DNumber(String number) {
    // Check if it's a valid 3D number (3 digits)
    return number.length == 3 && int.tryParse(number) != null;
  }
}
