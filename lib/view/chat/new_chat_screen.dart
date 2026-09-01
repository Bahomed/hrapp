import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/theme_service.dart';
import '../../utils/translation_helper.dart';
import 'chat_ui_helpers.dart';
import 'new_chat_controller.dart';

class NewChatScreen extends StatelessWidget {
  final bool pickMode;

  const NewChatScreen({super.key, this.pickMode = false});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    final c = Get.put(NewChatController(pickMode: pickMode),
        tag: pickMode ? 'pick' : 'new_chat');

    return Scaffold(
      backgroundColor: theme.getPageBackgroundColor(),
      appBar: AppBar(
        backgroundColor: theme.getSurfaceColor(),
        elevation: 0,
        title: Text(pickMode ? tr('add_participants') : tr('new_chat')),
        actions: [
          if (!pickMode)
            Obx(() => IconButton(
                  tooltip: tr('new_group'),
                  icon: Icon(c.groupMode.value
                      ? Icons.group
                      : Icons.group_outlined),
                  onPressed: () {
                    c.groupMode.toggle();
                    c.selected.clear();
                  },
                )),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: TextField(
              onChanged: c.onQueryChanged,
              style: TextStyle(color: theme.getTextPrimaryColor()),
              decoration: InputDecoration(
                hintText: tr('search_people'),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.getSurfaceColor(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              final isSearch = c.query.value.trim().isNotEmpty;
              final list = isSearch ? c.results : c.team;
              final loading =
                  isSearch ? c.searching.value : c.loadingTeam.value;

              if (loading && list.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (list.isEmpty) {
                return Center(
                  child: Text(
                    isSearch ? tr('no_results') : tr('no_team_members'),
                    style: TextStyle(color: theme.getTextSecondaryColor()),
                  ),
                );
              }

              return ListView.builder(
                itemCount: list.length + (isSearch ? 0 : 1),
                itemBuilder: (context, i) {
                  if (!isSearch && i == 0) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Text(
                        tr('my_team').toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: theme.getTextSecondaryColor(),
                        ),
                      ),
                    );
                  }
                  final u = list[isSearch ? i : i - 1];
                  return Obx(() {
                    final checked = c.selected.contains(u.id);
                    return ListTile(
                      onTap: () => c.onUserTap(u),
                      leading: ChatAvatar(
                        name: u.name,
                        imageUrl:
                            chatImageUrl(u.image, c.workspaceUrl.value),
                        online: u.online,
                        size: 44,
                      ),
                      title: Text(u.name ?? tr('unknown')),
                      subtitle:
                          u.employeeNo != null ? Text(u.employeeNo!) : null,
                      trailing: c.groupMode.value
                          ? Checkbox(
                              value: checked,
                              onChanged: (_) => c.toggleSelected(u.id),
                            )
                          : null,
                    );
                  });
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Obx(() {
        if (!c.groupMode.value || c.selected.isEmpty) {
          return const SizedBox.shrink();
        }
        return FloatingActionButton.extended(
          onPressed: c.busy.value
              ? null
              : () => pickMode
                  ? c.confirmSelection()
                  : _askGroupNameAndCreate(context, c),
          backgroundColor: theme.getPrimaryColor(),
          icon: const Icon(Icons.arrow_forward, color: Colors.white),
          label: Text(
            '${c.selected.length} ${tr('selected')}',
            style: const TextStyle(color: Colors.white),
          ),
        );
      }),
    );
  }

  Future<void> _askGroupNameAndCreate(
      BuildContext context, NewChatController c) async {
    if (c.selected.length < 2) {
      c.confirmSelection();
      return;
    }
    final nameCtrl = TextEditingController();
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: Text(tr('new_group')),
        content: TextField(
          controller: nameCtrl,
          decoration: InputDecoration(hintText: tr('group_name')),
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: Text(tr('cancel'))),
          TextButton(
              onPressed: () => Get.back(result: true),
              child: Text(tr('done'))),
        ],
      ),
    );
    if (ok == true) {
      c.confirmSelection(groupName: nameCtrl.text.trim());
    }
  }
}
