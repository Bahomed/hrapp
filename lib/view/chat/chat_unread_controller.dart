import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../repository/chat_repository.dart';

/// Feeds the unread badge on the Home bottom bar.
///
/// Polls `chat/unread-count` every 60 s, but only while the app is in the
/// foreground and the chat list is not open (the list refreshes itself).
/// Paused in the background; refreshed at once when the app comes back.
class ChatUnreadController extends GetxController with WidgetsBindingObserver {
  final ChatRepository _repo = ChatRepository();

  static const _interval = Duration(seconds: 60);

  final RxInt unread = 0.obs;
  Timer? _timer;
  bool _chatOpen = false;
  bool _inForeground = true;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    reload();
    _start();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _inForeground = state == AppLifecycleState.resumed;
    if (_inForeground) {
      reload();
      _start();
    } else {
      _stop();
    }
  }

  /// The chat list (bottom tab) is visible: it refreshes on its own.
  void setChatOpen(bool open) {
    _chatOpen = open;
    if (open) {
      _stop();
    } else {
      reload();
      _start();
    }
  }

  void _start() {
    _timer?.cancel();
    if (!_inForeground || _chatOpen) return;
    _timer = Timer.periodic(_interval, (_) => reload());
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> reload() async {
    try {
      unread.value = await _repo.getUnreadCount();
    } catch (_) {}
  }
}
