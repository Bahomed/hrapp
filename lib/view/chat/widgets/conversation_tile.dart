import 'package:flutter/material.dart';

import '../../../data/remote/response/chat_models.dart';
import '../../../services/theme_service.dart';
import '../../../utils/translation_helper.dart';
import '../chat_ui_helpers.dart';

class ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final String workspaceUrl;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;
  final VoidCallback onToggleMute;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.workspaceUrl,
    required this.onTap,
    required this.onTogglePin,
    required this.onToggleMute,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    final c = conversation;
    final preview = _previewText();
    final hasUnread = c.unread > 0;

    return InkWell(
      onTap: onTap,
      onLongPress: () => _showActions(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            ChatAvatar(
              name: c.name,
              imageUrl: c.isDirect
                  ? chatImageUrl(c.otherImage, workspaceUrl)
                  : null,
              online: c.isDirect && c.otherOnline,
              size: 52,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          c.name.isNotEmpty ? c.name : tr('chat'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight:
                                hasUnread ? FontWeight.w700 : FontWeight.w600,
                            color: theme.getTextPrimaryColor(),
                          ),
                        ),
                      ),
                      if (c.pinned)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(Icons.push_pin,
                              size: 14, color: theme.getTextSecondaryColor()),
                        ),
                      if (c.muted)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(Icons.notifications_off,
                              size: 14, color: theme.getTextSecondaryColor()),
                        ),
                      const SizedBox(width: 6),
                      Text(
                        c.lastMessage?.createdAt ?? '',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: hasUnread
                              ? theme.getPrimaryColor()
                              : theme.getTextSecondaryColor(),
                          fontWeight:
                              hasUnread ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: hasUnread
                                ? theme.getTextPrimaryColor()
                                : theme.getTextSecondaryColor(),
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          constraints: const BoxConstraints(minWidth: 20),
                          decoration: BoxDecoration(
                            color: theme.getPrimaryColor(),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            c.unread > 99 ? '99+' : '${c.unread}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _previewText() {
    final lm = conversation.lastMessage;
    if (lm == null) return tr('say_hello');
    final prefix = lm.isMine ? '${tr('you')}: ' : '';
    if (lm.body.isNotEmpty) return '$prefix${lm.body}';
    if (lm.hasFile) return '$prefix📎 ${tr('attachment')}';
    return tr('say_hello');
  }

  void _showActions(BuildContext context) {
    final theme = ThemeService.instance;
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
            const SizedBox(height: 8),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: theme.getDividerColor(),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(conversation.pinned
                  ? Icons.push_pin_outlined
                  : Icons.push_pin),
              title: Text(conversation.pinned ? tr('unpin') : tr('pin')),
              onTap: () {
                Navigator.pop(context);
                onTogglePin();
              },
            ),
            ListTile(
              leading: Icon(conversation.muted
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_off_outlined),
              title: Text(conversation.muted ? tr('unmute') : tr('mute')),
              onTap: () {
                Navigator.pop(context);
                onToggleMute();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
