import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/payment/application/payment_provider.dart';
import 'package:one_x/features/payment/domain/models/transaction_detail.dart';
import 'package:one_x/features/home/presentation/providers/home_provider.dart';
import 'package:one_x/shared/widgets/profile_avatar.dart';

class TransactionDetailScreen extends ConsumerStatefulWidget {
  final String transactionId;
  final String status;

  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
    required this.status,
  });

  @override
  ConsumerState<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState
    extends ConsumerState<TransactionDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = AppTheme.backgroundColor.computeLuminance() < 0.5;
    final backgroundColor = AppTheme.backgroundColor;
    final textColor = AppTheme.textColor;

    // Get current user data
    final homeDataAsync = ref.watch(homeDataProvider);
    final currentUser = homeDataAsync.value?.user;

    // Validate transaction ID
    if (widget.transactionId.isEmpty) {
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
            'ငွေစာရင်း အသေးစိတ်',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        body: Center(
          child: Text(
            'Invalid transaction ID',
            style: TextStyle(color: textColor),
          ),
        ),
      );
    }

    final transactionDetailAsync = ref.watch(
      transactionDetailsProvider(widget.transactionId),
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
          'ငွေစာရင်း အသေးစိတ်',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: transactionDetailAsync.when(
        data: (data) {
          // Parse the data into the model
          final detailResponse = TransactionDetailResponse.fromJson(data);
          final transaction = detailResponse.transaction;

          if (transaction == null) {
            return RefreshIndicator(
              onRefresh: () async {
                // Refresh transaction details
                return ref.refresh(
                  transactionDetailsProvider(widget.transactionId),
                );
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: Center(
                      child: Text(
                        'Transaction details not found',
                        style: TextStyle(color: textColor),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Format amount for display
          final formatter = NumberFormat('#,###');
          final formattedAmount = formatter.format(
            transaction.senderAmount ?? 0,
          );
          final isWithdraw = transaction.transactionType == 'withdraw';
          final amountText =
              isWithdraw ? '-$formattedAmount' : '+$formattedAmount';

          // Determine prefix sign for the amount display in the TextSpan
          final amountPrefix =
              (transaction.transactionType == 'withdraw' ||
                      transaction.transactionType == 'play_2d' ||
                      transaction.transactionType == 'play_3d')
                  ? '- '
                  : '+ ';

          // Format current date properly
          final dateFormatter = DateFormat('dd,MM,yyyy / hh:mm a');
          final formattedDate = dateFormatter.format(DateTime.now());

          // Wrap the detailed content in a RefreshIndicator
          return RefreshIndicator(
            onRefresh: () async {
              // Refresh transaction details
              return ref.refresh(
                transactionDetailsProvider(widget.transactionId),
              );
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // User Profile Section
                Center(
                  child: Column(
                    children: [
                      // Profile Image
                      ProfileAvatar(radius: 40, useHomeUserData: true),
                      const SizedBox(height: 8),
                      // Username - Using current user's profile
                      Text(
                        currentUser?.username ?? 'My Account',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // User ID
                      Text(
                        currentUser?.id != null
                            ? 'UserID-${currentUser!.id}'
                            : '-',
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Amount Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: amountPrefix,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: NumberFormat.currency(
                                    locale: 'en_US',
                                    symbol: '',
                                    decimalDigits: 0,
                                  ).format(transaction.senderAmount ?? 0),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Transaction Details Label
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'ငွေလွှဲအချက်အလက်',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Transaction Details List
                _buildDetailRow(
                  'အခြေအနေ',
                  '• ${transaction.transactionStatus == 'pending' ? 'လုပ်ဆောင်ဆဲ' : transaction.transactionStatus?.toUpperCase()}',
                  textColor,
                  transaction.transactionStatus == 'pending'
                      ? Colors.orange
                      : (transaction.transactionStatus == 'approved'
                          ? Colors.green
                          : Colors.orange),
                ),
                // Show approver information if status is approved
                if (transaction.transactionStatus == 'approved' &&
                    transaction.receiptUser != null)
                  _buildDetailRow(
                    'Approved by',
                    '• ${transaction.receiptUser?.username ?? 'Admin'}',
                    textColor,
                    Colors.green,
                  ),
                _buildDetailRow(
                  'Type',
                  '• ${transaction.transactionType == 'withdraw' ? 'ငွေထုတ်' : (transaction.transactionType == 'deposit' ? 'ငွေသွင်း' : 'အခြား')}',
                  textColor,
                  null,
                ),
                _buildDetailRow(
                  'Transfer to ( Bank Name )',
                  '• ${transaction.provider?.providerName ?? 'KPay ( Normal )'}',
                  textColor,
                  null,
                ),
                _buildDetailRow(
                  'Transfer to ( Holder Name )',
                  '• ${transaction.receiptUser?.username ?? 'Maung Maung'}',
                  textColor,
                  null,
                ),
                _buildDetailRow(
                  'Transfer to ( Account Number )',
                  '• ${transaction.senderAccount ?? '09123456789'}',
                  textColor,
                  null,
                ),
                _buildDetailRow(
                  'Requested Date / Time',
                  '• ${transaction.requestedAt ?? ''}',
                  textColor,
                  null,
                ),
                _buildDetailRow(
                  'Approved Date / Time',
                  '• ${transaction.approvedAt ?? ''}',
                  textColor,
                  null,
                ),

                // Remark Section
                const SizedBox(height: 16),
                Text(
                  'Remark',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        isDarkMode
                            ? Colors.grey.shade800.withOpacity(0.7)
                            : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    transaction.remark?.isNotEmpty == true
                        ? transaction.remark!
                        : '-',
                    style: TextStyle(
                      color: textColor.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ),

                // Bottom Button
                const SizedBox(height: 24),
                Visibility(
                  visible: transaction.transactionStatus == 'pending',
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // If transaction is pending, show cancel confirmation dialog
                        if (transaction.transactionStatus == 'pending') {
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  backgroundColor: backgroundColor,
                                  title: Text(
                                    'ဖျက်သိမ်းမှု အတည်ပြုပါ',
                                    style: TextStyle(color: textColor),
                                  ),
                                  content: Text(
                                    'ဤငွေလွှဲခြင်းကို ဖျက်သိမ်းရန် သေချာပါသလား?',
                                    style: TextStyle(color: textColor),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(
                                          context,
                                        ).pop(); // Close the dialog
                                      },
                                      child: Text(
                                        'မလုပ်တော့ပါ',
                                        style: TextStyle(
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(
                                          context,
                                        ).pop(); // Close the dialog
                                      },
                                      child: Text(
                                        'ဖျက်သိမ်းမည်',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                          );
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            transaction.transactionStatus == 'pending'
                                ? AppTheme.cardExtraColor
                                : Colors.grey.shade400.withOpacity(0.2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        transaction.transactionStatus == 'pending'
                            ? 'တောင်းဆိုမှုအား ဖျက်သိမ်းမည်'
                            : (transaction.transactionStatus == 'complete'
                                ? 'ငွေလွှဲခြင်းအောင်မြင်ပါသည်'
                                : 'ဆောင်ရွက်ဆဲဖြစ်သည် ဖြစ်ပါသည်'),
                        style: TextStyle(
                          color:
                              transaction.transactionStatus == 'pending'
                                  ? AppTheme.textColor
                                  : textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(
              child: Text(
                'Error loading transaction details: $error',
                style: TextStyle(color: textColor),
              ),
            ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    Color textColor,
    Color? valueColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
