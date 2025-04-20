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
              'အရောင်းပိတ်ချိန် - 01:30',
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
      print('Processing input text: ${_textController.text}');
      final List<Map<String, dynamic>> parsedData = _parseFormattedText(
        _textController.text,
      );

      print('Parsed data results: ${parsedData.length} entries');
      for (var entry in parsedData) {
        print('Number: ${entry['number']}, Amount: ${entry['amount']}');
      }

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

      // Create a map of number:amount and combine amounts for duplicate numbers
      Map<String, int> numberAmounts = {};
      int totalBetAmount = 0;

      for (var item in parsedData) {
        String number = item['number'];
        double amount = item['amount'];

        // Add to the total bet amount
        totalBetAmount += amount.toInt();

        // For the map, we'll combine amounts for the same number
        if (numberAmounts.containsKey(number)) {
          numberAmounts[number] = numberAmounts[number]! + amount.toInt();
          print('Combined amount for $number: ${numberAmounts[number]}');
        } else {
          numberAmounts[number] = amount.toInt();
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
      print('Total bet amount: $totalBetAmount');

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
                  selectedNumbers: uniqueNumbers,
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
    // Store parsed results directly in a list to preserve all entries including duplicates
    final List<Map<String, dynamic>> result = [];
    final List<String> lines = text.split('\n');

    print('Parsing ${lines.length} lines of input');

    // Process each line
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      print('Processing line: $line');

      // Check for direct formula + amount format (e.g., "AP500", "ညီကို၅၀၀")
      print('Checking for direct formula pattern in: "$line"');

      // Updated patterns for formula detection - simpler with better debugging
      final apPattern = RegExp(r'^(AP|ap|A|a|အပူး|ပူး|အပူးစုံ)([0-9๐-๙၀-၉]+)$');
      final spPattern = RegExp(r'^(SP|sp|စုံပူး|စပ)([0-9๐-๙၀-၉]+)$');
      final mpPattern = RegExp(r'^(MP|mp|မပူး|မပ)([0-9๐-๙၀-၉]+)$');
      final nkPattern = RegExp(
        r'^(NK|Nk|nk|နက္ခတ်|နတ်ခက်|နတ်ခတ်|နခ)([0-9๐-๙၀-၉]+)$',
      );
      final pwPattern = RegExp(r'^(PW|Pw|pw|ပါဝါ|ပဝ)([0-9๐-๙၀-၉]+)$');
      final nyikoPattern = RegExp(r'^(ညီကို|ညီနောင်)([0-9๐-๙၀-၉]+)$');

      // Add patterns for formulas with numeric arguments
      final npPattern = RegExp(
        r'^([0-9๐-๙၀-၉]+)(NP|Np|np|N\b|n\b|နောက်ပိတ်|နောက်|ပိတ်)([0-9๐-๙၀-၉]+)$',
      );
      final tsPattern = RegExp(
        r'^([0-9๐-๙၀-၉]+)(TS|ts|T\b|t\b|ထိပ်စီး|ထိပ်|ရှေ့)([0-9๐-๙၀-၉]+)$',
      );
      final pPattern = RegExp(
        r'^([0-9๐-๙၀-၉]+)(P\b|p\b|ပါ|အပါ|ပတ်)([0-9๐-๙၀-၉]+)$',
      );
      final brPattern = RegExp(
        r'^([0-9๐-๙၀-၉]+)(BR|Br|br|B\b|b\b|ဘရိတ်)([0-9๐-๙၀-၉]+)$',
      );
      final kPattern = RegExp(
        r'^([0-9๐-๙၀-၉]+)(K\b|k\b|ခွေ|ခ\b)([0-9๐-๙၀-၉]+)$',
      );
      final kpPattern = RegExp(
        r'^([0-9๐-๙၀-၉]+)(KP|Kp|kp|ခွေပူး|ခပူး)([0-9๐-๙၀-၉]+)$',
      );
      final rPattern = RegExp(r'^([0-9๐-๙၀-၉]+)([Rr@])([0-9๐-๙၀-၉]+)$');

      // Debug direct matches
      print('NK pattern match: ${nkPattern.hasMatch(line)}');
      print('PW pattern match: ${pwPattern.hasMatch(line)}');
      print('AP pattern match: ${apPattern.hasMatch(line)}');
      print('SP pattern match: ${spPattern.hasMatch(line)}');
      print('MP pattern match: ${mpPattern.hasMatch(line)}');
      print('ညီကို pattern match: ${nyikoPattern.hasMatch(line)}');
      print('NP pattern match: ${npPattern.hasMatch(line)}');

      RegExpMatch? match;
      String formulaType = "";
      String formula = "";
      String amountStr = "";

      // Try each pattern until we find a match
      if ((match = apPattern.firstMatch(line)) != null) {
        formulaType = "AP";
        formula = match!.group(1) ?? "";
        amountStr = match.group(2) ?? "";
        print('Matched AP pattern: formula=$formula, amount=$amountStr');
      } else if ((match = spPattern.firstMatch(line)) != null) {
        formulaType = "SP";
        formula = match!.group(1) ?? "";
        amountStr = match.group(2) ?? "";
        print('Matched SP pattern: formula=$formula, amount=$amountStr');
      } else if ((match = mpPattern.firstMatch(line)) != null) {
        formulaType = "MP";
        formula = match!.group(1) ?? "";
        amountStr = match.group(2) ?? "";
        print('Matched MP pattern: formula=$formula, amount=$amountStr');
      } else if ((match = nkPattern.firstMatch(line)) != null) {
        formulaType = "NK";
        formula = match!.group(1) ?? "";
        amountStr = match.group(2) ?? "";
        print('Matched NK pattern: formula=$formula, amount=$amountStr');
      } else if ((match = pwPattern.firstMatch(line)) != null) {
        formulaType = "PW";
        formula = match!.group(1) ?? "";
        amountStr = match.group(2) ?? "";
        print('Matched PW pattern: formula=$formula, amount=$amountStr');
      } else if ((match = nyikoPattern.firstMatch(line)) != null) {
        formulaType = "ညီကို";
        formula = match!.group(1) ?? "";
        amountStr = match.group(2) ?? "";
        print('Matched ညီကို pattern: formula=$formula, amount=$amountStr');
      }
      // New patterns with numeric arguments
      else if ((match = npPattern.firstMatch(line)) != null) {
        formulaType = "NP";
        formula = match!.group(2) ?? "";
        String numericPart = match.group(1) ?? "";
        amountStr = match.group(3) ?? "";
        print(
          'Matched NP pattern: digit=$numericPart, formula=$formula, amount=$amountStr',
        );
        // Set normalizedDigits for the formula application later
        numericPart = _normalizeNumber(numericPart);
        _processFormulaWithAmount(formulaType, numericPart, amountStr, result);
        continue;
      } else if ((match = tsPattern.firstMatch(line)) != null) {
        formulaType = "TS";
        formula = match!.group(2) ?? "";
        String numericPart = match.group(1) ?? "";
        amountStr = match.group(3) ?? "";
        print(
          'Matched TS pattern: digit=$numericPart, formula=$formula, amount=$amountStr',
        );
        numericPart = _normalizeNumber(numericPart);
        _processFormulaWithAmount(formulaType, numericPart, amountStr, result);
        continue;
      } else if ((match = pPattern.firstMatch(line)) != null) {
        formulaType = "P";
        formula = match!.group(2) ?? "";
        String numericPart = match.group(1) ?? "";
        amountStr = match.group(3) ?? "";
        print(
          'Matched P pattern: digit=$numericPart, formula=$formula, amount=$amountStr',
        );
        numericPart = _normalizeNumber(numericPart);
        _processFormulaWithAmount(formulaType, numericPart, amountStr, result);
        continue;
      } else if ((match = brPattern.firstMatch(line)) != null) {
        formulaType = "BR";
        formula = match!.group(2) ?? "";
        String numericPart = match.group(1) ?? "";
        amountStr = match.group(3) ?? "";
        print(
          'Matched BR pattern: digit=$numericPart, formula=$formula, amount=$amountStr',
        );
        numericPart = _normalizeNumber(numericPart);
        _processFormulaWithAmount(formulaType, numericPart, amountStr, result);
        continue;
      } else if ((match = kPattern.firstMatch(line)) != null) {
        formulaType = "K";
        formula = match!.group(2) ?? "";
        String numericPart = match.group(1) ?? "";
        amountStr = match.group(3) ?? "";
        print(
          'Matched K pattern: digit=$numericPart, formula=$formula, amount=$amountStr',
        );
        numericPart = _normalizeNumber(numericPart);
        _processFormulaWithAmount(formulaType, numericPart, amountStr, result);
        continue;
      } else if ((match = kpPattern.firstMatch(line)) != null) {
        formulaType = "KP";
        formula = match!.group(2) ?? "";
        String numericPart = match.group(1) ?? "";
        amountStr = match.group(3) ?? "";
        print(
          'Matched KP pattern: digit=$numericPart, formula=$formula, amount=$amountStr',
        );
        numericPart = _normalizeNumber(numericPart);
        _processFormulaWithAmount(formulaType, numericPart, amountStr, result);
        continue;
      } else if ((match = rPattern.firstMatch(line)) != null) {
        formulaType = "R";
        formula = match!.group(2) ?? "";
        String numericPart = match.group(1) ?? "";
        amountStr = match.group(3) ?? "";
        print(
          'Matched R pattern: digit=$numericPart, formula=$formula, amount=$amountStr',
        );
        numericPart = _normalizeNumber(numericPart);
        _processFormulaWithAmount(formulaType, numericPart, amountStr, result);
        continue;
      }

      if (formulaType.isNotEmpty && amountStr.isNotEmpty) {
        print(
          'Successfully identified formula type: $formulaType with amount: $amountStr',
        );
        try {
          // Check if amountStr contains Myanmar digits
          bool containsMyanmarDigits = RegExp(r'[၀-၉]').hasMatch(amountStr);
          print('Amount contains Myanmar digits: $containsMyanmarDigits');

          // Convert amount from Myanmar to Arabic digits
          final normalizedAmountStr = _normalizeNumber(amountStr);
          print(
            'Original amount: $amountStr, Normalized amount: $normalizedAmountStr',
          );

          // Make sure we remove any commas before parsing
          String cleanAmount = normalizedAmountStr.replaceAll(',', '');
          print('Clean amount for parsing: $cleanAmount');

          double amount = double.parse(cleanAmount);
          print('Parsed amount as number: $amount');

          // Apply the formula to get the numbers
          final numbers = _applyFormula("", formulaType, "");
          print(
            'Generated ${numbers.length} numbers from formula $formulaType: $numbers',
          );

          // Add each generated number with the specified amount
          for (final num in numbers) {
            result.add({'number': num, 'amount': amount});
            print(
              'Added number from direct formula: $num with amount: $amount',
            );
          }

          continue; // Skip the rest of the processing for this line
        } catch (e) {
          print('Error processing formula: $e');
        }
      } else {
        print(
          'No direct formula pattern matched, continuing with regular processing',
        );
      }

      // Original separator logic for other formats
      final RegExp amountSeparator = RegExp(r'[=\s-]');
      final parts = line.split(amountSeparator);

      if (parts.length >= 2) {
        // Last part is assumed to be the amount
        final amountStr = parts.last.trim();

        // Fix: Properly extract the number part without the separator
        final numbersPart = line.substring(0, line.indexOf(amountStr)).trim();
        // Remove any trailing separators that might have been left
        final cleanNumbersPart = numbersPart.replaceAll(
          RegExp(r'[=\s-]+$'),
          '',
        );

        print('Numbers part: $cleanNumbersPart, Amount part: $amountStr');

        // Convert amount from Myanmar to Arabic digits if needed
        final normalizedAmountStr = _normalizeNumber(amountStr);
        double? amount;

        try {
          amount = double.parse(normalizedAmountStr.replaceAll(',', ''));
          print('Parsed amount: $amount');
        } catch (e) {
          print('Failed to parse amount: $amountStr');
          continue;
        }

        // Process each line and extract numbers with their amounts
        _processInputForNumbers(cleanNumbersPart, amount, result);
      }
    }

    return result;
  }

  // Process input text to extract numbers and their amounts
  void _processInputForNumbers(
    String input,
    double amount,
    List<Map<String, dynamic>> result,
  ) {
    print('Processing input for numbers: $input');

    // Check if we have formula indicators in the input
    if (_hasFormula(input)) {
      print('Formula detected in: $input');

      String formulaType = "";
      String numericPart = "";

      // Extract the numeric part and identify formula with specific regex patterns

      // BR Formula (Break - numbers with same sum) - Check this BEFORE R formula
      if (RegExp(r'BR|Br|br|B\b|b\b|ဘရိတ်').hasMatch(input)) {
        formulaType = "BR";
        // Extract the digit before the BR formula identifier
        final match = RegExp(
          r'([0-9๐-๙]+)(BR|Br|br|B\b|b\b|ဘရိတ်)',
        ).firstMatch(input);
        if (match != null) {
          numericPart = match.group(1) ?? "";
          print('BR Formula: Extracted numeric part $numericPart from $input');
        }
      }
      // R Formula (Reverse) - Check AFTER BR to avoid misidentification
      else if (RegExp(r'[Rr@]').hasMatch(input)) {
        formulaType = "R";
        final match = RegExp(r'([0-9๐-๙]+)[Rr@]').firstMatch(input);
        if (match != null) {
          numericPart = match.group(1) ?? "";
        }
      }
      // TS Formula (Head/Top numbers)
      else if (RegExp(r'TS|ts|T\b|t\b|ထိပ်စီး|ထိပ်|ရှေ့').hasMatch(input)) {
        formulaType = "TS";
        final match = RegExp(
          r'([0-9๐-๙]+)(TS|ts|T\b|t\b|ထိပ်စီး|ထိပ်|ရှေ့)',
        ).firstMatch(input);
        if (match != null) {
          numericPart = match.group(1) ?? "";
        }
      }
      // NP Formula (Tail numbers) - Check BEFORE P formula to avoid misidentification
      else if (RegExp(
        r'NP|Np|np|N\b|n\b|နောက်ပိတ်|နောက်|ပိတ်',
      ).hasMatch(input)) {
        formulaType = "NP";
        final match = RegExp(
          r'([0-9๐-๙]+)(NP|Np|np|N\b|n\b|နောက်ပိတ်|နောက်|ပိတ်)|^(NP|Np|np|N\b|n\b|နောက်ပိတ်|နောက်|ပိတ်)([0-9๐-๙]+)',
        ).firstMatch(input);
        if (match != null) {
          // Check which capture group has the numeric part
          numericPart = match.group(1) ?? match.group(4) ?? "";
        }
      }
      // P Formula (Loop - numbers containing a digit)
      else if (RegExp(r'P\b|p\b|ပါ|အပါ|ပတ်').hasMatch(input)) {
        formulaType = "P";
        final match = RegExp(
          r'([0-9๐-๙]+)(P\b|p\b|ပါ|အပါ|ပတ်)|^(P\b|p\b|ပါ|အပါ|ပတ်)([0-9๐-๙]+)',
        ).firstMatch(input);
        if (match != null) {
          // Check which capture group has the numeric part
          numericPart = match.group(1) ?? match.group(4) ?? "";
        }
      }
      // KP Formula (Combinations with pairs) - Check BEFORE K formula to avoid misidentification
      else if (RegExp(r'KP|Kp|kp|ခွေပူး|ခပူး').hasMatch(input)) {
        formulaType = "KP";
        final match = RegExp(
          r'([0-9๐-๙]+)(KP|Kp|kp|ခွေပူး|ခပူး)|^(KP|Kp|kp|ခွေပူး|ခပူး)([0-9๐-๙]+)',
        ).firstMatch(input);
        if (match != null) {
          numericPart = match.group(1) ?? match.group(4) ?? "";
        }
      }
      // K Formula (Combinations without pairs)
      else if (RegExp(r'K\b|k\b|ခွေ|ခ\b').hasMatch(input)) {
        formulaType = "K";
        final match = RegExp(
          r'([0-9๐-๙]+)(K\b|k\b|ခွေ|ခ\b)|^(K\b|k\b|ခွေ|ခ\b)([0-9๐-๙]+)',
        ).firstMatch(input);
        if (match != null) {
          numericPart = match.group(1) ?? match.group(4) ?? "";
        }
      }
      // Other formulas (NK, PW, etc.) that don't require numeric part
      else if (RegExp(r'NK|Nk|nk|နက္ခတ်|နတ်ခက်|နတ်ခတ်|နခ').hasMatch(input)) {
        formulaType = "NK";
      } else if (RegExp(r'PW|Pw|pw|ပါဝါ|ပဝ').hasMatch(input)) {
        formulaType = "PW";
      } else if (RegExp(r'ညီကို|ညီနောင်').hasMatch(input)) {
        formulaType = "ညီကို";
      } else if (RegExp(r'AP|ap|A\b|a\b|အပူး|ပူး|အပူးစုံ').hasMatch(input)) {
        formulaType = "AP";
      } else if (RegExp(r'SP|sp|စုံပူး|စပ').hasMatch(input)) {
        formulaType = "SP";
      } else if (RegExp(r'MP|mp|မပူး|မပ').hasMatch(input)) {
        formulaType = "MP";
      }

      // For formulas that need a numeric part, normalize it
      if (numericPart.isNotEmpty) {
        numericPart = _normalizeNumber(numericPart);
      }

      print('Formula type detected: $formulaType, Numeric part: $numericPart');

      // Apply the formula
      final numbers = _applyFormula(input, formulaType, numericPart);
      print('Applied formula result, ${numbers.length} numbers: $numbers');

      if (numbers.isNotEmpty) {
        for (final num in numbers) {
          // Always add the number with its amount to preserve duplicates
          result.add({'number': num, 'amount': amount});
          print('Added number: $num with amount: $amount');
        }
        return;
      } else {
        print('Formula produced no numbers, skipping: $input');
      }
    }

    // Regular parsing (no formulas or formula not recognized)
    // Split numbers by various separators
    final RegExp numberSeparator = RegExp(r'[.,*/\s]+');
    final numberStrings = input.split(numberSeparator);
    print('Split input into ${numberStrings.length} parts: $numberStrings');

    for (final numStr in numberStrings) {
      if (numStr.trim().isEmpty) continue;

      // Check if individual number contains formula, but avoid recursive call with same input
      if (_hasFormula(numStr.trim()) && numStr.trim() != input) {
        print('Individual number has formula: $numStr');
        // Process this individually as it contains a formula
        _processInputForNumbers(numStr.trim(), amount, result);
        continue;
      }

      // Check if the input starts with valid digits or formula indicators
      final startsWithValid = RegExp(r'^[0-9๐-๙]').hasMatch(numStr.trim());
      if (!startsWithValid) continue; // Skip invalid formats

      // Normalize the number (Myanmar to Arabic digits)
      String normalizedNumber = _normalizeNumber(numStr.trim());

      // Remove any remaining non-digit characters that might have been left
      normalizedNumber = normalizedNumber.replaceAll(RegExp(r'[^0-9]'), '');

      print('Normalized number: $normalizedNumber');

      // Validate that it's a 2-digit number
      if (normalizedNumber.length == 2 &&
          int.tryParse(normalizedNumber) != null) {
        // Add the number with its amount directly to the result list
        result.add({'number': normalizedNumber, 'amount': amount});
        print('Added 2-digit number: $normalizedNumber with amount: $amount');
      }
    }
  }

  // Check if text contains a formula indicator
  bool _hasFormula(String text) {
    // Check for various formula indicators - order matters here, check longer patterns first
    return RegExp(
      r'BR|Br|br|B\b|b\b|ဘရိတ်|TS|ts|T\b|t\b|ထိပ်စီး|ထိပ်|ရှေ့|NP|Np|np|N\b|n\b|နောက်ပိတ်|နောက်|ပိတ်|KP|Kp|kp|ခွေပူး|ခပူး|K\b|k\b|ခွေ|ခ\b|NK|Nk|nk|နက္ခတ်|နတ်ခက်|နတ်ခတ်|နခ|PW|Pw|pw|ပါဝါ|ပဝ|P\b|p\b|ပါ|အပါ|ပတ်|[Rr@]|ညီကို|ညီနောင်|AP|ap|A\b|a\b|အပူး|ပူး|အပူးစုံ|SP|sp|စုံပူး|စပ|MP|mp|မပူး|မပ',
    ).hasMatch(text);
  }

  // Apply formula to get numbers
  List<String> _applyFormula(
    String formulaText,
    String formulaType,
    String normalizedDigits,
  ) {
    List<String> numbers = [];

    print('Applying formula $formulaType with digits "$normalizedDigits"');

    // R Formula (Reverse)
    if (formulaType == "R") {
      if (normalizedDigits.length == 2 &&
          int.tryParse(normalizedDigits) != null) {
        numbers.add(normalizedDigits);
        final reversed = normalizedDigits.split('').reversed.join('');
        if (reversed != normalizedDigits) {
          numbers.add(reversed);
        }
      }
    }
    // BR Formula (Break - numbers with same sum)
    else if (formulaType == "BR") {
      // Get the single digit that represents the sum we're looking for
      int? sumDigit;

      // Handle empty input case - use the first character from formulaText
      if (normalizedDigits.isEmpty) {
        // Try to extract the first digit from the formula text (e.g., "5BR")
        final match = RegExp(r'^([0-9๐-๙]+)').firstMatch(formulaText);
        if (match != null) {
          String extractedDigit = _normalizeNumber(match.group(1) ?? "");
          if (extractedDigit.isNotEmpty) {
            sumDigit = int.tryParse(extractedDigit[0]);
            print(
              'BR Formula: Extracted sum digit $sumDigit from formula text $formulaText',
            );
          }
        }
      } else if (normalizedDigits.isNotEmpty) {
        // Use the first character if provided directly
        sumDigit = int.tryParse(normalizedDigits[0]);
      }

      print('BR Formula: Looking for pairs that sum to $sumDigit');

      if (sumDigit != null && sumDigit >= 0 && sumDigit <= 18) {
        // Add all pairs that sum to this digit
        for (int i = 0; i <= 9; i++) {
          final j = sumDigit - i;
          if (j >= 0 && j <= 9) {
            // Format with leading zero for first digit if needed
            final formattedNumber = '$i$j';
            numbers.add(formattedNumber);
            print(
              'BR Formula: Added number $formattedNumber because $i + $j = $sumDigit',
            );
          }
        }
      } else {
        print(
          'BR Formula: Invalid sum value $sumDigit, must be between 0 and 18',
        );
      }
    }
    // TS Formula (Head/Top numbers)
    else if (formulaType == "TS") {
      final digit = normalizedDigits.isNotEmpty ? normalizedDigits[0] : '';
      if (digit.isNotEmpty && RegExp(r'[0-9]').hasMatch(digit)) {
        // Add all numbers starting with this digit
        for (int i = 0; i <= 9; i++) {
          numbers.add('$digit$i');
        }
      }
    }
    // P Formula (Loop - numbers containing a digit)
    else if (formulaType == "P") {
      final digit = normalizedDigits.isNotEmpty ? normalizedDigits[0] : '';
      if (digit.isNotEmpty && RegExp(r'[0-9]').hasMatch(digit)) {
        // Add all numbers containing this digit
        for (int i = 0; i <= 9; i++) {
          // First digit is the selected one
          numbers.add('$digit$i');
          // Second digit is the selected one
          if ('$i$digit' != '$digit$i') {
            numbers.add('$i$digit');
          }
        }
      }
    }
    // NP Formula (Tail numbers)
    else if (formulaType == "NP") {
      final digit = normalizedDigits.isNotEmpty ? normalizedDigits[0] : '';
      if (digit.isNotEmpty && RegExp(r'[0-9]').hasMatch(digit)) {
        // Add all numbers ending with this digit
        for (int i = 0; i <= 9; i++) {
          numbers.add('$i$digit');
        }
      }
    }
    // K Formula (Combinations without pairs)
    else if (formulaType == "K") {
      // Get unique digits
      final uniqueDigits = normalizedDigits.split('').toSet().toList();

      // Generate all combinations without pairs
      for (int i = 0; i < uniqueDigits.length; i++) {
        for (int j = 0; j < uniqueDigits.length; j++) {
          if (i != j) {
            numbers.add('${uniqueDigits[i]}${uniqueDigits[j]}');
          }
        }
      }
    }
    // KP Formula (Combinations with pairs)
    else if (formulaType == "KP") {
      // Get unique digits and ensure pairs are included
      final digits = normalizedDigits.split('');
      final uniqueDigits = digits.toSet().toList();

      // Generate all combinations including pairs
      for (int i = 0; i < uniqueDigits.length; i++) {
        for (int j = 0; j < uniqueDigits.length; j++) {
          numbers.add('${uniqueDigits[i]}${uniqueDigits[j]}');
        }
      }

      // Ensure all same-digit pairs (11, 22, etc.) are included
      // This ensures all possible pairs for each digit in the input
      for (int i = 0; i <= 9; i++) {
        if (digits.contains(i.toString())) {
          numbers.add('$i$i');
        }
      }

      // Remove duplicates if any
      numbers = numbers.toSet().toList();
    }
    // NK Formula (Nekkat/Zodiac)
    else if (formulaType == "NK") {
      // Updated correct Zodiac numbers
      numbers = ['07', '18', '24', '35', '69', '70', '81', '42', '53', '96'];
    }
    // PW Formula (Power)
    else if (formulaType == "PW") {
      // Updated correct Power numbers
      numbers = ['05', '16', '27', '38', '49', '50', '61', '72', '83', '94'];
    }
    // ညီကို/ညီနောင် Formula
    else if (formulaType == "ညီကို") {
      // Updated with complete set of ညီကို numbers (both directions)
      numbers = [
        '10',
        '21',
        '32',
        '43',
        '54',
        '65',
        '76',
        '87',
        '98',
        '09',
        '01',
        '12',
        '23',
        '34',
        '45',
        '56',
        '67',
        '78',
        '89',
        '90',
      ];
    }
    // AP Formula (All Pairs)
    else if (formulaType == "AP") {
      // Updated to include 00 in all pairs
      for (int i = 0; i <= 9; i++) {
        numbers.add('$i$i');
      }
    }
    // SP Formula (Even Pairs)
    else if (formulaType == "SP") {
      // Updated to include 00 in even pairs
      for (int i = 0; i <= 8; i += 2) {
        numbers.add('$i$i');
      }
    }
    // MP Formula (Odd Pairs)
    else if (formulaType == "MP") {
      // Odd pairs (already correct)
      for (int i = 1; i <= 9; i += 2) {
        numbers.add('$i$i');
      }
    }

    return numbers;
  }

  // Helper method to convert Myanmar digits to Arabic digits
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

  // Add this new method to process formula with amount
  void _processFormulaWithAmount(
    String formulaType,
    String numericPart,
    String amountStr,
    List<Map<String, dynamic>> result,
  ) {
    try {
      // Check if amountStr contains Myanmar digits
      bool containsMyanmarDigits = RegExp(r'[၀-၉]').hasMatch(amountStr);
      print('Amount contains Myanmar digits: $containsMyanmarDigits');

      // Convert amount from Myanmar to Arabic digits
      final normalizedAmountStr = _normalizeNumber(amountStr);
      print(
        'Original amount: $amountStr, Normalized amount: $normalizedAmountStr',
      );

      // Make sure we remove any commas before parsing
      String cleanAmount = normalizedAmountStr.replaceAll(',', '');
      print('Clean amount for parsing: $cleanAmount');

      double amount = double.parse(cleanAmount);
      print('Parsed amount as number: $amount');

      // Apply the formula to get the numbers
      final numbers = _applyFormula("", formulaType, numericPart);
      print(
        'Generated ${numbers.length} numbers from formula $formulaType: $numbers',
      );

      // Add each generated number with the specified amount
      for (final num in numbers) {
        result.add({'number': num, 'amount': amount});
        print('Added number from formula: $num with amount: $amount');
      }
    } catch (e) {
      print('Error processing formula with amount: $e');
    }
  }
}
