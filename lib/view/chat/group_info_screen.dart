import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/theme_service.dart';
import '../../utils/translation_helper.dart';
import 'chat_ui_helpers.dart';
import 'group_info_controller.dart';

class GroupInfoScreen extends StatelessWidget {
  final int conversationId;

  const GroupInfoScreen({super.key, required this.conversationId});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    final tag = 'group_info_$conversationId';
    final c = Get.isRegistered<GroupInfoController>(tag: tag)
        ? Get.find<GroupInfoController>(tag: tag)
        : Get.put(GroupInfoController(conversationId), tag: tag);

    return Scaffold(
      backgroundColor: theme.getPageBackgroundColor(),
      appBar: AppBar(
        backgroundColor: theme.getSurfaceColor(),
        elevation: 0,
        title: Text(tr('participants')),
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          children: [
            const SizedBox(height: 16),
            Center(
              child: ChatAvatar(
                name: c.name.value.isNotEmpty ? c.name.value : tr('chat'),
                size: 80,
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                c.name.value.isNotEmpty ? c.name.value : tr('chat'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: theme.getTextPrimaryColor(),
                ),
              ),
            ),
            Center(
              child: Text(
                trParams('n_participants', {'n': '${c.memberCount.value}'}),
                style: TextStyle(color: theme.getTextSecondaryColor()),
              ),
            ),
            const SizedBox(height: 12),
            if (c.isGroup) ...[
              if (c.isCreator.value)
                ListTile(
                  leading: const Icon(Icons.drive_file_rename_outline),
                  title: Text(tr('rename_group')),
                  onTap: c.rename,
                ),
              if (c.isCreator.value)
                ListTile(
                  leading: const Icon(Icons.person_add_alt),
                  title: Text(tr('add_participants')),
                  onTap: c.addParticipants,
                ),
              ListTile(
                leading: Icon(Icons.logout, color: theme.getErrorColor()),
                title: Text(tr('leave_group'),
                    style: TextStyle(color: theme.getErrorColor())),
                onTap: c.leave,
              ),
              const Divider(),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                tr('participants').toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: theme.getTextSecondaryColor(),
                ),
              ),
            ),
            ...c.participants.map((p) => ListTile(
                  leading: ChatAvatar(
                    name: p.name,
                    imageUrl: chatImageUrl(p.image, c.workspaceUrl.value),
                    online: p.online,
                    size: 42,
                  ),
                  title: Text(p.name ?? tr('unknown')),
                  subtitle: Text(
                    p.online ? tr('online') : (p.employeeNo ?? ''),
                    style: TextStyle(
                      color: p.online
                          ? const Color(0xFF26C281)
                          : theme.getTextSecondaryColor(),
                    ),
                  ),
                )),
            if (c.sharedFiles.isNotEmpty) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  tr('shared_files').toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: theme.getTextSecondaryColor(),
                  ),
                ),
              ),
              ...c.sharedFiles.map((f) => ListTile(
                    leading: Icon(
                      f.isImage
                          ? Icons.image_outlined
                          : f.isAudio
                              ? Icons.mic_none
                              : Icons.insert_drive_file_outlined,
                      color: theme.getPrimaryColor(),
                    ),
                    title: Text(f.name,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: f.sizeText.isNotEmpty ? Text(f.sizeText) : null,
                  )),
            ],
            const SizedBox(height: 24),
          ],
        );
      }),
    );
  }
}
