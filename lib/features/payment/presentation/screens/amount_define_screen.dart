import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/payment/application/payment_provider.dart';
import 'package:one_x/features/payment/domain/models/payment_model.dart';
import 'package:one_x/features/home/presentation/screens/home_screen.dart';

enum PaymentActionType { topUp, withdraw }

class AmountDefineScreen extends ConsumerStatefulWidget {
  final PaymentActionType type;
  final int providerId;
  final int billingId;
  final String providerName;
  final String imageLocation;

  const AmountDefineScreen({
    super.key,
    required this.type,
    required this.providerId,
    required this.billingId,
    required this.providerName,
    required this.imageLocation,
  });

  @override
  ConsumerState<AmountDefineScreen> createState() => _AmountDefineScreenState();
}

class _AmountDefineScreenState extends ConsumerState<AmountDefineScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _transactionIdController =
      TextEditingController();
  String? _selectedAmount;

  @override
  void initState() {
    super.initState();
    // Add listener to amount controller to deselect predefined amount when manually changed
    _amountController.addListener(_onAmountChanged);

    // Debug provider key
    print('Received provider key in AmountDefineScreen: ${widget.providerId}');
  }

  void _onAmountChanged() {
    // If amount is manually changed and doesn't match the selected amount, deselect it
    if (_selectedAmount != null) {
      String currentAmount = _amountController.text;
      String selectedAmount = _selectedAmount!.replaceAll(',', '');

      if (currentAmount != selectedAmount) {
        setState(() {
          _selectedAmount = null;
        });
      }
    }
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _phoneController.dispose();
    _amountController.dispose();
    _transactionIdController.dispose();
    super.dispose();
  }

  void _selectAmount(String amount) {
    setState(() {
      _selectedAmount = amount;
      _amountController.text = amount.replaceAll(',', '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AppTheme.backgroundColor.computeLuminance() < 0.5;
    final backgroundColor = AppTheme.backgroundColor;
    final textColor = AppTheme.textColor;
    final cardColor = isDarkMode ? AppTheme.cardColor : Colors.white;
    final borderColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;

    // Get screen size for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth =
        (screenWidth - 64) / 3; // 3 buttons per row with padding

    // Set status bar style based on theme
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
      ),
    );

    // Title based on payment type
    final title =
        widget.type == PaymentActionType.topUp ? 'ငွေဖြည့်ရန်' : 'ငွေထုတ်ရန်';

    // Sample balance - in a real app this would come from your API
    const walletBalance = '1,500,000 Ks';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.amber),
            onPressed: () {
              // Show info dialog if needed
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Payment provider icon
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color:
                                isDarkMode
                                    ? Colors.brown.shade900.withOpacity(0.5)
                                    : Colors.brown.shade100.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: ClipOval(
                              child: Image.network(
                                'http://13.212.81.56/storage/${widget.imageLocation}',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.account_balance_wallet,
                                    color: Colors.orange[300],
                                    size: 40,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(color: textColor, fontSize: 14),
                        decoration: InputDecoration(
                          labelText:
                              widget.type == PaymentActionType.withdraw
                                  ? 'Receiver Account Number***'
                                  : 'ငွေလွှဲသည့် ဖုန်းနံပါတ်***',
                          labelStyle: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondaryColor,
                          ),
                          floatingLabelStyle: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryColor,
                          ),
                          filled: true,
                          fillColor: AppTheme.darkGrayColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: AppTheme.primaryColor,
                              width: 1,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Transaction ID field (Only show for topup, not withdraw)
                      if (widget.type == PaymentActionType.topUp)
                        TextFormField(
                          controller: _transactionIdController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          style: TextStyle(color: textColor, fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'Transaction ID (6 digits)***',
                            labelStyle: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondaryColor,
                            ),
                            floatingLabelStyle: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondaryColor,
                            ),
                            filled: true,
                            fillColor: AppTheme.darkGrayColor,
                            counterText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: AppTheme.primaryColor,
                                width: 1,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                            alignLabelWithHint: true,
                          ),
                        ),
                      if (widget.type == PaymentActionType.topUp)
                        const SizedBox(height: 24),

                      // Amount field (with login style) - moved up in order
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: textColor, fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'ငွေပမာဏ***',
                          labelStyle: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondaryColor,
                          ),
                          floatingLabelStyle: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryColor,
                          ),
                          filled: true,
                          fillColor: AppTheme.darkGrayColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: AppTheme.primaryColor,
                              width: 1,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Text to explain the amount buttons
                      Text(
                        'အမြန် ရွေးမည်',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Amount selection grid
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildAmountButton(
                            widget.type == PaymentActionType.topUp
                                ? '3,000'
                                : '5,000',
                            buttonWidth,
                          ),
                          _buildAmountButton('10,000', buttonWidth),
                          _buildAmountButton('50,000', buttonWidth),
                          _buildAmountButton('100,000', buttonWidth),
                          _buildAmountButton('300,000', buttonWidth),
                          _buildAmountButton('500,000', buttonWidth),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom action buttons
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'မလုပ်တော့ပါ',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Validate inputs first before touching providers
                        final amount = _amountController.text.replaceAll(
                          ',',
                          '',
                        );

                        if (amount.isEmpty || double.tryParse(amount) == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a valid amount'),
                            ),
                          );
                          return;
                        }

                        if (widget.type == PaymentActionType.topUp &&
                            double.tryParse(amount)! < 3000) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Minimum top up amount is 3,000'),
                            ),
                          );
                          return;
                        }

                        if (widget.type == PaymentActionType.withdraw &&
                            double.tryParse(amount)! < 5000) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Minimum withdraw amount is 5,000'),
                            ),
                          );
                          return;
                        }

                        if (_phoneController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter account number'),
                            ),
                          );
                          return;
                        }

                        // Only validate transaction ID for top-up
                        if (widget.type == PaymentActionType.topUp) {
                          final transactionId = _transactionIdController.text;
                          if (transactionId.isEmpty ||
                              transactionId.length < 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enter a valid 6-digit transaction ID',
                                ),
                              ),
                            );
                            return;
                          }
                        }

                        // Properly handle provider ID
                        int providerId;
                        try {
                          providerId = widget.providerId;
                          print('Successfully parsed provider ID: $providerId');
                        } catch (e) {
                          print(
                            'Failed to parse provider ID from: ${widget.providerId}. Error: $e',
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Invalid provider ID format. Please try another payment provider.',
                              ),
                            ),
                          );
                          return;
                        }

                        // Validate provider ID
                        if (providerId <= 0) {
                          print('Invalid provider ID: $providerId');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Invalid provider ID. Please try another payment provider.',
                              ),
                            ),
                          );
                          return;
                        }

                        // Show loading indication for topup only
                        if (widget.type == PaymentActionType.topUp) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Successfully requested to review the deposit...',
                              ),
                            ),
                          );
                        }

                        // Use post-frame callback to avoid provider modification during build
                        WidgetsBinding.instance.addPostFrameCallback((_) async {
                          try {
                            final paymentNotifier = ref.read(
                              paymentProvider.notifier,
                            );
                            Map<String, dynamic> response;

                            if (widget.type == PaymentActionType.topUp) {
                              response = await paymentNotifier.processDeposit(
                                providerId: providerId,
                                billingId: widget.billingId,
                                amount: amount,
                                accountNumber: _phoneController.text,
                                transactionId: _transactionIdController.text,
                              );

                              if (mounted) {
                                // Display the success message from the API
                                if (response['status'] == 'success' &&
                                    response['message'] != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(response['message']),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Deposit request submitted successfully',
                                      ),
                                    ),
                                  );
                                }
                                // Navigate back to Home and set Wallet tab
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            HomeScreen(initialTabIndex: 2),
                                  ),
                                  (route) => false,
                                );
                              }
                            } else {
                              // For withdraw, use an empty string for transactionId
                              response = await paymentNotifier
                                  .processStoreWithdraw(
                                    billingId: widget.billingId,
                                    providerId: providerId,
                                    amount: amount,
                                    accountNumber: _phoneController.text,
                                    transactionId: "",
                                  );

                              if (mounted) {
                                // Always display the success message from the API for withdrawals
                                if (response['status'] == 'success' &&
                                    response['message'] != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(response['message']),
                                    ),
                                  );
                                  // Navigate back to Home and set Wallet tab
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              HomeScreen(initialTabIndex: 2),
                                    ),
                                    (route) => false,
                                  );
                                } else if (response['status'] != 'success') {
                                  // Show error message if status is not success
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        response['message'] ??
                                            'Withdrawal request failed',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  // Navigate back to Home and set Wallet tab
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              HomeScreen(initialTabIndex: 2),
                                    ),
                                    (route) => false,
                                  );
                                } else {
                                  // Fallback message if no message in response
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Withdrawal request submitted successfully',
                                      ),
                                    ),
                                  );
                                  // Navigate back to Home and set Wallet tab
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              HomeScreen(initialTabIndex: 2),
                                    ),
                                    (route) => false,
                                  );
                                }
                              }
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                ),
                              );
                            }
                            print('Error during payment process: $e');
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'အတည်ပြုမည်',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
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

  Widget _buildAmountButton(String amount, double width) {
    final isSelected = _selectedAmount == amount;
    final isDarkMode = AppTheme.backgroundColor.computeLuminance() < 0.5;

    return GestureDetector(
      onTap: () => _selectAmount(amount),
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppTheme.primaryColor
                  : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          amount,
          style: TextStyle(
            color:
                isSelected
                    ? Colors.white
                    : (isDarkMode ? Colors.white : Colors.black),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
