import 'package:flutter/material.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/bet/domain/models/play_history_list_response.dart';
import 'package:intl/intl.dart';
import 'package:one_x/features/bet/presentation/screens/bet_slip_screen.dart';

class PlayHistoryListWidget extends StatefulWidget {
  final List<Histories>? histories;
  final Function()? onRefresh;
  final bool isLoading;

  const PlayHistoryListWidget({
    super.key,
    required this.histories,
    this.onRefresh,
    this.isLoading = false,
  });

  @override
  State<PlayHistoryListWidget> createState() => _PlayHistoryListWidgetState();
}

class _PlayHistoryListWidgetState extends State<PlayHistoryListWidget> {
  String _selectedTimeFilter = 'All';
  DateTime? _selectedDate;

  Future<void> _handleRefresh() async {
    if (widget.onRefresh != null) {
      widget.onRefresh!();
    }
    // Return a completed future to end the refresh indicator
    return Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we're in a white/light theme
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(height: 20),

        // Betting history items - this is the main content
        widget.isLoading
            ? Center(child: CircularProgressIndicator())
            : Flexible(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                color: AppTheme.primaryColor,
                backgroundColor:
                    isLightTheme ? Colors.white : AppTheme.cardColor,
                child:
                    widget.histories == null || widget.histories!.isEmpty
                        ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 80),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Center(
                                child: Text(
                                  'No history records found',
                                  style: TextStyle(color: AppTheme.textColor),
                                ),
                              ),
                            ),
                          ],
                        )
                        : ListView.builder(
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ).copyWith(bottom: 80),
                          itemCount: widget.histories!.length + 1,
                          itemBuilder: (context, index) {
                            if (index == widget.histories!.length) {
                              return const SizedBox(height: 60);
                            }
                            final history = widget.histories![index];
                            return _buildBetHistoryItem(history);
                          },
                        ),
              ),
            ),
      ],
    );
  }

  // Calculate total amount from all histories
  String _calculateTotalAmount() {
    if (widget.histories == null || widget.histories!.isEmpty) {
      return '0';
    }

    int total = 0;
    for (var history in widget.histories!) {
      if (history.amount != null) {
        total += int.tryParse(history.amount!) ?? 0;
      }
    }

    // Format with thousands separator
    final formatter = NumberFormat('#,###');
    return formatter.format(total);
  }

  // Time filter tab
  Widget _buildTimeFilterTab({required String label, required bool isActive}) {
    // Determine if we're in a white/light theme
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTimeFilter = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isActive
                    ? AppTheme.primaryColor
                    : isLightTheme
                    ? Colors.grey.shade300
                    : AppTheme.textColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow:
              isActive && isLightTheme
                  ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppTheme.textColor,
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // Build history item based on the data model
  Widget _buildBetHistoryItem(Histories history) {
    // Determine if we're in a white/light theme
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;

    // Get number of digits
    int digitCount = 0;
    if (history.lottery?.lotteryDigits != null) {
      digitCount = history.lottery!.lotteryDigits!.length;
    }

    // Format the date string
    String formattedDate = '';
    String formattedTime = '';
    if (history.date != null) {
      try {
        final DateTime dateTime = DateTime.parse(history.date!);
        formattedDate = DateFormat('E dd-MM-yyyy').format(dateTime);
        formattedTime = DateFormat('hh:mm a').format(dateTime);
      } catch (e) {
        formattedDate = history.date ?? '';
        formattedTime = '';
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => BetSlipScreen(
                  invoiceId: history.id,
                  fromWinningRecords: true,
                ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isLightTheme ? Colors.white : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow:
              isLightTheme
                  ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
          border:
              isLightTheme
                  ? Border.all(color: Colors.grey.shade300, width: 1)
                  : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            history.invoiceNumber ?? 'N/A',
                            style: TextStyle(
                              color: AppTheme.textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${digitCount.toString()} ကွက်)',
                          style: TextStyle(
                            color: AppTheme.textColor,
                            fontSize: 14,
                            fontFamily: 'Pyidaungsu',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${history.amount ?? '0'} Ks',
                    style: TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    history.user?.username ?? 'Unknown User',
                    style: TextStyle(color: Colors.purple, fontSize: 13),
                  ),
                  Text(
                    '$formattedDate | $formattedTime',
                    style: TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 12,
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
}
