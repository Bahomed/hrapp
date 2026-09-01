import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../data/local/preferences.dart';
import '../../../services/theme_service.dart';

/// Playback bubble for a voice-note attachment. The attachment URL is
/// participant-gated behind the API's Bearer auth, so the token is attached
/// as a request header.
class VoiceMessagePlayer extends StatefulWidget {
  final String url;
  final bool isMine;

  const VoiceMessagePlayer({super.key, required this.url, required this.isMine});

  @override
  State<VoiceMessagePlayer> createState() => _VoiceMessagePlayerState();
}

class _VoiceMessagePlayerState extends State<VoiceMessagePlayer> {
  final AudioPlayer _player = AudioPlayer();
  final List<StreamSubscription> _subs = [];
  bool _loading = false;
  bool _ready = false;
  bool _playing = false;
  Duration _position = Duration.zero;
  Duration _total = Duration.zero;

  @override
  void initState() {
    super.initState();
    _subs.add(_player.playerStateStream.listen((s) {
      if (!mounted) return;
      setState(() => _playing = s.playing);
      if (s.processingState == ProcessingState.completed) {
        _player.seek(Duration.zero);
        _player.pause();
      }
    }));
    _subs.add(_player.positionStream.listen((p) {
      if (mounted) setState(() => _position = p);
    }));
    _subs.add(_player.durationStream.listen((d) {
      if (mounted) setState(() => _total = d ?? Duration.zero);
    }));
    _preload();
  }

  Future<void> _preload() async {
    try {
      final token = await Preferences().getToken();
      await _player.setUrl(
        widget.url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (mounted) setState(() => _ready = true);
    } catch (_) {
      // Leave _ready false; tapping play retries.
    }
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_loading) return;
    if (!_ready) {
      setState(() => _loading = true);
      await _preload();
      if (mounted) setState(() => _loading = false);
      if (!_ready) return;
    }
    _playing ? await _player.pause() : await _player.play();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    final accent = widget.isMine ? Colors.white : theme.getPrimaryColor();
    final faint = widget.isMine
        ? Colors.white.withValues(alpha: 0.35)
        : theme.getPrimaryColor().withValues(alpha: 0.25);
    final progress = _total.inMilliseconds > 0
        ? (_position.inMilliseconds / _total.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return SizedBox(
      width: 214,
      child: Row(
        children: [
          GestureDetector(
            onTap: _toggle,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: widget.isMine
                    ? Colors.white.withValues(alpha: 0.2)
                    : theme.getPrimaryColor().withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: _loading
                  ? Padding(
                      padding: const EdgeInsets.all(9),
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: accent),
                    )
                  : Icon(
                      _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: accent,
                      size: 22,
                    ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: faint,
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _total > Duration.zero
                      ? '${_fmt(_position)} / ${_fmt(_total)}'
                      : _fmt(_position),
                  style: TextStyle(
                    fontSize: 10,
                    color: widget.isMine
                        ? Colors.white.withValues(alpha: 0.75)
                        : theme.getTextSecondaryColor(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
