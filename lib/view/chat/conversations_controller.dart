import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/remote/response/chat_models.dart';
import '../../repository/chat_repository.dart';
import '../../services/theme_service.dart';
import '../../utils/translation_helper.dart';
import 'chat_screen.dart';

class ConversationsController extends GetxController {
  final ChatRepository _repo = ChatRepository();
  final ThemeService _theme = ThemeService.instance;

  final RxList<Conversation> conversations = <Conversation>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  Timer? _heartbeat;
  Timer? _poll;

  int get totalUnread =>
      conversations.fold(0, (sum, c) => sum + c.unread);

  @override
  void onInit() {
    super.onInit();
    load();
    _heartbeat = Timer.periodic(const Duration(seconds: 60), (_) => _repo.heartbeat());
    _repo.heartbeat();
    _poll = Timer.periodic(const Duration(seconds: 15), (_) => _silentRefresh());
  }

  @override
  void onClose() {
    _heartbeat?.cancel();
    _poll?.cancel();
    super.onClose();
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      conversations.value = await _repo.getConversations();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> reload() => load();

  Future<void> _silentRefresh() async {
    try {
      conversations.value = await _repo.getConversations();
    } catch (_) {}
  }

  void openConversation(Conversation c) {
    // Optimistically clear the unread pill.
    final i = conversations.indexWhere((x) => x.id == c.id);
    if (i != -1) conversations[i] = conversations[i].copyWith(unread: 0);
    Get.to(() => ChatScreen(conversationId: c.id))?.then((_) => _silentRefresh());
  }

  Future<void> togglePin(Conversation c) async {
    try {
      final pinned = await _repo.togglePin(c.id);
      final i = conversations.indexWhere((x) => x.id == c.id);
      if (i != -1) conversations[i] = conversations[i].copyWith(pinned: pinned);
      _resort();
    } catch (e) {
      _snack(e.toString());
    }
  }

  Future<void> toggleMute(Conversation c) async {
    try {
      final muted = await _repo.toggleMute(c.id);
      final i = conversations.indexWhere((x) => x.id == c.id);
      if (i != -1) conversations[i] = conversations[i].copyWith(muted: muted);
    } catch (e) {
      _snack(e.toString());
    }
  }

  void _resort() {
    final list = conversations.toList()
      ..sort((a, b) {
        if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
        return 0;
      });
    conversations.value = list;
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
