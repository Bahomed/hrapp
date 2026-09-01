import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../../../data/remote/response/chat_models.dart';
import '../../../services/theme_service.dart';
import '../../../utils/translation_helper.dart';
import '../chat_ui_helpers.dart';
import 'voice_message_player.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool showSenderName;
  final Map<String, String> authHeaders;
  final void Function(ChatMessageModel message) onLongPress;

  const MessageBubble({
    super.key,
    required this.message,
    required this.showSenderName,
    required this.authHeaders,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    final isMine = message.isMine;
    final maxWidth = MediaQuery.of(context).size.width * 0.74;

    final radius = isMine
        ? const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(4),
            bottomLeft: Radius.circular(14),
            bottomRight: Radius.circular(14),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(14),
            bottomLeft: Radius.circular(14),
            bottomRight: Radius.circular(14),
          );

    final bubble = GestureDetector(
      onLongPress: message.deleted ? null : () => onLongPress(message),
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: isMine ? theme.getPrimaryColor() : theme.getCardColor(),
          borderRadius: radius,
          border: isMine
              ? null
              : Border.all(color: theme.getDividerColor()),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showSenderName && !message.deleted)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  message.senderName ?? '',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: chatAvatarColor(message.senderName),
                  ),
                ),
              ),
            if (message.deleted)
              Text(
                '🚫 ${tr('message_deleted')}',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                  color: isMine
                      ? Colors.white70
                      : theme.getTextSecondaryColor(),
                ),
              )
            else ...[
              ...message.files.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: _Attachment(
                      file: f,
                      isMine: isMine,
                      authHeaders: authHeaders,
                    ),
                  )),
              if ((message.body ?? '').isNotEmpty)
                Text(
                  message.body!,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.4,
                    color: isMine ? Colors.white : theme.getTextPrimaryColor(),
                  ),
                ),
            ],
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.time,
                  style: TextStyle(
                    fontSize: 9.5,
                    color: isMine
                        ? Colors.white60
                        : theme.getTextSecondaryColor(),
                  ),
                ),
                if (isMine && message.status != null) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 13,
                    color: message.isRead
                        ? const Color(0xFF8ECBFF)
                        : Colors.white60,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 2,
          bottom: message.reactions.isEmpty ? 3 : 0,
          left: isMine ? 48 : 0,
          right: isMine ? 0 : 48,
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            bubble,
            if (message.reactions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 3, bottom: 4),
                child: Wrap(
                  spacing: 4,
                  children: message.reactions
                      .map((r) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.getSurfaceColor(),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: r.mine
                                    ? theme.getPrimaryColor()
                                    : theme.getDividerColor(),
                              ),
                            ),
                            child: Text(
                              '${r.emoji} ${r.count}',
                              style: const TextStyle(fontSize: 11),
                            ),
                          ))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Attachment extends StatelessWidget {
  final ChatFile file;
  final bool isMine;
  final Map<String, String> authHeaders;

  const _Attachment({
    required this.file,
    required this.isMine,
    required this.authHeaders,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;

    if (file.isImage) {
      return GestureDetector(
        onTap: () => _openImageViewer(context),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            file.url,
            headers: authHeaders,
            width: 210,
            height: 190,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : Container(
                    width: 210,
                    height: 190,
                    color: Colors.black12,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
            errorBuilder: (_, __, ___) => Container(
              width: 210,
              height: 90,
              color: Colors.black12,
              child: const Icon(Icons.broken_image),
            ),
          ),
        ),
      );
    }

    if (file.isAudio) {
      return VoiceMessagePlayer(url: file.url, isMine: isMine);
    }

    return GestureDetector(
      onTap: () => _downloadAndOpen(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isMine
              ? Colors.white.withValues(alpha: 0.16)
              : theme.getSurfaceColor(),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insert_drive_file_outlined,
                size: 20,
                color: isMine ? Colors.white : theme.getPrimaryColor()),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    file.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isMine ? Colors.white : theme.getTextPrimaryColor(),
                    ),
                  ),
                  if (file.sizeText.isNotEmpty)
                    Text(
                      file.sizeText,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isMine
                            ? Colors.white70
                            : theme.getTextSecondaryColor(),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openImageViewer(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: Image.network(file.url, headers: authHeaders),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadAndOpen(BuildContext context) async {
    try {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/${file.name}';
      final dio = Dio();
      await dio.download(
        file.url,
        path,
        options: Options(headers: authHeaders),
      );
      await OpenFile.open(path);
    } catch (e) {
      Get.snackbar(
        tr('error'),
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
