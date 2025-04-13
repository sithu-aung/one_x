import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/bet/domain/models/holiday_list_response.dart';
import 'package:one_x/features/bet/presentation/providers/bet_providers.dart';

class TwoDHolidaysWidget extends ConsumerWidget {
  const TwoDHolidaysWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(twoDHolidaysProvider)
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
                      'ရုံးပိတ်ရက်များ ရယူရန် မအောင်မြင်ပါ',
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
                        ref.read(twoDHolidaysProvider.notifier).getHolidays();
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
          data: (holidayData) {
            if (holidayData.holidays == null || holidayData.holidays!.isEmpty) {
              return Center(
                child: Text(
                  'ရုံးပိတ်ရက်များ မရှိပါ',
                  style: TextStyle(color: AppTheme.textColor),
                ),
              );
            }

            // Sort holidays by date (newest first)
            final sortedHolidays = List<Holidays>.from(holidayData.holidays!);
            sortedHolidays.sort((a, b) {
              if (a.holidayDate == null || b.holidayDate == null) return 0;
              return b.holidayDate!.compareTo(a.holidayDate!);
            });

            return RefreshIndicator(
              onRefresh: () async {
                await ref.read(twoDHolidaysProvider.notifier).getHolidays();
              },
              child: ListView.builder(
                itemCount: sortedHolidays.length,
                itemBuilder: (context, index) {
                  final holiday = sortedHolidays[index];
                  return _buildHolidayCard(context: context, holiday: holiday);
                },
              ),
            );
          },
        );
  }

  Widget _buildHolidayCard({
    required BuildContext context,
    required Holidays holiday,
  }) {
    // Format the date as DD-MM-YYYY
    String formattedDate = '';
    String myanmarDayName = '';
    if (holiday.holidayDate != null) {
      try {
        final date = DateTime.parse(holiday.holidayDate!);
        formattedDate = DateFormat('dd-MM-yyyy').format(date);

        // Get the day of week in English
        final dayOfWeek = DateFormat('EEEE').format(date);

        // Convert to Myanmar day name
        myanmarDayName = _getMyanmarDayName(dayOfWeek);
      } catch (e) {
        formattedDate = holiday.holidayDate ?? '';
        myanmarDayName = '';
      }
    }

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
      child: SizedBox(
        height: 70,
        child: Row(
          children: [
            // Date and label column
            Container(
              width: 130,
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    myanmarDayName,
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Vertical divider with padding
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(
                width: 0.5,
                color: AppTheme.textSecondaryColor.withOpacity(0.3),
              ),
            ),

            // Holiday name
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  holiday.name ?? 'Unknown Holiday',
                  style: TextStyle(color: AppTheme.textColor, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to convert English day name to Myanmar day name
  String _getMyanmarDayName(String englishDayName) {
    switch (englishDayName.toLowerCase()) {
      case 'monday':
        return 'တနင်္လာ';
      case 'tuesday':
        return 'အင်္ဂါ';
      case 'wednesday':
        return 'ဗုဒ္ဓဟူး';
      case 'thursday':
        return 'ကြာသပတေး';
      case 'friday':
        return 'သောကြာ';
      case 'saturday':
        return 'စနေ';
      case 'sunday':
        return 'တနင်္ဂနွေ';
      default:
        return 'ရုံးပိတ်ရက်';
    }
  }
}
