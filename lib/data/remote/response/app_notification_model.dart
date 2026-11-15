import 'dart:convert';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';

enum NotificationType {
  general,
  payroll,
  requestStatus,
  message,
  approval,
  attendance,
  schedule,
  task,
  /// Overtime HR assigned to me (session_overtime_assigned) → My Overtime.
  overtime,
  /// My assigned overtime was accepted / rejected (to the assigner).
  overtimeAnswer,
}

/// A file of a broadcast sent to me: `{ id, name, size, mime, ext, url }`.
/// Opened with GET my/notifications/attachments/{id}.
class NotificationFile {
  final int id;
  final String name;
  final int size;
  final String? mime;
  final String? ext;

  NotificationFile({required this.id, required this.name, this.size = 0, this.mime, this.ext});

  factory NotificationFile.fromJson(Map<String, dynamic> j) => NotificationFile(
        id: j['id'] is int ? j['id'] : int.tryParse('${j['id']}') ?? 0,
        name: (j['name'] ?? 'file').toString(),
        size: j['size'] is int ? j['size'] : int.tryParse('${j['size']}') ?? 0,
        mime: j['mime']?.toString(),
        ext: j['ext']?.toString(),
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'size': size, 'mime': mime, 'ext': ext};
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
  final List<NotificationFile> attachments;

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
    this.attachments = const [],
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
      attachments: (json['attachments'] is List)
          ? (json['attachments'] as List)
              .whereType<Map>()
              .map((e) => NotificationFile.fromJson(Map<String, dynamic>.from(e)))
              .where((f) => f.id > 0)
              .toList()
          : const [],
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
      'attachments': attachments.map((f) => f.toJson()).toList(),
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
      attachments: attachments,
    );
  }

  static NotificationType _parseNotificationType(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'session_overtime_assigned':
      case 'overtime_assigned':
      case 'assigned_overtime':
        return NotificationType.overtime;
      case 'session_overtime_accepted':
      case 'session_overtime_rejected':
        return NotificationType.overtimeAnswer;
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
      case 'attendance':
      case 'attendance_delay':
      case 'attendance_half_day_absent':
      case 'attendance_absent':
      case 'attendance_missing_checkout':
      case 'attendance_flex_under_hours':
        return NotificationType.attendance;
      case 'schedule':
      case 'session_assigned':
      case 'session_day_off_added':
      case 'session_day_off_reversed':
        return NotificationType.schedule;
      case 'task':
        return NotificationType.task;
      default:
        return NotificationType.general;
    }
  }

  String get typeDisplayName {
    switch (type) {
      case NotificationType.general:
        return tr('notification_type_general');
      case NotificationType.payroll:
        return tr('notification_type_payroll');
      case NotificationType.requestStatus:
        return tr('notification_type_request_status');
      case NotificationType.message:
        return tr('notification_type_message');
      case NotificationType.approval:
        return tr('notification_type_approval');
      case NotificationType.attendance:
        return tr('attendance');
      case NotificationType.schedule:
        return tr('work_schedule');
      case NotificationType.task:
        return tr('tasks');
      case NotificationType.overtime:
      case NotificationType.overtimeAnswer:
        return tr('my_overtime');
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
      case NotificationType.attendance:
        return '🕐';
      case NotificationType.schedule:
        return '📅';
      case NotificationType.task:
        return '📌';
      case NotificationType.overtime:
      case NotificationType.overtimeAnswer:
        return '⏱️';
    }
  }
}
