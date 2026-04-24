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
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
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

  factory SupportParticipantModel.fromJson(Map<String, dynamic> json) {
    return SupportParticipantModel(
      userId: json['userId']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ??
          json['firstName']?.toString() ??
          'Support',
      avatar: json['avatar']?.toString() ?? json['profileImage']?.toString(),
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
    final other =
        participants.where((p) => p.userId != myId).firstOrNull;
    return other?.userId ?? '';
  }

  String otherParticipantName(String myId) {
    final other =
        participants.where((p) => p.userId != myId).firstOrNull;
    return other?.name ?? 'Support';
  }

  factory SupportConversationModel.fromJson(Map<String, dynamic> json) {
    final rawParticipants = json['participants'];
    final List<SupportParticipantModel> participants = rawParticipants is List
        ? rawParticipants
            .map((p) => SupportParticipantModel.fromJson(
                p is Map ? Map<String, dynamic>.from(p) : {}))
            .toList()
        : [];

    final rawLast = json['lastMessage'];
    final SupportMessageModel? lastMessage = rawLast is Map
        ? SupportMessageModel.fromJson(Map<String, dynamic>.from(rawLast))
        : null;

    final rawMessages = json['messages'];
    final List<SupportMessageModel> messages = rawMessages is List
        ? rawMessages
            .map((m) => SupportMessageModel.fromJson(
                m is Map ? Map<String, dynamic>.from(m) : {}))
            .toList()
        : [];

    return SupportConversationModel(
      id: json['id']?.toString() ?? '',
      participants: participants,
      lastMessage: lastMessage,
      unreadCount: json['unreadCount'] is int
          ? json['unreadCount']
          : int.tryParse(json['unreadCount']?.toString() ?? '0') ?? 0,
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
      messages: messages,
    );
  }
}
