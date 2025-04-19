import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/bet/data/repositories/bet_repository.dart';
import 'package:one_x/features/bet/presentation/providers/bet_providers.dart';
import 'package:one_x/features/bet/presentation/screens/copy_number_screen.dart';
import 'package:one_x/features/bet/presentation/screens/dream_number_screen.dart';
import 'package:one_x/features/bet/presentation/screens/number_selection_screen.dart';
import 'package:one_x/features/bet/presentation/screens/quick_select_screen.dart';
import 'package:one_x/features/home/presentation/providers/home_provider.dart';
import 'package:one_x/features/home/data/models/home_model.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:one_x/features/bet/presentation/screens/bet_slip_screen.dart';
import 'package:one_x/features/bet/presentation/screens/amount_entry_screen.dart';
import 'package:one_x/core/utils/api_service.dart';

class TypeThreeDScreen extends ConsumerStatefulWidget {
  final String selectedTimeSection;
  final String sessionName;

  const TypeThreeDScreen({
    super.key,
    required this.selectedTimeSection,
    required this.sessionName,
  });

  @override
  _TypeThreeDScreenState createState() => _TypeThreeDScreenState();
}

class _TypeThreeDScreenState extends ConsumerState<TypeThreeDScreen> {
  // Controllers for the input fields
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _numberFocusNode = FocusNode();
  final FocusNode _amountFocusNode = FocusNode();

  // List to store the 3D entries
  final List<ThreeDEntry> _entries = [];

  // List to store amount controllers for each entry
  final List<TextEditingController> _entryAmountControllers = [];

  // Total amount
  int _totalAmount = 0;

  // Start time and remaining time
  final String _startTime = "06:07";
  final String _remainingTime = "00:01:02";
  Set<String> selectedNumbers = {};
  final int _amount = 0;
  final int _minAmount = 100;
  Set<String> unavailableNumbers = {};

  // R button toggle state
  bool _isRToggled = false;

  // Bulk entry mode
  bool _isBulkEntryMode = false;
  final TextEditingController _bulkAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Focus on the number field initially
    Future.delayed(Duration.zero, () {
      _numberFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _numberController.dispose();
    _amountController.dispose();
    _numberFocusNode.dispose();
    _amountFocusNode.dispose();

    // Dispose all entry amount controllers
    for (var controller in _entryAmountControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  // Show error snackbar
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Format amount with commas
  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  // Add a new entry
  void _addEntry() {
    // Validate the number
    final number = _numberController.text.trim();
    if (number.isEmpty) {
      _showError("Please enter a number");
      return;
    }

    // Validate the number is 3 digits
    if (number.length != 3 || !RegExp(r'^\d{3}$').hasMatch(number)) {
      _showError("Please enter a valid 3D number (000-999)");
      return;
    }

    // Validate the amount
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      _showError("Please enter an amount");
      return;
    }

    final amount = int.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showError("Please enter a valid amount");
      return;
    }

    // Add the entry to the list
    setState(() {
      // Add the original number
      _entries.add(ThreeDEntry(number: number, amount: amount));
      _entryAmountControllers.add(
        TextEditingController(text: amount.toString()),
      );

      // If R is toggled on, also add the reversed number
      if (_isRToggled) {
        final reversedNumber = number.split('').reversed.join();
        if (number != reversedNumber) {
          _entries.add(ThreeDEntry(number: reversedNumber, amount: amount));
          _entryAmountControllers.add(
            TextEditingController(text: amount.toString()),
          );
        }
      }

      _updateTotalAmount();

      // Clear the input fields
      _numberController.clear();
      _amountController.clear();

      // Focus back on the number field
      _numberFocusNode.requestFocus();
    });
  }

  // Delete an entry
  void _deleteEntry(int index) {
    setState(() {
      _entries.removeAt(index);
      _entryAmountControllers.removeAt(index);
      _updateTotalAmount();
    });
  }

  // Update the amount for an entry
  void _updateEntryAmount(int index, String value) {
    final newAmount = int.tryParse(value);
    if (newAmount != null && newAmount > 0) {
      setState(() {
        _entries[index] = ThreeDEntry(
          number: _entries[index].number,
          amount: newAmount,
        );
        _updateTotalAmount();
      });
    }
  }

  // Update the total amount
  void _updateTotalAmount() {
    _totalAmount = _entries.fold(0, (sum, entry) => sum + entry.amount);
  }

  // Submit the entries
  void _submitEntries() async {
    if (_entries.isEmpty) {
      _showError("Please add at least one entry");
      return;
    }

    // Show confirmation dialog
    _showConfirmationDialog();
  }

  // Show confirmation dialog with better styling
  void _showConfirmationDialog() {
    // First check if user data is available
    final homeData = ref.read(homeDataProvider);

    // If user data is still loading or has an error, show appropriate message
    if (homeData is AsyncLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait, user data is still loading...'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    } else if (homeData is AsyncError) {
      ScaffoldMessenger.of(context).showSnackBar(
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
                      '( ${_entries.length} ကွက် )',
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
                        onTap: () {
                          Navigator.pop(context);
                          _processBetPlacement(user);
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

  // Process bet placement with API call
  Future<void> _processBetPlacement(User user) async {
    try {
      // Show loading dialog
      _showLoadingDialog();

      // Build selections array in the format expected by the API
      List<Map<String, dynamic>> selections =
          _entries.map((entry) {
            return {
              "permanent_number": entry.number,
              "amount": entry.amount,
              "is_tape": "inactive",
              "is_hot": "inactive",
            };
          }).toList();

      // Build digits string
      String digits = _entries.map((entry) => entry.number).join(',');

      // Create request payload
      Map<String, dynamic> requestBody = {
        "selections": selections,
        "digits": digits,
        "bet_time": _getBetTimeValue(widget.sessionName),
        "totalAmount": _totalAmount,
        "user_id": user.id,
        "name": "three",
      };

      // Get repository from provider
      final repository = ref.read(betRepositoryProvider);

      // Call API to submit the bet
      final response = await repository.confirm3DBetPlacement(requestBody);

      // Dismiss loading dialog
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Check response
      if (response.containsKey('error') && response['error'] == true) {
        // Extract error message
        String errorMessage = response['message'] ?? 'An error occurred';

        // Check if there are specific validation errors
        if (response.containsKey('errors') && response['errors'] is Map) {
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
        _showError(errorMessage);
        return;
      }

      // Process invoice data
      Map<String, dynamic> invoiceData = {};
      if (response.containsKey('invoice')) {
        invoiceData = response['invoice'];
      }

      // Refresh homeDataProvider to update user balance
      ref.invalidate(homeDataProvider);

      // Navigate to bet slip screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => BetSlipScreen(
                  betItems:
                      _entries
                          .map(
                            (e) => BetItem(
                              number: e.number,
                              amount: e.amount.toString(),
                              betType: '3D နံပါတ်',
                            ),
                          )
                          .toList(),
                  totalAmount: _totalAmount,
                  userName: user.username,
                  invoiceData: invoiceData.isNotEmpty ? invoiceData : null,
                  invoiceId:
                      invoiceData.containsKey('id') ? invoiceData['id'] : null,
                ),
          ),
        );
      }
    } catch (e) {
      // Dismiss loading dialog if still showing
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Only show error notification if it's not an ApiException
      if (e is! ApiException) {
        _showError("Failed to place bet: $e");
      }
    }
  }

  // Get bet time value based on session name
  String _getBetTimeValue(String sessionName) {
    switch (sessionName.toLowerCase()) {
      case 'morning':
        return 'morning';
      case 'evening':
        return 'evening';
      default:
        return sessionName;
    }
  }

  // Show loading dialog
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppTheme.cardColor,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'ကျေးဇူးပြု၍ ခဏစောင့်ပါ...',
                  style: TextStyle(color: AppTheme.textColor),
                ),
              ],
            ),
          ),
    );
  }

  // Add entries in bulk
  void _addBulkEntries() {
    // Validate the amount
    final amountText = _bulkAmountController.text.trim();
    if (amountText.isEmpty) {
      _showError("Please enter an amount");
      return;
    }

    final amount = int.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showError("Please enter a valid amount");
      return;
    }

    // Add entries for all selected numbers
    setState(() {
      for (String number in selectedNumbers) {
        _entries.add(ThreeDEntry(number: number, amount: amount));
        // Create a controller for each entry
        _entryAmountControllers.add(
          TextEditingController(text: amount.toString()),
        );
      }

      _updateTotalAmount();

      // Clear the input fields and selected numbers
      _bulkAmountController.clear();
      selectedNumbers = {};

      // Exit bulk entry mode
      _isBulkEntryMode = false;
    });
  }

  // Reset bulk entry mode
  void _resetBulkEntryMode() {
    setState(() {
      selectedNumbers = {};
      _isBulkEntryMode = false;
      _bulkAmountController.clear();
    });
  }

  // Add bulk entries from quick select or dream number results
  void _processBulkSelectionResults(List<String> selectedDigits) {
    if (selectedDigits.isEmpty) return;

    // Filter out invalid numbers
    Set<String> validNumbers = {};
    for (var number in selectedDigits) {
      if (number.length == 3 && !unavailableNumbers.contains(number)) {
        validNumbers.add(number);
      }
    }

    if (validNumbers.isEmpty) return;

    setState(() {
      // Enter bulk entry mode
      _isBulkEntryMode = true;
      selectedNumbers = validNumbers;
      // Focus on the bulk amount field
      Future.delayed(Duration.zero, () {
        _bulkAmountController.clear();
        FocusScope.of(context).requestFocus(FocusNode());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: Text('3D ထိုးရန်', style: TextStyle(color: AppTheme.textColor)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              'အရောင်းပိတ်ချိန် - ${widget.selectedTimeSection}',
              style: TextStyle(color: AppTheme.primaryColor, fontSize: 13),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Balance section
          _buildBalanceBar(),

          // Entries list
          Expanded(
            child:
                _entries.isEmpty
                    ? Center(
                      child: Text(
                        'ထိုးလိုသော 3D ဂဏန်းများကို ထည့်သွင်းပါ',
                        style: TextStyle(color: AppTheme.textSecondaryColor),
                      ),
                    )
                    : Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          // Header
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '3D နံပါတ်',
                                    style: TextStyle(
                                      color: AppTheme.textColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'ထိုးငွေ (ကျပ်)',
                                    style: TextStyle(
                                      color: AppTheme.textColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(
                                  width: 40,
                                ), // Space for delete button
                              ],
                            ),
                          ),

                          // List of entries
                          Expanded(
                            child: ListView.builder(
                              itemCount: _entries.length,
                              itemBuilder: (context, index) {
                                final entry = _entries[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          entry.number,
                                          style: TextStyle(
                                            color: AppTheme.textColor,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: AppTheme.cardExtraColor,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border:
                                                AppTheme.backgroundColor
                                                            .computeLuminance() >
                                                        0.5
                                                    ? Border.all(
                                                      color:
                                                          Colors.grey.shade300,
                                                    )
                                                    : null,
                                          ),
                                          child: Center(
                                            child: TextField(
                                              controller:
                                                  index <
                                                          _entryAmountControllers
                                                              .length
                                                      ? _entryAmountControllers[index]
                                                      : TextEditingController(
                                                        text:
                                                            entry.amount
                                                                .toString(),
                                                      ),
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                              ],
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: AppTheme.textColor,
                                                fontSize: 16,
                                              ),
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                    ),
                                                hintText: 'ငွေပမာဏ',
                                                hintStyle: TextStyle(
                                                  color:
                                                      AppTheme
                                                          .textSecondaryColor,
                                                ),
                                              ),
                                              onChanged:
                                                  (value) => _updateEntryAmount(
                                                    index,
                                                    value,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.close,
                                          color: Colors.red,
                                          size: 18,
                                        ),
                                        onPressed: () => _deleteEntry(index),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          // Divider
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Divider(
                              color: AppTheme.textSecondaryColor.withOpacity(
                                0.3,
                              ),
                            ),
                          ),

                          // Total
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Text(
                                  '(${_entries.length} ကွက်)',
                                  style: TextStyle(
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Total',
                                  style: TextStyle(
                                    color: AppTheme.textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 32),
                                Text(
                                  _formatAmount(_totalAmount),
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
          ),

          // Bottom time info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ဖွင့်ချိန်: $_startTime',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'ပိတ်ချိန်ကျန်: $_remainingTime',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Button rows
          _buildActionButtons(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child:
                _isBulkEntryMode ? _buildBulkEntryUI() : _buildNormalEntryUI(),
          ),
          _buildButtonRows(),
          SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildBalanceBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => NumberSelectionScreen(
                            sessionName: widget.sessionName,
                            selectedTimeSection: widget.selectedTimeSection,
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
                    () => Navigator.push(
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

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton('အမြန် ရွေးရန်'),
            const SizedBox(width: 8),
            _buildActionButton('ထိပ်စီး ဂဏန်း'),
            const SizedBox(width: 8),
            _buildActionButton('အိပ်မက် ဂဏန်း'),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text) {
    // Determine if we're in a white/light theme
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;

    // Calculate width based on text length
    final textWidth = text.length * 10.0;
    final minWidth = 100.0;

    return GestureDetector(
      onTap: () async {
        if (text == 'အမြန် ရွေးရန်') {
          // Navigate to QuickSelectScreen and pass currently selected numbers from quick select
          final previousQuickSelectNumbers =
              selectedNumbers.where((number) => true).toList();

          final result = await Navigator.push<List<String>>(
            context,
            MaterialPageRoute(
              builder:
                  (context) => QuickSelectScreen(
                    previouslySelectedNumbers: previousQuickSelectNumbers,
                  ),
            ),
          );

          // Process results if we got any back
          if (result != null && result.isNotEmpty) {
            _processBulkSelectionResults(result);
          }
        } else if (text == 'အိပ်မက် ဂဏန်း') {
          // Navigate to DreamNumberScreen
          final result = await Navigator.push<List<String>>(
            context,
            MaterialPageRoute(builder: (context) => const DreamNumberScreen()),
          );

          // Process results if we got any back
          if (result != null && result.isNotEmpty) {
            _processBulkSelectionResults(result);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        width: math.max(textWidth, minWidth),
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
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textColor, fontSize: 13),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonRows() {
    // Determine if we're in a white/light theme
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Clear all entries
                setState(() {
                  _entries.clear();
                  _updateTotalAmount();
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
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: selectedNumbers.isEmpty ? _addEntry : _addBulkEntries,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                minimumSize: const Size(double.infinity, 45),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.3),
              ),
              child: Text(
                'အကွက်ဖြည့်မည်',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: _submitEntries,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                minimumSize: const Size(double.infinity, 45),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.3),
              ),
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
        ],
      ),
    );
  }

  // Build the UI for bulk entry mode
  Widget _buildBulkEntryUI() {
    // Determine if we're in a white/light theme
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;

    return Column(
      children: [
        // Display selected count and bulk amount input
        Row(
          children: [
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color:
                    isLightTheme
                        ? Colors.amber.withOpacity(0.15)
                        : Colors.grey.shade800,
                borderRadius: BorderRadius.circular(8),
                border:
                    isLightTheme
                        ? Border.all(color: Colors.amber, width: 1.5)
                        : null,
              ),
              child: Center(
                child: Text(
                  '${selectedNumbers.length} ကွက်',
                  style: TextStyle(
                    color: isLightTheme ? Colors.amber.shade800 : Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _bulkAmountController,
                  autofocus: true,
                  style: TextStyle(color: AppTheme.textColor),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: 'ထိုးငွေ(Min - 100 ကျပ်)',
                    hintStyle: TextStyle(color: AppTheme.textSecondaryColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onSubmitted: (_) => _addBulkEntries(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // Build the normal entry UI (when not in bulk mode)
  Widget _buildNormalEntryUI() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _numberController,
              focusNode: _numberFocusNode,
              style: TextStyle(color: AppTheme.textColor),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              decoration: InputDecoration(
                hintText: 'နံပါတ်',
                hintStyle: TextStyle(color: AppTheme.textSecondaryColor),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onSubmitted: (_) {
                _amountFocusNode.requestFocus();
              },
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            setState(() {
              _isRToggled = !_isRToggled;
            });
          },
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color:
                  _isRToggled
                      ? (AppTheme.backgroundColor.computeLuminance() > 0.5
                          ? Colors.amber.withOpacity(0.15)
                          : Colors.grey.shade800)
                      : (AppTheme.backgroundColor.computeLuminance() > 0.5
                          ? Colors.grey.shade200
                          : Colors.grey.shade900),
              borderRadius: BorderRadius.circular(8),
              border:
                  _isRToggled
                      ? (AppTheme.backgroundColor.computeLuminance() > 0.5
                          ? Border.all(color: Colors.amber, width: 1.5)
                          : null)
                      : (AppTheme.backgroundColor.computeLuminance() > 0.5
                          ? Border.all(color: Colors.grey.shade400)
                          : null),
            ),
            child: Center(
              child: Text(
                'R',
                style: TextStyle(
                  color:
                      _isRToggled
                          ? (AppTheme.backgroundColor.computeLuminance() > 0.5
                              ? Colors.amber.shade800
                              : Colors.amber)
                          : (AppTheme.backgroundColor.computeLuminance() > 0.5
                              ? Colors.grey.shade600
                              : Colors.grey.shade500),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _amountController,
              focusNode: _amountFocusNode,
              style: TextStyle(color: AppTheme.textColor),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: 'ငွေပမာဏ',
                hintStyle: TextStyle(color: AppTheme.textSecondaryColor),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onSubmitted: (_) {
                _addEntry();
              },
            ),
          ),
        ),
      ],
    );
  }
}

// Helper class for 3D entries
class ThreeDEntry {
  final String number;
  final int amount;

  ThreeDEntry({required this.number, required this.amount});
}
