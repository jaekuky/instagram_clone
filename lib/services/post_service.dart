import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post_model.dart';
import 'supabase_service.dart';

class PostService {
  final SupabaseClient _client = SupabaseService.client;

  // ──────────────────────────────────────────
  // 피드 조회
  // ──────────────────────────────────────────

  /// 피드 게시물 목록 (최신순, 페이지네이션)
  /// profiles 정보 JOIN 포함
  Future<List<PostModel>> getFeedPosts({
    int limit = 20,
    int offset = 0,
  }) async {
    final data = await _client
        .from('posts')
        .select('*, profiles(*)')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (data as List).map((json) => PostModel.fromJson(json)).toList();
  }

  /// 팔로잉 유저들의 게시물만 조회
  Future<List<PostModel>> getFollowingFeedPosts({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    // 1) 내가 팔로우하는 유저 ID 목록
    final followsData = await _client
        .from('follows')
        .select('following_id')
        .eq('follower_id', userId);

    final followingIds = (followsData as List)
        .map((f) => f['following_id'] as String)
        .toList();

    // 본인 게시물도 포함
    followingIds.add(userId);

    // 2) 해당 유저들의 게시물 조회
    final data = await _client
        .from('posts')
        .select('*, profiles(*)')
        .inFilter('user_id', followingIds)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (data as List).map((json) => PostModel.fromJson(json)).toList();
  }

  /// 특정 사용자의 게시물 목록
  Future<List<PostModel>> getUserPosts({
    required String userId,
    int limit = 30,
    int offset = 0,
  }) async {
    final data = await _client
        .from('posts')
        .select('*, profiles(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (data as List).map((json) => PostModel.fromJson(json)).toList();
  }

  /// 단일 게시물 조회
  Future<PostModel?> getPostById(String postId) async {
    try {
      final data = await _client
          .from('posts')
          .select('*, profiles(*)')
          .eq('id', postId)
          .single();
      return PostModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  // ──────────────────────────────────────────
  // 게시물 CRUD
  // ──────────────────────────────────────────

  /// 게시물 생성
  Future<PostModel> createPost({
    required String userId,
    required String imageUrl,
    String? caption,
    String location = '',
  }) async {
    final data = await _client
        .from('posts')
        .insert({
          'user_id': userId,
          'image_url': imageUrl,
          'caption': caption,
          'location': location,
        })
        .select('*, profiles(*)')
        .single();
    return PostModel.fromJson(data);
  }

  /// 게시물 수정
  Future<PostModel> updatePost({
    required String postId,
    String? caption,
    String? location,
  }) async {
    final updates = <String, dynamic>{};
    if (caption != null) updates['caption'] = caption;
    if (location != null) updates['location'] = location;

    final data = await _client
        .from('posts')
        .update(updates)
        .eq('id', postId)
        .select('*, profiles(*)')
        .single();
    return PostModel.fromJson(data);
  }

  /// 게시물 삭제
  Future<void> deletePost(String postId) async {
    await _client.from('posts').delete().eq('id', postId);
  }

  // ──────────────────────────────────────────
  // 탐색 (Explore)
  // ──────────────────────────────────────────

  /// 인기 게시물 (좋아요 순)
  Future<List<PostModel>> getExplorePosts({
    int limit = 30,
    int offset = 0,
  }) async {
    final data = await _client
        .from('posts')
        .select('*, profiles(*)')
        .order('likes_count', ascending: false)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (data as List).map((json) => PostModel.fromJson(json)).toList();
  }
}
