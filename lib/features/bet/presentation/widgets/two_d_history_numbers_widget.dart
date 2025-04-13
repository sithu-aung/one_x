import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/bet/domain/models/two_d_history_response.dart';
import 'package:one_x/features/bet/presentation/providers/bet_providers.dart';

class TwoDHistoryNumbersWidget extends ConsumerWidget {
  const TwoDHistoryNumbersWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(twoDHistoryNumbersProvider)
        .when(
          loading:
              () => Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              ),
          error:
              (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'အချက်အလက်များ ရယူရန် မအောင်မြင်ပါ',
                      style: TextStyle(
                        color: AppTheme.textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: TextStyle(color: AppTheme.textSecondaryColor),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref
                            .read(twoDHistoryNumbersProvider.notifier)
                            .getHistoryNumbers();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('ပြန်လည်ကြိုးစားကြည့်ပါ'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
          data: (historyData) {
            if (historyData.data == null || historyData.data!.isEmpty) {
              return const Center(child: Text('No history data available'));
            }

            // Group the data by date
            final groupedData = <String, List<Data>>{};
            for (var item in historyData.data!) {
              if (item.createdAt != null) {
                try {
                  final date = DateTime.parse(item.createdAt!);
                  final dateString = DateFormat('dd-MM-yyyy').format(date);

                  if (!groupedData.containsKey(dateString)) {
                    groupedData[dateString] = [];
                  }
                  groupedData[dateString]!.add(item);
                } catch (e) {
                  print('Error parsing date: ${item.createdAt}');
                }
              }
            }

            // Sort the dates (most recent first)
            final sortedDates =
                groupedData.keys.toList()..sort((a, b) => b.compareTo(a));

            return RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(twoDHistoryNumbersProvider.notifier)
                    .getHistoryNumbers();
              },
              child: ListView.builder(
                itemCount: sortedDates.length,
                itemBuilder: (context, index) {
                  final date = sortedDates[index];
                  final items = groupedData[date]!;

                  // Convert date format for display
                  final displayDate = _formatDateForDisplay(date);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Date header
                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          displayDate,
                          style: TextStyle(
                            color: AppTheme.textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),

                      // Result cards for this date
                      ...items.map((item) {
                        // Try to extract time from createdAt
                        String timeString = '12:01 AM';
                        if (item.createdAt != null) {
                          try {
                            final datetime = DateTime.parse(item.createdAt!);
                            timeString = DateFormat('hh:mm a').format(datetime);
                          } catch (e) {
                            print('Error parsing time: ${item.createdAt}');
                          }
                        }

                        return _buildResultCard(
                          context: context,
                          time: timeString,
                          set: item.set ?? '--',
                          value: item.value ?? '--',
                          luckyNumber: item.luckyNumber ?? '--',
                        );
                      }),

                      const SizedBox(height: 10),
                    ],
                  );
                },
              ),
            );
          },
        );
  }

  String _formatDateForDisplay(String dateString) {
    try {
      // Input format is dd-MM-yyyy, create a DateTime object
      final parts = dateString.split('-');
      if (parts.length != 3) return dateString;

      final day = int.tryParse(parts[0]) ?? 1;
      final month = int.tryParse(parts[1]) ?? 1;
      final year = int.tryParse(parts[2]) ?? 2024;

      final date = DateTime(year, month, day);

      // Format the date in desired display format
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildResultCard({
    required BuildContext context,
    required String time,
    required String set,
    required String value,
    required String luckyNumber,
  }) {
    // Determine if we're in a white/light theme
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow:
            isLightTheme
                ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ]
                : null,
        border:
            isLightTheme
                ? Border.all(color: Colors.grey.shade300, width: 1)
                : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            child: Center(
              child: Text(
                time,
                style: TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 42),
            child: Divider(
              color: AppTheme.textSecondaryColor.withOpacity(0.4),
              thickness: 0.7,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'SET',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        set,
                        style: TextStyle(
                          color: AppTheme.textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'VALUE',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: TextStyle(
                          color: AppTheme.textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '2D',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        luckyNumber,
                        style: TextStyle(
                          color:
                              luckyNumber == '--'
                                  ? Colors.blue
                                  : AppTheme.backgroundColor == Colors.white
                                  ? const Color(
                                    0xFFFFD700,
                                  ).withRed(255).withGreen(215).withBlue(0)
                                  : AppTheme.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
