import 'package:tibi/controller/apps/session_controller.dart';
import 'package:tibi/helpers/services/notifications/notification_service.dart';
import 'package:tibi/models/notifications/notification_model.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  final _session = Get.find<SessionController>();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount   = 0.obs;
  final RxBool isLoading    = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore      = false.obs;

  static const int _limit = 20;
  int _currentPage = 1;

  String get _userId =>
      _session.userId.value.isNotEmpty ? _session.userId.value : _session.user?.id ?? '';

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  // ── Chargement initial ────────────────────────────────────────────────────

  Future<void> loadNotifications() async {
    if (_userId.isEmpty) return;
    _currentPage = 1;
    isLoading(true);
    try {
      final result = await NotificationService.fetchNotifications(
        userId: _userId,
        page: 1,
        limit: _limit,
      );
      notifications.assignAll(result.items);
      unreadCount.value = result.unreadCount;
      hasMore.value = result.hasMore;
    } finally {
      isLoading(false);
    }
  }

  // ── Pagination ────────────────────────────────────────────────────────────

  Future<void> loadMore() async {
    if (!hasMore.value || isLoadingMore.value || _userId.isEmpty) return;
    _currentPage++;
    isLoadingMore(true);
    try {
      final result = await NotificationService.fetchNotifications(
        userId: _userId,
        page: _currentPage,
        limit: _limit,
      );
      notifications.addAll(result.items);
      hasMore.value = result.hasMore;
    } finally {
      isLoadingMore(false);
    }
  }

  // ── Marquer une notification comme lue ────────────────────────────────────

  Future<void> markOneRead(String id) async {
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx == -1 || notifications[idx].isRead) return;

    notifications[idx] = notifications[idx].copyWith(isRead: true);
    if (unreadCount.value > 0) unreadCount.value--;

    await NotificationService.markOneRead(id: id);
  }

  // ── Marquer tout comme lu ─────────────────────────────────────────────────

  Future<void> markAllRead() async {
    if (_userId.isEmpty) return;
    final ok = await NotificationService.markAllRead(userId: _userId);
    if (ok) {
      notifications.assignAll(
          notifications.map((n) => n.copyWith(isRead: true)).toList());
      unreadCount.value = 0;
    }
  }

  // ── Supprimer une notification ────────────────────────────────────────────

  Future<void> delete(String id) async {
    final notif = notifications.firstWhereOrNull((n) => n.id == id);
    if (notif == null) return;

    notifications.removeWhere((n) => n.id == id);
    if (!notif.isRead && unreadCount.value > 0) unreadCount.value--;

    final ok = await NotificationService.deleteNotification(id: id);
    if (!ok) {
      // Rollback si echec
      notifications.insert(0, notif);
      if (!notif.isRead) unreadCount.value++;
    }
  }

  // ── Supprimer toutes les notifications ───────────────────────────────────

  Future<bool> deleteAll() async {
    if (_userId.isEmpty) return false;
    final snapshot = List<NotificationModel>.from(notifications);
    final prevUnread = unreadCount.value;

    notifications.clear();
    unreadCount.value = 0;
    hasMore.value = false;

    final ok = await NotificationService.deleteAll(userId: _userId);
    if (!ok) {
      notifications.assignAll(snapshot);
      unreadCount.value = prevUnread;
    }
    return ok;
  }

  // ── Refresh ───────────────────────────────────────────────────────────────

  @override
  Future<void> refresh() => loadNotifications();
}
