import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/bet/presentation/screens/bet_slip_screen.dart';
import 'package:one_x/core/utils/api_service.dart'; // Contains ApiException
import 'package:one_x/core/services/storage_service.dart';
import 'package:one_x/features/home/presentation/providers/home_provider.dart';
import 'package:one_x/features/home/data/models/home_model.dart';
import 'package:one_x/features/bet/data/repositories/bet_repository.dart';
import 'package:one_x/features/bet/presentation/providers/bet_provider.dart';
import 'package:one_x/features/bet/domain/models/check_amount_response.dart';

class BetItem {
  final String number;
  String amount;
  final String betType;

  BetItem({required this.number, this.amount = '', required this.betType});
}

class AmountEntryScreen extends ConsumerStatefulWidget {
  final List<String> selectedNumbers;
  final String betType;
  final int initialAmount;
  final String sessionName;
  final String userName;
  final int userId;
  final String type;
  final Map<String, int>? numberAmounts;

  const AmountEntryScreen({
    super.key,
    required this.selectedNumbers,
    this.betType = '2D နံပါတ်',
    this.initialAmount = 0,
    required this.sessionName,
    this.userName = 'User',
    this.userId = 0,
    this.type = '2D',
    this.numberAmounts,
  });

  @override
  ConsumerState<AmountEntryScreen> createState() => _AmountEntryScreenState();
}

class _AmountEntryScreenState extends ConsumerState<AmountEntryScreen> {
  late List<BetItem> _betItems;
  int _totalAmount = 0;
  final Map<int, TextEditingController> _controllers = {};
  late ScaffoldMessengerState _scaffoldMessenger;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  void initState() {
    super.initState();
    _initBetItems();
  }

  void _initBetItems() {
    print(
      'Initializing bet items from selectedNumbers: ${widget.selectedNumbers}',
    );
    if (widget.numberAmounts != null) {
      print('Number amounts map: ${widget.numberAmounts}');
    }

    _betItems = [];

    // Process each number in the selectedNumbers list - the list is now deduplicated
    for (String number in widget.selectedNumbers) {
      String formattedAmount = '';

      // Get the amount for this number from the numberAmounts map
      if (widget.numberAmounts != null &&
          widget.numberAmounts!.containsKey(number)) {
        formattedAmount = _formatAmount(widget.numberAmounts![number]!);
        print('Number $number, setting amount to $formattedAmount');
      }
      // Otherwise use initialAmount if provided
      else if (widget.initialAmount > 0) {
        formattedAmount = _formatAmount(widget.initialAmount);
        print('Using initialAmount for $number: $formattedAmount');
      }

      _betItems.add(
        BetItem(
          number: number,
          betType: widget.betType,
          amount: formattedAmount,
        ),
      );
    }

    // Initialize controllers for each item
    for (int i = 0; i < _betItems.length; i++) {
      _controllers[i] = TextEditingController(text: _betItems[i].amount);
    }

    // Calculate initial total
    _calculateTotal();

    // Call the API to check bet amounts
    _checkBetAmounts();
  }

  void _checkBetAmounts() async {
    // Only proceed if there are bet items to check
    if (_betItems.isEmpty) return;

    try {
      // Create selections array for API request
      List<Map<String, dynamic>> selections =
          _betItems.map((item) {
            return {
              "permanent_number": item.number,
              "amount":
                  item.amount.isEmpty
                      ? 0
                      : int.parse(item.amount.replaceAll(',', '')),
              "is_tape": "inactive",
              "is_hot": "inactive",
            };
          }).toList();

      // Create API request payload
      Map<String, dynamic> requestBody = {
        "selections": selections,
        "session": widget.sessionName,
      };

      // Call the API
      final response = await ref
          .read(betRepositoryProvider)
          .checkBetAmounts(requestBody);

      // If there's information in the response, show it in a toast
      if (response.information != null && response.information!.isNotEmpty) {
        Fluttertoast.showToast(
          msg: '      ${response.information}      ',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }

      // Replace all bet items with selections from the response
      if (response.selections != null && response.selections!.isNotEmpty) {
        setState(() {
          // Clear existing items and controllers
          _betItems.clear();
          _controllers.clear();

          // Add new items from the response
          for (int i = 0; i < response.selections!.length; i++) {
            var selection = response.selections![i];
            if (selection.permanentNumber != null && selection.amount != null) {
              String formattedAmount = _formatAmount(selection.amount!);

              // Add new bet item
              _betItems.add(
                BetItem(
                  number: selection.permanentNumber!,
                  betType: widget.betType,
                  amount: formattedAmount,
                ),
              );

              // Create new controller
              _controllers[i] = TextEditingController(text: formattedAmount);
            }
          }

          // Recalculate the total amount
          _calculateTotal();
        });
      }
    } catch (e) {
      print('Error checking bet amounts: $e');
      // Don't show an error to the user, just log it
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _calculateTotal() {
    int total = 0;
    for (var item in _betItems) {
      if (item.amount.isNotEmpty) {
        total += int.tryParse(item.amount.replaceAll(',', '')) ?? 0;
      }
    }
    setState(() {
      _totalAmount = total;
    });
  }

  void _updateAmount(int index, String value) {
    if (value.isEmpty) {
      setState(() {
        _betItems[index].amount = '';
      });
      _calculateTotal();
      return;
    }

    // Parse the input value, removing any commas
    int? amount = int.tryParse(value.replaceAll(',', ''));
    if (amount != null) {
      // Format with commas
      String formattedAmount = amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );

      setState(() {
        _betItems[index].amount = formattedAmount;
      });

      // Update the controller text to show formatted value
      _controllers[index]!.value = _controllers[index]!.value.copyWith(
        text: formattedAmount,
        selection: TextSelection.collapsed(offset: formattedAmount.length),
      );

      _calculateTotal();
    }
  }

  void _removeItem(int index) {
    setState(() {
      _betItems.removeAt(index);
    });
    _calculateTotal();
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch homeDataProvider to rebuild if data changes
    final homeDataValue = ref.watch(homeDataProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.type} ထိုးရန်',
          style: TextStyle(color: AppTheme.textColor),
        ),
      ),
      body: SafeArea(
        child: homeDataValue.when(
          data:
              (homeData) => Column(
                children: [
                  _buildBalanceInfo(homeData.user.balance),
                  Expanded(child: _buildBetItemsList()),
                  _buildBottomButtons(),
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

  Widget _buildBalanceInfo(int balance) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Icon(
            Icons.account_balance_wallet,
            color: AppTheme.textColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Balance ',
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
          Text(
            '${_formatAmount(balance)} Ks.',
            style: TextStyle(
              color: AppTheme.textColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBetItemsList() {
    // Determine if we're in a white/light theme
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;

    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(16),
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
          border: isLightTheme ? Border.all(color: Colors.grey.shade300) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildListHeader(),
            const SizedBox(height: 10),
            Column(
              children: List.generate(
                _betItems.length,
                (index) => _buildBetItemRow(index),
              ),
            ),
            Divider(color: AppTheme.textSecondaryColor.withOpacity(0.3)),
            _buildTotalRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildListHeader() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            widget.betType,
            style: TextStyle(color: AppTheme.textColor, fontSize: 14),
          ),
        ),
        Expanded(
          flex: 4,
          child: Center(
            child: Text(
              'ထိုးငွေ ( ကျပ် )',
              style: TextStyle(color: AppTheme.textColor, fontSize: 14),
            ),
          ),
        ),
        const SizedBox(width: 40), // Space for delete button
      ],
    );
  }

  Widget _buildBetItemRow(int index) {
    final item = _betItems[index];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              item.number,
              style: TextStyle(
                color: AppTheme.textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.cardExtraColor,
                borderRadius: BorderRadius.circular(8),
                border:
                    AppTheme.backgroundColor.computeLuminance() > 0.5
                        ? Border.all(color: Colors.grey.shade300)
                        : null,
              ),
              child: Center(
                child: TextField(
                  controller: _controllers[index],
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textColor, fontSize: 16),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    hintText: 'Amount',
                    hintStyle: TextStyle(color: AppTheme.textSecondaryColor),
                  ),
                  onChanged: (value) => _updateAmount(index, value),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: IconButton(
              icon: Icon(Icons.close, color: AppTheme.primaryColor),
              onPressed: () => _removeItem(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Total (${_betItems.length} ကွက်)',
              style: TextStyle(
                color: AppTheme.textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              _formatAmount(_totalAmount),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 40), // Space to align with rows
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: AppTheme.cardExtraColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'ထပ်ထည့်မည်',
                    style: TextStyle(
                      color: AppTheme.getTextColorForBackground(
                        AppTheme.cardExtraColor,
                      ),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () {
                _validateAndConfirm();
              },
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'ထိုးမည်',
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
        ],
      ),
    );
  }

  void _showConfirmationDialog() {
    // First check if user data is available
    final homeData = ref.read(homeDataProvider);

    // If user data is still loading or has an error, show appropriate message
    if (homeData is AsyncLoading) {
      _scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Please wait, user data is still loading...'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    } else if (homeData is AsyncError) {
      _scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error: ${(homeData as AsyncError).error}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Extract user data
    final User user = homeData.value!.user;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppTheme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'အတည်ပြုရန်',
                      style: TextStyle(
                        color: AppTheme.getTextColorForBackground(
                          AppTheme.cardColor,
                        ),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        color: AppTheme.getTextColorForBackground(
                          AppTheme.cardColor,
                        ),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Text(
                  'သေချာပါသလား?',
                  style: TextStyle(
                    color: AppTheme.getTextColorForBackground(
                      AppTheme.cardColor,
                    ),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  user.username,
                  style: TextStyle(
                    color: AppTheme.getTextColorForBackground(
                      AppTheme.cardColor,
                    ),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        color: AppTheme.getTextColorForBackground(
                          AppTheme.cardColor,
                        ),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      '( ${_betItems.length} ကွက် )',
                      style: TextStyle(
                        color: AppTheme.getTextColorForBackground(
                          AppTheme.cardColor,
                        ),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      _formatAmount(_totalAmount),
                      style: TextStyle(
                        color: AppTheme.getTextColorForBackground(
                          AppTheme.cardColor,
                        ),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: AppTheme.cardExtraColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'NO',
                              style: TextStyle(
                                color: AppTheme.getTextColorForBackground(
                                  AppTheme.cardExtraColor,
                                ),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          // Filter out items with empty amounts
                          List<BetItem> validBetItems =
                              _betItems
                                  .where((item) => item.amount.isNotEmpty)
                                  .toList();

                          // Only proceed if there are valid bet items
                          if (validBetItems.isNotEmpty) {
                            try {
                              // Build selections array
                              List<Map<String, dynamic>> selections =
                                  validBetItems.map((item) {
                                    return {
                                      "permanent_number": item.number,
                                      "amount": int.parse(
                                        item.amount.replaceAll(',', ''),
                                      ),
                                      "is_tape": "inactive",
                                      "is_hot": "inactive",
                                    };
                                  }).toList();

                              // Build digits string
                              String digits = validBetItems
                                  .map((item) => item.number)
                                  .join(',');

                              // Create request payload
                              Map<String, dynamic> requestBody = {
                                "selections": selections,
                                "digits": digits,
                                "bet_time": _getBetTimeValue(
                                  widget.sessionName,
                                ),
                                "totalAmount": _totalAmount,
                                "user_id": user.id,
                                "name": widget.type == '3D' ? 'three' : 'twod',
                              };

                              // Make API call using repository - Choose endpoint based on type
                              final response =
                                  widget.type == '3D'
                                      ? await ref
                                          .read(betRepositoryProvider)
                                          .confirm3DBetPlacement(requestBody)
                                      : await ref
                                          .read(betRepositoryProvider)
                                          .confirm2DBetPlacement(requestBody);

                              // Check if response contains an error
                              if (response.containsKey('error') &&
                                  response['error'] == true) {
                                // Close the dialog
                                Navigator.pop(context);

                                // Extract error message
                                String errorMessage =
                                    response['message'] ?? 'An error occurred';

                                // Check if there are specific validation errors
                                if (response.containsKey('errors') &&
                                    response['errors'] is Map) {
                                  final errors = response['errors'] as Map;
                                  // Format validation errors
                                  final List<String> errorMessages = [];

                                  errors.forEach((key, value) {
                                    if (value is List && value.isNotEmpty) {
                                      errorMessages.add(value.first.toString());
                                    } else if (value != null) {
                                      errorMessages.add(value.toString());
                                    }
                                  });

                                  if (errorMessages.isNotEmpty) {
                                    errorMessage = errorMessages.join('\n');
                                  }
                                }

                                // Show error message
                                _scaffoldMessenger.showSnackBar(
                                  SnackBar(
                                    content: Text(errorMessage),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                                return;
                              }

                              Map<String, dynamic> invoiceData = {};
                              if (response.containsKey('invoice')) {
                                invoiceData = response['invoice'];
                              }

                              // Refresh homeDataProvider to update user balance
                              ref.invalidate(homeDataProvider);

                              Navigator.pop(context);

                              // Navigate to bet slip screen
                              if (mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => BetSlipScreen(
                                          betItems: validBetItems,
                                          totalAmount: _totalAmount,
                                          userName: widget.userName,
                                          invoiceData:
                                              invoiceData.isNotEmpty
                                                  ? invoiceData
                                                  : null,
                                          invoiceId:
                                              invoiceData.containsKey('id')
                                                  ? invoiceData['id']
                                                  : null,
                                        ),
                                  ),
                                );
                              }
                            } catch (e) {
                              // Check if the widget is still mounted before accessing context
                              if (mounted) {
                                // Close loading indicator if dialog is still open
                                try {
                                  Navigator.of(
                                    context,
                                    rootNavigator: true,
                                  ).pop();
                                } catch (_) {
                                  // Ignore errors if dialog is already closed
                                }

                                // Only show error notification if it's not an ApiException
                                // (ApiExceptions are already handled by the API service)
                                if (e is! ApiException) {
                                  _scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text('Error: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              }
                            }
                          } else {
                            // Show a notification that no valid bet items exist
                            _scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enter amount for at least one number',
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              'YES',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _validateAndConfirm() async {
    // Only proceed if there are bet items to check
    if (_betItems.isEmpty) {
      Fluttertoast.showToast(
        msg: '      ကျေးဇူးပြု၍ အနည်းဆုံး နံပါတ်တစ်ခု ထည့်ပါ      ',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    try {
      // Create selections array for API request
      List<Map<String, dynamic>> selections =
          _betItems.map((item) {
            return {
              "permanent_number": item.number,
              "amount":
                  item.amount.isEmpty
                      ? 0
                      : int.parse(item.amount.replaceAll(',', '')),
              "is_tape": "inactive",
              "is_hot": "inactive",
            };
          }).toList();

      // Create API request payload
      Map<String, dynamic> requestBody = {
        "selections": selections,
        "session": widget.sessionName,
      };

      // Call the API
      final response = await ref
          .read(betRepositoryProvider)
          .checkBetAmounts(requestBody);

      // If there's information in the response, show it in a toast and don't proceed
      if (response.information != null && response.information!.isNotEmpty) {
        Fluttertoast.showToast(
          msg: '      ${response.information}      ',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        // Replace all bet items with selections from the response
        if (response.selections != null && response.selections!.isNotEmpty) {
          setState(() {
            // Clear existing items and controllers
            _betItems.clear();
            _controllers.clear();

            // Add new items from the response
            for (int i = 0; i < response.selections!.length; i++) {
              var selection = response.selections![i];
              if (selection.permanentNumber != null &&
                  selection.amount != null) {
                String formattedAmount = _formatAmount(selection.amount!);

                // Add new bet item
                _betItems.add(
                  BetItem(
                    number: selection.permanentNumber!,
                    betType: widget.betType,
                    amount: formattedAmount,
                  ),
                );

                // Create new controller
                _controllers[i] = TextEditingController(text: formattedAmount);
              }
            }

            // Recalculate the total amount
            _calculateTotal();
          });
        }
        return;
      }

      // Replace all bet items with selections from the response
      if (response.selections != null && response.selections!.isNotEmpty) {
        setState(() {
          // Clear existing items and controllers
          _betItems.clear();
          _controllers.clear();

          // Add new items from the response
          for (int i = 0; i < response.selections!.length; i++) {
            var selection = response.selections![i];
            if (selection.permanentNumber != null && selection.amount != null) {
              String formattedAmount = _formatAmount(selection.amount!);

              // Add new bet item
              _betItems.add(
                BetItem(
                  number: selection.permanentNumber!,
                  betType: widget.betType,
                  amount: formattedAmount,
                ),
              );

              // Create new controller
              _controllers[i] = TextEditingController(text: formattedAmount);
            }
          }

          // Recalculate the total amount
          _calculateTotal();
        });
      }

      // If no information (no errors), proceed to show confirmation dialog
      _showConfirmationDialog();
    } catch (e) {
      print('Error validating bet: $e');
      Fluttertoast.showToast(
        msg: '      တစ်ခုခုမှားယွင်းနေပါသည်။ နောက်မှ ပြန်လည်ကြိုးစားပါ      ',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  // Helper method to ensure bet_time is always "morning" or "evening"
  String _getBetTimeValue(String sessionName) {
    // Default to morning if the value can't be determined
    if (sessionName.toLowerCase().contains("evening") ||
        sessionName.toLowerCase().contains("eve") ||
        sessionName.contains("နေ့လည်") ||
        sessionName.contains("PM") ||
        sessionName.contains("pm")) {
      return "evening";
    }
    return "morning";
  }
}
