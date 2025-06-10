import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:intl/intl.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/payment/application/payment_provider.dart';
import 'package:one_x/features/payment/domain/models/transaction_history.dart';
import 'package:one_x/features/home/presentation/providers/home_provider.dart';
import 'package:one_x/features/payment/presentation/screens/transaction_detail_screen.dart';

enum TransactionFilter { all, deposit, withdraw, other }

// Provider for wallet transaction history
final walletHistoryProvider =
    riverpod.FutureProvider<TransactionHistoryResponse>((ref) async {
      final repository = ref.read(paymentRepositoryProvider);
      try {
        final response = await repository.getWalletHistory();
        return TransactionHistoryResponse.fromJson(response);
      } catch (e) {
        print('Error in walletHistoryProvider: $e');
        rethrow;
      }
    });

class TransactionHistoryScreen extends riverpod.ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  riverpod.ConsumerState<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState
    extends riverpod.ConsumerState<TransactionHistoryScreen> {
  TransactionFilter _currentFilter = TransactionFilter.all;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // Load wallet history when screen initializes
    Future(() {
      // Refresh home data to get the latest balance
      ref.refresh(homeDataProvider);
      // Refresh transaction history
      ref.refresh(walletHistoryProvider);
    });
  }

  String _formatDate(String dateString) {
    try {
      final parts = dateString.split('-');
      if (parts.length == 3) {
        return '${parts[2]} ${_getMonthName(int.parse(parts[1]))}';
      }
      return dateString;
    } catch (e) {
      return dateString;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  String _formatTime(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return DateFormat('HH:mm a').format(dateTime);
    } catch (e) {
      return timestamp;
    }
  }

  void _showDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: AppTheme.backgroundColor,
              onSurface: AppTheme.textColor,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: AppTheme.backgroundColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
      ref.refresh(walletHistoryProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get wallet history
    final walletHistoryAsync = ref.watch(walletHistoryProvider);

    // Theme-aware colors
    final isDarkMode = AppTheme.backgroundColor.computeLuminance() < 0.5;
    final backgroundColor = AppTheme.backgroundColor;
    final textColor = AppTheme.textColor;
    final cardColor = AppTheme.cardColor;
    final borderColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;

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
          'Transaction History',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Balance card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: borderColor, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'လက်ကျန်ငွေ',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      riverpod.Consumer(
                        builder: (context, ref, _) {
                          final homeDataValue = ref.watch(homeDataProvider);
                          return homeDataValue.when(
                            data: (homeData) {
                              final balance = homeData.user.balance;
                              final formatter = NumberFormat('#,###');
                              return Text(
                                '${formatter.format(balance)} Ks',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                            loading:
                                () => Text(
                                  '0 Ks',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            error:
                                (_, __) => Text(
                                  '0 Ks',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Deposit',
                            style: TextStyle(
                              color: textColor.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                          riverpod.Consumer(
                            builder: (context, ref, _) {
                              final walletHistoryValue = ref.watch(
                                walletHistoryProvider,
                              );
                              return walletHistoryValue.when(
                                data: (history) {
                                  final formatter = NumberFormat('#,###');
                                  final totalDeposit =
                                      int.tryParse(history.totalDeposit ?? '0') ??
                                      0;
                                  return Text(
                                    '${formatter.format(totalDeposit)} Ks',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                },
                                loading:
                                    () => Text(
                                      '0 Ks',
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                error:
                                    (_, __) => Text(
                                      '0 Ks',
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Withdraw',
                            style: TextStyle(
                              color: textColor.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                          riverpod.Consumer(
                            builder: (context, ref, _) {
                              final walletHistoryValue = ref.watch(
                                walletHistoryProvider,
                              );
                              return walletHistoryValue.when(
                                data: (history) {
                                  final formatter = NumberFormat('#,###');
                                  final totalWithdraw =
                                      int.tryParse(
                                        history.totalWithdraw ?? '0',
                                      ) ??
                                      0;
                                  return Text(
                                    '${formatter.format(totalWithdraw)} Ks',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                },
                                loading:
                                    () => Text(
                                      '0 Ks',
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                error:
                                    (_, __) => Text(
                                      '0 Ks',
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Filter tabs
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border(bottom: BorderSide(color: borderColor, width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFilterTab(TransactionFilter.all, 'All'),
                  _buildFilterTab(TransactionFilter.deposit, 'Deposit'),
                  _buildFilterTab(TransactionFilter.withdraw, 'Withdraw'),
                  _buildFilterTab(TransactionFilter.other, 'Other'),
                ],
              ),
            ),

            // Transaction list
            Expanded(
              child: walletHistoryAsync.when(
                data: (history) {
                  if (history.data == null || history.data!.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        // Refresh home data to get the latest balance
                        ref.refresh(homeDataProvider);
                        // Refresh transaction history
                        return ref.refresh(walletHistoryProvider);
                      },
                      child: ListView(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: Center(
                              child: Text(
                                'No transactions found',
                                style: TextStyle(color: textColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      // Refresh home data to get the latest balance
                      ref.refresh(homeDataProvider);
                      // Refresh transaction history
                      return ref.refresh(walletHistoryProvider);
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: history.data!.length,
                      itemBuilder: (context, index) {
                        final dateGroup = history.data![index];
                        final formattedDate = _formatDate(dateGroup.date!);

                        // Filter transactions based on selected filter
                        var transactions = dateGroup.transactions ?? [];
                        if (_currentFilter == TransactionFilter.deposit) {
                          transactions =
                              transactions
                                  .where((t) => t.transactionType == 'deposit')
                                  .toList();
                        } else if (_currentFilter == TransactionFilter.withdraw) {
                          transactions =
                              transactions
                                  .where((t) => t.transactionType == 'withdraw')
                                  .toList();
                        } else if (_currentFilter == TransactionFilter.other) {
                          transactions =
                              transactions
                                  .where(
                                    (t) =>
                                        t.transactionType != 'deposit' &&
                                        t.transactionType != 'withdraw',
                                  )
                                  .toList();
                        }

                        if (transactions.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date header
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 16,
                              ),
                              margin: const EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                color:
                                    isDarkMode
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                formattedDate,
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            // Transactions for this date
                            ...transactions.map((transaction) {
                              bool isDeposit =
                                  transaction.transactionType == 'deposit';
                              bool isWithdraw =
                                  transaction.transactionType == 'withdraw';
                              bool isPlay2D =
                                  transaction.transactionType == 'play_2d';
                              bool isPlay3D =
                                  transaction.transactionType == 'play_3d';

                              // Format for type display
                              String typeDisplay = 'Type';
                              if (isWithdraw) {
                                typeDisplay = 'Type - ငွေထုတ်';
                              } else if (isDeposit) {
                                typeDisplay = 'Type - ငွေသွင်း';
                              } else if (isPlay2D) {
                                typeDisplay = 'Type - ထိုးကြေး(2D)';
                              } else if (isPlay3D) {
                                typeDisplay = 'Type - ထိုးကြေး(3D)';
                              }

                              // Status display
                              Widget statusWidget = Container();
                              if (transaction.transactionStatus == 'complete') {
                                statusWidget = Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Complete',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              } else if (transaction.transactionStatus ==
                                  'pending') {
                                statusWidget = Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Pending',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              }

                              // Description text
                              String descriptionText = '';
                              if (isWithdraw) {
                                descriptionText = 'Withdraw from Your Wallet';
                              } else if (isDeposit) {
                                descriptionText = 'Deposit to Your Wallet';
                              } else if (isPlay2D || isPlay3D) {
                                descriptionText = 'Withdraw from Your Wallet';
                              } else {
                                descriptionText = 'Transfer To Real Bank Account';
                              }

                              // Amount formatter with sign
                              final amount = transaction.senderAmount ?? 0;
                              final formattedAmount = NumberFormat(
                                "#,##0",
                              ).format(amount);
                              final amountText =
                                  isWithdraw || isPlay2D || isPlay3D
                                      ? '-$formattedAmount'
                                      : '+$formattedAmount';
                              final amountColor =
                                  isWithdraw || isPlay2D || isPlay3D
                                      ? Colors.red
                                      : Colors.green;

                              return Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: InkWell(
                                  onTap: () {
                                    // Check if transaction ID exists
                                    final transId = transaction.id;
                                    if (transId == null ||
                                        transId.toString().isEmpty) {
                                      // If transactionId is empty, use the id as a fallback
                                      if (transaction.id != null) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (
                                                  context,
                                                ) => TransactionDetailScreen(
                                                  transactionId:
                                                      transaction.id.toString(),
                                                  status:
                                                      transaction
                                                          .transactionStatus ??
                                                      '',
                                                ),
                                          ),
                                        );
                                      } else {
                                        // No valid ID available, show error message
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Transaction ID not available',
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      // Use the transaction ID
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  TransactionDetailScreen(
                                                    transactionId:
                                                        transId.toString(),
                                                    status:
                                                        transaction
                                                            .transactionStatus ??
                                                        '',
                                                  ),
                                        ),
                                      );
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Row(
                                    children: [
                                      // Transaction icon
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color:
                                              isWithdraw
                                                  ? AppTheme.primaryColor
                                                      .withOpacity(0.1)
                                                  : Colors.orange.withOpacity(
                                                    0.1,
                                                  ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child:
                                              isPlay2D || isPlay3D
                                                  ? Image.asset(
                                                    'assets/images/ticket.png',
                                                    fit: BoxFit.contain,
                                                  )
                                                  : Padding(
                                                    padding: const EdgeInsets.all(
                                                      2,
                                                    ),
                                                    child: Image.asset(
                                                      isWithdraw
                                                          ? 'assets/images/cash_out.png'
                                                          : 'assets/images/cash_in.png',
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Transaction details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Flexible(
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        typeDisplay,
                                                        style: TextStyle(
                                                          color: textColor,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      statusWidget,
                                                    ],
                                                  ),
                                                ),
                                                // Show amount in place of status tag
                                                Text(
                                                  amountText,
                                                  style: TextStyle(
                                                    color: amountColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  descriptionText,
                                                  style: TextStyle(
                                                    color: textColor.withOpacity(
                                                      0.7,
                                                    ),
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                // Show new_balance instead of fixed date
                                                Text(
                                                  '${NumberFormat("#,##0").format(transaction.lastBalance ?? 0)} Ks',
                                                  style: TextStyle(
                                                    color: textColor.withOpacity(
                                                      0.7,
                                                    ),
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),

                            // Add divider between dates
                            if (index < history.data!.length - 1)
                              const Divider(height: 24),
                          ],
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (error, stack) => Center(
                      child: Text(
                        'Error loading transactions: $error',
                        style: TextStyle(color: textColor),
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(TransactionFilter filter, String text) {
    final isSelected = _currentFilter == filter;
    final isDarkMode = AppTheme.backgroundColor.computeLuminance() < 0.5;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentFilter = filter;
        });
      },
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              color:
                  isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondaryColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.4),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
