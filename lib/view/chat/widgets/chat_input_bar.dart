import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../services/theme_service.dart';
import '../../../utils/translation_helper.dart';
import '../chat_controller.dart';

class ChatInputBar extends StatefulWidget {
  final ChatController controller;

  const ChatInputBar({super.key, required this.controller});

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _text = TextEditingController();
  final AudioRecorder _recorder = AudioRecorder();
  final ImagePicker _picker = ImagePicker();

  bool _recording = false;
  bool _hasText = false;
  int _seconds = 0;
  String? _recordPath;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _text.addListener(() {
      final has = _text.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _text.dispose();
    _recorder.dispose();
    super.dispose();
  }

  void _send() {
    final t = _text.text.trim();
    if (t.isEmpty) return;
    _text.clear();
    widget.controller.sendText(t);
  }

  Future<void> _pickAttachment() async {
    final theme = ThemeService.instance;
    final choice = await showModalBottomSheet<String>(
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
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(tr('photo')),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(tr('camera')),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: Text(tr('file')),
              onTap: () => Navigator.pop(context, 'file'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (choice == null) return;

    if (choice == 'gallery' || choice == 'camera') {
      final x = await _picker.pickImage(
        source: choice == 'camera' ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 80,
      );
      if (x != null) widget.controller.sendFile(File(x.path));
    } else {
      final res = await FilePicker.platform.pickFiles();
      final path = res?.files.single.path;
      if (path != null) widget.controller.sendFile(File(path));
    }
  }

  Future<void> _startRecording() async {
    if (!await _recorder.hasPermission()) return;
    final dir = await getTemporaryDirectory();
    _recordPath =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    _seconds = 0;
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, sampleRate: 44100),
      path: _recordPath!,
    );
    if (!mounted) return;
    setState(() => _recording = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  Future<void> _stopRecording({required bool cancel}) async {
    if (!_recording) return;
    _timer?.cancel();
    final path = await _recorder.stop();
    if (!mounted) return;
    setState(() {
      _recording = false;
      _seconds = 0;
    });
    if (cancel || path == null || path.isEmpty) {
      if (path != null) {
        try {
          await File(path).delete();
        } catch (_) {}
      }
      return;
    }
    final f = File(path);
    if (await f.exists() && await f.length() > 500) {
      widget.controller.sendAudio(path);
    }
  }

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
      decoration: BoxDecoration(
        color: theme.getCardColor(),
        border: Border(top: BorderSide(color: theme.getDividerColor())),
      ),
      child: SafeArea(
        top: false,
        child: _recording ? _recordingBar(theme) : _normalBar(theme),
      ),
    );
  }

  Widget _normalBar(ThemeService theme) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.attach_file, color: theme.getTextSecondaryColor()),
          onPressed: _pickAttachment,
        ),
        IconButton(
          icon: Icon(Icons.crop_free, color: theme.getTextSecondaryColor()),
          tooltip: tr('camera'),
          onPressed: () async {
            final x = await _picker.pickImage(
                source: ImageSource.camera, imageQuality: 80);
            if (x != null) widget.controller.sendFile(File(x.path));
          },
        ),
        Expanded(
          child: TextField(
            controller: _text,
            minLines: 1,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            style: TextStyle(color: theme.getTextPrimaryColor()),
            decoration: InputDecoration(
              hintText: tr('type_a_message'),
              hintStyle: TextStyle(color: theme.getTextSecondaryColor()),
              filled: true,
              fillColor: theme.getSurfaceColor(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: _hasText ? _send : _startRecording,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.getPrimaryColor(),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _hasText ? Icons.send_rounded : Icons.mic_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _recordingBar(ThemeService theme) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _stopRecording(cancel: true),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: theme.getErrorColor().withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.delete_outline_rounded,
                color: theme.getErrorColor(), size: 22),
          ),
        ),
        const SizedBox(width: 10),
        const _PulsingDot(),
        const SizedBox(width: 8),
        Text(
          _fmt(_seconds),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: theme.getTextPrimaryColor(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: _WaveformBars(color: theme.getPrimaryColor())),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => _stopRecording(cancel: false),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: theme.getPrimaryColor(),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
          ),
        ),
      ],
    );
  }
}

class _WaveformBars extends StatefulWidget {
  final Color color;
  const _WaveformBars({required this.color});

  @override
  State<_WaveformBars> createState() => _WaveformBarsState();
}

class _WaveformBarsState extends State<_WaveformBars> {
  final _rng = math.Random();
  late List<double> _bars;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _bars = List.generate(24, (_) => 0.3);
    _timer = Timer.periodic(const Duration(milliseconds: 90), (_) {
      if (!mounted) return;
      setState(() {
        _bars = _bars
            .map((v) => (v + (_rng.nextDouble() - 0.5) * 0.5).clamp(0.08, 1.0))
            .toList();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: _bars
          .map((h) => Container(
                width: 3,
                height: (h * 22).clamp(3.0, 22.0),
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ))
          .toList(),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red.withValues(alpha: 0.4 + 0.6 * _ctrl.value),
        ),
      ),
    );
  }
}
