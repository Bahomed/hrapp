import 'dart:async';

import 'package:get/get.dart';

import '../../repository/chat_repository.dart';

/// Lightweight controller that feeds the unread badge on the Home app bar.
/// Polls the chat unread-count endpoint; safe to `Get.put` once on Home.
class ChatUnreadController extends GetxController {
  final ChatRepository _repo = ChatRepository();

  final RxInt unread = 0.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    reload();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => reload());
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> reload() async {
    try {
      unread.value = await _repo.getUnreadCount();
    } catch (_) {}
  }
}
