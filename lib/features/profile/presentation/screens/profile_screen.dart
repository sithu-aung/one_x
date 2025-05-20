import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/auth/presentation/providers/auth_provider.dart';
import 'package:one_x/features/profile/application/profile_provider.dart';
import 'package:intl/intl.dart';
import 'package:one_x/core/constants/app_constants.dart';
import 'package:one_x/shared/widgets/profile_avatar.dart';
import 'package:flutter/services.dart';

// Convert to StatefulConsumerWidget for state management with access to ref
class ProfileScreen extends ConsumerStatefulWidget {
  final bool fromHomeDrawer;

  const ProfileScreen({super.key, this.fromHomeDrawer = false});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authUser = authState.user;

    // Get user data from profile provider
    final userProfileAsync = ref.watch(userProfileProvider);
    // Get user responses data - removed as API doesn't exist
    // final userResponsesAsync = ref.watch(userResponsesProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      // Only show AppBar if coming from home drawer, otherwise show no AppBar
      appBar:
          widget.fromHomeDrawer
              ? AppBar(
                backgroundColor: AppTheme.backgroundColor,
                elevation: 0,
                automaticallyImplyLeading: false,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: AppTheme.textColor),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              )
              : null,
      body: SafeArea(
        bottom: false, // Don't pad for bottom navigation
        child: userProfileAsync.when(
          data: (profileData) {
            final user = profileData.user;

            // If we have user responses data, and it's also loaded successfully
            // Removed - API doesn't exist
            // if (userResponsesAsync.value != null &&
            //    userResponsesAsync.value!.user != null &&
            //    userResponsesAsync.value!.user!.userResponseField != null) {
            //  // Add the userResponseField from the responses to the user object
            //  user!.userResponseField =
            //      userResponsesAsync.value!.user!.userResponseField;
            // }

            return _buildProfileContent(context, user);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) {
            // Fallback to auth user data or show error
            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Error loading profile: $error',
                      style: TextStyle(color: AppTheme.textColor),
                    ),
                  ),
                  if (authUser != null) _buildProfileContent(context, null),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, user) {
    return SingleChildScrollView(
      child: Container(
        // Add bottom margin to prevent content from being covered by bottom navigation bar
        margin: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile title at top left - only show if coming from home drawer
            if (widget.fromHomeDrawer)
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
                child: ProfileAvatar(
                  radius: 50,
                  showEditButton: true,
                  onEditTap: () => _showProfilePhotoOptions(context),
                  useHomeUserData:
                      false, // Always use fresh data on profile screen
                  profilePhotoUrl: user?.profilePhoto,
                ),
              ),
            ),

            // User name
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  user?.username ?? 'Player Name',
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
                  'ID#${user?.userCode ?? 'A00220000'}',
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            // Account Information section
            _buildSectionHeader('Account Information'),
            _buildInfoItem('UserID', user?.userKey ?? '-'),
            _buildInfoItem('Birth Date', user?.dateOfBirth ?? '-'),
            _buildInfoItem('Joined Date', user?.createdAtHuman ?? '-'),
            _buildInfoItem('User Email', user?.email ?? '-'),

            // Password field (tappable)
            GestureDetector(
              onTap: () {
                // Navigate to password change screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PasswordChangeScreen(),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
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
                      style: TextStyle(color: AppTheme.textColor, fontSize: 16),
                    ),
                    const Spacer(),
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        'ပြောင်းရန်',
                        style: AppTheme.burmeseTextStyle(
                          color: AppTheme.textColor,
                        ),
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
            ),

            // Edit Profile button
            // GestureDetector(
            //   onTap: () {
            //     // Navigate to edit profile screen
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => ProfileEditScreen(user: user),
            //       ),
            //     );
            //   },
            //   child: Container(
            //     margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            //     padding: const EdgeInsets.symmetric(
            //       horizontal: 16,
            //       vertical: 12,
            //     ),
            //     decoration: BoxDecoration(
            //       color: AppTheme.cardColor,
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //     child: Row(
            //       children: [
            //         Icon(Icons.edit, color: AppTheme.textColor, size: 20),
            //         const SizedBox(width: 16),
            //         Text(
            //           'Edit Profile',
            //           style: TextStyle(color: AppTheme.textColor, fontSize: 16),
            //         ),
            //         const Spacer(),
            //         Icon(
            //           Icons.arrow_forward_ios,
            //           color: AppTheme.textColor,
            //           size: 16,
            //         ),
            //       ],
            //     ),
            //   ),
            // ),

            // Contact Information section
            _buildSectionHeader('Contact Information'),
            _buildInfoItem('Phone', user?.phone ?? '-'),
            _buildInfoItem('Hidden Phone', user?.hiddenPhone ?? '-'),
            // Copiable referral code
            Container(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // Label
                  Text(
                    'မိတ်ဆက်ကုဒ်',
                    style: TextStyle(color: AppTheme.textColor, fontSize: 16),
                  ),
                  const Spacer(),

                  // Value
                  InkWell(
                    onTap:
                        user?.myReferral != null &&
                                user.myReferral.toString().isNotEmpty
                            ? () => _copyToClipboard(user.myReferral.toString())
                            : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 180),
                      child: Text(
                        user?.myReferral ?? '-',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildInfoItem('Address', user?.address ?? '-'),

            // User Balance information
            _buildSectionHeader('Balance Information'),
            _buildInfoItem(
              'Current Balance',
              user?.balance != null
                  ? '${NumberFormat('#,###').format(user.balance)} Ks'
                  : 'Not available',
            ),
            _buildInfoItem(
              'Created At',
              user?.createdAtHuman != null
                  ? user.createdAtHuman.toString()
                  : '-',
            ),

            // User Response Field information if available - removed as API doesn't exist
            // if (user?.userResponseField != null) ...[
            //   _buildSectionHeader('User Response Field'),
            //   _buildInfoItem(
            //     'Response',
            //     user.userResponseField!.response ?? 'Not available',
            //   ),
            //   _buildInfoItem(
            //     'Response Type',
            //     user.userResponseField!.responseType ?? 'Not available',
            //   ),
            //   _buildInfoItem(
            //     'Created At',
            //     user.userResponseField!.createdAt ?? 'Not available',
            //   ),
            //   _buildInfoItem(
            //     'Updated At',
            //     user.userResponseField!.updatedAt ?? 'Not available',
            //   ),
            // ],
            const SizedBox(height: 16),
          ],
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
        style: TextStyle(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Label
          Text(
            label,
            style: TextStyle(color: AppTheme.textColor, fontSize: 16),
          ),
          const Spacer(),

          // Value
          Container(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 16,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // Show dialog with options to take photo or pick from gallery
  void _showProfilePhotoOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: Text(
            'Change Profile Photo',
            style: TextStyle(color: AppTheme.textColor),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: AppTheme.primaryColor,
                ),
                title: Text(
                  'Choose from gallery',
                  style: TextStyle(color: AppTheme.textColor),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppTheme.primaryColor),
                title: Text(
                  'Take a photo',
                  style: TextStyle(color: AppTheme.textColor),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  // Pick image from gallery or camera and upload it
  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        // Show loading indicator
        _showLoadingDialog(context);

        // Upload profile photo
        await ref
            .read(uploadProfilePhotoProvider(imageFile).future)
            .then((_) async {
              // Force a complete refresh of user profile data
              ref.refreshProfileData();

              // Close loading dialog
              if (mounted && context.mounted) {
                Navigator.pop(context);
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile photo updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            })
            .catchError((error) {
              // Close loading dialog
              if (mounted && context.mounted) {
                Navigator.pop(context);
                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to update profile photo: $error'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            });
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Show loading dialog
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Uploading profile photo...',
                style: TextStyle(color: AppTheme.textColor),
              ),
            ],
          ),
        );
      },
    );
  }

  // Copy to clipboard helper
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    if (mounted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Copied to clipboard'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

// Password Change Screen
class PasswordChangeScreen extends ConsumerStatefulWidget {
  const PasswordChangeScreen({super.key});

  @override
  ConsumerState<PasswordChangeScreen> createState() =>
      _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends ConsumerState<PasswordChangeScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Change Password',
          style: TextStyle(color: AppTheme.textColor),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.textColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Old Password Field
                  Text(
                    'Old Password',
                    style: TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _oldPasswordController,
                    obscureText: _obscureOldPassword,
                    style: TextStyle(color: AppTheme.textColor),
                    decoration: InputDecoration(
                      fillColor: AppTheme.cardColor,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Enter your current password',
                      hintStyle: TextStyle(color: AppTheme.textSecondaryColor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureOldPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppTheme.textSecondaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureOldPassword = !_obscureOldPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your current password';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),
                  // New Password Field
                  Text(
                    'New Password',
                    style: TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: _obscureNewPassword,
                    style: TextStyle(color: AppTheme.textColor),
                    decoration: InputDecoration(
                      fillColor: AppTheme.cardColor,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Enter new password',
                      hintStyle: TextStyle(color: AppTheme.textSecondaryColor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNewPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppTheme.textSecondaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter new password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),
                  // Confirm New Password Field
                  Text(
                    'Confirm New Password',
                    style: TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    style: TextStyle(color: AppTheme.textColor),
                    decoration: InputDecoration(
                      fillColor: AppTheme.cardColor,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Confirm new password',
                      hintStyle: TextStyle(color: AppTheme.textSecondaryColor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppTheme.textSecondaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your new password';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 40),
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _isLoading
                              ? null
                              : () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  try {
                                    final passwordData = {
                                      'old_password':
                                          _oldPasswordController.text,
                                      'new_password':
                                          _newPasswordController.text,
                                      'confirm_password':
                                          _confirmPasswordController.text,
                                    };

                                    final response = await ref.read(
                                      changePasswordProvider(
                                        passwordData,
                                      ).future,
                                    );

                                    if (response.containsKey('success') &&
                                        response['success'] == true) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Password changed successfully',
                                          ),
                                        ),
                                      );
                                      Navigator.pop(context);
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            response['message'] ??
                                                'Failed to change password',
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: ${e.toString()}'),
                                      ),
                                    );
                                  } finally {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text(
                                'Change Password',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Profile Edit Screen
class ProfileEditScreen extends ConsumerStatefulWidget {
  final dynamic user;

  const ProfileEditScreen({super.key, required this.user});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _viberPhoneController;
  late final TextEditingController _telegramController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.username ?? '');
    _phoneController = TextEditingController(text: widget.user?.phone ?? '');
    _viberPhoneController = TextEditingController(
      text: widget.user?.hiddenPhone ?? '',
    );
    _telegramController = TextEditingController(
      text: widget.user?.myReferral ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _viberPhoneController.dispose();
    _telegramController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(color: AppTheme.textColor),
        ),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.textColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture
                  Center(
                    child: ProfileAvatar(
                      radius: 50,
                      showEditButton: true,
                      useHomeUserData: false,
                      // Use the user's profile photo directly if available
                      profilePhotoUrl: widget.user?.profilePhoto,
                    ),
                  ),

                  const SizedBox(height: 30),
                  // Name Field
                  Text(
                    'Name',
                    style: TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    style: TextStyle(color: AppTheme.textColor),
                    decoration: InputDecoration(
                      fillColor: AppTheme.cardColor,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Enter your name',
                      hintStyle: TextStyle(color: AppTheme.textSecondaryColor),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),
                  // Phone Field
                  Text(
                    'Phone',
                    style: TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneController,
                    style: TextStyle(color: AppTheme.textColor),
                    decoration: InputDecoration(
                      fillColor: AppTheme.cardColor,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Enter your phone number',
                      hintStyle: TextStyle(color: AppTheme.textSecondaryColor),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),
                  // Viber Phone Field
                  Text(
                    'Viber Phone',
                    style: TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _viberPhoneController,
                    style: TextStyle(color: AppTheme.textColor),
                    decoration: InputDecoration(
                      fillColor: AppTheme.cardColor,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Enter your Viber phone number',
                      hintStyle: TextStyle(color: AppTheme.textSecondaryColor),
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Telegram Account Field
                  Text(
                    'Telegram Account',
                    style: TextStyle(
                      color: AppTheme.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _telegramController,
                    style: TextStyle(color: AppTheme.textColor),
                    decoration: InputDecoration(
                      fillColor: AppTheme.cardColor,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Enter your Telegram account',
                      hintStyle: TextStyle(color: AppTheme.textSecondaryColor),
                    ),
                  ),

                  const SizedBox(height: 40),
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _isLoading
                              ? null
                              : () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  try {
                                    final profileData = {
                                      'username': _nameController.text,
                                      'phone': _phoneController.text,
                                      'viber_phone': _viberPhoneController.text,
                                      'telegram_account':
                                          _telegramController.text,
                                    };

                                    final response = await ref.read(
                                      updateProfileProvider(profileData).future,
                                    );

                                    if (response.containsKey('success') &&
                                        response['success'] == true) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Profile updated successfully',
                                          ),
                                        ),
                                      );
                                      Navigator.pop(context);
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            response['message'] ??
                                                'Failed to update profile',
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: ${e.toString()}'),
                                      ),
                                    );
                                  } finally {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
