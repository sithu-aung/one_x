import 'package:flutter/material.dart';
import 'package:one_x/core/theme/app_theme.dart';

class TapeHotSelectionDialog extends StatefulWidget {
  final List<String> tapeNumbers;
  final List<String> hotNumbers;

  const TapeHotSelectionDialog({
    super.key,
    required this.tapeNumbers,
    required this.hotNumbers,
  });

  @override
  State<TapeHotSelectionDialog> createState() => _TapeHotSelectionDialogState();
}

class _TapeHotSelectionDialogState extends State<TapeHotSelectionDialog> {
  Set<String> selectedNumbers = {};

  @override
  Widget build(BuildContext context) {
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;
    final screenSize = MediaQuery.of(context).size;

    return AlertDialog(
      backgroundColor: AppTheme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.all(16),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Hot And Tape',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close,
              color: AppTheme.textColor.withOpacity(0.7),
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight:
              screenSize.height * 0.6, // Limit max height to 60% of screen
          maxWidth: screenSize.width - 40, // Account for insetPadding
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hot numbers section
              Text(
                'ဟော့ဂဏန်း',
                style: TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildNumberGrid(widget.hotNumbers),
              const SizedBox(height: 16),

              // Tape numbers section
              Text(
                'ထိပ်ဂဏန်း',
                style: TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildNumberGrid(widget.tapeNumbers),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.all(16),
      actions: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isLightTheme
                          ? Colors.grey.shade300
                          : Colors.grey.shade800,
                  foregroundColor: AppTheme.textColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'CANCEL',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed:
                    () => Navigator.of(context).pop(selectedNumbers.toList()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberGrid(List<String> numbers) {
    // Get available width from the constraint (accounting for paddings)
    final double screenWidth = MediaQuery.of(context).size.width;
    // Estimate available width (dialog width minus paddings)
    final double availableWidth =
        screenWidth -
        72; // 20 insetPadding each side + 16 contentPadding each side

    // For 6 items per row with 8 spacing between them
    final double itemWidth =
        (availableWidth - (5 * 8)) / 6; // 5 spaces for 6 items
    final double optimalItemSize = itemWidth.clamp(
      40,
      48,
    ); // Keep items between 40-48 pixels

    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.start,
        children:
            numbers.map((number) {
              final bool isSelected = selectedNumbers.contains(number);

              return InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedNumbers.remove(number);
                    } else {
                      selectedNumbers.add(number);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: optimalItemSize,
                  height: optimalItemSize,
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? AppTheme.primaryColor
                            : (AppTheme.backgroundColor == Colors.white
                                ? Colors.grey.shade200
                                : Colors.grey.shade800),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      number,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14, // Slightly smaller font to fit 6 per row
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
