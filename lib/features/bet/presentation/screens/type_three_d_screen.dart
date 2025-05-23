import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/bet/data/repositories/bet_repository.dart';
import 'package:one_x/features/bet/presentation/providers/bet_providers.dart'
    as bet_providers;
import 'package:one_x/features/bet/presentation/providers/bet_provider.dart';
import 'package:one_x/features/bet/presentation/screens/copy_3d_number_screen.dart';
import 'package:one_x/features/bet/presentation/screens/copy_number_screen.dart';
import 'package:one_x/features/bet/presentation/screens/dream_number_screen.dart';
import 'package:one_x/features/bet/presentation/screens/number_selection_3d_screen.dart';
import 'package:one_x/features/bet/presentation/screens/number_selection_screen.dart';
import 'package:one_x/features/bet/presentation/screens/quick_select_screen.dart';
import 'package:one_x/features/home/presentation/providers/home_provider.dart';
import 'package:one_x/features/home/data/models/home_model.dart';
import 'package:one_x/features/bet/domain/models/available_response.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'dart:async';
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

  // Session data for passing to other screens
  late final Map<String, dynamic> _sessionData = {
    'session_name': widget.selectedTimeSection,
    'status': 'active',
  };

  // List to store the 3D entries
  final List<ThreeDEntry> _entries = [];

  // List to store amount controllers for each entry
  final List<TextEditingController> _entryAmountControllers = [];

  // Total amount
  int _totalAmount = 0;

  // Countdown timer
  late Timer _countdownTimer;
  late int _remainingSeconds = 90; // Default to 1:30 until API data is loaded
  bool _isLoadingCountdown = true;

  // Start time and remaining time
  final String _startTime = "06:07";
  Set<String> selectedNumbers = {};
  final int _amount = 0;
  final int _minAmount = 100;
  Set<String> unavailableNumbers = {};

  // R button toggle state
  bool _isRToggled = false;

  // Bulk entry mode
  bool _isBulkEntryMode = false;
  final TextEditingController _bulkAmountController = TextEditingController();

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
  void initState() {
    super.initState();
    // Focus on the number field initially
    Future.delayed(Duration.zero, () {
      _numberFocusNode.requestFocus();
    });

    // Fetch countdown data from API
    _fetchCountdownData();
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

    // Cancel the timer to prevent memory leaks
    if (mounted) {
      _countdownTimer.cancel();
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

    setState(() {
      // Check if the original number already exists in the entries
      bool originalExists = false;
      for (int i = 0; i < _entries.length; i++) {
        if (_entries[i].number == number) {
          // Update the amount instead of adding new entry
          _entries[i] = ThreeDEntry(
            number: number,
            amount: _entries[i].amount + amount,
          );
          // Update the controller as well
          _entryAmountControllers[i].text = _entries[i].amount.toString();
          originalExists = true;
          break;
        }
      }

      // Add the entry if it doesn't exist
      if (!originalExists) {
        _entries.add(ThreeDEntry(number: number, amount: amount));
        _entryAmountControllers.add(
          TextEditingController(text: amount.toString()),
        );
      }

      // If R is toggled on, add all permutations of the number
      if (_isRToggled) {
        final permutations = _generatePermutations(number);

        // Add all permutations except the original number which is already handled
        for (final perm in permutations) {
          if (perm != number) {
            // Check if this permutation already exists
            bool permExists = false;
            for (int i = 0; i < _entries.length; i++) {
              if (_entries[i].number == perm) {
                // Update the amount instead of adding new entry
                _entries[i] = ThreeDEntry(
                  number: perm,
                  amount: _entries[i].amount + amount,
                );
                // Update the controller as well
                _entryAmountControllers[i].text = _entries[i].amount.toString();
                permExists = true;
                break;
              }
            }

            // Add the permutation if it doesn't exist
            if (!permExists) {
              _entries.add(ThreeDEntry(number: perm, amount: amount));
              _entryAmountControllers.add(
                TextEditingController(text: amount.toString()),
              );
            }
          }
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

    // Get home data from provider
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

    // Create a map of number:amount for the selected numbers
    Map<String, int> numberAmounts = {};
    List<String> selectedNumbers = [];

    for (var entry in _entries) {
      selectedNumbers.add(entry.number);
      numberAmounts[entry.number] = entry.amount;
    }

    // Navigate to amount entry screen
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => AmountEntryScreen(
                selectedNumbers: selectedNumbers,
                betType: '3D နံပါတ်',
                sessionName: widget.sessionName,
                userName: user.username,
                userId: user.id,
                type: '3D',
                numberAmounts: numberAmounts,
              ),
        ),
      );
    }
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
        // Check if the number already exists in the entries
        bool numberExists = false;
        for (int i = 0; i < _entries.length; i++) {
          if (_entries[i].number == number) {
            // Update the amount instead of adding new entry
            _entries[i] = ThreeDEntry(
              number: number,
              amount: _entries[i].amount + amount,
            );
            // Update the controller as well
            _entryAmountControllers[i].text = _entries[i].amount.toString();
            numberExists = true;
            break;
          }
        }

        // Add the original number if it doesn't exist
        if (!numberExists) {
          _entries.add(ThreeDEntry(number: number, amount: amount));
          _entryAmountControllers.add(
            TextEditingController(text: amount.toString()),
          );
        }

        // If R is toggled on, also add all permutations of the number
        if (_isRToggled) {
          final permutations = _generatePermutations(number);

          // Add all permutations except the original number which is already handled
          for (final perm in permutations) {
            if (perm != number) {
              // Check if this permutation already exists
              bool permExists = false;
              for (int i = 0; i < _entries.length; i++) {
                if (_entries[i].number == perm) {
                  // Update the amount instead of adding new entry
                  _entries[i] = ThreeDEntry(
                    number: perm,
                    amount: _entries[i].amount + amount,
                  );
                  // Update the controller as well
                  _entryAmountControllers[i].text =
                      _entries[i].amount.toString();
                  permExists = true;
                  break;
                }
              }

              // Add the permutation if it doesn't exist
              if (!permExists) {
                _entries.add(ThreeDEntry(number: perm, amount: amount));
                _entryAmountControllers.add(
                  TextEditingController(text: amount.toString()),
                );
              }
            }
          }
        }
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        child: Column(
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
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border:
                                                  AppTheme.backgroundColor
                                                              .computeLuminance() >
                                                          0.5
                                                      ? Border.all(
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade300,
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
                                                    (value) =>
                                                        _updateEntryAmount(
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
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

            // Button rows
            _buildActionButtons(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child:
                  _isBulkEntryMode
                      ? _buildBulkEntryUI()
                      : _buildNormalEntryUI(),
            ),
            _buildButtonRows(),
            SizedBox(height: 12),
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
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => NumberSelection3DScreen(
                            sessionName: widget.sessionName,
                            sessionData: _sessionData,
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
                            (context) => Copy3DNumberScreen(
                              sessionName:
                                  widget.sessionName == "morning" ||
                                          widget.sessionName == "evening"
                                      ? widget.sessionName
                                      : "morning", // Use "morning" as a fallback
                              sessionData: _sessionData,
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
          _showQuickSelectOptionsDialog();
        } else if (text == 'အိပ်မက် ဂဏန်း') {
          // Navigate to DreamNumberScreen
          final result = await Navigator.push<List<String>>(
            context,
            MaterialPageRoute(
              builder: (context) => const DreamNumberScreen(type: '3D'),
            ),
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
                      if (selectedNumbers.isNotEmpty) {
                        _processBulkSelectionResults(sameDigitNumbers);
                      }
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
                      if (selectedNumbers.isNotEmpty) {
                        _processBulkSelectionResults(evenNumbers);
                      }
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
                      if (selectedNumbers.isNotEmpty) {
                        _processBulkSelectionResults(oddNumbers);
                      }
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

  Widget _buildButtonRows() {
    // Determine if we're in a white/light theme
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
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
                minimumSize: const Size(double.infinity, 32),
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
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
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
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
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
                  fontSize: 13,
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
            // Add R toggle button for bulk entry
            GestureDetector(
              onTap: () {
                setState(() {
                  _isRToggled = !_isRToggled;
                });
              },
              child: Tooltip(
                message:
                    'ဂဏန်းအားလုံး ပါမြူတေးရှင်း (အပြန်အလှန်ဖွဲ့စည်းမှုများ)',
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color:
                        _isRToggled
                            ? (isLightTheme
                                ? Colors.amber.withOpacity(0.15)
                                : Colors.grey.shade800)
                            : (isLightTheme
                                ? Colors.grey.shade200
                                : Colors.grey.shade900),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        _isRToggled
                            ? (isLightTheme
                                ? Border.all(color: Colors.amber, width: 1.5)
                                : null)
                            : (isLightTheme
                                ? Border.all(color: Colors.grey.shade400)
                                : null),
                  ),
                  child: Center(
                    child: Text(
                      'R',
                      style: TextStyle(
                        color:
                            _isRToggled
                                ? (isLightTheme
                                    ? Colors.amber.shade800
                                    : Colors.amber)
                                : (isLightTheme
                                    ? Colors.grey.shade600
                                    : Colors.grey.shade500),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
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
          child: Tooltip(
            message: 'ဂဏန်းအားလုံး ပါမြူတေးရှင်း (အပြန်အလှန်ဖွဲ့စည်းမှုများ)',
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
