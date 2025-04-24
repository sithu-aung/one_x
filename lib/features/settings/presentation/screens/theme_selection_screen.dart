import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:one_x/core/providers/theme_provider.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/core/utils/secure_storage.dart';
import 'package:one_x/features/auth/presentation/screens/login_screen.dart';

class ThemeSelectionScreen extends ConsumerWidget {
  const ThemeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Theme Settings')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Theme',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: ListView.builder(
                  itemCount: ThemeConfig.availableThemes.length,
                  itemBuilder: (context, index) {
                    final theme = ThemeConfig.availableThemes[index];
                    final isSelected = theme.type == themeState.currentTheme;

                    return _buildThemeCard(
                      context: context,
                      theme: theme,
                      isSelected: isSelected,
                      onTap: () {
                        ref.read(themeProvider.notifier).setTheme(theme.type);
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 16.h),
              Divider(height: 1, thickness: 1),
              SizedBox(height: 16.h),
              // Logout button section
              _buildLogoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutConfirmation(context),
        icon: Icon(Icons.logout, color: Colors.white),
        label: Text(
          'Logout',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Logout'),
            content: Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => _performLogout(context),
                child: Text('Logout', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _performLogout(BuildContext context) async {
    // Clear focus before navigating
    FocusManager.instance.primaryFocus?.unfocus();

    // Clear all storage
    await SecureStorage.clearAllCredentials();

    // Use rootNavigator to ensure we're using the top-most navigator
    if (context.mounted) {
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  Widget _buildThemeCard({
    required BuildContext context,
    required ThemeConfig theme,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    // Get theme-specific button gradient
    List<Color> buttonGradient = [];
    switch (theme.type) {
      case ThemeType.blackRed:
        buttonGradient = [const Color(0xFFFF3131), const Color(0xFFBC0000)];
        break;
      case ThemeType.whiteBlue:
        buttonGradient = [const Color(0xFF42A5F5), const Color(0xFF1565C0)];
        break;
      case ThemeType.darkGreen:
        buttonGradient = [const Color(0xFF8BC34A), const Color(0xFF4CAF50)];
        break;
      case ThemeType.purpleGold:
        buttonGradient = [const Color(0xFFFFD700), const Color(0xFFFFA000)];
        break;
      case ThemeType.darkPurple:
        buttonGradient = [const Color(0xFFE040FB), const Color(0xFF9C27B0)];
        break;
      case ThemeType.whitePurple:
        buttonGradient = [const Color(0xFFAB47BC), const Color(0xFF7B1FA2)];
        break;
      case ThemeType.darkIndigo:
        buttonGradient = [const Color(0xFF3F51B5), const Color(0xFF1A237E)];
        break;
      case ThemeType.whiteIndigo:
        buttonGradient = [const Color(0xFF5C6BC0), const Color(0xFF3949AB)];
        break;
    }

    return Card(
      elevation: isSelected ? 4.r : 1.r,
      margin: EdgeInsets.only(bottom: 16.r),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side:
            isSelected
                ? BorderSide(color: theme.primaryColor, width: 2.r)
                : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    theme.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: theme.primaryColor,
                      size: 24.r,
                    ),
                ],
              ),
              SizedBox(height: 16.h),
              // Theme preview (app mockup)
              Container(
                height: 100.h,
                decoration: BoxDecoration(
                  color: theme.backgroundColor,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: theme.darkGrayColor, width: 1.r),
                ),
                child: Column(
                  children: [
                    // App bar
                    Container(
                      height: 30.h,
                      padding: EdgeInsets.symmetric(horizontal: 8.r),
                      decoration: BoxDecoration(
                        color: theme.backgroundColor,
                        border: Border(
                          bottom: BorderSide(
                            color: theme.darkGrayColor,
                            width: 0.5.r,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.menu, color: theme.textColor, size: 16.r),
                          Spacer(),
                          Text(
                            'App Preview',
                            style: TextStyle(
                              color: theme.textColor,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.notifications,
                            color: theme.textColor,
                            size: 16.r,
                          ),
                        ],
                      ),
                    ),
                    // Content
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(8.r),
                        child: Row(
                          children: [
                            // Button with theme colors
                            Expanded(
                              child: Container(
                                height: 40.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6.r),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: buttonGradient,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Button',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            // Card with theme colors
                            Expanded(
                              child: Container(
                                height: 40.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6.r),
                                  color: theme.cardColor,
                                ),
                                child: Center(
                                  child: Text(
                                    'Card',
                                    style: TextStyle(
                                      color: theme.textColor,
                                      fontSize: 10.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  _buildColorPreview(
                    color: theme.backgroundColor,
                    label: 'Background',
                  ),
                  SizedBox(width: 8.w),
                  _buildColorPreview(
                    color: theme.primaryColor,
                    label: 'Primary',
                  ),
                  SizedBox(width: 8.w),
                  _buildColorPreview(color: theme.accentColor, label: 'Accent'),
                  SizedBox(width: 8.w),
                  _buildColorPreview(
                    color: theme.secondaryColor,
                    label: 'Secondary',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorPreview({required Color color, required String label}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 36.r,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8.r),
              border:
                  color.value == Colors.white.value
                      ? Border.all(color: Colors.grey.withOpacity(0.3))
                      : null,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
