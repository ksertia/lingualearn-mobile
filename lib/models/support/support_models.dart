class SupportMessageModel {
  final String id;
  final String senderId;
  final String recipientId;
  final String content;
  final String type;
  final bool read;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  SupportMessageModel({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.content,
    required this.type,
    required this.read,
    required this.createdAt,
    this.metadata = const {},
  });

  bool isFromUser(String userId) => senderId == userId;

  factory SupportMessageModel.fromJson(Map<String, dynamic> json) {
    return SupportMessageModel(
      id: json['id']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      recipientId: json['recipientId']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      type: json['type']?.toString() ?? 'text',
      read: json['read'] == true || json['isRead'] == true,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
              DateTime.now(),
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : {},
    );
  }
}

class SupportParticipantModel {
  final String userId;
  final String name;
  final String? avatar;

  SupportParticipantModel({
    required this.userId,
    required this.name,
    this.avatar,
  });

  // Gère deux formats :
  //   1. {userId, name, avatar}           (ancien format interne)
  //   2. {id, username, profile:{firstName, lastName, avatarUrl}}  (réponse API réelle)
  factory SupportParticipantModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] is Map
        ? Map<String, dynamic>.from(json['profile'] as Map)
        : <String, dynamic>{};

    final firstName = profile['firstName']?.toString() ?? '';
    final lastName  = profile['lastName']?.toString()  ?? '';
    final fullName  = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');

    return SupportParticipantModel(
      userId: json['id']?.toString() ??
              json['userId']?.toString() ?? '',
      name: fullName.isNotEmpty
          ? fullName
          : json['username']?.toString() ??
            json['name']?.toString() ??
            'Support',
      avatar: profile['avatarUrl']?.toString() ??
              json['avatar']?.toString() ??
              json['profileImage']?.toString(),
    );
  }
}

class SupportConversationModel {
  final String id;
  final List<SupportParticipantModel> participants;
  final SupportMessageModel? lastMessage;
  final int unreadCount;
  final DateTime updatedAt;
  final List<SupportMessageModel> messages;

  SupportConversationModel({
    required this.id,
    required this.participants,
    this.lastMessage,
    required this.unreadCount,
    required this.updatedAt,
    this.messages = const [],
  });

  String otherParticipantId(String myId) {
    final other = participants.where((p) => p.userId != myId).firstOrNull;
    return other?.userId ?? '';
  }

  String otherParticipantName(String myId) {
    final other = participants.where((p) => p.userId != myId).firstOrNull;
    return other?.name ?? 'Support TiBi';
  }

  factory SupportConversationModel.fromJson(Map<String, dynamic> json) {
    // ── Format API réel : {sender: {...}, recipient: {...}, lastMessage, unreadCount}
    // ── Format alternatif : {participants: [...], id, ...}
    List<SupportParticipantModel> participants = [];

    if (json['sender'] != null || json['recipient'] != null) {
      // Format API réel : sender + recipient
      final sender    = json['sender'];
      final recipient = json['recipient'];
      if (sender is Map) {
        participants.add(SupportParticipantModel.fromJson(
            Map<String, dynamic>.from(sender)));
      }
      if (recipient is Map) {
        participants.add(SupportParticipantModel.fromJson(
            Map<String, dynamic>.from(recipient)));
      }
    } else if (json['participants'] is List) {
      participants = (json['participants'] as List)
          .map((p) => SupportParticipantModel.fromJson(
              p is Map ? Map<String, dynamic>.from(p) : {}))
          .toList();
    }

    // Construire un ID stable à partir des participants si absent
    final rawId = json['id']?.toString();
    String id;
    if (rawId != null && rawId.isNotEmpty) {
      id = rawId;
    } else {
      final sorted = participants.map((p) => p.userId).toList()..sort();
      id = sorted.join('_');
    }

    final rawLast = json['lastMessage'];
    final SupportMessageModel? lastMessage = rawLast is Map
        ? SupportMessageModel.fromJson(Map<String, dynamic>.from(rawLast))
        : null;

    // updatedAt : on essaie plusieurs clés
    final rawDate = json['updatedAt'] ?? json['createdAt'] ??
        lastMessage?.createdAt.toIso8601String();
    final updatedAt = DateTime.tryParse(rawDate?.toString() ?? '') ?? DateTime.now();

    final rawMessages = json['messages'];
    final List<SupportMessageModel> messages = rawMessages is List
        ? rawMessages
            .map((m) => SupportMessageModel.fromJson(
                m is Map ? Map<String, dynamic>.from(m) : {}))
            .toList()
        : [];

    return SupportConversationModel(
      id: id,
      participants: participants,
      lastMessage: lastMessage,
      unreadCount: json['unreadCount'] is int
          ? json['unreadCount'] as int
          : int.tryParse(json['unreadCount']?.toString() ?? '0') ?? 0,
      updatedAt: updatedAt,
      messages: messages,
    );
  }
}
