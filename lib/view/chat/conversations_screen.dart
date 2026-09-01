import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/local/preferences.dart';
import '../../services/theme_service.dart';
import '../../utils/translation_helper.dart';
import 'conversations_controller.dart';
import 'new_chat_screen.dart';
import 'widgets/conversation_tile.dart';

class ConversationsScreen extends StatelessWidget {
  /// When true the screen is hosted inside the Home bottom-nav Scaffold, so it
  /// drops its own AppBar (the Home AppBar stays visible above it).
  final bool embedded;

  const ConversationsScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    final c = Get.put(ConversationsController());

    final fab = FloatingActionButton(
      backgroundColor: theme.getPrimaryColor(),
      onPressed: () => Get.to(() => const NewChatScreen()),
      child: const Icon(Icons.edit_outlined, color: Colors.white),
    );

    final body = _buildBody(context, theme, c);

    // Hosted inside the Home bottom-nav Scaffold: no nested Scaffold / AppBar,
    // just fill the area and keep clear of the curved nav bar.
    if (embedded) {
      return Container(
        color: theme.getPageBackgroundColor(),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 70),
                child: body,
              ),
              Positioned(right: 16, bottom: 84, child: fab),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.getPageBackgroundColor(),
      appBar: AppBar(
        backgroundColor: theme.getSurfaceColor(),
        elevation: 0,
        title: Text(tr('messages')),
      ),
      floatingActionButton: fab,
      body: body,
    );
  }

  Widget _buildBody(
      BuildContext context, ThemeService theme, ConversationsController c) {
    return Obx(() {
        if (c.isLoading.value && c.conversations.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.hasError.value && c.conversations.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 40, color: Colors.redAccent),
                  const SizedBox(height: 12),
                  Text(c.errorMessage.value, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  OutlinedButton(
                      onPressed: c.reload, child: Text(tr('retry'))),
                ],
              ),
            ),
          );
        }
        if (c.conversations.isEmpty) {
          return RefreshIndicator(
            onRefresh: c.reload,
            child: ListView(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                Center(
                  child: Text(
                    tr('no_conversations'),
                    style: TextStyle(color: theme.getTextSecondaryColor()),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: c.reload,
          child: FutureBuilder<String>(
            future: Preferences().getWorkspaceUrl(),
            builder: (context, snap) {
              final workspaceUrl = snap.data ?? '';
              return ListView.separated(
                itemCount: c.conversations.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  indent: 80,
                  color: theme.getDividerColor(),
                ),
                itemBuilder: (context, i) {
                  final conv = c.conversations[i];
                  return ConversationTile(
                    conversation: conv,
                    workspaceUrl: workspaceUrl,
                    onTap: () => c.openConversation(conv),
                    onTogglePin: () => c.togglePin(conv),
                    onToggleMute: () => c.toggleMute(conv),
                  );
                },
              );
            },
          ),
        );
      });
  }
}
