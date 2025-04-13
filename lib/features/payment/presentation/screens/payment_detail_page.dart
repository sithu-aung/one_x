import 'package:flutter/material.dart';
import 'package:one_x/core/theme/app_theme.dart';

class PaymentDetailPage extends StatelessWidget {
  final String type;
  final String amount;
  final String provider;
  final String date;

  const PaymentDetailPage({
    super.key,
    required this.type,
    required this.amount,
    required this.provider,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AppTheme.backgroundColor.computeLuminance() < 0.5;
    final backgroundColor = AppTheme.backgroundColor;
    final textColor = AppTheme.textColor;
    final secondaryTextColor =
        isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600;

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
          'Payment Detail',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 50,
              backgroundColor:
                  isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
              backgroundImage: const AssetImage('assets/images/avatar.png'),
            ),
            const SizedBox(height: 16),
            Text(
              'Ma Thidar Nyein',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                amount,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildDetailRow('Type', type, secondaryTextColor, textColor),
                  const SizedBox(height: 24),
                  _buildDetailRow(
                    'Payment Provider',
                    provider,
                    secondaryTextColor,
                    textColor,
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow(
                    'Account No',
                    '09123456789',
                    secondaryTextColor,
                    textColor,
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow(
                    'Transaction No',
                    '987652345678',
                    secondaryTextColor,
                    textColor,
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow(
                    'Date/Time',
                    date,
                    secondaryTextColor,
                    textColor,
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow('Type', type, secondaryTextColor, textColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    Color labelColor,
    Color valueColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: TextStyle(fontSize: 15, color: labelColor)),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}
