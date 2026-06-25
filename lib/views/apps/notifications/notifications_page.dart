import 'package:tibi/controller/apps/notifications/notification_controller.dart';
import 'package:tibi/helpers/theme/app_colors.dart';
import 'package:tibi/models/notifications/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

const _kGreen     = Color(0xFF188329);
const _kGreenDark = Color(0xFF0F5C1C);

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final NotificationController _ctrl;
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _ctrl = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController());

    // Charge toujours les données à l'ouverture de la page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.loadNotifications();
    });

    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
              _scrollCtrl.position.maxScrollExtent - 100 &&
          _ctrl.hasMore.value &&
          !_ctrl.isLoadingMore.value) {
        _ctrl.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildBody(context)),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 14, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kGreen, _kGreenDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: Get.back,
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25), width: 1),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 17),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (_ctrl.unreadCount.value > 0)
                      Text(
                        '${_ctrl.unreadCount.value} non lue${_ctrl.unreadCount.value > 1 ? 's' : ''}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.80),
                          fontSize: 13,
                        ),
                      ),
                  ],
                )),
          ),
          Obx(() => _ctrl.notifications.any((n) => !n.isRead)
              ? TextButton(
                  onPressed: _ctrl.markAllRead,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                  ),
                  child: const Text(
                    'Tout lire',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────

  Widget _buildBody(BuildContext context) {
    return Obx(() {
      if (_ctrl.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: _kGreen, strokeWidth: 2.5),
        );
      }

      if (_ctrl.notifications.isEmpty) return _buildEmpty(context);

      return RefreshIndicator(
        color: _kGreen,
        onRefresh: _ctrl.refresh,
        child: ListView.builder(
          controller: _scrollCtrl,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: _ctrl.notifications.length + 1,
          itemBuilder: (_, i) {
            if (i == _ctrl.notifications.length) {
              return Obx(() => _ctrl.isLoadingMore.value
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: _kGreen),
                        ),
                      ),
                    )
                  : const SizedBox.shrink());
            }
            return _buildCard(context, _ctrl.notifications[i]);
          },
        ),
      );
    });
  }

  // ── Card ───────────────────────────────────────────────────────────────────

  Widget _buildCard(BuildContext context, NotificationModel notif) {
    final isUnread = !notif.isRead;
    final icon = _iconFor(notif.type);
    final color = _colorFor(notif.type);

    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: Colors.white, size: 24),
      ),
      onDismissed: (_) => _ctrl.delete(notif.id),
      child: GestureDetector(
        onTap: () => _ctrl.markOneRead(notif.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isUnread
                ? _kGreen.withValues(alpha: 0.05)
                : AppColors.card(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isUnread
                  ? _kGreen.withValues(alpha: 0.20)
                  : AppColors.border(context),
              width: isUnread ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isUnread
                    ? _kGreen.withValues(alpha: 0.08)
                    : AppColors.shadow(context),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isUnread
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8, height: 8,
                            decoration: const BoxDecoration(
                              color: _kGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary(context),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(notif.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Empty ──────────────────────────────────────────────────────────────────

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _kGreen.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_none_rounded,
                  color: _kGreen, size: 48),
            ),
            const SizedBox(height: 20),
            Text(
              'Aucune notification',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tu seras notifié ici dès qu\'il y a de l\'activité.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary(context),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  IconData _iconFor(String type) {
    switch (type.toLowerCase()) {
      case 'success': return Icons.check_circle_outline_rounded;
      case 'warning': return Icons.warning_amber_rounded;
      case 'error':   return Icons.error_outline_rounded;
      case 'lesson':  return Icons.menu_book_rounded;
      case 'badge':   return Icons.emoji_events_rounded;
      case 'message': return Icons.chat_bubble_outline_rounded;
      default:        return Icons.notifications_outlined;
    }
  }

  Color _colorFor(String type) {
    switch (type.toLowerCase()) {
      case 'success': return _kGreen;
      case 'warning': return const Color(0xFFF59E0B);
      case 'error':   return const Color(0xFFEF4444);
      case 'lesson':  return const Color(0xFF0EA5E9);
      case 'badge':   return const Color(0xFFF27F22);
      case 'message': return const Color(0xFF7C3AED);
      default:        return _kGreen;
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} jours';
    return DateFormat('d MMM yyyy', 'fr_FR').format(dt);
  }
}
