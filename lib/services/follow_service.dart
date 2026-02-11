import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/follow_model.dart';
import '../models/user_model.dart';
import 'supabase_service.dart';

class FollowService {
  final SupabaseClient _client = SupabaseService.client;

  // ──────────────────────────────────────────
  // 팔로우 / 언팔로우
  // ──────────────────────────────────────────

  /// 팔로우 토글 (팔로우 → 언팔로우, 언팔로우 → 팔로우)
  /// 반환: true = 팔로우됨, false = 언팔로우됨
  Future<bool> toggleFollow({
    required String followerId,
    required String followingId,
  }) async {
    final existing = await _client
        .from('follows')
        .select('id')
        .eq('follower_id', followerId)
        .eq('following_id', followingId)
        .maybeSingle();

    if (existing != null) {
      // 이미 팔로우 → 언팔로우
      await _client.from('follows').delete().eq('id', existing['id']);
      return false;
    } else {
      // 팔로우
      await _client.from('follows').insert({
        'follower_id': followerId,
        'following_id': followingId,
      });
      return true;
    }
  }

  /// 팔로우
  Future<void> follow({
    required String followerId,
    required String followingId,
  }) async {
    await _client.from('follows').insert({
      'follower_id': followerId,
      'following_id': followingId,
    });
  }

  /// 언팔로우
  Future<void> unfollow({
    required String followerId,
    required String followingId,
  }) async {
    await _client
        .from('follows')
        .delete()
        .eq('follower_id', followerId)
        .eq('following_id', followingId);
  }

  // ──────────────────────────────────────────
  // 팔로우 상태 확인
  // ──────────────────────────────────────────

  /// 팔로우 여부 확인
  Future<bool> isFollowing({
    required String followerId,
    required String followingId,
  }) async {
    final data = await _client
        .from('follows')
        .select('id')
        .eq('follower_id', followerId)
        .eq('following_id', followingId)
        .maybeSingle();
    return data != null;
  }

  // ──────────────────────────────────────────
  // 팔로워 / 팔로잉 목록
  // ──────────────────────────────────────────

  /// 특정 사용자의 팔로워 목록
  Future<List<UserModel>> getFollowers({
    required String userId,
    int limit = 50,
    int offset = 0,
  }) async {
    final data = await _client
        .from('follows')
        .select('follower:follower_id(*)') // profiles 테이블 JOIN
        .eq('following_id', userId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (data as List)
        .where((json) => json['follower'] != null)
        .map((json) =>
            UserModel.fromJson(json['follower'] as Map<String, dynamic>))
        .toList();
  }

  /// 특정 사용자의 팔로잉 목록
  Future<List<UserModel>> getFollowing({
    required String userId,
    int limit = 50,
    int offset = 0,
  }) async {
    final data = await _client
        .from('follows')
        .select('following:following_id(*)') // profiles 테이블 JOIN
        .eq('follower_id', userId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (data as List)
        .where((json) => json['following'] != null)
        .map((json) =>
            UserModel.fromJson(json['following'] as Map<String, dynamic>))
        .toList();
  }
}
