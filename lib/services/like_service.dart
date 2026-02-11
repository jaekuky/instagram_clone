import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/like_model.dart';
import 'supabase_service.dart';

class LikeService {
  final SupabaseClient _client = SupabaseService.client;

  // ──────────────────────────────────────────
  // 좋아요 토글
  // ──────────────────────────────────────────

  /// 좋아요 토글 (좋아요 → 취소, 취소 → 좋아요)
  /// 반환: true = 좋아요됨, false = 취소됨
  Future<bool> toggleLike({
    required String postId,
    required String userId,
  }) async {
    final existing = await _client
        .from('likes')
        .select('id')
        .eq('post_id', postId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) {
      // 이미 좋아요 → 취소
      await _client.from('likes').delete().eq('id', existing['id']);
      return false;
    } else {
      // 좋아요 추가
      await _client.from('likes').insert({
        'post_id': postId,
        'user_id': userId,
      });
      return true;
    }
  }

  // ──────────────────────────────────────────
  // 좋아요 상태 확인
  // ──────────────────────────────────────────

  /// 특정 게시물에 좋아요를 눌렀는지 확인
  Future<bool> isLiked({
    required String postId,
    required String userId,
  }) async {
    final data = await _client
        .from('likes')
        .select('id')
        .eq('post_id', postId)
        .eq('user_id', userId)
        .maybeSingle();
    return data != null;
  }

  /// 여러 게시물에 대한 좋아요 상태 한꺼번에 확인
  Future<Set<String>> getLikedPostIds({
    required List<String> postIds,
    required String userId,
  }) async {
    if (postIds.isEmpty) return {};

    final data = await _client
        .from('likes')
        .select('post_id')
        .eq('user_id', userId)
        .inFilter('post_id', postIds);

    return (data as List).map((e) => e['post_id'] as String).toSet();
  }

  // ──────────────────────────────────────────
  // 좋아요 목록
  // ──────────────────────────────────────────

  /// 특정 게시물의 좋아요 목록
  Future<List<LikeModel>> getPostLikes({
    required String postId,
    int limit = 50,
    int offset = 0,
  }) async {
    final data = await _client
        .from('likes')
        .select('*')
        .eq('post_id', postId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (data as List).map((json) => LikeModel.fromJson(json)).toList();
  }
}
