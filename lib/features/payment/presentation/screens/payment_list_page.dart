import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/payment/application/payment_provider.dart';
import 'package:one_x/features/payment/domain/models/payment_model.dart';

class PaymentListPage extends ConsumerStatefulWidget {
  const PaymentListPage({super.key});

  @override
  ConsumerState<PaymentListPage> createState() => _PaymentListPageState();
}

class _PaymentListPageState extends ConsumerState<PaymentListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _currentFilter = 'All';
  final List<String> _filters = ['All', 'TopUp', 'Withdraw'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentFilter = _filters[_tabController.index];
        });
      }
    });

    // Load transaction data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentProvider.notifier).loadTransactions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentProvider);
    final transactions = paymentState.transactions;

    // Theme-aware colors
    final isDarkMode = AppTheme.backgroundColor.computeLuminance() < 0.5;
    final backgroundColor = AppTheme.backgroundColor;
    final textColor = AppTheme.textColor;
    final cardColor = AppTheme.cardColor;
    final borderColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
    final tabBgColor = isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100;
    final selectedTabColor =
        isDarkMode
            ? AppTheme.primaryColor.withOpacity(0.3)
            : AppTheme.primaryColor.withOpacity(0.1);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'Transaction History',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTabItem(0, 'All', Icons.list),
                  const SizedBox(width: 12),
                  _buildTabItem(1, 'TopUp', Icons.arrow_downward),
                  const SizedBox(width: 12),
                  _buildTabItem(2, 'Withdraw', Icons.arrow_upward),
                ],
              ),
            ),
          ),
          Expanded(
            child:
                paymentState.isLoading
                    ? Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                    )
                    : transactions.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color:
                                isDarkMode
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No transaction history found',
                            style: TextStyle(
                              color:
                                  isDarkMode
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                    : _buildTransactionList(
                      context,
                      transactions,
                      _currentFilter,
                      cardColor,
                      textColor,
                      borderColor,
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(
    BuildContext context,
    List<TransactionModel> transactions,
    String filter,
    Color cardColor,
    Color textColor,
    Color borderColor,
  ) {
    final filteredTransactions =
        filter == 'All'
            ? transactions
            : transactions
                .where(
                  (txn) =>
                      txn.type.toString().split('.').last.toLowerCase() == filter.toLowerCase(),
                )
                .toList();

    if (filteredTransactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              filter == 'TopUp' ? Icons.arrow_downward : Icons.arrow_upward,
              size: 64,
              color:
                  AppTheme.backgroundColor.computeLuminance() < 0.5
                      ? Colors.grey.shade700
                      : Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No ${filter.toLowerCase()} transactions found',
              style: TextStyle(
                color:
                    AppTheme.backgroundColor.computeLuminance() < 0.5
                        ? Colors.grey.shade400
                        : Colors.grey.shade700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        final transaction = filteredTransactions[index];
        return _buildTransactionCard(
          context,
          transaction,
          cardColor,
          textColor,
          borderColor,
        );
      },
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    TransactionModel transaction,
    Color cardColor,
    Color textColor,
    Color borderColor,
  ) {
    final isDarkMode = AppTheme.backgroundColor.computeLuminance() < 0.5;
    final isDeposit = transaction.type.toString().split('.').last.toLowerCase() == 'topup';
    final formatter = NumberFormat('#,###.##');
    final amount = formatter.format(transaction.amount);
    final formattedDate = DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(transaction.createdAt);

    final amountColor =
        isDeposit
            ? (isDarkMode ? Colors.green.shade300 : Colors.green.shade700)
            : (isDarkMode ? Colors.red.shade300 : Colors.red.shade700);

    final iconBgColor =
        isDeposit
            ? (isDarkMode
                ? Colors.green.shade900.withOpacity(0.3)
                : Colors.green.shade50)
            : (isDarkMode
                ? Colors.red.shade900.withOpacity(0.3)
                : Colors.red.shade50);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          if (!isDarkMode)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/payment/detail',
            arguments: transaction,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isDeposit ? Icons.arrow_downward : Icons.arrow_upward,
                  color: amountColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDeposit ? 'TopUp' : 'Withdraw',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        color:
                            isDarkMode
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isDeposit ? "+" : "-"} $amount ${transaction.currency}',
                    style: TextStyle(
                      color: amountColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color:
                          transaction.status.toLowerCase() == 'completed'
                              ? (isDarkMode
                                  ? Colors.green.shade900.withOpacity(0.3)
                                  : Colors.green.shade50)
                              : (isDarkMode
                                  ? Colors.orange.shade900.withOpacity(0.3)
                                  : Colors.orange.shade50),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      transaction.status,
                      style: TextStyle(
                        color:
                            transaction.status.toLowerCase() == 'completed'
                                ? (isDarkMode
                                    ? Colors.green.shade300
                                    : Colors.green.shade700)
                                : (isDarkMode
                                    ? Colors.orange.shade300
                                    : Colors.orange.shade700),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTabItem(int index, String title, IconData iconData) {
    final isSelected = _tabController.index == index;
    final isDarkMode = AppTheme.backgroundColor.computeLuminance() < 0.5;
    final isLightTheme = !isDarkMode;
    
    return Container(
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? null
            : Border.all(color: AppTheme.primaryColor, width: 1),
        boxShadow: isSelected && isLightTheme
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: TextButton.icon(
        icon: Icon(
          iconData,
          size: 16,
          color: isSelected 
              ? Colors.white 
              : isLightTheme
                  ? AppTheme.primaryColor 
                  : AppTheme.textColor,
        ),
        label: Text(
          title,
          style: TextStyle(
            color: isSelected 
                ? Colors.white 
                : isLightTheme
                    ? Colors.black 
                    : AppTheme.textColor,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            overflow: TextOverflow.ellipsis,
          ),
          maxLines: 1,
        ),
        onPressed: () {
          _tabController.animateTo(index);
        },
      ),
    );
  }
}
