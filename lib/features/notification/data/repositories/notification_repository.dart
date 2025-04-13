import 'package:one_x/core/constants/app_constants.dart';
import 'package:one_x/core/services/storage_service.dart';
import 'package:one_x/core/utils/api_service.dart';
import 'package:one_x/features/notification/data/models/notification_model.dart';

class NotificationRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  NotificationRepository({
    required ApiService apiService,
    required StorageService storageService,
  }) : _apiService = apiService,
       _storageService = storageService;

  /// Fetches notifications for the authenticated user
  Future<List<NotificationModel>> getNotifications() async {
    // Get the response from the API
    final response = await _apiService.get('/api/notification');

    if (response != null) {
      // Handle response with 'success' and 'data' fields
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> notificationsJson = response['data'];
        return notificationsJson
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      }

      // Handle response that is directly a data array
      if (response['data'] != null && response['data'] is List) {
        final List<dynamic> notificationsJson = response['data'];
        return notificationsJson
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      }

      // Handle case where response itself is the array
      if (response is List) {
        return response
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      }
    }

    return [];
  }

  /// Marks a notification as read
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      final endpoint = AppConstants.readNotificationEndpoint.replaceAll(
        '{id}',
        notificationId,
      );
      await _apiService.post(endpoint);
      return true;
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Mark a notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await _apiService.post(
        '/api/notifications/$notificationId/read',
      );

      return response != null && response['success'] == true;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  // Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final response = await _apiService.post('/notifications/read-all');

      return response != null && response['success'] == true;
    } catch (e) {
      print('Error marking all notifications as read: $e');
      return false;
    }
  }
}
