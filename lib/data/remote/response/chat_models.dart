// Chat models — decode the {success, message, data} envelope from
// App\Http\Controllers\Api\ChatController.

int _asInt(dynamic v) {
  if (v is int) return v;
  if (v is String) return int.tryParse(v) ?? 0;
  if (v is double) return v.toInt();
  return 0;
}

bool _asBool(dynamic v) {
  if (v is bool) return v;
  if (v is int) return v != 0;
  if (v is String) return v == '1' || v.toLowerCase() == 'true';
  return false;
}

String? _asStringOrNull(dynamic v) => v?.toString();

/// Generic envelope wrapper. `T` is produced by [parse] from `data`.
class ChatEnvelope<T> {
  final bool success;
  final String message;
  final T? data;

  ChatEnvelope({required this.success, required this.message, this.data});

  factory ChatEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic data) parse,
  ) {
    final raw = json['data'];
    return ChatEnvelope<T>(
      success: _asBool(json['success']),
      message: (json['message'] ?? '').toString(),
      data: raw == null ? null : parse(raw),
    );
  }
}

class LastMessagePreview {
  final String body;
  final String? sender;
  final bool isMine;
  final bool hasFile;
  final String createdAt; // already humanised by the API (diffForHumans)

  LastMessagePreview({
    required this.body,
    this.sender,
    required this.isMine,
    required this.hasFile,
    required this.createdAt,
  });

  factory LastMessagePreview.fromJson(Map<String, dynamic> json) {
    return LastMessagePreview(
      body: (json['body'] ?? '').toString(),
      sender: _asStringOrNull(json['sender']),
      isMine: _asBool(json['is_mine']),
      hasFile: _asBool(json['has_file']),
      createdAt: (json['created_at'] ?? '').toString(),
    );
  }
}

class Conversation {
  final int id;
  final String type; // direct | group | department | section
  final String name;
  final bool otherOnline;
  final String? otherImage;
  final String? otherEmployeeNo;
  final int memberCount;
  final bool pinned;
  final bool muted;
  final int unread;
  final LastMessagePreview? lastMessage;

  Conversation({
    required this.id,
    required this.type,
    required this.name,
    required this.otherOnline,
    this.otherImage,
    this.otherEmployeeNo,
    required this.memberCount,
    required this.pinned,
    required this.muted,
    required this.unread,
    this.lastMessage,
  });

  bool get isDirect => type == 'direct';

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: _asInt(json['id']),
      type: (json['type'] ?? 'direct').toString(),
      name: (json['name'] ?? '').toString(),
      otherOnline: _asBool(json['other_online']),
      otherImage: _asStringOrNull(json['other_image']),
      otherEmployeeNo: _asStringOrNull(json['other_employee_no']),
      memberCount: _asInt(json['member_count']),
      pinned: _asBool(json['pinned']),
      muted: _asBool(json['muted']),
      unread: _asInt(json['unread']),
      lastMessage: json['last_message'] is Map
          ? LastMessagePreview.fromJson(
              Map<String, dynamic>.from(json['last_message']))
          : null,
    );
  }

  Conversation copyWith({bool? pinned, bool? muted, int? unread}) {
    return Conversation(
      id: id,
      type: type,
      name: name,
      otherOnline: otherOnline,
      otherImage: otherImage,
      otherEmployeeNo: otherEmployeeNo,
      memberCount: memberCount,
      pinned: pinned ?? this.pinned,
      muted: muted ?? this.muted,
      unread: unread ?? this.unread,
      lastMessage: lastMessage,
    );
  }
}

class ChatUser {
  final int id;
  final String? name;
  final String? employeeNo;
  final String? image;
  final bool online;

  ChatUser({
    required this.id,
    this.name,
    this.employeeNo,
    this.image,
    this.online = false,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: _asInt(json['id']),
      name: _asStringOrNull(json['name']),
      employeeNo: _asStringOrNull(json['employee_no']),
      image: _asStringOrNull(json['image']),
      online: _asBool(json['online']),
    );
  }
}

class ChatFile {
  final String url;
  final String name;
  final String type; // image | audio | document
  final int size;
  final String sizeText;

  ChatFile({
    required this.url,
    required this.name,
    required this.type,
    required this.size,
    required this.sizeText,
  });

  bool get isImage => type == 'image';
  bool get isAudio => type == 'audio';

  factory ChatFile.fromJson(Map<String, dynamic> json) {
    return ChatFile(
      url: (json['url'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      type: (json['type'] ?? 'document').toString(),
      size: _asInt(json['size']),
      sizeText: (json['size_text'] ?? '').toString(),
    );
  }
}

class MessageReaction {
  final String emoji;
  final int count;
  final bool mine;

  MessageReaction({required this.emoji, required this.count, required this.mine});

  factory MessageReaction.fromJson(Map<String, dynamic> json) {
    return MessageReaction(
      emoji: (json['emoji'] ?? '').toString(),
      count: _asInt(json['count']),
      mine: _asBool(json['mine']),
    );
  }
}

class ChatMessageModel {
  final int id;
  final int senderId;
  final String? senderName;
  final String? senderImage;
  final String? senderEmployeeNo;
  final String? body;
  final bool deleted;
  final bool isMine;
  final String? status; // sent | read | null
  final String time; // "h:i A"
  final String day; // Today | Yesterday | "MMM d, yyyy"
  final List<MessageReaction> reactions;
  final List<ChatFile> files;

  ChatMessageModel({
    required this.id,
    required this.senderId,
    this.senderName,
    this.senderImage,
    this.senderEmployeeNo,
    this.body,
    required this.deleted,
    required this.isMine,
    this.status,
    required this.time,
    required this.day,
    required this.reactions,
    required this.files,
  });

  bool get isRead => status == 'read';

  ChatMessageModel copyWith({
    String? body,
    bool? deleted,
    String? status,
    List<MessageReaction>? reactions,
    List<ChatFile>? files,
    bool clearBody = false,
  }) {
    return ChatMessageModel(
      id: id,
      senderId: senderId,
      senderName: senderName,
      senderImage: senderImage,
      senderEmployeeNo: senderEmployeeNo,
      body: clearBody ? null : (body ?? this.body),
      deleted: deleted ?? this.deleted,
      isMine: isMine,
      status: status ?? this.status,
      time: time,
      day: day,
      reactions: reactions ?? this.reactions,
      files: files ?? this.files,
    );
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: _asInt(json['id']),
      senderId: _asInt(json['sender_id']),
      senderName: _asStringOrNull(json['sender_name']),
      senderImage: _asStringOrNull(json['sender_image']),
      senderEmployeeNo: _asStringOrNull(json['sender_employee_no']),
      body: _asStringOrNull(json['body']),
      deleted: _asBool(json['deleted']),
      isMine: _asBool(json['is_mine']),
      status: _asStringOrNull(json['status']),
      time: (json['time'] ?? '').toString(),
      day: (json['day'] ?? '').toString(),
      reactions: (json['reactions'] as List? ?? [])
          .map((e) => MessageReaction.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      files: (json['files'] as List? ?? [])
          .map((e) => ChatFile.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

/// Result of `GET /conversations/{id}/messages`. The meta block
/// (name, participants, shared files …) is only sent on the first page —
/// i.e. when neither `after_id` nor `before_id` is supplied.
class MessagesPage {
  final int convId;
  final List<ChatMessageModel> messages;

  // meta — nullable, first page only
  final String? convName;
  final String? convType;
  final bool? isCreator;
  final int? memberCount;
  final bool? pinned;
  final bool? muted;
  final List<ChatUser> participants;
  final List<ChatFile> sharedFiles;

  MessagesPage({
    required this.convId,
    required this.messages,
    this.convName,
    this.convType,
    this.isCreator,
    this.memberCount,
    this.pinned,
    this.muted,
    this.participants = const [],
    this.sharedFiles = const [],
  });

  bool get hasMeta => convName != null || convType != null;

  factory MessagesPage.fromJson(Map<String, dynamic> json) {
    return MessagesPage(
      convId: _asInt(json['conv_id']),
      messages: (json['messages'] as List? ?? [])
          .map((e) => ChatMessageModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      convName: _asStringOrNull(json['conv_name']),
      convType: _asStringOrNull(json['conv_type']),
      isCreator: json.containsKey('is_creator') ? _asBool(json['is_creator']) : null,
      memberCount: json.containsKey('member_count') ? _asInt(json['member_count']) : null,
      pinned: json.containsKey('pinned') ? _asBool(json['pinned']) : null,
      muted: json.containsKey('muted') ? _asBool(json['muted']) : null,
      participants: (json['participants'] as List? ?? [])
          .map((e) => ChatUser.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      sharedFiles: (json['shared_files'] as List? ?? [])
          .map((e) => ChatFile.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class DepartmentSectionOption {
  final int id;
  final String name;

  DepartmentSectionOption({required this.id, required this.name});

  factory DepartmentSectionOption.fromJson(Map<String, dynamic> json) {
    return DepartmentSectionOption(
      id: _asInt(json['id']),
      name: (json['name'] ?? '').toString(),
    );
  }
}
