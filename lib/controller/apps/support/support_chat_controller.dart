import 'dart:async';
import 'package:tibi/controller/apps/session_controller.dart';
import 'package:tibi/helpers/services/support/support_chat_service.dart';
import 'package:tibi/models/support/support_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SupportChatController extends GetxController {
  final _session = Get.find<SessionController>();

  final RxList<SupportConversationModel> conversations =
      <SupportConversationModel>[].obs;
  final RxList<SupportMessageModel> messages = <SupportMessageModel>[].obs;
  final Rxn<SupportConversationModel> activeConversation = Rxn();

  final RxBool isLoadingConversations = false.obs;
  final RxBool isLoadingMessages      = false.obs;
  final RxBool isLoadingMore          = false.obs;
  final RxBool isSending              = false.obs;
  final RxBool hasMoreMessages        = false.obs;
  final RxInt  unreadCount            = 0.obs;

  static const int _pageLimit    = 30;
  static const int _pollSeconds  = 5;
  int _currentPage = 1;

  Timer? _pollTimer;
  bool   _isPolling = false;

  // ── Identité ──────────────────────────────────────────────────────────────

  String get currentUserId => _session.userId.value.isNotEmpty
      ? _session.userId.value
      : _session.user?.id ?? '';

  bool get _isLearner {
    final type = _session.user?.accountType ?? '';
    return type != 'admin' && type != 'platform_manager';
  }

  String get supportAgentName {
    final conv = activeConversation.value ?? conversations.firstOrNull;
    return conv?.otherParticipantName(currentUserId) ?? 'Support TiBi';
  }

  String get _otherUserId {
    final conv = activeConversation.value ?? conversations.firstOrNull;
    return conv?.otherParticipantId(currentUserId) ?? '';
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    loadConversations();
    _loadUnreadCount();
    _startPolling();
  }

  @override
  void onClose() {
    _stopPolling();
    super.onClose();
  }

  // ── Polling (remplace Socket.IO) ──────────────────────────────────────────

  void _startPolling() {
    _pollTimer = Timer.periodic(
      const Duration(seconds: _pollSeconds),
      (_) => _pollNewMessages(),
    );
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _pollNewMessages() async {
    if (_isPolling) return;
    final otherUser = _otherUserId;
    if (otherUser.isEmpty) {
      // Pas encore de conversation : vérifier si une est disponible
      await _loadUnreadCount();
      return;
    }

    _isPolling = true;
    try {
      final result = await SupportChatService.fetchConversationPaginated(
        userA: currentUserId,
        userB: otherUser,
        page: 1,
        limit: _pageLimit,
      );

      final existingIds = messages.map((m) => m.id).toSet();
      bool hasNew = false;
      for (final msg in result.items) {
        if (!existingIds.contains(msg.id)) {
          messages.add(msg);
          hasNew = true;
        }
      }
      if (hasNew) {
        _sortMessages();
        // Marquer comme lu les messages de l'autre
        SupportChatService.markMessagesRead(senderId: otherUser);
        await _loadUnreadCount();
      }
    } catch (_) {
      // Silencieux — pas d'erreur visible pour le polling
    } finally {
      _isPolling = false;
    }
  }

  // ── Charger les conversations ──────────────────────────────────────────────

  Future<void> loadConversations() async {
    isLoadingConversations(true);
    try {
      final result = await SupportChatService.fetchConversations();
      conversations.assignAll(result);
      if (result.isNotEmpty && activeConversation.value == null) {
        await openConversation(result.first);
      }
    } finally {
      isLoadingConversations(false);
    }
  }

  // ── Ouvrir une conversation (page 1) ──────────────────────────────────────

  Future<void> openConversation(SupportConversationModel conv) async {
    activeConversation.value = conv;
    _currentPage = 1;
    messages.clear();
    isLoadingMessages(true);
    try {
      final otherUser = conv.otherParticipantId(currentUserId);

      List<SupportMessageModel> fetched;
      bool more = false;

      if (conv.messages.isNotEmpty) {
        fetched = conv.messages;
        more = conv.messages.length >= _pageLimit;
      } else if (otherUser.isNotEmpty) {
        final result = await SupportChatService.fetchConversationPaginated(
          userA: currentUserId,
          userB: otherUser,
          page: 1,
          limit: _pageLimit,
        );
        fetched = result.items;
        more = result.hasMore;
      } else {
        fetched = [];
      }

      final pending = messages.where((m) => m.id.startsWith('tmp_')).toList();
      final fetchedIds = fetched.map((m) => m.id).toSet();
      messages.assignAll(fetched);
      for (final p in pending) {
        if (!fetchedIds.contains(p.id)) messages.add(p);
      }
      hasMoreMessages(more);
      _sortMessages();

      if (conv.unreadCount > 0 && otherUser.isNotEmpty) {
        await SupportChatService.markMessagesRead(senderId: otherUser);
        _loadUnreadCount();
      }
    } finally {
      isLoadingMessages(false);
    }
  }

  // ── Charger les messages plus anciens (pagination) ────────────────────────

  Future<void> loadMoreMessages() async {
    if (!hasMoreMessages.value || isLoadingMore.value) return;
    final otherUser = _otherUserId;
    if (otherUser.isEmpty) return;

    _currentPage++;
    isLoadingMore(true);
    try {
      final result = await SupportChatService.fetchConversationPaginated(
        userA: currentUserId,
        userB: otherUser,
        page: _currentPage,
        limit: _pageLimit,
      );
      messages.insertAll(0, result.items);
      hasMoreMessages(result.hasMore);
      _sortMessages();
    } finally {
      isLoadingMore(false);
    }
  }

  // ── Envoyer un message ────────────────────────────────────────────────────

  Future<void> sendMessage(String content) async {
    final text = content.trim();
    if (text.isEmpty || isSending.value) return;

    isSending(true);

    final optimistic = SupportMessageModel(
      id: 'tmp_${DateTime.now().millisecondsSinceEpoch}',
      senderId: currentUserId,
      recipientId: _otherUserId.isNotEmpty ? _otherUserId : 'support',
      content: text,
      type: 'text',
      read: false,
      createdAt: DateTime.now(),
    );
    messages.add(optimistic);

    try {
      SupportMessageModel? sent;

      if (_isLearner) {
        sent = await SupportChatService.sendSupportMessage(content: text);
      } else {
        final recipientId = _otherUserId.isNotEmpty ? _otherUserId : '';
        if (recipientId.isEmpty) {
          messages.removeWhere((m) => m.id == optimistic.id);
          isSending(false);
          return;
        }
        sent = await SupportChatService.sendMessage(
          senderId: currentUserId,
          recipientId: recipientId,
          content: text,
          type: 'text',
          metadata: {},
        );
      }

      if (sent != null) {
        final idx = messages.indexWhere((m) => m.id == optimistic.id);
        if (idx != -1) messages[idx] = sent;
        if (_isLearner &&
            activeConversation.value == null &&
            sent.recipientId.isNotEmpty) {
          await loadConversations();
        }
      }
    } catch (_) {
      messages.removeWhere((m) => m.id == optimistic.id);
      Get.snackbar(
        'Erreur',
        "Impossible d'envoyer le message. Réessayez.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 16,
      );
    } finally {
      isSending(false);
    }
  }

  // ── Supprimer un message ──────────────────────────────────────────────────

  Future<void> deleteMessage(String messageId) async {
    final backup = List<SupportMessageModel>.from(messages);
    messages.removeWhere((m) => m.id == messageId);

    final ok = await SupportChatService.deleteMessage(messageId);
    if (!ok) {
      messages.assignAll(backup);
      Get.snackbar(
        'Erreur',
        'Impossible de supprimer ce message.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 16,
      );
    }
  }

  // ── Unread count ──────────────────────────────────────────────────────────

  Future<void> _loadUnreadCount() async {
    final count = await SupportChatService.fetchUnreadCount();
    unreadCount.value = count;
  }

  // ── Refresh manuel ────────────────────────────────────────────────────────

  @override
  Future<void> refresh() async {
    final result = await SupportChatService.fetchConversations();
    conversations.assignAll(result);

    final conv = activeConversation.value;
    if (conv != null) {
      final otherUser = conv.otherParticipantId(currentUserId);
      if (otherUser.isNotEmpty) {
        final fresh = await SupportChatService.fetchConversationPaginated(
          userA: currentUserId,
          userB: otherUser,
          page: 1,
          limit: _pageLimit,
        );
        final existingIds = messages.map((m) => m.id).toSet();
        for (final msg in fresh.items) {
          if (!existingIds.contains(msg.id)) messages.add(msg);
        }
        _sortMessages();
      }
    }
    await _loadUnreadCount();
  }

  void _sortMessages() {
    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }
}
