import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// Audio field that supports importing a file or recording from the microphone.
/// Reports audio path changes via [onChanged] and recording state via [onRecordingStateChanged].
class AudioRecorderField extends StatefulWidget {
  final String? initialAudioPath;
  final ValueChanged<String?> onChanged;
  final ValueChanged<bool>? onRecordingStateChanged;

  const AudioRecorderField({
    super.key,
    this.initialAudioPath,
    required this.onChanged,
    this.onRecordingStateChanged,
  });

  @override
  State<AudioRecorderField> createState() => _AudioRecorderFieldState();
}

class _AudioRecorderFieldState extends State<AudioRecorderField> {
  final AudioRecorder _recorder = AudioRecorder();
  String? _audioPath;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _audioPath = widget.initialAudioPath;
  }

  @override
  void dispose() {
    if (_isRecording) unawaited(_recorder.cancel());
    unawaited(_recorder.dispose());
    super.dispose();
  }

  Future<void> _pickAudio() async {
    if (_isRecording) {
      _showSnack('Arrêtez l\'enregistrement avant d\'importer un audio.', Colors.orange);
      return;
    }
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    final path = result?.files.single.path;
    if (path != null) {
      setState(() => _audioPath = path);
      widget.onChanged(path);
    } else if (result != null && mounted) {
      _showSnack('Impossible de récupérer ce fichier audio.', Colors.red);
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    if (!await _recorder.hasPermission()) {
      if (mounted) _showSnack('L\'accès au microphone est nécessaire pour enregistrer.', Colors.orange);
      return;
    }
    var encoder = AudioEncoder.wav;
    if (!await _recorder.isEncoderSupported(encoder)) encoder = AudioEncoder.aacLc;
    final path = await _buildRecordingPath(encoder);
    await _recorder.start(RecordConfig(encoder: encoder), path: path);
    if (!mounted) return;
    setState(() => _isRecording = true);
    widget.onRecordingStateChanged?.call(true);
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stop();
    if (!mounted) return;
    setState(() {
      _isRecording = false;
      if (path != null && path.isNotEmpty) _audioPath = path;
    });
    widget.onRecordingStateChanged?.call(false);
    if (path != null && path.isNotEmpty) {
      widget.onChanged(path);
    } else {
      _showSnack('Aucun fichier audio n\'a été généré.', Colors.red);
    }
  }

  Future<String> _buildRecordingPath(AudioEncoder encoder) async {
    final dir = await getApplicationDocumentsDirectory();
    final recordings = Directory('${dir.path}${Platform.pathSeparator}recordings');
    if (!await recordings.exists()) await recordings.create(recursive: true);
    final ext = encoder == AudioEncoder.aacLc ? 'm4a' : 'wav';
    return '${recordings.path}${Platform.pathSeparator}question_${DateTime.now().millisecondsSinceEpoch}.$ext';
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: _isRecording ? null : _pickAudio,
          icon: const Icon(Icons.audiotrack),
          label: Text(_audioPath == null ? 'Importer un fichier audio' : 'Audio sélectionné'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _toggleRecording,
          icon: Icon(_isRecording ? Icons.stop_circle : Icons.mic),
          label: Text(_isRecording ? 'Arrêter l\'enregistrement' : 'Enregistrer un audio'),
        ),
        if (_isRecording) ...[
          const SizedBox(height: 10),
          const Text(
            'Enregistrement en cours...',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
          ),
        ],
        if (_audioPath != null && _audioPath!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            'Fichier : ${_audioPath!.split(RegExp(r'[\\/]')).last}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ],
    );
  }
}
