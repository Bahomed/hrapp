import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/local/preferences.dart';
import '../../data/remote/response/chat_models.dart';
import '../../repository/chat_repository.dart';
import '../../services/theme_service.dart';
import '../../utils/translation_helper.dart';

class ChatController extends GetxController {
  ChatController(this.conversationId);

  final int conversationId;

  final ChatRepository _repo = ChatRepository();
  final ThemeService _theme = ThemeService.instance;
  final Preferences _prefs = Preferences();

  final RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSending = false.obs;
  final RxBool loadingOlder = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // meta (first page)
  final RxString convName = ''.obs;
  final RxString convType = 'direct'.obs;
  final RxBool isCreator = false.obs;
  final RxInt memberCount = 0.obs;
  final RxBool pinned = false.obs;
  final RxBool muted = false.obs;
  final RxList<ChatUser> participants = <ChatUser>[].obs;
  final RxList<ChatFile> sharedFiles = <ChatFile>[].obs;

  final RxString workspaceUrl = ''.obs;
  final RxString authToken = ''.obs;
  final ScrollController scrollController = ScrollController();

  Map<String, String> get authHeaders =>
      authToken.value.isEmpty ? const {} : {'Authorization': 'Bearer ${authToken.value}'};

  Timer? _poll;
  Timer? _heartbeat;
  bool _noOlder = false;

  bool get isGroup => convType.value != 'direct';

  @override
  void onInit() {
    super.onInit();
    _prefs.getWorkspaceUrl().then((v) => workspaceUrl.value = v);
    _prefs.getToken().then((v) => authToken.value = v);
    scrollController.addListener(_onScroll);
    loadFirstPage();
    _repo.heartbeat();
    _heartbeat = Timer.periodic(const Duration(seconds: 60), (_) => _repo.heartbeat());
    _poll = Timer.periodic(const Duration(seconds: 5), (_) => _pollNew());
  }

  @override
  void onClose() {
    _poll?.cancel();
    _heartbeat?.cancel();
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.hasClients &&
        scrollController.position.pixels <= 80 &&
        !loadingOlder.value &&
        !_noOlder &&
        messages.isNotEmpty) {
      loadOlder();
    }
  }

  Future<void> loadFirstPage() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      final page = await _repo.getMessages(conversationId);
      messages.value = page.messages;
      _applyMeta(page);
      _scrollToBottom(jump: true);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void _applyMeta(MessagesPage page) {
    if (!page.hasMeta) return;
    convName.value = page.convName ?? convName.value;
    convType.value = page.convType ?? convType.value;
    isCreator.value = page.isCreator ?? isCreator.value;
    memberCount.value = page.memberCount ?? memberCount.value;
    pinned.value = page.pinned ?? pinned.value;
    muted.value = page.muted ?? muted.value;
    participants.value = page.participants;
    sharedFiles.value = page.sharedFiles;
  }

  Future<void> _pollNew() async {
    if (messages.isEmpty) {
      // Nothing yet — retry the full first page so an incoming first message shows.
      try {
        final page = await _repo.getMessages(conversationId);
        if (page.messages.isNotEmpty) {
          messages.value = page.messages;
          _applyMeta(page);
          _scrollToBottom();
        }
      } catch (_) {}
      return;
    }
    try {
      final afterId = messages.last.id;
      final page = await _repo.getMessages(conversationId, afterId: afterId);
      if (page.messages.isEmpty) {
        // No new rows — but a message being *read* by the other party only
        // flips its `status` on an existing row, so reconcile receipts.
        final hasPendingReceipt =
            messages.any((m) => m.isMine && m.status != null && !m.isRead);
        if (hasPendingReceipt) await _reconcileReceipts();
        return;
      }
      final atBottom = _isAtBottom();
      final existing = messages.map((m) => m.id).toSet();
      messages.addAll(page.messages.where((m) => !existing.contains(m.id)));
      if (atBottom) _scrollToBottom();
    } catch (_) {}
  }

  /// Re-fetch the latest window and fold any changed read-receipt / deletion
  /// state into messages we already hold. A message being read by the other
  /// party produces no new row, so `after_id` polling can never see it.
  Future<void> _reconcileReceipts() async {
    try {
      final page = await _repo.getMessages(conversationId);
      if (page.messages.isEmpty) return;
      final byId = {for (final m in page.messages) m.id: m};
      var changed = false;
      for (var i = 0; i < messages.length; i++) {
        final cur = messages[i];
        final fresh = byId[cur.id];
        if (fresh == null) continue;
        if (fresh.status != cur.status || fresh.deleted != cur.deleted) {
          messages[i] = cur.copyWith(
            status: fresh.status,
            deleted: fresh.deleted,
          );
          changed = true;
        }
      }
      if (changed) messages.refresh();
    } catch (_) {}
  }

  Future<void> loadOlder() async {
    if (loadingOlder.value || _noOlder || messages.isEmpty) return;
    try {
      loadingOlder.value = true;
      final beforeId = messages.first.id;
      final page = await _repo.getMessages(conversationId, beforeId: beforeId);
      if (page.messages.isEmpty) {
        _noOlder = true;
        return;
      }
      final existing = messages.map((m) => m.id).toSet();
      final older = page.messages.where((m) => !existing.contains(m.id)).toList();
      if (older.isEmpty) {
        _noOlder = true;
        return;
      }
      final offsetBefore = scrollController.hasClients
          ? scrollController.position.maxScrollExtent - scrollController.position.pixels
          : 0.0;
      messages.insertAll(0, older);
      // Keep the viewport anchored after prepending.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.jumpTo(
              scrollController.position.maxScrollExtent - offsetBefore);
        }
      });
    } catch (e) {
      _snack(e.toString());
    } finally {
      loadingOlder.value = false;
    }
  }

  Future<void> refreshThread() => loadFirstPage();

  // ── Sending ─────────────────────────────────────────────────────────────

  Future<void> sendText(String text) async {
    final body = text.trim();
    if (body.isEmpty || isSending.value) return;
    await _send(body: body);
  }

  Future<void> sendFile(File file) async {
    if (isSending.value) return;
    await _send(file: file);
  }

  Future<void> sendAudio(String path) async {
    if (isSending.value) return;
    await _send(file: File(path));
  }

  Future<void> _send({String? body, File? file}) async {
    try {
      isSending.value = true;
      await _repo.sendMessage(conversationId, body: body, file: file);
      // Pull the new message(s) back so we render exactly what the server stored.
      final afterId = messages.isNotEmpty ? messages.last.id : null;
      final page = afterId != null
          ? await _repo.getMessages(conversationId, afterId: afterId)
          : await _repo.getMessages(conversationId);
      if (afterId != null) {
        final existing = messages.map((m) => m.id).toSet();
        messages.addAll(page.messages.where((m) => !existing.contains(m.id)));
      } else {
        messages.value = page.messages;
        _applyMeta(page);
      }
      _scrollToBottom();
    } catch (e) {
      _snack(e.toString());
    } finally {
      isSending.value = false;
    }
  }

  // ── Reactions / delete ──────────────────────────────────────────────────

  Future<void> toggleReaction(ChatMessageModel msg, String emoji) async {
    try {
      final updated = await _repo.toggleReaction(msg.id, emoji);
      final i = messages.indexWhere((m) => m.id == msg.id);
      if (i != -1) messages[i] = messages[i].copyWith(reactions: updated);
    } catch (e) {
      _snack(e.toString());
    }
  }

  Future<void> deleteMessage(ChatMessageModel msg) async {
    try {
      await _repo.deleteMessage(msg.id);
      final i = messages.indexWhere((m) => m.id == msg.id);
      if (i != -1) {
        messages[i] = messages[i].copyWith(
          deleted: true,
          clearBody: true,
          reactions: const [],
          files: const [],
        );
      }
    } catch (e) {
      _snack(e.toString());
    }
  }

  // ── Pin / mute ──────────────────────────────────────────────────────────

  Future<void> togglePin() async {
    try {
      pinned.value = await _repo.togglePin(conversationId);
    } catch (e) {
      _snack(e.toString());
    }
  }

  Future<void> toggleMute() async {
    try {
      muted.value = await _repo.toggleMute(conversationId);
    } catch (e) {
      _snack(e.toString());
    }
  }

  // ── helpers ─────────────────────────────────────────────────────────────

  bool _isAtBottom() {
    if (!scrollController.hasClients) return true;
    return scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 120;
  }

  void _scrollToBottom({bool jump = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      final target = scrollController.position.maxScrollExtent;
      if (jump) {
        scrollController.jumpTo(target);
      } else {
        scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _snack(String msg) {
    Get.snackbar(
      tr('error'),
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _theme.getErrorColor(),
      colorText: Colors.white,
    );
  }
}
