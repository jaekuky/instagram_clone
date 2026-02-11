import 'user_model.dart';

class PostModel {
  final String id;
  final String userId;
  final String imageUrl;
  final String? caption;
  final String location;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// JOIN으로 가져온 작성자 프로필 정보 (선택적)
  final UserModel? user;

  /// 현재 사용자가 좋아요를 눌렀는지 (클라이언트 측에서 설정)
  final bool isLiked;

  /// 현재 사용자가 저장했는지 (클라이언트 측에서 설정)
  final bool isSaved;

  const PostModel({
    required this.id,
    required this.userId,
    required this.imageUrl,
    this.caption,
    this.location = '',
    this.likesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.isLiked = false,
    this.isSaved = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      imageUrl: json['image_url'] as String,
      caption: json['caption'] as String?,
      location: json['location'] as String? ?? '',
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
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
      'caption': caption,
      'location': location,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// INSERT용 (id, counts, timestamps 제외)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'image_url': imageUrl,
      'caption': caption,
      'location': location,
    };
  }

  PostModel copyWith({
    String? id,
    String? userId,
    String? imageUrl,
    String? caption,
    String? location,
    int? likesCount,
    int? commentsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserModel? user,
    bool? isLiked,
    bool? isSaved,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      location: location ?? this.location,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}
