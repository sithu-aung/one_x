import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/payment/application/payment_provider.dart';
import 'package:one_x/features/payment/domain/models/payment_model.dart';

class WithdrawAmountDefineScreen extends ConsumerStatefulWidget {
  const WithdrawAmountDefineScreen({super.key});

  @override
  ConsumerState<WithdrawAmountDefineScreen> createState() =>
      _WithdrawAmountDefineScreenState();
}

class _WithdrawAmountDefineScreenState
    extends ConsumerState<WithdrawAmountDefineScreen> {
  final TextEditingController _amountController = TextEditingController();
  String? _selectedAmount;
  PaymentProviderModel? _selectedProvider;

  @override
  void initState() {
    super.initState();
    // Add listener to amount controller to deselect predefined amount when manually changed
    _amountController.addListener(_onAmountChanged);

    // Load withdrawal providers when screen initializes
    Future(() {
      ref.read(paymentProvider.notifier).loadWithdrawalProviders();
    });
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
    _amountController.dispose();
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

    // Watch withdrawal providers
    final providersAsyncValue = ref.watch(withdrawalProvidersProvider);

    // Set status bar style based on theme
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
      ),
    );

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
          'ငွေထုတ်ရန်',
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bank Provider Dropdown
                    providersAsyncValue.when(
                      data: (providers) {
                        if (providers.isEmpty) {
                          return Center(
                            child: Text(
                              'No withdrawal providers available',
                              style: TextStyle(color: textColor),
                            ),
                          );
                        }

                        // Set default selected provider if not yet selected
                        if (_selectedProvider == null && providers.isNotEmpty) {
                          // Defer the setState to avoid build-time changes
                          Future.microtask(() {
                            setState(() {
                              _selectedProvider = providers.first;
                            });
                          });
                        }

                        return Container(
                          decoration: BoxDecoration(
                            color: AppTheme.darkGrayColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonFormField<PaymentProviderModel>(
                            value: _selectedProvider,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Bank Provider***',
                              labelStyle: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondaryColor,
                              ),
                              floatingLabelStyle: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondaryColor,
                              ),
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
                            ),
                            dropdownColor: AppTheme.darkGrayColor,
                            items:
                                providers.map((provider) {
                                  return DropdownMenuItem<PaymentProviderModel>(
                                    value: provider,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 30,
                                          height: 30,
                                          padding: const EdgeInsets.all(2),
                                          child:
                                              provider.imageLocation.isNotEmpty
                                                  ? Image.network(
                                                    'http://13.212.81.56/storage/${provider.imageLocation}',
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) => Icon(
                                                          Icons
                                                              .account_balance_wallet,
                                                          color:
                                                              Colors
                                                                  .orange[300],
                                                          size: 20,
                                                        ),
                                                  )
                                                  : Icon(
                                                    Icons
                                                        .account_balance_wallet,
                                                    color: Colors.orange[300],
                                                    size: 20,
                                                  ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          provider.providerName +
                                              (provider
                                                          .billing
                                                          ?.providerPhone !=
                                                      null
                                                  ? ' - ${provider.billing!.providerPhone}'
                                                  : ''),
                                          style: TextStyle(color: textColor),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                            onChanged: (PaymentProviderModel? newValue) {
                              setState(() {
                                _selectedProvider = newValue;
                              });
                            },
                          ),
                        );
                      },
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error:
                          (error, stackTrace) => Center(
                            child: Text(
                              'Error: $error',
                              style: TextStyle(color: textColor),
                            ),
                          ),
                    ),
                    const SizedBox(height: 20),

                    // Amount field
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
                        _buildAmountButton('5,000', buttonWidth),
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
                      // Validate inputs first
                      final amount = _amountController.text.replaceAll(',', '');

                      if (_selectedProvider == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a bank provider'),
                          ),
                        );
                        return;
                      }

                      if (_selectedProvider!.billing == null ||
                          _selectedProvider!.billing!.providerPhone.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Selected provider has no account number',
                            ),
                          ),
                        );
                        return;
                      }

                      if (amount.isEmpty ||
                          double.tryParse(amount) == null ||
                          double.parse(amount) < 10000) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Minimum amount is 10,000 MMK'),
                          ),
                        );
                        return;
                      }

                      // Use post-frame callback to avoid provider modification during build
                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        try {
                          final paymentNotifier = ref.read(
                            paymentProvider.notifier,
                          );

                          // For withdraw, use empty string for transactionId
                          final response = await paymentNotifier
                              .processStoreWithdraw(
                                providerId: _selectedProvider!.id,
                                amount: amount,
                                accountNumber:
                                    _selectedProvider!.billing!.providerPhone,
                                transactionId: "",
                              );

                          if (mounted) {
                            // Display the response message from the API
                            if (response['status'] == 'success' &&
                                response['message'] != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(response['message'])),
                              );
                              Navigator.pop(context);
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
                            } else {
                              // Fallback message if no message in response
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Withdrawal request submitted successfully',
                                  ),
                                ),
                              );
                              Navigator.pop(context);
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${e.toString()}')),
                            );
                          }
                          print('Error during withdrawal process: $e');
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
