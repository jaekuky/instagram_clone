import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/saved_post_model.dart';
import 'supabase_service.dart';

class SavedPostService {
  final SupabaseClient _client = SupabaseService.client;

  // ──────────────────────────────────────────
  // 저장 토글
  // ──────────────────────────────────────────

  /// 게시물 저장 토글
  /// 반환: true = 저장됨, false = 저장 취소됨
  Future<bool> toggleSave({
    required String postId,
    required String userId,
  }) async {
    final existing = await _client
        .from('saved_posts')
        .select('id')
        .eq('post_id', postId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) {
      await _client.from('saved_posts').delete().eq('id', existing['id']);
      return false;
    } else {
      await _client.from('saved_posts').insert({
        'post_id': postId,
        'user_id': userId,
      });
      return true;
    }
  }

  // ──────────────────────────────────────────
  // 저장 상태 확인
  // ──────────────────────────────────────────

  /// 특정 게시물이 저장되었는지 확인
  Future<bool> isSaved({
    required String postId,
    required String userId,
  }) async {
    final data = await _client
        .from('saved_posts')
        .select('id')
        .eq('post_id', postId)
        .eq('user_id', userId)
        .maybeSingle();
    return data != null;
  }

  /// 여러 게시물에 대한 저장 상태 한꺼번에 확인
  Future<Set<String>> getSavedPostIds({
    required List<String> postIds,
    required String userId,
  }) async {
    if (postIds.isEmpty) return {};

    final data = await _client
        .from('saved_posts')
        .select('post_id')
        .eq('user_id', userId)
        .inFilter('post_id', postIds);

    return (data as List).map((e) => e['post_id'] as String).toSet();
  }

  // ──────────────────────────────────────────
  // 저장 목록
  // ──────────────────────────────────────────

  /// 내 저장 게시물 목록 (게시물 정보 JOIN)
  Future<List<SavedPostModel>> getSavedPosts({
    required String userId,
    int limit = 30,
    int offset = 0,
  }) async {
    final data = await _client
        .from('saved_posts')
        .select('*, posts(*, profiles(*))')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (data as List)
        .map((json) => SavedPostModel.fromJson(json))
        .toList();
  }
}
