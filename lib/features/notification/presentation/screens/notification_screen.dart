import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/notification/data/models/notification_model.dart';
import 'package:one_x/features/notification/presentation/providers/notification_provider.dart';
import 'package:one_x/features/notification/presentation/widgets/notification_item.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch notifications when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationProvider.notifier).fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationProvider);
    final notifications = notificationState.notifications;
    final isLoading = notificationState.isLoading;
    final hasError = notificationState.error != null;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: Text(
          'Notifications',
          style: TextStyle(color: AppTheme.textColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (notifications.any((notification) => !notification.isRead))
            IconButton(
              icon: Icon(Icons.done_all, color: AppTheme.primaryColor),
              onPressed: () {
                // Mark all notifications as read
                ref.read(notificationProvider.notifier).markAllAsRead();
              },
              tooltip: 'Mark all as read',
            ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(notificationProvider.notifier).fetchNotifications();
          },
          child: _buildNotificationList(
            notifications: notifications,
            isLoading: isLoading,
            hasError: hasError,
            errorMessage: notificationState.error,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationList({
    required List<NotificationModel> notifications,
    required bool isLoading,
    required bool hasError,
    String? errorMessage,
  }) {
    if (isLoading && notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError && notifications.isEmpty) {
      return Center(
        child: Text(
          errorMessage ?? 'Failed to load notifications',
          style: TextStyle(color: AppTheme.textColor, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 48,
              color: AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(color: AppTheme.textColor, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return NotificationItem(
          notification: notification,
          onTap: () {
            // Mark notification as read
            if (!notification.isRead) {
              ref
                  .read(notificationProvider.notifier)
                  .markAsRead(notification.id.toString());
            }

            // Handle notification action based on type
            // You can navigate to different screens based on notification type
            _handleNotificationTap(notification);
          },
        );
      },
    );
  }

  // Handle notification tap based on action type
  void _handleNotificationTap(NotificationModel notification) {
    // This would navigate to different screens based on notification type
    if (notification.actionType == 'payment' &&
        notification.actionData != null) {
      // Navigate to payment details
      print('Navigate to payment details: ${notification.actionData}');
    } else if (notification.actionType == 'promotion' &&
        notification.actionData != null) {
      // Navigate to promotion details
      print('Navigate to promotion: ${notification.actionData}');
    } else if (notification.actionType == 'win' &&
        notification.actionData != null) {
      // Navigate to winning details
      print('Navigate to winning details: ${notification.actionData}');
    } else {
      // Show notification details in a dialog if no specific action
      _showNotificationDetails(notification);
    }
  }

  // Show notification details in a dialog
  void _showNotificationDetails(NotificationModel notification) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppTheme.cardColor,
            title: Text(
              notification.title,
              style: TextStyle(
                color: AppTheme.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (notification.image != null &&
                    notification.image!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    height: 180,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(notification.image!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                Text(
                  notification.message,
                  style: TextStyle(color: AppTheme.textColor),
                ),
                const SizedBox(height: 12),
                Text(
                  notification.getFormattedDate(),
                  style: TextStyle(
                    color: AppTheme.textSecondaryColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                ),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}
