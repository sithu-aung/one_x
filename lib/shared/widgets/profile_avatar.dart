import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/core/constants/app_constants.dart';
import 'package:one_x/features/home/presentation/providers/home_provider.dart';
import 'package:one_x/features/profile/application/profile_provider.dart';

/// A reusable widget to display user profile avatar consistently across the app.
/// This widget automatically refreshes when the profile image changes.
class ProfileAvatar extends ConsumerWidget {
  /// The radius of the circle avatar
  final double radius;

  /// Whether to show the edit button
  final bool showEditButton;

  /// Callback when edit button is tapped
  final VoidCallback? onEditTap;

  /// Whether to use cached home user data (faster but may be outdated)
  /// Set to false to always fetch fresh profile data
  final bool useHomeUserData;

  /// User profile photo URL (optional, overrides fetched data)
  final String? profilePhotoUrl;

  /// Creates a profile avatar widget
  const ProfileAvatar({
    super.key,
    this.radius = 40,
    this.showEditButton = false,
    this.onEditTap,
    this.useHomeUserData = true,
    this.profilePhotoUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If profilePhotoUrl is provided, use it directly
    if (profilePhotoUrl != null) {
      return _buildAvatar(profilePhotoUrl, ref, context);
    }

    // Otherwise, get profile photo from providers
    if (useHomeUserData) {
      // Use homeUserProvider for navigation drawer and other places
      // where quick loading is preferred
      final homeUser = ref.watch(homeUserProvider);

      if (homeUser?.profilePhoto != null) {
        return _buildAvatar(homeUser!.profilePhoto, ref, context);
      }
    }

    // For profile screen or when we need latest data
    return ref
        .watch(userProfileProvider)
        .when(
          data: (userData) {
            final user = userData.user;
            if (user?.profilePhoto != null) {
              return _buildAvatar(user!.profilePhoto, ref, context);
            }
            return _buildDefaultAvatar(context);
          },
          loading: () => _buildLoadingAvatar(),
          error: (_, __) => _buildDefaultAvatar(context),
        );
  }

  Widget _buildAvatar(
    dynamic profilePhoto,
    WidgetRef ref,
    BuildContext context,
  ) {
    // Convert profilePhoto to proper URL format
    final String imageUrl =
        profilePhoto.toString().startsWith('http')
            ? profilePhoto.toString()
            : '${AppConstants.baseUrl}/storage/$profilePhoto';

    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundImage: NetworkImage(imageUrl),
          onBackgroundImageError: (_, __) {
            // Image error handling is built into the CircleAvatar
          },
          backgroundColor: Colors.grey.shade200,
        ),
        if (showEditButton)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onEditTap,
              child: Container(
                height: radius * 0.7,
                width: radius * 0.7,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: radius * 0.4,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDefaultAvatar(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: const AssetImage('assets/images/avatar.png'),
      backgroundColor: Colors.grey.shade200,
    );
  }

  Widget _buildLoadingAvatar() {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade200,
      child: SizedBox(
        width: radius * 0.7,
        height: radius * 0.7,
        child: const CircularProgressIndicator(),
      ),
    );
  }
}

/// A provider that allows forcing refresh of profile data
/// Use this to trigger refresh when profile photo is updated
final profileRefreshProvider = StateProvider<int>((ref) => 0);

/// Extension method to easily refresh profile data
extension ProfileRefreshExtension on WidgetRef {
  /// Refreshes profile data in all widgets that use ProfileAvatar
  void refreshProfileData() {
    // Increment the refresh count to trigger rebuild
    read(profileRefreshProvider.notifier).state++;

    // Refresh the actual data providers
    refresh(userProfileProvider);
    refresh(homeDataProvider);
  }
}
