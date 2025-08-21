import 'dart:convert';

enum NotificationType {
  general,
  payroll,
  requestStatus,
  message,
  approval,
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;
  final String? actionUrl;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
    this.actionUrl,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: _parseNotificationType(json['type'] ?? 'general'),
      data: json['data'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      isRead: json['is_read'] ?? false,
      imageUrl: json['image_url'],
      actionUrl: json['action_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.name,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'image_url': imageUrl,
      'action_url': actionUrl,
    };
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    bool? isRead,
    String? imageUrl,
    String? actionUrl,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  static NotificationType _parseNotificationType(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'general':
        return NotificationType.general;
      case 'payroll':
        return NotificationType.payroll;
      case 'request_status':      // API format (with underscore)
      case 'requeststatus':       // Alternative format
      case 'requestStatus':       // camelCase format
        return NotificationType.requestStatus;
      case 'message':
        return NotificationType.message;
      case 'approval':
        return NotificationType.approval;
      default:
        return NotificationType.general;
    }
  }

  String get typeDisplayName {
    switch (type) {
      case NotificationType.general:
        return 'General';
      case NotificationType.payroll:
        return 'Payroll';
      case NotificationType.requestStatus:
        return 'Request Status';
      case NotificationType.message:
        return 'Message';
      case NotificationType.approval:
        return 'Approval';
    }
  }

  String get typeIcon {
    switch (type) {
      case NotificationType.general:
        return '📢';
      case NotificationType.payroll:
        return '💰';
      case NotificationType.requestStatus:
        return '📋';
      case NotificationType.message:
        return '💬';
      case NotificationType.approval:
        return '✅';
    }
  }
}
