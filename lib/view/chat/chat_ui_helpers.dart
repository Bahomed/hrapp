import 'package:flutter/material.dart';

/// Initials for an avatar: first letter of the first two words, upper-cased.
/// "Aman Ullah" -> "AU", "DIT 1st Sem Girls" -> "D1", "" -> "?".
String chatInitials(String? name) {
  final parts = (name ?? '')
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    final p = parts.first;
    return (p.length >= 2 ? p.substring(0, 2) : p).toUpperCase();
  }
  return (parts[0].characters.first + parts[1].characters.first).toUpperCase();
}

const List<Color> _avatarPalette = [
  Color(0xFF4F7AFF),
  Color(0xFF00B8A9),
  Color(0xFFF6A623),
  Color(0xFFE0567B),
  Color(0xFF7B68EE),
  Color(0xFF26C281),
  Color(0xFFEB5757),
  Color(0xFF2D9CDB),
];

Color chatAvatarColor(String? seed) {
  final s = (seed ?? '').trim();
  if (s.isEmpty) return _avatarPalette.first;
  var hash = 0;
  for (final code in s.codeUnits) {
    hash = (hash * 31 + code) & 0x7fffffff;
  }
  return _avatarPalette[hash % _avatarPalette.length];
}

/// Resolve an image path from the API (which may be relative) to an absolute URL.
String? chatImageUrl(String? raw, String workspaceUrl) {
  if (raw == null || raw.trim().isEmpty) return null;
  final v = raw.trim();
  if (v.startsWith('http://') || v.startsWith('https://')) return v;
  final base = workspaceUrl.endsWith('/')
      ? workspaceUrl.substring(0, workspaceUrl.length - 1)
      : workspaceUrl;
  return v.startsWith('/') ? '$base$v' : '$base/$v';
}

class ChatAvatar extends StatelessWidget {
  final String? name;
  final String? imageUrl;
  final double size;
  final bool online;

  const ChatAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 46,
    this.online = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = chatAvatarColor(name);
    Widget avatar = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg.withValues(alpha: 0.18), shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: (imageUrl != null && imageUrl!.isNotEmpty)
          ? Image.network(
              imageUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _initials(bg),
            )
          : _initials(bg),
    );

    if (!online) return avatar;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: size * 0.28,
            height: size * 0.28,
            decoration: BoxDecoration(
              color: const Color(0xFF26C281),
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).cardColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _initials(Color bg) => Text(
        chatInitials(name),
        style: TextStyle(
          color: bg,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.36,
        ),
      );
}
