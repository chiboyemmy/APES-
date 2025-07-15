import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:path_provider/path_provider.dart';

import '../../../data/services/local_storage/local_storage_directory.dart';
import '../../../utils/constants/sizes.dart';

class TAudioPlayer extends StatefulWidget {
  final String audioUrl;

  const TAudioPlayer({super.key, required this.audioUrl});

  @override
  TAudioPlayerState createState() => TAudioPlayerState();
}

class TAudioPlayerState extends State<TAudioPlayer> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _totalDuration = Duration.zero;
  Duration _currentPosition = Duration.zero;
  String _localFilePath = '';
  double _downloadProgress = 0.0;
  final LocalStorageService _localStorageService = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _loadAudio();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });
    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      _resetPlayer();
    });
  }

  Future<void> _loadAudio() async {
    _isLoading = true;
    setState(() {});

    // Check if the audio is cached
    final file = await _getCachedFile(widget.audioUrl);
    if (file.existsSync()) {
      // If cached, load the audio from local storage
      _localFilePath = file.path;
      await _audioPlayer.setSourceDeviceFile(_localFilePath);
    } else {
      // If not cached, download and cache the audio
      final downloadedFile =
          await _localStorageService.downloadFileWithProgress(
        fileUrl: widget.audioUrl,
        onProgress: (progress) {
          setState(() {
            _downloadProgress = progress;
          });
        },
      );

      // Once downloaded, load the audio
      _localFilePath = downloadedFile.path;
      await _audioPlayer.setSourceDeviceFile(_localFilePath);
    }

    _isLoading = false;
    setState(() {});
  }

  Future<File> _getCachedFile(String url) async {
    final dir = await getApplicationDocumentsDirectory();
    final filename = url.split('/').last;
    return File('${dir.path}/$filename');
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_currentPosition >= _totalDuration) {
        // Replay if audio completed
        await _audioPlayer.seek(Duration.zero);
      }
      await _audioPlayer.play(DeviceFileSource(_localFilePath));
    }
  }

  Future<void> _onSliderChanged(double value) async {
    final position = Duration(seconds: value.toInt());
    await _audioPlayer.seek(position);
  }

  void _resetPlayer() {
    setState(() {
      _currentPosition = Duration.zero;
      _isPlaying = false;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: TSizes.md, vertical: TSizes.sm),
      child: Row(
        children: [
          _isLoading
              ? CircularProgressIndicator(
                  value: _downloadProgress, color: Colors.white)
              : GestureDetector(
                  onTap: _togglePlayPause,
                  child: Icon(_isPlaying ? Iconsax.pause5 : Iconsax.play5,
                      color: Colors.white, size: TSizes.iconLg - 5)),
          Expanded(
            child: Column(
              children: [
                Slider(
                  min: 0,
                  max: _totalDuration.inSeconds.toDouble(),
                  value: _currentPosition.inSeconds.toDouble(),
                  onChanged: (value) => _onSliderChanged(value),
                ),
                Row(
                  children: [
                    Text(_formatDuration(_currentPosition),
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge!
                            .apply(color: Colors.white)),
                    const Spacer(),
                    Text(_formatDuration(_totalDuration),
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge!
                            .apply(color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
