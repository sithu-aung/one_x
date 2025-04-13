import 'package:flutter/material.dart';
import 'package:one_x/core/theme/app_theme.dart';
import 'package:one_x/features/notification/data/models/notification_model.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLightTheme = AppTheme.backgroundColor.computeLuminance() > 0.5;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color:
              notification.isRead
                  ? AppTheme.cardColor
                  : isLightTheme
                  ? AppTheme.primaryColor.withOpacity(0.05)
                  : AppTheme.primaryColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                notification.isRead
                    ? isLightTheme
                        ? Colors.grey.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1)
                    : AppTheme.primaryColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow:
              isLightTheme
                  ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification icon
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: notification.getColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  notification.getIconData(),
                  color: notification.getColor(),
                  size: 20,
                ),
              ),

              // Notification content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with unread indicator
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              color: AppTheme.textColor,
                              fontSize: 15,
                              fontWeight:
                                  notification.isRead
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    // Message content
                    Text(
                      notification.message,
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Time
                    Text(
                      notification.getFormattedDate(),
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
