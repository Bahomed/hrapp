import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/local/preferences.dart';
import '../../data/remote/response/chat_models.dart';
import '../../repository/chat_repository.dart';
import '../../services/theme_service.dart';
import '../../utils/translation_helper.dart';
import 'chat_screen.dart';

class NewChatController extends GetxController {
  NewChatController({this.pickMode = false});

  /// When true the screen just returns a `List<int>` of selected user ids
  /// (used by "add participants"); it never starts a conversation.
  final bool pickMode;

  final ChatRepository _repo = ChatRepository();
  final ThemeService _theme = ThemeService.instance;

  final RxBool loadingTeam = true.obs;
  final RxBool searching = false.obs;
  final RxList<ChatUser> team = <ChatUser>[].obs;
  final RxList<ChatUser> results = <ChatUser>[].obs;
  final RxString query = ''.obs;
  final RxBool groupMode = false.obs; // multi-select
  final RxList<int> selected = <int>[].obs;
  final RxString workspaceUrl = ''.obs;
  final RxBool busy = false.obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    if (pickMode) groupMode.value = true;
    Preferences().getWorkspaceUrl().then((v) => workspaceUrl.value = v);
    loadTeam();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> loadTeam() async {
    try {
      loadingTeam.value = true;
      team.value = await _repo.myTeam();
    } catch (_) {
    } finally {
      loadingTeam.value = false;
    }
  }

  void onQueryChanged(String q) {
    query.value = q;
    _debounce?.cancel();
    if (q.trim().isEmpty) {
      results.clear();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      try {
        searching.value = true;
        results.value = await _repo.searchUsers(q.trim());
      } catch (_) {
      } finally {
        searching.value = false;
      }
    });
  }

  void toggleSelected(int id) {
    if (selected.contains(id)) {
      selected.remove(id);
    } else {
      selected.add(id);
    }
  }

  Future<void> onUserTap(ChatUser u) async {
    if (groupMode.value) {
      toggleSelected(u.id);
      return;
    }
    if (busy.value) return;
    try {
      busy.value = true;
      final convId = await _repo.startDirect(u.id);
      Get.off(() => ChatScreen(conversationId: convId));
    } catch (e) {
      _snack(e.toString());
    } finally {
      busy.value = false;
    }
  }

  Future<void> confirmSelection({String? groupName}) async {
    if (selected.isEmpty) return;

    if (pickMode) {
      Get.back(result: selected.toList());
      return;
    }

    if (busy.value) return;
    try {
      busy.value = true;
      if (selected.length == 1) {
        final convId = await _repo.startDirect(selected.first);
        Get.off(() => ChatScreen(conversationId: convId));
      } else {
        final convId =
            await _repo.startGroup(selected.toList(), name: groupName);
        Get.off(() => ChatScreen(conversationId: convId));
      }
    } catch (e) {
      _snack(e.toString());
    } finally {
      busy.value = false;
    }
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
