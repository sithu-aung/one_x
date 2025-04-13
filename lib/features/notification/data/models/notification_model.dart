import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String? image;
  final DateTime createdAt;
  final bool isRead;
  final String? actionType;
  final String? actionData;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.image,
    required this.createdAt,
    required this.isRead,
    this.actionType,
    this.actionData,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] != null ? json['id'].toString() : '0',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      image: json['image'],
      createdAt:
          json['created_at'] != null
              ? (json['created_at'] is String &&
                      !json['created_at'].contains('ago')
                  ? DateTime.parse(json['created_at'])
                  : DateTime.now())
              : DateTime.now(),
      isRead:
          json['read_at'] != null ||
          json['is_read'] == 1 ||
          json['is_read'] == true,
      actionType: json['action_type'] ?? json['status'],
      actionData: json['action_data'],
    );
  }

  // For determining notification icon type
  IconData getIconData() {
    if (actionType == 'payment') {
      return Icons.payment;
    } else if (actionType == 'promotion') {
      return Icons.local_offer;
    } else if (actionType == 'update') {
      return Icons.system_update;
    } else if (actionType == 'win') {
      return Icons.emoji_events;
    } else {
      return Icons.notifications;
    }
  }

  // For determining notification color
  Color getColor() {
    if (actionType == 'payment') {
      return Colors.green;
    } else if (actionType == 'promotion') {
      return Colors.orange;
    } else if (actionType == 'update') {
      return Colors.blue;
    } else if (actionType == 'win') {
      return Colors.amber;
    } else {
      return Colors.purple;
    }
  }

  // Get formatted date
  String getFormattedDate() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }
}
