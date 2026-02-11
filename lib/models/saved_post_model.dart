import 'post_model.dart';

class SavedPostModel {
  final String id;
  final String userId;
  final String postId;
  final DateTime createdAt;

  /// JOIN으로 가져온 게시물 정보 (선택적)
  final PostModel? post;

  const SavedPostModel({
    required this.id,
    required this.userId,
    required this.postId,
    required this.createdAt,
    this.post,
  });

  factory SavedPostModel.fromJson(Map<String, dynamic> json) {
    return SavedPostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      postId: json['post_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      post: json['posts'] != null
          ? PostModel.fromJson(json['posts'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'post_id': postId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// INSERT용 (id, created_at 제외)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'post_id': postId,
    };
  }

  SavedPostModel copyWith({
    String? id,
    String? userId,
    String? postId,
    DateTime? createdAt,
    PostModel? post,
  }) {
    return SavedPostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      postId: postId ?? this.postId,
      createdAt: createdAt ?? this.createdAt,
      post: post ?? this.post,
    );
  }
}
