import 'dart:io';

import 'package:co.injazathr.injazathr/data/local/preferences.dart';
import 'package:co.injazathr.injazathr/data/remote/dio_client/dio_client.dart';
import 'package:co.injazathr.injazathr/data/remote/network_url/network_url.dart';
import 'package:co.injazathr.injazathr/data/remote/response/chat_models.dart';
import 'package:dio/dio.dart';

import '../utils/exceptionhandler.dart';
import '../utils/translation_helper.dart';

/// Mobile chat API client. Mirrors App\Http\Controllers\Api\ChatController
/// method-for-method. Follows the same conventions as PayrollRepository /
/// EmployeesRepository (token + workspace URL from Preferences, DioException
/// funnelled through exceptionHandler).
class ChatRepository {
  final Preferences preferences = Preferences();
  final DioClient dioClient = DioClient();

  Future<Map<String, String>> _authHeader() async {
    final token = await preferences.getToken();
    return {'Authorization': 'Bearer $token'};
  }

  Map<String, dynamic> _localeQuery([Map<String, dynamic>? extra]) => {
        'locale': getCurrentLanguage(),
        ...?extra,
      };

  Never _rethrow(Object e) {
    if (e is DioException) {
      if (e.error is SocketException) throw 'No Internet Connection';
      throw exceptionHandler(e);
    }
    throw e.toString();
  }

  // ── Conversations ────────────────────────────────────────────────────────

  Future<List<Conversation>> getConversations() async {
    try {
      final res = await dioClient.get(
        '${await preferences.getWorkspaceUrl()}$chatConversationsUrl',
        await _authHeader(),
        _localeQuery(),
      );
      final env = ChatEnvelope.fromJson(res.data, (d) {
        final list = (d as Map)['conversations'] as List? ?? [];
        return list
            .map((e) => Conversation.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      });
      return env.data ?? <Conversation>[];
    } catch (e) {
      _rethrow(e);
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final res = await dioClient.get(
        '${await preferences.getWorkspaceUrl()}$chatUnreadCountUrl',
        await _authHeader(),
        _localeQuery(),
      );
      final env = ChatEnvelope.fromJson(
          res.data, (d) => (d as Map)['count'] as int? ?? 0);
      return env.data ?? 0;
    } catch (e) {
      _rethrow(e);
    }
  }

  Future<void> heartbeat() async {
    try {
      await dioClient.post(
        '${await preferences.getWorkspaceUrl()}$chatHeartbeatUrl',
        {},
        _localeQuery(),
        await _authHeader(),
      );
    } catch (_) {
      // Presence is best-effort; never surface an error for it.
    }
  }

  // ── Messages ─────────────────────────────────────────────────────────────

  Future<MessagesPage> getMessages(
    int conversationId, {
    int? afterId,
    int? beforeId,
  }) async {
    try {
      final query = _localeQuery({
        if (afterId != null) 'after_id': afterId,
        if (beforeId != null) 'before_id': beforeId,
      });
      final res = await dioClient.get(
        '${await preferences.getWorkspaceUrl()}${chatMessagesUrl(conversationId)}',
        await _authHeader(),
        query,
      );
      final env = ChatEnvelope.fromJson(
          res.data, (d) => MessagesPage.fromJson(Map<String, dynamic>.from(d)));
      return env.data ?? MessagesPage(convId: conversationId, messages: const []);
    } catch (e) {
      _rethrow(e);
    }
  }

  /// Send a text and/or a single attachment. Always multipart, matching the
  /// backend which reads `body` as a form field and `file` as an upload.
  Future<int> sendMessage(
    int conversationId, {
    String? body,
    File? file,
  }) async {
    try {
      final form = FormData.fromMap({
        if (body != null && body.isNotEmpty) 'body': body,
        if (file != null)
          'file': await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        'locale': getCurrentLanguage(),
      });
      final res = await dioClient.postForImageUpload(
        '${await preferences.getWorkspaceUrl()}${chatSendMessageUrl(conversationId)}',
        form,
        await _authHeader(),
      );
      final env = ChatEnvelope.fromJson(
          res.data, (d) => (d as Map)['message_id'] as int? ?? 0);
      return env.data ?? 0;
    } catch (e) {
      _rethrow(e);
    }
  }

  Future<void> deleteMessage(int messageId) async {
    try {
      await dioClient.delete(
        '${await preferences.getWorkspaceUrl()}${chatDeleteMessageUrl(messageId)}',
        await _authHeader(),
        _localeQuery(),
      );
    } catch (e) {
      _rethrow(e);
    }
  }

  Future<List<MessageReaction>> toggleReaction(int messageId, String emoji) async {
    try {
      final res = await dioClient.post(
        '${await preferences.getWorkspaceUrl()}${chatReactUrl(messageId)}',
        {'emoji': emoji},
        _localeQuery(),
        await _authHeader(),
      );
      final env = ChatEnvelope.fromJson(res.data, (d) {
        final list = (d as Map)['reactions'] as List? ?? [];
        return list
            .map((e) => MessageReaction.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      });
      return env.data ?? <MessageReaction>[];
    } catch (e) {
      _rethrow(e);
    }
  }

  // ── Pin / mute ───────────────────────────────────────────────────────────

  Future<bool> togglePin(int conversationId) async {
    try {
      final res = await dioClient.post(
        '${await preferences.getWorkspaceUrl()}${chatPinUrl(conversationId)}',
        {},
        _localeQuery(),
        await _authHeader(),
      );
      final env = ChatEnvelope.fromJson(
          res.data, (d) => (d as Map)['pinned'] as bool? ?? false);
      return env.data ?? false;
    } catch (e) {
      _rethrow(e);
    }
  }

  Future<bool> toggleMute(int conversationId) async {
    try {
      final res = await dioClient.post(
        '${await preferences.getWorkspaceUrl()}${chatMuteUrl(conversationId)}',
        {},
        _localeQuery(),
        await _authHeader(),
      );
      final env = ChatEnvelope.fromJson(
          res.data, (d) => (d as Map)['muted'] as bool? ?? false);
      return env.data ?? false;
    } catch (e) {
      _rethrow(e);
    }
  }

  // ── People ───────────────────────────────────────────────────────────────

  Future<List<ChatUser>> searchUsers(String query) async {
    try {
      final res = await dioClient.get(
        '${await preferences.getWorkspaceUrl()}$chatSearchUsersUrl',
        await _authHeader(),
        _localeQuery({'q': query}),
      );
      return _usersFrom(res.data);
    } catch (e) {
      _rethrow(e);
    }
  }

  Future<List<ChatUser>> myTeam() async {
    try {
      final res = await dioClient.get(
        '${await preferences.getWorkspaceUrl()}$chatMyTeamUrl',
        await _authHeader(),
        _localeQuery(),
      );
      return _usersFrom(res.data);
    } catch (e) {
      _rethrow(e);
    }
  }

  List<ChatUser> _usersFrom(dynamic data) {
    final env = ChatEnvelope.fromJson(data, (d) {
      final list = (d as Map)['users'] as List? ?? [];
      return list
          .map((e) => ChatUser.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    });
    return env.data ?? <ChatUser>[];
  }

  // ── Start conversations ──────────────────────────────────────────────────

  Future<int> startDirect(int userId) async {
    try {
      final res = await dioClient.post(
        '${await preferences.getWorkspaceUrl()}$chatStartDirectUrl',
        {'user_id': userId},
        _localeQuery(),
        await _authHeader(),
      );
      return _conversationIdFrom(res.data);
    } catch (e) {
      _rethrow(e);
    }
  }

  Future<int> startGroup(List<int> userIds, {String? name}) async {
    try {
      final res = await dioClient.post(
        '${await preferences.getWorkspaceUrl()}$chatStartGroupUrl',
        {
          'user_ids': userIds,
          if (name != null && name.isNotEmpty) 'name': name,
        },
        _localeQuery(),
        await _authHeader(),
      );
      return _conversationIdFrom(res.data);
    } catch (e) {
      _rethrow(e);
    }
  }

  int _conversationIdFrom(dynamic data) {
    final env = ChatEnvelope.fromJson(
        data, (d) => (d as Map)['conversation_id'] as int? ?? 0);
    return env.data ?? 0;
  }

  // ── Group management ─────────────────────────────────────────────────────

  Future<String> renameGroup(int conversationId, String name) async {
    try {
      final res = await dioClient.post(
        '${await preferences.getWorkspaceUrl()}${chatRenameUrl(conversationId)}',
        {'name': name},
        _localeQuery(),
        await _authHeader(),
      );
      final env = ChatEnvelope.fromJson(
          res.data, (d) => (d as Map)['name']?.toString() ?? name);
      return env.data ?? name;
    } catch (e) {
      _rethrow(e);
    }
  }

  Future<int> addParticipants(int conversationId, List<int> userIds) async {
    try {
      final res = await dioClient.post(
        '${await preferences.getWorkspaceUrl()}${chatParticipantsUrl(conversationId)}',
        {'user_ids': userIds},
        _localeQuery(),
        await _authHeader(),
      );
      final env = ChatEnvelope.fromJson(
          res.data, (d) => (d as Map)['member_count'] as int? ?? 0);
      return env.data ?? 0;
    } catch (e) {
      _rethrow(e);
    }
  }

  Future<void> leaveGroup(int conversationId) async {
    try {
      // Backend registers this as DELETE /chat/{id}/leave.
      await dioClient.delete(
        '${await preferences.getWorkspaceUrl()}${chatLeaveUrl(conversationId)}',
        await _authHeader(),
        _localeQuery(),
      );
    } catch (e) {
      _rethrow(e);
    }
  }

  Future<void> removeParticipant(int conversationId, int userId) async {
    try {
      await dioClient.delete(
        '${await preferences.getWorkspaceUrl()}${chatRemoveParticipantUrl(conversationId, userId)}',
        await _authHeader(),
        _localeQuery(),
      );
    } catch (e) {
      _rethrow(e);
    }
  }

  // ── Department / section auto-groups (no launch UI in v1) ────────────────

  Future<Map<String, List<DepartmentSectionOption>>> myDepartmentSections() async {
    try {
      final res = await dioClient.get(
        '${await preferences.getWorkspaceUrl()}$chatMyDepartmentSectionsUrl',
        await _authHeader(),
        _localeQuery(),
      );
      final env = ChatEnvelope.fromJson(res.data, (d) {
        final map = d as Map;
        List<DepartmentSectionOption> parse(String key) =>
            (map[key] as List? ?? [])
                .map((e) => DepartmentSectionOption.fromJson(
                    Map<String, dynamic>.from(e)))
                .toList();
        return {
          'departments': parse('departments'),
          'sections': parse('sections'),
        };
      });
      return env.data ?? {'departments': [], 'sections': []};
    } catch (e) {
      _rethrow(e);
    }
  }

  Future<int> openDepartmentGroup(int departmentId) async {
    try {
      final res = await dioClient.post(
        '${await preferences.getWorkspaceUrl()}${chatDepartmentGroupUrl(departmentId)}',
        {},
        _localeQuery(),
        await _authHeader(),
      );
      return _conversationIdFrom(res.data);
    } catch (e) {
      _rethrow(e);
    }
  }

  Future<int> openSectionGroup(int deptSectionId) async {
    try {
      final res = await dioClient.post(
        '${await preferences.getWorkspaceUrl()}${chatSectionGroupUrl(deptSectionId)}',
        {},
        _localeQuery(),
        await _authHeader(),
      );
      return _conversationIdFrom(res.data);
    } catch (e) {
      _rethrow(e);
    }
  }
}
