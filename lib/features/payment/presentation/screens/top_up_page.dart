import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/payment/application/payment_provider.dart';
import 'package:one_x/features/payment/domain/models/payment_model.dart';
import 'package:one_x/features/home/presentation/providers/home_provider.dart';
import 'package:one_x/features/payment/presentation/screens/amount_define_screen.dart';

class TopUpPage extends ConsumerStatefulWidget {
  const TopUpPage({super.key});

  @override
  ConsumerState<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends ConsumerState<TopUpPage> {
  int? selectedProviderId;
  String? selectedProviderName;
  String? selectedImageLocation;

  @override
  void initState() {
    super.initState();
    // Initialize payment providers on first load using post-frame callback
    Future(() {
      ref.read(paymentProvider.notifier).loadPaymentProviders();
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AppTheme.backgroundColor.computeLuminance() < 0.5;
    final backgroundColor = AppTheme.backgroundColor;
    final textColor = AppTheme.textColor;

    // Access the payment providers
    final providersAsyncValue = ref.watch(paymentProvidersProvider);

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
          'ငွေသွင်းရန်',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: providersAsyncValue.when(
                data: (providers) {
                  if (providers.providers.isEmpty) {
                    return Center(
                      child: Text(
                        'No payment providers available',
                        style: TextStyle(color: textColor),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: providers.providers.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final provider = providers.providers[index];
                      final phoneNumber = provider.billing?.providerPhone ?? '';
                      return _buildPaymentOption(
                        context: context,
                        imagePath: provider.imageLocation,
                        title: provider.providerName,
                        subtitle: phoneNumber,
                        providerId: provider.id,
                        isSelected: selectedProviderId == provider.id,
                        onTap: () {
                          setState(() {
                            selectedProviderId = provider.id;
                            selectedProviderName = provider.providerName;
                            selectedImageLocation = provider.imageLocation;
                          });
                        },
                        onCopyPressed:
                            phoneNumber.isNotEmpty
                                ? () => _copyToClipboard(phoneNumber)
                                : null,
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (error, stackTrace) => Center(
                      child: Text(
                        'Error loading payment providers: $error',
                        style: TextStyle(color: textColor),
                      ),
                    ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -1),
                  blurRadius: 4,
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('မလုပ်တော့ပါ'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        selectedProviderId == null
                            ? null
                            : () => _navigateToAmountDefineScreen(
                              context,
                              selectedProviderName!,
                              selectedProviderId!,
                              selectedImageLocation!,
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade400,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('ရွေးချယ်မည်'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAmountDefineScreen(
    BuildContext context,
    String providerName,
    int providerId,
    String imageLocation,
  ) {
    // Add print statement to debug the provider key
    print('Provider Key: $providerId');

    // Try to parse the provider ID from the provider key, or pass it as is
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AmountDefineScreen(
              type: PaymentActionType.topUp,
              providerId: providerId,
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
    required int providerId,
    required bool isSelected,
    required VoidCallback onTap,
    VoidCallback? onCopyPressed,
  }) {
    final isDarkMode = AppTheme.backgroundColor.computeLuminance() < 0.5;
    final cardColor = isDarkMode ? AppTheme.cardColor : Colors.white;
    final textColor = AppTheme.textColor;
    final subTextColor = AppTheme.textSecondaryColor;
    final borderColor =
        isSelected
            ? Theme.of(context).primaryColor
            : isDarkMode
            ? Colors.grey.shade800
            : Colors.grey.shade200;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
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
                if (onCopyPressed != null)
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    color:
                        isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                    onPressed: onCopyPressed,
                    tooltip: 'Copy phone number',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
