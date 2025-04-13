import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_x/core/utils/api_service.dart';
import 'package:one_x/core/services/storage_service.dart';
import 'package:one_x/features/notification/data/models/notification_model.dart';
import 'package:one_x/features/notification/data/repositories/notification_repository.dart';

// Api and storage service providers (these should exist elsewhere in your app)
final apiServiceProvider = Provider<ApiService>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return ApiService(storageService: storageService);
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// Repository provider
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return NotificationRepository(
    apiService: apiService,
    storageService: storageService,
  );
});

// Provider for notification state
class NotificationState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? error;

  NotificationState({
    required this.notifications,
    required this.isLoading,
    this.error,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  // Count unread notifications
  int get unreadCount =>
      notifications.where((notification) => !notification.isRead).length;
}

// Notification state notifier
class NotificationStateNotifier extends StateNotifier<NotificationState> {
  final NotificationRepository _repository;

  NotificationStateNotifier(this._repository)
    : super(NotificationState(notifications: [], isLoading: false));

  // Fetch all notifications
  Future<void> fetchNotifications() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final notifications = await _repository.getNotifications();
      state = state.copyWith(notifications: notifications, isLoading: false);
    } on ApiException catch (e) {
      // Let 401 errors propagate for proper global handling by ApiService
      if (e.statusCode == 401) {
        rethrow;
      }
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load notifications: ${e.message}',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load notifications: $e',
      );
    }
  }

  // Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final success = await _repository.markAsRead(notificationId);
      if (success) {
        // Fetch fresh notification data to update all statuses
        await fetchNotifications();
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to mark notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final success = await _repository.markAllAsRead();
      if (success) {
        // Fetch fresh notification data to update all statuses
        await fetchNotifications();
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to mark all notifications as read: $e',
      );
    }
  }
}

// Provider for notification state
final notificationProvider =
    StateNotifierProvider<NotificationStateNotifier, NotificationState>((ref) {
      final repository = ref.watch(notificationRepositoryProvider);
      return NotificationStateNotifier(repository);
    });

// Unread count provider
final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).unreadCount;
});
