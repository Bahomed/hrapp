import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../services/theme_service.dart';

/// Shimmer placeholder shown while the first page of messages loads.
class ChatSkeleton extends StatelessWidget {
  const ChatSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    final base = theme.isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey.shade300;
    final highlight =
        theme.isDarkMode ? const Color(0xFF3A3A3A) : Colors.grey.shade100;

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      itemCount: 7,
      itemBuilder: (_, i) {
        final isMine = i.isOdd;
        final width = 120.0 + (i % 3) * 46.0;
        return Shimmer.fromColors(
          baseColor: base,
          highlightColor: highlight,
          child: Align(
            alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(
                top: 5,
                bottom: 5,
                left: isMine ? 64 : 0,
                right: isMine ? 0 : 64,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isMine) ...[
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Container(
                    width: width,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
