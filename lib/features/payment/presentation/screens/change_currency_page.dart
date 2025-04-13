import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/payment/application/payment_provider.dart';

class ChangeCurrencyPage extends ConsumerStatefulWidget {
  const ChangeCurrencyPage({super.key});

  @override
  ConsumerState<ChangeCurrencyPage> createState() => _ChangeCurrencyPageState();
}

class _ChangeCurrencyPageState extends ConsumerState<ChangeCurrencyPage> {
  late String selectedCurrency;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize with current currency from provider
    selectedCurrency = ref.read(paymentProvider).preferredCurrency;
  }

  void _changeCurrency() {
    if (selectedCurrency == ref.read(paymentProvider).preferredCurrency) {
      // No change needed
      Navigator.pop(context);
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Use Future.delayed to avoid setState during build
    Future.delayed(Duration.zero, () async {
      try {
        final success = await ref
            .read(paymentProvider.notifier)
            .updateCurrency(selectedCurrency);

        if (success) {
          if (mounted) {
            Navigator.pop(context, selectedCurrency);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to update currency. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
            setState(() {
              isLoading = false;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            isLoading = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get current balance to check if it's zero
    final paymentState = ref.watch(paymentProvider);
    final hasZeroBalance = paymentState.balance?.amount == 0;

    final isDarkMode = AppTheme.backgroundColor.computeLuminance() < 0.5;
    final backgroundColor = AppTheme.backgroundColor;
    final textColor = AppTheme.textColor;
    final warningColor =
        isDarkMode ? Colors.amber.shade300 : Colors.amber.shade700;
    final warningBgColor =
        isDarkMode
            ? Colors.amber.shade900.withOpacity(0.3)
            : Colors.amber.shade50;

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
          'Change Default Currency',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: warningBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: warningColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You can change the default currency only when your balance is zero (0).',
                      style: TextStyle(color: warningColor, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Myanmar Currency Option
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedCurrency = 'MMK';
                });
              },
              child: _buildCurrencyOption(
                flag: 'assets/images/mm_flag.png',
                name: 'Myanmar Currency',
                code: 'MMK',
                isSelected: selectedCurrency == 'MMK',
              ),
            ),
            const SizedBox(height: 12),
            // USA Currency Option
            GestureDetector(
              onTap: () {
                setState(() {
                  selectedCurrency = 'USD';
                });
              },
              child: _buildCurrencyOption(
                flag: 'assets/images/en_flag.png',
                name: 'USA Currency',
                code: 'USD',
                isSelected: selectedCurrency == 'USD',
              ),
            ),
            const Spacer(),
            // Change Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: PrimaryButton(
                  onPressed:
                      hasZeroBalance && !isLoading ? _changeCurrency : () {},
                  label: isLoading ? 'Changing...' : 'Change',
                  enabled: hasZeroBalance && !isLoading,
                ),
              ),
            ),
            if (!hasZeroBalance)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                child: Center(
                  child: Text(
                    'Your balance must be zero to change currency',
                    style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyOption({
    required String flag,
    required String name,
    required String code,
    required bool isSelected,
  }) {
    final isDarkMode = AppTheme.backgroundColor.computeLuminance() < 0.5;
    final textColor = AppTheme.textColor;
    final subTextColor = AppTheme.textSecondaryColor;
    final selectedBgColor =
        isDarkMode
            ? AppTheme.primaryColor.withOpacity(0.3)
            : const Color(0xFFF4F3FF);
    final unselectedBgColor = isDarkMode ? AppTheme.cardColor : Colors.white;
    final borderColor =
        isSelected
            ? AppTheme.primaryColor
            : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? selectedBgColor : unselectedBgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(flag, width: 40, height: 30, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              Text(code, style: TextStyle(fontSize: 14, color: subTextColor)),
            ],
          ),
          const Spacer(),
          if (isSelected)
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 16),
            ),
        ],
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final bool enabled;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AppTheme.backgroundColor.computeLuminance() < 0.5;

    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        disabledBackgroundColor:
            isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
        elevation: enabled ? 4 : 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color:
              enabled
                  ? Colors.white
                  : (isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
