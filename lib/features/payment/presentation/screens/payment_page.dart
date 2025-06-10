import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/payment/application/payment_provider.dart';
import 'package:one_x/features/payment/presentation/screens/change_currency_page.dart';
import 'package:one_x/features/payment/presentation/screens/payment_list_page.dart';
import 'package:one_x/features/payment/presentation/screens/top_up_page.dart';
import 'package:one_x/features/payment/presentation/screens/transaction_history_screen.dart';
import 'package:one_x/features/payment/presentation/screens/withdraw_amount_define_screen.dart';
import 'package:one_x/features/payment/presentation/screens/withdraw_page.dart';

class PaymentPage extends ConsumerStatefulWidget {
  const PaymentPage({super.key});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  @override
  void initState() {
    super.initState();
    // Load payment data when page is opened
    Future.microtask(() {
      ref.read(paymentProvider.notifier).loadInitialData();
    });
  }

  String _formatCurrency(double amount, String currency) {
    if (currency == 'MMK') {
      return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} Ks';
    } else {
      return '\$${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
    }
  }

  Future<void> _refreshPaymentData() async {
    await ref.read(paymentProvider.notifier).loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentProvider);
    final currentCurrency = paymentState.preferredCurrency;
    final balance = paymentState.balance?.amount ?? 150000;
    final exchangeRate = paymentState.exchangeRate;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    final isDarkMode = AppTheme.backgroundColor.computeLuminance() < 0.5;
    final textColor = AppTheme.textColor;
    final backgroundColor = AppTheme.backgroundColor;
    final cardColor = isDarkMode ? AppTheme.cardColor : Colors.grey[100];
    final iconColor = textColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child:
            paymentState.isLoading
                ? Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                )
                : RefreshIndicator(
                  onRefresh: _refreshPaymentData,
                  color: AppTheme.primaryColor,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Default Currency Section
                          GestureDetector(
                            onTap: () async {
                              // await Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => const ChangeCurrencyPage(),
                              //   ),
                              // );
                              // // Refresh data after returning from currency page
                              // ref.read(paymentProvider.notifier).loadInitialData();
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Default Currency - ',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: textColor,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Image.asset(
                                          'assets/images/${currentCurrency.toLowerCase()}.png',
                                          width: 24,
                                          height: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          currentCurrency,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: textColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.8),
                              image: const DecorationImage(
                                image: AssetImage(
                                  'assets/images/payment_card_background.png',
                                ),
                                fit: BoxFit.cover,
                                opacity: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'လက်ကျန်ငွေ',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _formatCurrency(
                                    balance.toDouble(),
                                    currentCurrency,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // const SizedBox(height: 24),
                          // // Exchange Rate Section
                          // Container(
                          //   width: double.infinity,
                          //   padding: const EdgeInsets.all(16),
                          //   decoration: BoxDecoration(
                          //     color: cardColor,
                          //     borderRadius: BorderRadius.circular(12),
                          //     border:
                          //         isDarkMode
                          //             ? Border.all(color: Colors.grey.shade800)
                          //             : null,
                          //   ),
                          //   child: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       Text(
                          //         'Update Exchange Rate',
                          //         style: TextStyle(
                          //           fontSize: 16,
                          //           fontWeight: FontWeight.w500,
                          //           color: textColor,
                          //         ),
                          //       ),
                          //       const SizedBox(height: 12),
                          //       Row(
                          //         mainAxisAlignment: MainAxisAlignment.center,
                          //         children: [
                          //           Image.asset(
                          //             'assets/images/usd.png',
                          //             width: 28,
                          //             height: 28,
                          //           ),
                          //           const SizedBox(width: 4),
                          //           Text(
                          //             '1 USD',
                          //             style: TextStyle(
                          //               fontSize: 14,
                          //               fontWeight: FontWeight.w500,
                          //               color: textColor,
                          //             ),
                          //           ),
                          //           const SizedBox(width: 8),
                          //           Text(
                          //             '=',
                          //             style: TextStyle(
                          //               fontSize: 14,
                          //               fontWeight: FontWeight.w500,
                          //               color: textColor,
                          //             ),
                          //           ),
                          //           const SizedBox(width: 8),
                          //           Image.asset(
                          //             'assets/images/mmk.png',
                          //             width: 28,
                          //             height: 28,
                          //           ),
                          //           const SizedBox(width: 4),
                          //           Flexible(
                          //             child: Text(
                          //               '${exchangeRate?.rate.toStringAsFixed(0) ?? '4,500'} MMK',
                          //               style: TextStyle(
                          //                 fontSize: 14,
                          //                 fontWeight: FontWeight.w500,
                          //                 color: textColor,
                          //               ),
                          //               overflow: TextOverflow.ellipsis,
                          //             ),
                          //           ),
                          //         ],
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: _buildActionButton(
                                  icon: Icons.add,
                                  label: 'ငွေသွင်း',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const TopUpPage(),
                                      ),
                                    ).then((_) {
                                      // Refresh data after returning from top up page
                                      ref
                                          .read(paymentProvider.notifier)
                                          .loadInitialData();
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildActionButton(
                                  icon: Icons.arrow_downward,
                                  label: 'ငွေထုတ်',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const WithdrawPage(),
                                      ),
                                    ).then((_) {
                                      // Refresh data after returning from withdraw page
                                      ref
                                          .read(paymentProvider.notifier)
                                          .loadInitialData();
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildActionButton(
                                  icon: Icons.receipt_long,
                                  label: 'မှတ်တမ်း',
                                  onTap: () {
                                    // Load transactions before navigating to record page
                                    ref
                                        .read(paymentProvider.notifier)
                                        .loadTransactions();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                const TransactionHistoryScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildInstructionCard(
                            title: 'ငွေဖြည့်သွင်းနည်း',
                            instructions: [
                              '"ငွေဖြည့်ရန်" ကို နှိပ်ပါ။',
                              'KBZ Pay, Wave Pay, CB Pay နှင့် AYA Pay တို့မှ မိမိငွေဖြည့်လိုသည့် ဘဏ်ကို ရွေးပါ။',
                              'သက်ဆိုင်ရာ Pay ဖြင့် ငွေဖြည့်နိုင်သော အကောင့်များ ပေါ်လာပါလိမ့်မည်။',
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildInstructionCard(
                            title: 'ငွေထုတ်နည်း',
                            instructions: [
                              '"ငွေထုတ်ရန်" ကို နှိပ်ပါ။',
                              'KBZ Pay, Wave Pay, CB Pay နှင့် AYA Pay တို့မှ မိမိငွေထုတ်လိုသည့် ဘဏ်ကို ရွေးပါ။',
                              'သက်ဆိုင်ရာ Pay ဖြင့် ငွေထုတ်နိုင်သော အကောင့်များ ပေါ်လာပါလိမ့်မည်။',
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    String imagePath = '';
    if (label == 'Top Up') {
      imagePath = 'assets/images/refund.png';
    } else if (label == 'Withdraw') {
      imagePath = 'assets/images/withdraw.png';
    } else {
      imagePath = 'assets/images/record.png';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(imagePath, width: 18, height: 18, color: Colors.white),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionCard({
    required String title,
    required List<String> instructions,
  }) {
    final isDarkMode = AppTheme.backgroundColor.computeLuminance() < 0.5;
    final textColor = AppTheme.textColor;
    final cardColor = isDarkMode ? AppTheme.cardColor : Colors.grey[100];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isDarkMode ? Border.all(color: AppTheme.cardExtraColor) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ...List.generate(
            instructions.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${index + 1}။ ', style: TextStyle(color: textColor)),
                  Expanded(
                    child: Text(
                      instructions[index],
                      style: TextStyle(fontSize: 14, color: textColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
