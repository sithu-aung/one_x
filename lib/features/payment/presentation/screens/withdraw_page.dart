// DEPRECATED: This file is no longer needed as we're now using the WithdrawAmountDefineScreen
// directly instead of this intermediate page. This file should be removed after
// all references are updated to use the new screen.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/payment/application/payment_provider.dart';
import 'package:one_x/features/payment/presentation/screens/amount_define_screen.dart';

class WithdrawPage extends ConsumerStatefulWidget {
  const WithdrawPage({super.key});

  @override
  ConsumerState<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends ConsumerState<WithdrawPage> {
  @override
  void initState() {
    super.initState();
    // Initialize withdrawal providers on first load using post-frame callback
    Future(() {
      ref.read(paymentProvider.notifier).loadWithdrawalProviders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AppTheme.backgroundColor.computeLuminance() < 0.5;
    final backgroundColor = AppTheme.backgroundColor;
    final textColor = AppTheme.textColor;

    // Access the withdrawal providers
    final providersAsyncValue = ref.watch(withdrawalProvidersProvider);

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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: providersAsyncValue.when(
            data: (providers) {
              if (providers.isEmpty) {
                return Center(
                  child: Text(
                    'No withdrawal providers available',
                    style: TextStyle(color: textColor),
                  ),
                );
              }

              return ListView.separated(
                itemCount: providers.length,
                separatorBuilder:
                    (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final provider = providers[index];
                  return _buildPaymentOption(
                    context: context,
                    // Use imageLocation if available, otherwise fallback to assets
                    imagePath: provider.imageLocation,
                    title: provider.providerName,
                    subtitle: 'Withdrawal Provider',
                    onTap:
                        () => _navigateToAmountDefineScreen(
                          context,
                          provider.providerName,
                          provider.id,
                          provider.billing!.id,
                          provider.imageLocation,
                        ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (error, stackTrace) => Center(
                  child: Text(
                    'Error loading withdrawal providers: $error',
                    style: TextStyle(color: textColor),
                  ),
                ),
          ),
        ),
      ),
    );
  }

  void _navigateToAmountDefineScreen(
    BuildContext context,
    String providerName,
    int providerId,
    int billingId,
    String imageLocation,
  ) {
    // Add print statement to debug the provider key
    print('Provider Key: $providerId');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (context) => AmountDefineScreen(
              type: PaymentActionType.withdraw,
              providerId: providerId,
              billingId: billingId,
              providerName: providerName,
              imageLocation: imageLocation,
            ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required BuildContext context,
    required String imagePath,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDarkMode = AppTheme.backgroundColor.computeLuminance() < 0.5;
    final cardColor = isDarkMode ? AppTheme.cardColor : Colors.white;
    final textColor = AppTheme.textColor;
    final subTextColor = AppTheme.textSecondaryColor;
    final borderColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
        boxShadow:
            isDarkMode
                ? null
                : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 0,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.black26 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      imagePath.isNotEmpty
                          ? Image.network(
                            'http://13.212.81.56/storage/$imagePath',
                            errorBuilder:
                                (context, error, stackTrace) => Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.orange[300],
                                  size: 24,
                                ),
                          )
                          : Icon(
                            Icons.account_balance_wallet,
                            color: Colors.orange[300],
                            size: 24,
                          ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 14, color: subTextColor),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color:
                      isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
