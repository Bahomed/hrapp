import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/remote/response/chat_models.dart';
import '../../services/theme_service.dart';
import '../../utils/translation_helper.dart';
import 'chat_controller.dart';
import 'chat_ui_helpers.dart';
import 'group_info_screen.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/chat_skeleton.dart';
import 'widgets/message_bubble.dart';

class ChatScreen extends StatelessWidget {
  final int conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    final tag = 'chat_$conversationId';
    final c = Get.isRegistered<ChatController>(tag: tag)
        ? Get.find<ChatController>(tag: tag)
        : Get.put(ChatController(conversationId), tag: tag);

    return Scaffold(
      backgroundColor: theme.getPageBackgroundColor(),
      appBar: AppBar(
        titleSpacing: 0,
        toolbarHeight: 62,
        backgroundColor: theme.getSurfaceColor(),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.getTextPrimaryColor()),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            Obx(() => ChatAvatar(
                  name: c.convName.value.isNotEmpty ? c.convName.value : tr('chat'),
                  size: 36,
                )),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() => Text(
                        c.convName.value.isNotEmpty
                            ? c.convName.value
                            : tr('chat'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: theme.getTextPrimaryColor()),
                      )),
                  Obx(() {
                    final sub = c.isGroup
                        ? trParams(
                            'n_participants', {'n': '${c.memberCount.value}'})
                        : (c.participants.isNotEmpty &&
                                c.participants.first.online
                            ? tr('online')
                            : '');
                    if (sub.isEmpty) return const SizedBox.shrink();
                    return Text(
                      sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 11,
                          color: theme.getTextSecondaryColor()),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () =>
                Get.to(() => GroupInfoScreen(conversationId: conversationId)),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'pin') c.togglePin();
              if (v == 'mute') c.toggleMute();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'pin',
                child: Text(c.pinned.value ? tr('unpin') : tr('pin')),
              ),
              PopupMenuItem(
                value: 'mute',
                child: Text(c.muted.value ? tr('unmute') : tr('mute')),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (c.isLoading.value && c.messages.isEmpty) {
                return const ChatSkeleton();
              }
              if (c.hasError.value && c.messages.isEmpty) {
                return _ErrorState(
                    message: c.errorMessage.value, onRetry: c.refreshThread);
              }
              if (c.messages.isEmpty) {
                return Center(
                  child: Text(
                    tr('no_messages_say_hello'),
                    style: TextStyle(color: theme.getTextSecondaryColor()),
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: c.refreshThread,
                child: ListView.builder(
                  controller: c.scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: c.messages.length + 1,
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return Obx(() => c.loadingOlder.value
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            )
                          : const SizedBox.shrink());
                    }
                    final idx = i - 1;
                    final msg = c.messages[idx];
                    final prev = idx == 0 ? null : c.messages[idx - 1];
                    final showDay = prev == null || prev.day != msg.day;
                    return Column(
                      children: [
                        if (showDay) _DayDivider(label: msg.day),
                        MessageBubble(
                          message: msg,
                          showSenderName: c.isGroup && !msg.isMine,
                          authHeaders: c.authHeaders,
                          onLongPress: (m) => _showMessageActions(context, c, m),
                        ),
                      ],
                    );
                  },
                ),
              );
            }),
          ),
          ChatInputBar(controller: c),
        ],
      ),
    );
  }

  void _showMessageActions(
      BuildContext context, ChatController c, ChatMessageModel msg) {
    final theme = ThemeService.instance;
    const emojis = ['👍', '❤️', '😂', '🎉'];
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.getSurfaceColor(),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: theme.getDividerColor(),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: emojis
                  .map((e) => GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          c.toggleReaction(msg, e);
                        },
                        child: Text(e, style: const TextStyle(fontSize: 28)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 6),
            if (msg.isMine && !msg.deleted)
              ListTile(
                leading: Icon(Icons.delete_outline, color: theme.getErrorColor()),
                title: Text(tr('delete')),
                onTap: () {
                  Navigator.pop(context);
                  c.deleteMessage(msg);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DayDivider extends StatelessWidget {
  final String label;
  const _DayDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Divider(color: theme.getDividerColor())),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 11.5, color: theme.getTextSecondaryColor()),
            ),
          ),
          Expanded(child: Divider(color: theme.getDividerColor())),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: Text(tr('retry'))),
          ],
        ),
      ),
    );
  }
}
