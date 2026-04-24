import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:fasolingo/helpers/services/support/support_chat_service.dart';
import 'package:fasolingo/models/support/support_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SupportChatController extends GetxController {
  final _session = Get.find<SessionController>();

  final RxList<SupportConversationModel> conversations =
      <SupportConversationModel>[].obs;
  final RxList<SupportMessageModel> messages = <SupportMessageModel>[].obs;
  final Rxn<SupportConversationModel> activeConversation = Rxn();

  final RxBool isLoadingConversations = false.obs;
  final RxBool isLoadingMessages = false.obs;
  final RxBool isSending = false.obs;
  final RxInt unreadCount = 0.obs;

  String get currentUserId => _session.userId.value.isNotEmpty
      ? _session.userId.value
      : _session.user?.id ?? '';



  String get supportAgentName {
    final conv = activeConversation.value ?? conversations.firstOrNull;
    return conv?.otherParticipantName(currentUserId) ?? 'Support TIBIS';
  }

  @override
  void onInit() {
    super.onInit();
    loadConversations();
    _loadUnreadCount();
  }

  Future<void> loadConversations() async {
    isLoadingConversations(true);
    try {
      final result = await SupportChatService.fetchConversations();
      conversations.assignAll(result);
      if (result.isNotEmpty) {
        await openConversation(result.first);
      }
    } finally {
      isLoadingConversations(false);
    }
  }

  Future<void> openConversation(SupportConversationModel conv) async {
    activeConversation.value = conv;
    isLoadingMessages(true);
    try {
      // Use embedded messages if available, else fetch separately
      if (conv.messages.isNotEmpty) {
        messages.assignAll(conv.messages);
      } else {
        final result = await SupportChatService.fetchMessages(conv.id);
        messages.assignAll(result);
      }
      _sortMessages();
      if (conv.unreadCount > 0) {
        await SupportChatService.markMessagesRead(conversationId: conv.id);
        _loadUnreadCount();
      }
    } finally {
      isLoadingMessages(false);
    }
  }

  Future<void> sendMessage(String content) async {
    final text = content.trim();
    if (text.isEmpty || isSending.value) return;

    isSending(true);
    final recipientId = "cmmumux670000ok449i15bjd1";

    // Optimistic insert
    final optimistic = SupportMessageModel(
      id: 'tmp_${DateTime.now().millisecondsSinceEpoch}',
      senderId: currentUserId,
      recipientId: recipientId,
      content: text,
      type: 'text',
      read: false,
      createdAt: DateTime.now(),
    );
    messages.add(optimistic);

    try {
      final sent = await SupportChatService.sendMessage(
        senderId: currentUserId,
        recipientId: recipientId,
        content: text,
        type: 'text',
        metadata: {},
      );
      if (sent != null) {
        final idx = messages.indexWhere((m) => m.id == optimistic.id);
        if (idx != -1) messages[idx] = sent;
      }
    } catch (_) {
      messages.removeWhere((m) => m.id == optimistic.id);
      Get.snackbar(
        'Erreur',
        "Impossible d'envoyer le message. Réessayez.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: const Color(0xFFFFFFFF),
        margin: const EdgeInsets.all(16),
        borderRadius: 16,
      );
    } finally {
      isSending(false);
    }
  }

  Future<void> _loadUnreadCount() async {
    final count = await SupportChatService.fetchUnreadCount();
    unreadCount.value = count;
  }

  @override
  Future<void> refresh() async {
    await loadConversations();
    await _loadUnreadCount();
  }

  void _sortMessages() {
    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }
}
