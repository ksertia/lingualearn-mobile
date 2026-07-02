import 'package:dio/dio.dart';
import 'package:tibi/controller/apps/session_controller.dart';
import 'package:tibi/models/notifications/notification_model.dart';
import 'package:get/get.dart';

class NotificationService {
  static final _session = Get.find<SessionController>();

  // ── GET /notifications/user/{userId}?page=&limit= ─────────────────────────

  static Future<({List<NotificationModel> items, int total, int unreadCount, bool hasMore})>
      fetchNotifications({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _session.dio.get(
        '/notifications/user/$userId',
        queryParameters: {'page': page, 'limit': limit},
      );
      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map;
        final rawItems = data['items'] ?? data['data'] ?? data['notifications'] ?? [];
        final items = rawItems is List
            ? rawItems
                .map((e) => NotificationModel.fromJson(
                    e is Map ? Map<String, dynamic>.from(e) : {}))
                .toList()
            : <NotificationModel>[];
        final total = data['total'] is int ? data['total'] as int : 0;
        final unread = data['unreadCount'] is int ? data['unreadCount'] as int : 0;
        return (items: items, total: total, unreadCount: unread, hasMore: items.length >= limit);
      }
      return (items: <NotificationModel>[], total: 0, unreadCount: 0, hasMore: false);
    } on DioException catch (e) {
      print('NotificationService.fetchNotifications: ${e.message}');
      return (items: <NotificationModel>[], total: 0, unreadCount: 0, hasMore: false);
    }
  }

  // ── PUT /notifications/user/{userId}/read-all ─────────────────────────────

  static Future<bool> markAllRead({required String userId}) async {
    try {
      final response = await _session.dio.put('/notifications/user/$userId/read-all');
      return response.statusCode == 200;
    } catch (e) {
      print('NotificationService.markAllRead: $e');
      return false;
    }
  }

  // ── PUT /notifications/{id}/read ──────────────────────────────────────────

  static Future<bool> markOneRead({required String id}) async {
    try {
      final response = await _session.dio.put('/notifications/$id/read');
      return response.statusCode == 200;
    } catch (e) {
      print('NotificationService.markOneRead: $e');
      return false;
    }
  }

  // ── DELETE /notifications/{id} ────────────────────────────────────────────

  static Future<bool> deleteNotification({required String id}) async {
    try {
      final response = await _session.dio.delete('/notifications/$id');
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('NotificationService.delete: $e');
      return false;
    }
  }

  // ── DELETE /notifications/user/{userId} ───────────────────────────────────

  static Future<bool> deleteAll({required String userId}) async {
    try {
      final response =
          await _session.dio.delete('/notifications/user/$userId');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('NotificationService.deleteAll: $e');
      return false;
    }
  }
}
