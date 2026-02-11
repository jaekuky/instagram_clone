import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';
import 'supabase_service.dart';

class NotificationService {
  final SupabaseClient _client = SupabaseService.client;

  // ──────────────────────────────────────────
  // 알림 조회
  // ──────────────────────────────────────────

  /// 내 알림 목록 (최신순, 페이지네이션)
  Future<List<NotificationModel>> getNotifications({
    required String userId,
    int limit = 30,
    int offset = 0,
  }) async {
    final data = await _client
        .from('notifications')
        .select('*, actor:actor_id(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (data as List)
        .map((json) => NotificationModel.fromJson(json))
        .toList();
  }

  /// 읽지 않은 알림 수
  Future<int> getUnreadCount(String userId) async {
    final data = await _client
        .from('notifications')
        .select('id')
        .eq('user_id', userId)
        .eq('is_read', false);
    return (data as List).length;
  }

  // ──────────────────────────────────────────
  // 알림 상태 변경
  // ──────────────────────────────────────────

  /// 단일 알림 읽음 처리
  Future<void> markAsRead(String notificationId) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  /// 모든 알림 읽음 처리
  Future<void> markAllAsRead(String userId) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  /// 알림 삭제
  Future<void> deleteNotification(String notificationId) async {
    await _client.from('notifications').delete().eq('id', notificationId);
  }

  // ──────────────────────────────────────────
  // 실시간 구독
  // ──────────────────────────────────────────

  /// 내 알림 실시간 스트림
  Stream<List<Map<String, dynamic>>> watchNotifications(String userId) {
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }
}
