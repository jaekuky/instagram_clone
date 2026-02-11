import 'user_model.dart';

class FollowModel {
  final String id;
  final String followerId;
  final String followingId;
  final DateTime createdAt;

  /// JOIN으로 가져온 프로필 정보 (선택적)
  final UserModel? follower;
  final UserModel? following;

  const FollowModel({
    required this.id,
    required this.followerId,
    required this.followingId,
    required this.createdAt,
    this.follower,
    this.following,
  });

  factory FollowModel.fromJson(Map<String, dynamic> json) {
    return FollowModel(
      id: json['id'] as String,
      followerId: json['follower_id'] as String,
      followingId: json['following_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      follower: json['follower'] != null
          ? UserModel.fromJson(json['follower'] as Map<String, dynamic>)
          : null,
      following: json['following'] != null
          ? UserModel.fromJson(json['following'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'follower_id': followerId,
      'following_id': followingId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// INSERT용 (id, created_at 제외)
  Map<String, dynamic> toInsertJson() {
    return {
      'follower_id': followerId,
      'following_id': followingId,
    };
  }

  FollowModel copyWith({
    String? id,
    String? followerId,
    String? followingId,
    DateTime? createdAt,
    UserModel? follower,
    UserModel? following,
  }) {
    return FollowModel(
      id: id ?? this.id,
      followerId: followerId ?? this.followerId,
      followingId: followingId ?? this.followingId,
      createdAt: createdAt ?? this.createdAt,
      follower: follower ?? this.follower,
      following: following ?? this.following,
    );
  }
}
