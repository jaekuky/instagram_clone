import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'supabase_service.dart';

/// Supabase Storage 파일 업로드/삭제 서비스
class StorageService {
  final SupabaseClient _client = SupabaseService.client;
  final Uuid _uuid = const Uuid();

  // ──────────────────────────────────────────
  // 프로필 아바타 (avatars 버킷)
  // ──────────────────────────────────────────

  /// 프로필 사진 업로드
  /// 경로: avatars/{userId}/{uuid}.{ext}
  Future<String> uploadAvatar({
    required String userId,
    required Uint8List fileBytes,
    required String fileExtension,
  }) async {
    final fileName = '${_uuid.v4()}.$fileExtension';
    final filePath = '$userId/$fileName';

    await _client.storage.from('avatars').uploadBinary(
          filePath,
          fileBytes,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: true,
          ),
        );

    return _client.storage.from('avatars').getPublicUrl(filePath);
  }

  /// 기존 아바타 삭제
  Future<void> deleteAvatar(String filePath) async {
    await _client.storage.from('avatars').remove([filePath]);
  }

  // ──────────────────────────────────────────
  // 게시물 이미지 (posts 버킷)
  // ──────────────────────────────────────────

  /// 게시물 이미지 업로드
  /// 경로: posts/{userId}/{uuid}.{ext}
  Future<String> uploadPostImage({
    required String userId,
    required Uint8List fileBytes,
    required String fileExtension,
  }) async {
    final fileName = '${_uuid.v4()}.$fileExtension';
    final filePath = '$userId/$fileName';

    await _client.storage.from('posts').uploadBinary(
          filePath,
          fileBytes,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: false,
          ),
        );

    return _client.storage.from('posts').getPublicUrl(filePath);
  }

  /// 게시물 이미지 삭제
  Future<void> deletePostImage(String filePath) async {
    await _client.storage.from('posts').remove([filePath]);
  }

  /// 이미지 URL에서 Storage 경로 추출
  String extractPathFromUrl(String url, String bucket) {
    final bucketPath = '/storage/v1/object/public/$bucket/';
    final idx = url.indexOf(bucketPath);
    if (idx == -1) return '';
    return url.substring(idx + bucketPath.length);
  }

  // ──────────────────────────────────────────
  // 스토리 이미지 (stories 버킷)
  // ──────────────────────────────────────────

  /// 스토리 이미지 업로드
  /// 경로: stories/{userId}/{uuid}.{ext}
  Future<String> uploadStoryImage({
    required String userId,
    required Uint8List fileBytes,
    required String fileExtension,
  }) async {
    final fileName = '${_uuid.v4()}.$fileExtension';
    final filePath = '$userId/$fileName';

    await _client.storage.from('stories').uploadBinary(
          filePath,
          fileBytes,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: false,
          ),
        );

    return _client.storage.from('stories').getPublicUrl(filePath);
  }

  /// 스토리 이미지 삭제
  Future<void> deleteStoryImage(String filePath) async {
    await _client.storage.from('stories').remove([filePath]);
  }
}
