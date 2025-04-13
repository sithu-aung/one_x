import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/bet/presentation/screens/bet_slip_screen.dart';
import 'package:one_x/features/bet/presentation/screens/amount_entry_screen.dart';
import 'package:one_x/features/home/presentation/providers/home_provider.dart';
import 'package:one_x/features/bet/presentation/providers/bet_provider.dart';
import 'package:one_x/core/utils/api_service.dart'; // Contains ApiException
import 'package:one_x/core/services/storage_service.dart';
import 'dart:convert';

class CopyNumberScreen extends ConsumerStatefulWidget {
  final String sessionName;
  final String selectedTimeSection;

  const CopyNumberScreen({
    super.key,
    required this.sessionName,
    required this.selectedTimeSection,
  });

  @override
  ConsumerState<CopyNumberScreen> createState() => _CopyNumberScreenState();
}

class _CopyNumberScreenState extends ConsumerState<CopyNumberScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  late ScaffoldMessengerState _scaffoldMessenger;

  // Sample parsed data
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
        title: Text('2D ထိုးရန်', style: TextStyle(color: AppTheme.textColor)),
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
                hintText: '01 = 1000\n02 = 2000\n03 = 5000',
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
            '- ဥပမာ: ၁၂.၂၃.၃၄, 12 23 34, ၁၂*၂၃*၃၄, 12,23,34, ၁၂/၂၃/၃၄',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Text(
            '### ထိုးဂဏန်းနှင့် ထိုးငွေကြား ခွဲခြားရန် အမှတ်အသားများ',
            style: TextStyle(
              color: AppTheme.textColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '- ထိုးဂဏန်းနှင့် ထိုးငွေကြားတွင် အောက်ပါအမှတ်အသားများ သိုမဟုတ် ဖော်မြူလာများထည့်ပါ။',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '  - = (equal)',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '  - (space)',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '  - - (dash)',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '  - ဖော်မြူလာများ (အောက်တွင်ဖော်ပြထားသည်)',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '- ဥပမာ: ၁၂=၅၀၀, 12 500, ၁၂-၅၀၀',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Text(
            '### ဖော်မြူလာများ (Formula Types)',
            style: TextStyle(
              color: AppTheme.textColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '- R (နံပါတ်နှင့် ပြောင်းပြန်လှန်ထိုးခြင်း): R, r, @',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '  - ဥပမာ: ၁၂R၅၀၀ (12 နှင့် 21), 12.23R500, ၁၂r၅၀၀ ၁၀၀',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '- ဘရိတ် (ပေါင်းလဒ်တူသော နံပါတ်များ): BR, Br, br, B, b, ဘရိတ်',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '  - ဥပမာ: ၅BR၅၀၀ (05, 14, 23, 32, 41, ...)',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '- ထိပ်စီး / ရှေ့ (ပထမဂဏန်းတူသော နံပါတ်များ): TS, ts, T, t, ထိပ်စီး, ထိပ်, ရှေ့',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '  - ဥပမာ: ၁TS၅၀၀ (10, 11, 12, ..., 19)',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '- ပါ / ပတ် (နံပါတ်တစ်လုံးပါသော နံပါတ်များ): P, p, ပါ, အပါ, ပတ်',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '  - ဥပမာ: ၁P၅၀၀ (10, 11, 12, ..., 19)',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '- နောက်ပိတ် / နောက် / ပိတ် (နောက်ဆုံးဂဏန်းတူသော နံပါတ်များ): NP, Np, np, N, n, နောက်ပိတ်, နောက်, ပိတ်',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '  - ဥပမာ: ၁NP၅၀၀ (01, 11, 21, ..., 91)',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '- ခွေ (ဂဏန်းများဖြင့် ပေါင်းစပ်ထိုးခြင်း - အပူးမပါ): K, k, ခွေ, ခ',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '  - ဥပမာ: ၁၂၃K၅၀၀ (12, 13, 21, 23, 31, 32)',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '- ခွေပူး (ဂဏန်းများဖြင့် ပေါင်းစပ်ထိုးခြင်း - အပူးပါ): KP, Kp, kp, ခွေပူး, ခပူး',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '  - ဥပမာ: ၁၂၃KP၅၀၀ (11, 12, 13, 21, 22, 23, 31, 32, 33)',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '- နက္ခတ် (သတ်မှတ်ထားသော နံပါတ်များ): NK, Nk, nk, နက္ခတ်, နတ်ခက်, နတ်ခတ်, နခ',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '  - ဥပမာ: NK၅၀၀ (07, 18, 24, ...)',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '- ပါဝါ (သတ်မှတ်ထားသော နံပါတ်များ): PW, Pw, pw, ပါဝါ, ပဝ',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '  - ဥပမာ: PW၅၀၀ (05, 16, 27, ...)',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '- ညီကို / ညီနောင် (သတ်မှတ်ထားသော နံပါတ်များ): ညီကို, ညီနောင်',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '  - ဥပမာ: ညီကို၅၀၀ (10, 21, 32, ...)',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '- အပူး (ဂဏန်းတူသော နံပါတ်များ): AP, ap, A, a, အပူး, ပူး, အပူးစုံ',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '  - ဥပမာ: AP၅၀၀ (00, 11, 22, ..., 99)',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '- စုံပူး (စုံဂဏန်းတူသော နံပါတ်များ): SP, sp, စုံပူး, စပ',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '  - ဥပမာ: SP၅၀၀ (00, 22, 44, 66, 88)',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '- မပူး (မဂဏန်းတူသော နံပါတ်များ): MP, mp, မပူး, မပ',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '  - ဥပမာ: MP၅၀၀ (11, 33, 55, 77, 99)',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Text(
            '### မှတ်ချက်',
            style: TextStyle(
              color: AppTheme.textColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '- ဖော်မြူလာများကို နံပါတ်နှင့် ထိုးငွေများနှင့်အတူ အသုံးပြုနိုင်ပါသည်။',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '- ဖော်မြူလာမပါပါက ထိုးဂဏန်းနှင့် ပြောင်းပြန်လှန်ထိုးမည် (implicit R)။',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '  - ဥပမာ: ၁၂.၂၃ ၅၀၀ (12, 21, 23, 32)',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '- ဖော်မြူလာများကို အင်္ဂလိပ် သိုမဟုတ် မြန်မာစာလုံးများဖြင့် ရေးသားနိုင်ပါသည်။',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '- နံပါတ်များကို မြန်မာဂဏန်း (၀-၉) သိုမဟုတ် အာရဗီဂဏန်း (0-9) ဖြင့် ရေးသားနိုင်ပါသည်။',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final bottomPadding = isIOS ? MediaQuery.of(context).padding.bottom : 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16 + bottomPadding.toDouble(),
        top: 16,
      ),
      child: ElevatedButton(
        onPressed:
            _isLoading || _textController.text.trim().isEmpty
                ? null
                : _processInput,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey,
          minimumSize: const Size(double.infinity, 45),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 3,
        ),
        child:
            _isLoading
                ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Text(
                  'နောက်တဆင့်',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
      ),
    );
  }

  void _processInput() async {
    if (_textController.text.trim().isEmpty) {
      _showErrorMessage('ကျေးဇူးပြု၍ ဂဏန်းများနှင့် ပမာဏများကို ထည့်သွင်းပါ။');
      return;
    }

    setState(() {
      _isLoading = true;
      _parsedNumbers.clear();
      _totalAmount = 0;
    });

    try {
      final List<Map<String, dynamic>> parsedData = _parseFormattedText(
        _textController.text,
      );

      if (parsedData.isEmpty) {
        _showErrorMessage(
          'ဖော်မတ်ပုံစံမှားယွင်းနေပါသည်။ ဥပမာပုံစံများကို လေ့လာကြည့်ပါ။',
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get user data from homeDataProvider
      final homeData = ref.read(homeDataProvider);
      if (homeData is! AsyncData) {
        _showErrorMessage('သုံးစွဲသူအချက်အလက်များရယူရာတွင် ပြဿနာရှိပါသည်။');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final user = homeData.value!.user;

      // Extract numbers and create a map of number:amount
      List<String> numbers = [];
      Map<String, int> numberAmounts = {};

      for (var item in parsedData) {
        String number = item['number'];
        double amount = item['amount'];
        numbers.add(number);
        numberAmounts[number] = amount.toInt();
      }

      setState(() {
        _isLoading = false;
      });

      // Navigate to amount entry screen instead of directly submitting
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => AmountEntryScreen(
                  selectedNumbers: numbers,
                  betType: '2D နံပါတ်',
                  sessionName: widget.sessionName,
                  userName: user.username,
                  userId: user.id,
                  type: '2D',
                  numberAmounts: numberAmounts,
                ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Only show error message if it's not an ApiException
      if (e is! ApiException) {
        // Try to parse the error response
        String errorMessage = e.toString();

        try {
          // Check if the error is a JSON string containing a message
          if (e.toString().contains('{') && e.toString().contains('}')) {
            // Extract the JSON part from the error string
            final jsonStart = e.toString().indexOf('{');
            final jsonEnd = e.toString().lastIndexOf('}') + 1;
            final jsonStr = e.toString().substring(jsonStart, jsonEnd);

            // Parse the JSON
            final errorData = json.decode(jsonStr);

            // Check if there's a message field
            if (errorData.containsKey('message') &&
                errorData['message'] != null &&
                errorData['message'].toString().isNotEmpty) {
              errorMessage = errorData['message'];
            }
            // If no message but there are errors, use the first error
            else if (errorData.containsKey('errors') &&
                errorData['errors'] is Map &&
                errorData['errors'].isNotEmpty) {
              final errors = errorData['errors'];
              final firstErrorKey = errors.keys.first;
              if (errors[firstErrorKey] is List &&
                  errors[firstErrorKey].isNotEmpty) {
                errorMessage = errors[firstErrorKey][0];
              }
            }
          }
        } catch (parseError) {
          // If JSON parsing fails, use the original error message
          print('Error parsing error response: $parseError');
        }

        _showErrorMessage(errorMessage);
      }
    }
  }

  List<Map<String, dynamic>> _parseFormattedText(String text) {
    final List<Map<String, dynamic>> result = [];
    final List<String> lines = text.split('\n');

    for (final line in lines) {
      if (line.trim().isEmpty) continue;

      // Try to match the "number = amount" pattern
      final RegExp basicPattern = RegExp(r'(\d{2})\s*[=\s-]\s*(\d+)');
      final match = basicPattern.firstMatch(line);

      if (match != null) {
        final number = match.group(1);
        final amountStr = match.group(2);

        if (number != null && amountStr != null) {
          try {
            final amount = double.parse(amountStr.replaceAll(',', ''));
            result.add({'number': number, 'amount': amount});
          } catch (e) {
            // If parsing fails, skip this line
            print('Failed to parse amount: $amountStr');
          }
        }
      }
    }

    return result;
  }

  void _showErrorMessage(String message) {
    _scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
