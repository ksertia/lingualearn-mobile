import 'package:dio/dio.dart';
import 'package:fasolingo/controller/apps/session_controller.dart';
import 'package:fasolingo/models/support/support_models.dart';
import 'package:get/get.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class SupportChatService {
  static final _session = Get.find<SessionController>();
  static bool _loggerAdded = false;

  static void _ensureLogger() {
    if (_loggerAdded) return;
    _session.dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      compact: true,
      maxWidth: 120,
    ));
    _loggerAdded = true;
  }

  /// GET /messages-ws/conversations
  static Future<List<SupportConversationModel>> fetchConversations() async {
    try {
      _ensureLogger();
      final response = await _session.dio.get('/messages-ws/conversations');
      if (response.statusCode == 200) {
        final raw = response.data;
        final list = raw is List
            ? raw
            : raw is Map && raw['data'] is List
                ? raw['data'] as List
                : raw is Map && raw['conversations'] is List
                    ? raw['conversations'] as List
                    : <dynamic>[];
        return list
            .map((e) => SupportConversationModel.fromJson(
                e is Map ? Map<String, dynamic>.from(e) : {}))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      print('SupportChatService.fetchConversations: ${e.message}');
      return [];
    } catch (e) {
      print('SupportChatService.fetchConversations unexpected: $e');
      return [];
    }
  }

  /// GET /messages-ws/conversations/:id
  static Future<List<SupportMessageModel>> fetchMessages(
      String conversationId) async {
    try {
      _ensureLogger();
      final response =
          await _session.dio.get('/messages-ws/conversations/$conversationId');
      if (response.statusCode == 200) {
        final raw = response.data;
        final list = raw is List
            ? raw
            : raw is Map && raw['messages'] is List
                ? raw['messages'] as List
                : raw is Map && raw['data'] is List
                    ? raw['data'] as List
                    : <dynamic>[];
        return list
            .map((e) => SupportMessageModel.fromJson(
                e is Map ? Map<String, dynamic>.from(e) : {}))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      print('SupportChatService.fetchMessages: ${e.message}');
      return [];
    } catch (e) {
      print('SupportChatService.fetchMessages unexpected: $e');
      return [];
    }
  }

  /// POST /messages-ws
  static Future<SupportMessageModel?> sendMessage({
    required String senderId,
    required String recipientId,
    required String content,
    String type = 'text',
    Map<String, dynamic> metadata = const {},
  }) async {
    try {
      _ensureLogger();
      final response = await _session.dio.post(
        '/messages-ws',
        data: {
          'senderId': senderId,
          'recipientId': recipientId,
          'content': content,
          'type': type,
          'metadata': metadata,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final raw = response.data;
        final msgJson = raw is Map && raw['data'] is Map
            ? Map<String, dynamic>.from(raw['data'] as Map)
            : raw is Map
                ? Map<String, dynamic>.from(raw)
                : <String, dynamic>{};
        return SupportMessageModel.fromJson(msgJson);
      }
      return null;
    } on DioException catch (e) {
      print('SupportChatService.sendMessage: ${e.message}');
      return null;
    } catch (e) {
      print('SupportChatService.sendMessage unexpected: $e');
      return null;
    }
  }

  /// POST /messages-ws/read
  static Future<void> markMessagesRead({
    String? conversationId,
    List<String>? messageIds,
  }) async {
    try {
      _ensureLogger();
      final body = <String, dynamic>{};
      if (conversationId != null) body['conversationId'] = conversationId;
      if (messageIds != null) body['messageIds'] = messageIds;
      await _session.dio.post('/messages-ws/read', data: body);
    } catch (e) {
      print('SupportChatService.markRead: $e');
    }
  }

  /// GET /messages-ws/unread-count
  static Future<int> fetchUnreadCount() async {
    try {
      _ensureLogger();
      final response = await _session.dio.get('/messages-ws/unread-count');
      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map;
        return data['count'] is int
            ? data['count'] as int
            : int.tryParse(data['count']?.toString() ?? '0') ?? 0;
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }
}
