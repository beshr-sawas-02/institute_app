// lib/data/models/notification_model.dart

import '../../utils/app_colors.dart';
import 'package:flutter/material.dart';

class NotificationModel {
  final int id;
  final int userId;
  final int? relatedId;
  final String? relatedType;
  final String title;
  final String message;
  final String type;
  final String channel;
  final bool isRead;
  final String? readAt;
  final bool sent;
  final String? sentAt;
  final String? createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    this.relatedId,
    this.relatedType,
    required this.title,
    required this.message,
    required this.type,
    required this.channel,
    required this.isRead,
    this.readAt,
    required this.sent,
    this.sentAt,
    this.createdAt,
  });

  Color get typeColor {
    switch (type) {
      case 'success': return AppColors.success;
      case 'warning': return AppColors.warning;
      case 'alert': return AppColors.error;
      case 'info':
      default: return AppColors.info;
    }
  }

  Color get typeBgColor {
    switch (type) {
      case 'success': return AppColors.successLight;
      case 'warning': return AppColors.warningLight;
      case 'alert': return AppColors.errorLight;
      case 'info':
      default: return AppColors.infoLight;
    }
  }

  IconData get typeIcon {
    switch (type) {
      case 'success': return Icons.check_circle_outline;
      case 'warning': return Icons.warning_amber_outlined;
      case 'alert': return Icons.error_outline;
      case 'info':
      default: return Icons.info_outline;
    }
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      relatedId: json['relatedId'] as int?,
      relatedType: json['relatedType'] as String?,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? 'info',
      channel: json['channel'] as String? ?? 'in_app',
      isRead: json['isRead'] as bool? ?? false,
      readAt: json['readAt'] as String?,
      sent: json['sent'] as bool? ?? false,
      sentAt: json['sentAt'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      userId: userId,
      relatedId: relatedId,
      relatedType: relatedType,
      title: title,
      message: message,
      type: type,
      channel: channel,
      isRead: isRead ?? this.isRead,
      readAt: readAt,
      sent: sent,
      sentAt: sentAt,
      createdAt: createdAt,
    );
  }

  @override
  String toString() => 'NotificationModel(id: $id, title: $title, isRead: $isRead)';
}

// ==================== Unread Count ====================

class UnreadCountModel {
  final int unreadCount;
  const UnreadCountModel({required this.unreadCount});

  factory UnreadCountModel.fromJson(Map<String, dynamic> json) {
    return UnreadCountModel(
      unreadCount: json['unreadCount'] as int? ?? 0,
    );
  }
}

// ==================== lib/data/models/pagination_model.dart ====================

class PaginationMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const PaginationMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  bool get hasNextPage => page < totalPages;
  bool get hasPrevPage => page > 1;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 10,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }
}

class PaginatedModel<T> {
  final List<T> data;
  final PaginationMeta meta;

  const PaginatedModel({required this.data, required this.meta});

  factory PaginatedModel.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromJson,
      ) {
    final rawData = json['data'] as List<dynamic>? ?? [];
    final items = rawData
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList();

    return PaginatedModel(
      data: items,
      meta: PaginationMeta.fromJson(
        json['meta'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  bool get isEmpty => data.isEmpty;
  bool get isNotEmpty => data.isNotEmpty;
  int get length => data.length;
}