import 'package:tibi/controller/apps/support/support_chat_controller.dart';
import 'package:tibi/helpers/theme/app_colors.dart';
import 'package:tibi/models/support/support_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../helpers/utils/ui_mixins.dart';

const Color _kOrange     = Color(0xFFF27F22);


// Couleur de la bulle reçue (bulle envoyée = AppColors.cardAlt, adaptative)
const Color _csBubbleOther    = Color(0xFF0084FF);

class ContactSupportPage extends StatefulWidget {
  const ContactSupportPage({super.key});

  @override
  State<ContactSupportPage> createState() => _ContactSupportPageState();
}

class _ContactSupportPageState extends State<ContactSupportPage>
    with SingleTickerProviderStateMixin, UIMixin {
  late final SupportChatController _ctrl;
  final _msgCtrl   = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(SupportChatController());
    ever(_ctrl.messages, (_) => _scrollToBottom());
    // Charger les messages plus anciens quand on scrolle vers le haut
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels <= 60 &&
          _ctrl.hasMoreMessages.value &&
          !_ctrl.isLoadingMore.value) {
        _ctrl.loadMoreMessages();
      }
    });
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildBody()),
          _buildInputBar(),
        ],
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_kOrange, _kOrange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: GestureDetector(
          onTap: Get.back,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 17),
          ),
        ),
      ),
      titleSpacing: 0,
      title: Obx(() {
        final name = _ctrl.supportAgentName;
        return Row(
          children: [
            _buildAgentAvatar(name, size: 34),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4ADE80),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'En ligne',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.80),
                            fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }),
      actions: [
        IconButton(
          onPressed: _ctrl.refresh,
          icon: const Icon(Icons.refresh_rounded,
              color: Colors.white, size: 20),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    return Obx(() {
      if (_ctrl.isLoadingConversations.value) return _buildLoading();

      if (_ctrl.messages.isEmpty && !_ctrl.isLoadingMessages.value) {
        return _buildEmptyState();
      }

      if (_ctrl.isLoadingMessages.value) return _buildLoading();

      return _buildMessageList();
    });
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: _kOrange, strokeWidth: 2.5),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_kOrange, _kOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _kOrange.withValues(alpha: 0.30),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.support_agent_rounded,
                  color: Colors.white, size: 46),
            ),
            const SizedBox(height: 22),
            Text(
              'Bienvenue au support',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary(context)),
            ),
            const SizedBox(height: 10),
            Text(
              'Notre équipe est disponible pour vous aider.\nÉcrivez votre message ci-dessous pour démarrer.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary(context),
                  height: 1.6),
            ),
            const SizedBox(height: 28),
            _buildInfoChip(
              Icons.schedule_rounded,
              'Répond généralement en moins de 24h',
            ),
            const SizedBox(height: 10),
            _buildInfoChip(
              Icons.lock_outline_rounded,
              'Conversation sécurisée et confidentielle',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _kOrange, size: 15),
          const SizedBox(width: 7),
          Text(label,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context))),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    final msgs = _ctrl.messages;
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
      itemCount: msgs.length + 1, // +1 pour l'indicateur de chargement en tête

      itemBuilder: (_, i) {
        // Index 0 = indicateur "charger plus"
        if (i == 0) {
          return Obx(() => _ctrl.isLoadingMore.value
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: _kOrange),
                    ),
                  ),
                )
              : const SizedBox.shrink());
        }
        final msg = msgs[i - 1];
        final isMe = msg.isFromUser(_ctrl.currentUserId);
        final realIndex = i - 1;
        final showDate = realIndex == 0 ||
            !_isSameDay(msgs[realIndex - 1].createdAt, msg.createdAt);
        final showAvatar = !isMe &&
            (realIndex == msgs.length - 1 ||
                msgs[realIndex + 1].isFromUser(_ctrl.currentUserId));

        return Column(
          children: [
            if (showDate) _buildDateSeparator(msg.createdAt),
            _buildBubble(msg, isMe, showAvatar),
          ],
        );
      },
    );
  }

  Widget _buildDateSeparator(DateTime dt) {
    final now = DateTime.now();
    final label = _isSameDay(dt, now)
        ? "Aujourd'hui"
        : _isSameDay(dt, now.subtract(const Duration(days: 1)))
            ? 'Hier'
            : DateFormat('d MMMM yyyy', 'fr_FR').format(dt);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(child: Divider(color: AppColors.divider(context))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow(context),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                label,
                style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary(context),
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Expanded(child: Divider(color: AppColors.divider(context))),
        ],
      ),
    );
  }

  Widget _buildBubble(
      SupportMessageModel msg, bool isMe, bool showAvatar) {
    final bubbleColor = isMe ? AppColors.cardAlt(context) : _csBubbleOther;
    final textColor   = isMe ? AppColors.textPrimary(context) : Colors.white;

    return Padding(
      padding: EdgeInsets.only(
        top: 3,
        bottom: 3,
        left: isMe ? 60 : 0,
        right: isMe ? 0 : 60,
      ),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            showAvatar
                ? _buildAgentAvatar(_ctrl.supportAgentName, size: 28)
                : const SizedBox(width: 28),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onLongPress: () => _confirmDelete(msg, isMe),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isMe ? 18 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      msg.content,
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(msg.createdAt.toLocal()),
                      style: TextStyle(
                          fontSize: 10.5, color: AppColors.textSecondary(context)),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        msg.read
                            ? Icons.done_all_rounded
                            : Icons.done_rounded,
                        size: 13,
                        color: msg.read ? _kOrange : AppColors.textSecondary(context),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          if (isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }

  void _confirmDelete(SupportMessageModel msg, bool isMe) {
    // Seul l'expéditeur peut supprimer son message
    if (!isMe) return;

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Supprimer ce message ?',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        content: Text(
          '"${msg.content.length > 60 ? '${msg.content.substring(0, 60)}…' : msg.content}"',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary(context)),
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              'Annuler',
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _ctrl.deleteMessage(msg.id);
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(
                  color: Color(0xFFEF4444), fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // ── Input bar ─────────────────────────────────────────────────────────────

  Widget _buildInputBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card(context),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
          14, 10, 14, MediaQuery.of(context).viewInsets.bottom + 14),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: AppColors.cardAlt(context),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _msgCtrl,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(
                      fontSize: 14, color: AppColors.textPrimary(context)),
                  decoration: InputDecoration(
                    hintText: 'Écrire un message...',
                    hintStyle: TextStyle(
                        fontSize: 14, color: AppColors.textHint(context)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Obx(() => GestureDetector(
                  onTap: _ctrl.isSending.value
                      ? null
                      : () {
                          final text = _msgCtrl.text;
                          if (text.trim().isEmpty) return;
                          _msgCtrl.clear();
                          _ctrl.sendMessage(text);
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: _ctrl.isSending.value
                          ? null
                          : const LinearGradient(
                              colors: [_kOrange, _kOrange],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      color: _ctrl.isSending.value
                          ? AppColors.cardAlt(context)
                          : null,
                      shape: BoxShape.circle,
                      boxShadow: _ctrl.isSending.value
                          ? []
                          : [
                              BoxShadow(
                                color: _kOrange.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Center(
                      child: _ctrl.isSending.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.0, color: _kOrange),
                            )
                          : const Icon(Icons.send_rounded,
                              color: Colors.white, size: 19),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildAgentAvatar(String name, {double size = 36}) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kOrange, _kOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: size * 0.38,
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
