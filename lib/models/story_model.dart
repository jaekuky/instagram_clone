import 'user_model.dart';

class StoryModel {
  final String id;
  final String userId;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime expiresAt;

  /// JOIN으로 가져온 프로필 정보 (선택적)
  final UserModel? user;

  const StoryModel({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.createdAt,
    required this.expiresAt,
    this.user,
  });

  /// 스토리가 아직 유효한지 확인
  bool get isActive => DateTime.now().isBefore(expiresAt);

  /// 스토리 만료까지 남은 시간
  Duration get remainingTime => expiresAt.difference(DateTime.now());

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      imageUrl: json['image_url'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      user: json['profiles'] != null
          ? UserModel.fromJson(json['profiles'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
    };
  }

  /// INSERT용 (id, created_at, expires_at는 DB 기본값 사용)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'image_url': imageUrl,
    };
  }

  StoryModel copyWith({
    String? id,
    String? userId,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? expiresAt,
    UserModel? user,
  }) {
    return StoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      user: user ?? this.user,
    );
  }
}
