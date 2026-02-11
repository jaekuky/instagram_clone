import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/story_model.dart';
import 'supabase_service.dart';

class StoryService {
  final SupabaseClient _client = SupabaseService.client;

  // ──────────────────────────────────────────
  // 스토리 조회
  // ──────────────────────────────────────────

  /// 활성 스토리 목록 (만료되지 않은 것만)
  /// 팔로잉 유저들의 스토리만 보여줌
  Future<List<StoryModel>> getActiveStories({
    required String userId,
  }) async {
    // 1) 팔로잉 ID 목록
    final followsData = await _client
        .from('follows')
        .select('following_id')
        .eq('follower_id', userId);

    final followingIds = (followsData as List)
        .map((f) => f['following_id'] as String)
        .toList();

    // 본인 스토리도 포함
    followingIds.add(userId);

    // 2) 만료되지 않은 스토리 조회
    final data = await _client
        .from('stories')
        .select('*, profiles(*)')
        .inFilter('user_id', followingIds)
        .gt('expires_at', DateTime.now().toIso8601String())
        .order('created_at', ascending: false);

    return (data as List).map((json) => StoryModel.fromJson(json)).toList();
  }

  /// 특정 사용자의 활성 스토리
  Future<List<StoryModel>> getUserStories(String userId) async {
    final data = await _client
        .from('stories')
        .select('*, profiles(*)')
        .eq('user_id', userId)
        .gt('expires_at', DateTime.now().toIso8601String())
        .order('created_at', ascending: true);

    return (data as List).map((json) => StoryModel.fromJson(json)).toList();
  }

  // ──────────────────────────────────────────
  // 스토리 CRUD
  // ──────────────────────────────────────────

  /// 스토리 생성
  Future<StoryModel> createStory({
    required String userId,
    required String imageUrl,
  }) async {
    final data = await _client
        .from('stories')
        .insert({
          'user_id': userId,
          'image_url': imageUrl,
        })
        .select('*, profiles(*)')
        .single();
    return StoryModel.fromJson(data);
  }

  /// 스토리 삭제
  Future<void> deleteStory(String storyId) async {
    await _client.from('stories').delete().eq('id', storyId);
  }
}
