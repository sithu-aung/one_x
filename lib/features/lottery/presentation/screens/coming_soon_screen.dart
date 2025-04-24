import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:one_x/core/theme/app_theme.dart';

class ComingSoonScreen extends StatelessWidget {
  final String title;

  const ComingSoonScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AppTheme.backgroundColor.computeLuminance() < 0.5;
    final backgroundColor = AppTheme.backgroundColor;
    final textColor = AppTheme.textColor;
    final dividerColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;

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
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description text
                Text(
                  '$title ကို ကံစမ်းနိုင်ရန်အတွက် အောက်ပါ ဖုန်းနံပါတ်များအား ဆက်သွယ် နိုင်ပါသည်။',
                  style: TextStyle(color: textColor, fontSize: 16),
                ),
                const SizedBox(height: 24),

                // Contact information section
                _buildContactItem(
                  platform: 'Viber',
                  iconColor: const Color(0xFF8E24AA),
                  contactNumber: '09789651459',
                  svgPath: 'assets/images/viber.svg',
                  textColor: textColor,
                ),
                const SizedBox(height: 16),
                _buildContactItem(
                  platform: 'Telegram',
                  iconColor: Colors.blue,
                  contactNumber: '09777577779',
                  svgPath: 'assets/images/telegram.svg',
                  textColor: textColor,
                ),

                // Divider
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Divider(color: dividerColor),
                ),

                // Software description
                Text(
                  'မကြာမီအချိန်တွင်းမှာ 1xKing Software မှ တိုက်ရိုက်ကစားနိုင်မည် ဖြစ်ပါသည်။',
                  style: TextStyle(color: textColor, fontSize: 16),
                ),

                // Illustration - use custom painter instead of image asset
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Image.asset(
                      'assets/images/coming_soon_template.png',
                      width: 220,
                    ),
                  ),
                ),

                // Coming Soon text
                Center(
                  child: Text(
                    'Coming Soon!',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required String platform,
    required Color iconColor,
    required String contactNumber,
    required String svgPath,
    required Color textColor,
  }) {
    // Create widget for the icon
    Widget iconWidget = SvgPicture.asset(
      svgPath,
      width: 24,
      height: 24,
      // Fallback to a default icon if SVG fails to load
      placeholderBuilder:
          (BuildContext context) =>
              Icon(platform == 'Viber' ? Icons.phone : Icons.send, size: 20),
    );

    return Row(
      children: [
        iconWidget,
        const SizedBox(width: 12),
        Text(
          '$platform - $contactNumber',
          style: TextStyle(color: textColor, fontSize: 16),
        ),
      ],
    );
  }
}
