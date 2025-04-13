import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/auth/presentation/providers/auth_provider.dart';
import 'package:one_x/features/home/presentation/providers/home_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authUser = authState.user;
    
    // Get user data from home provider if available
    final homeUser = ref.watch(homeUserProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        bottom: false, // Don't pad for bottom navigation
        child: SingleChildScrollView(
          child: Container(
            // Add bottom margin to prevent content from being covered by bottom navigation bar
            margin: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile title at top left
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    top: 16.0,
                    bottom: 8.0,
                  ),
                  child: Text(
                    'Profile',
                    style: TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Profile picture with edit button
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              homeUser?.profilePhoto != null
                                  ? NetworkImage(homeUser!.profilePhoto)
                                  : authUser?.avatar != null
                                      ? NetworkImage(authUser!.avatar!)
                                      : const AssetImage('assets/images/avatar.png')
                                          as ImageProvider,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            height: 35,
                            width: 35,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // User name
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      homeUser?.username ?? authUser?.name ?? 'User Name',
                      style: AppTheme.burmeseTextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                    ),
                  ),
                ),

                // ID number
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    child: Text(
                      'ID#${homeUser?.userCode ?? authUser?.id ?? 'A00220000'}',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                // Account Information section
                _buildSectionHeader('Account Information'),
                _buildInfoItem('User Key', homeUser?.userKey ?? 'Not available'),
                _buildInfoItem('Birth Date', homeUser?.dateOfBirth ?? 'Not available'),
                _buildInfoItem('Joined Date', 'Sept 10, 2024'),
                _buildInfoItem(
                  'User Email',
                  homeUser?.email ?? authUser?.email ?? 'Not available',
                ),

                // Password field (tappable)
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 16,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock, color: AppTheme.textColor, size: 20),
                      const SizedBox(width: 16),
                      Text(
                        'Password',
                        style: TextStyle(
                          color: AppTheme.textColor,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 100,
                        alignment: Alignment.center,
                        child: Text(
                          '••••••••',
                          style: TextStyle(color: AppTheme.textColor),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppTheme.textColor,
                        size: 16,
                      ),
                    ],
                  ),
                ),

                // Edit Profile button
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 16,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: AppTheme.textColor, size: 20),
                      const SizedBox(width: 16),
                      Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: AppTheme.textColor,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppTheme.textColor,
                        size: 16,
                      ),
                    ],
                  ),
                ),

                // Contact Information section
                _buildSectionHeader('Contact Information'),
                _buildInfoItem('Phone', homeUser?.phone ?? 'Not available'),
                _buildInfoItem('Viber Phone', '09123456789'),
                _buildInfoItem(
                  'Telegram Account',
                  'https://telegram/aa/profile',
                ),
                _buildInfoItem('Address', homeUser?.address ?? 'Not available'),

                // Bank Information section
                _buildSectionHeader('Bank Information'),

                // KBZ Pay
                _buildBankItem(
                  'KBZ Pay',
                  'Special',
                  'assets/images/kbz_pay.png',
                  '09 12345678',
                ),

                // Wave Pay
                _buildBankItem(
                  'Wave Pay',
                  'Normal',
                  'assets/images/wave_money.png',
                  '09 12345678',
                ),

                // CB Pay
                _buildBankItem(
                  'CB Pay',
                  'Normal',
                  'assets/images/cb_pay.png',
                  '09 12345678',
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
      child: Text(
        title,
        style: AppTheme.burmeseTextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.textColor,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTheme.burmeseTextStyle(
                fontSize: 13,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.burmeseTextStyle(
                fontSize: 13,
                color: AppTheme.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankItem(
    String name,
    String type,
    String iconPath,
    String accountNumber,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  AppTheme.backgroundColor.computeLuminance() < 0.5
                      ? Colors.white
                      : AppTheme.cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(6),
            child: Image.asset(iconPath),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$name ( $type )',
                style: TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                accountNumber,
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
