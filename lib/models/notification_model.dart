import 'user_model.dart';

/// 알림 유형
enum NotificationType {
  like,
  comment,
  follow;

  /// DB 문자열 → enum
  static NotificationType fromString(String value) {
    switch (value) {
      case 'like':
        return NotificationType.like;
      case 'comment':
        return NotificationType.comment;
      case 'follow':
        return NotificationType.follow;
      default:
        return NotificationType.like;
    }
  }

  /// enum → DB 문자열
  String toValue() => name;

  /// 알림 메시지 생성
  String toMessage(String actorName) {
    switch (this) {
      case NotificationType.like:
        return '$actorName님이 회원님의 게시물을 좋아합니다.';
      case NotificationType.comment:
        return '$actorName님이 댓글을 남겼습니다.';
      case NotificationType.follow:
        return '$actorName님이 회원님을 팔로우하기 시작했습니다.';
    }
  }
}

class NotificationModel {
  final String id;
  final String userId;
  final String actorId;
  final NotificationType type;
  final String? postId;
  final bool isRead;
  final DateTime createdAt;

  /// JOIN으로 가져온 행위자(actor) 프로필 정보 (선택적)
  final UserModel? actor;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.actorId,
    required this.type,
    this.postId,
    this.isRead = false,
    required this.createdAt,
    this.actor,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      actorId: json['actor_id'] as String,
      type: NotificationType.fromString(json['type'] as String),
      postId: json['post_id'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      actor: json['actor'] != null
          ? UserModel.fromJson(json['actor'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'actor_id': actorId,
      'type': type.toValue(),
      'post_id': postId,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? actorId,
    NotificationType? type,
    String? postId,
    bool? isRead,
    DateTime? createdAt,
    UserModel? actor,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      actorId: actorId ?? this.actorId,
      type: type ?? this.type,
      postId: postId ?? this.postId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      actor: actor ?? this.actor,
    );
  }
}
