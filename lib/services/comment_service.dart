import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/comment_model.dart';
import 'supabase_service.dart';

class CommentService {
  final SupabaseClient _client = SupabaseService.client;

  // ──────────────────────────────────────────
  // 댓글 조회
  // ──────────────────────────────────────────

  /// 특정 게시물의 댓글 목록 (최신순)
  Future<List<CommentModel>> getComments({
    required String postId,
    int limit = 50,
    int offset = 0,
  }) async {
    final data = await _client
        .from('comments')
        .select('*, profiles(*)')
        .eq('post_id', postId)
        .order('created_at', ascending: true)
        .range(offset, offset + limit - 1);

    return (data as List).map((json) => CommentModel.fromJson(json)).toList();
  }

  /// 특정 게시물의 댓글 수 조회
  Future<int> getCommentsCount(String postId) async {
    final data = await _client
        .from('comments')
        .select('id')
        .eq('post_id', postId);
    return (data as List).length;
  }

  // ──────────────────────────────────────────
  // 댓글 CRUD
  // ──────────────────────────────────────────

  /// 댓글 생성
  Future<CommentModel> createComment({
    required String postId,
    required String userId,
    required String content,
  }) async {
    final data = await _client
        .from('comments')
        .insert({
          'post_id': postId,
          'user_id': userId,
          'content': content,
        })
        .select('*, profiles(*)')
        .single();
    return CommentModel.fromJson(data);
  }

  /// 댓글 삭제
  Future<void> deleteComment(String commentId) async {
    await _client.from('comments').delete().eq('id', commentId);
  }

  // ──────────────────────────────────────────
  // 실시간 구독
  // ──────────────────────────────────────────

  /// 특정 게시물의 댓글 실시간 스트림
  Stream<List<Map<String, dynamic>>> watchComments(String postId) {
    return _client
        .from('comments')
        .stream(primaryKey: ['id'])
        .eq('post_id', postId)
        .order('created_at', ascending: true);
  }
}
