import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/local/preferences.dart';
import '../../data/remote/response/chat_models.dart';
import '../../repository/chat_repository.dart';
import '../../services/theme_service.dart';
import '../../utils/translation_helper.dart';
import 'new_chat_screen.dart';

class GroupInfoController extends GetxController {
  GroupInfoController(this.conversationId);

  final int conversationId;
  final ChatRepository _repo = ChatRepository();
  final ThemeService _theme = ThemeService.instance;

  final RxBool isLoading = true.obs;
  final RxString name = ''.obs;
  final RxString type = 'group'.obs;
  final RxBool isCreator = false.obs;
  final RxInt memberCount = 0.obs;
  final RxList<ChatUser> participants = <ChatUser>[].obs;
  final RxList<ChatFile> sharedFiles = <ChatFile>[].obs;
  final RxString workspaceUrl = ''.obs;

  bool get isGroup => type.value != 'direct';

  @override
  void onInit() {
    super.onInit();
    Preferences().getWorkspaceUrl().then((v) => workspaceUrl.value = v);
    load();
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      final page = await _repo.getMessages(conversationId);
      name.value = page.convName ?? '';
      type.value = page.convType ?? 'group';
      isCreator.value = page.isCreator ?? false;
      memberCount.value = page.memberCount ?? page.participants.length;
      participants.value = page.participants;
      sharedFiles.value = page.sharedFiles;
    } catch (e) {
      _snack(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rename() async {
    final ctrl = TextEditingController(text: name.value);
    final result = await Get.defaultDialog<String>(
      title: tr('rename_group'),
      content: TextField(
        controller: ctrl,
        decoration: InputDecoration(hintText: tr('group_name')),
      ),
      textConfirm: tr('save'),
      textCancel: tr('cancel'),
      onConfirm: () => Get.back(result: ctrl.text.trim()),
    );
    if (result == null || result.isEmpty) return;
    try {
      name.value = await _repo.renameGroup(conversationId, result);
      Get.snackbar(tr('success'), tr('group_renamed'),
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      _snack(e.toString());
    }
  }

  Future<void> addParticipants() async {
    final picked = await Get.to<List<int>>(
      () => const NewChatScreen(pickMode: true),
    );
    if (picked == null || picked.isEmpty) return;
    try {
      memberCount.value = await _repo.addParticipants(conversationId, picked);
      await load();
      Get.snackbar(tr('success'), tr('participants_added'),
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      _snack(e.toString());
    }
  }

  Future<void> leave() async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: Text(tr('leave_group')),
        content: Text(tr('confirm_leave_group')),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: Text(tr('cancel'))),
          TextButton(onPressed: () => Get.back(result: true), child: Text(tr('leave_group'))),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _repo.leaveGroup(conversationId);
      Get.until((r) => r.isFirst);
    } catch (e) {
      _snack(e.toString());
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
