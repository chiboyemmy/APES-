import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../data/services/local_storage/local_storage_directory.dart';
import '../../../utils/constants/sizes.dart';

class CustomAudioMessageWidget extends StatefulWidget {
  final String audioFileUrl; // URL for downloading the audio file
  final bool isSender;
  final int messageWidth;
  final List<double>?
      preExtractedWaveformData; // Pre-extracted waveform data (optional)

  const CustomAudioMessageWidget({
    super.key,
    required this.audioFileUrl,
    required this.isSender,
    required this.messageWidth,
    this.preExtractedWaveformData, // Pre-extracted waveform data
  });

  @override
  CustomAudioMessageWidgetState createState() =>
      CustomAudioMessageWidgetState();
}

class CustomAudioMessageWidgetState extends State<CustomAudioMessageWidget> {
  late String _filePath;
  bool _isPlaying = false;
  bool _isDownloaded = false;
  bool _isDownloading = false;
  List<double>? _waveformData;
  double _downloadProgress = 0.0;
  late final int _numberOfSamples;
  final PlayerController _playerController = PlayerController();
  final LocalStorageService _localStorageService =
      LocalStorageService(); // Local storage service

  @override
  void initState() {
    super.initState();
    _initializeFilePath();
    _calculateNumberOfSamples();
    _loadOrExtractWaveformData();
    _checkAndDownloadFile();
  }

  Future<void> _initializeFilePath() async {
    _filePath = await LocalStorageService().getFilePath(widget.audioFileUrl);
  }

  Future<void> _initializePlayer() async {
    try {
      _playerController.onCompletion.listen((_) async {
        setState(() {
          // Reset the player when the audio is completed
          _isPlaying = false;
          _resetPlayer();
        });

        await _playerController.preparePlayer(
          path: _filePath,
          shouldExtractWaveform: true,
          noOfSamples: _numberOfSamples,
          volume: 1.0,
        );
      });

      await _playerController.preparePlayer(
        path: _filePath,
        shouldExtractWaveform: true,
        noOfSamples: _numberOfSamples,
        volume: 1.0,
      );
    } catch (e) {
      print('Error initializing player: $e');
    }
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _playerController.pausePlayer();
    } else {
      await _playerController.startPlayer();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (_isDownloading)
          Center(child: CircularProgressIndicator(value: _downloadProgress)),
        if (_isDownloaded)
          IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white),
              onPressed: _togglePlay),
        if (!_isDownloaded && !_isDownloading)
          IconButton(
              icon: const Icon(Iconsax.voice_cricle, color: Colors.white),
              onPressed: _downloadFile),
        if (_isDownloaded)
          Expanded(
            child: AudioFileWaveforms(
              playerController: _playerController,
              waveformType: WaveformType.fitWidth,
              waveformData: _waveformData ?? [],
              margin: const EdgeInsets.only(right: TSizes.spaceBtwItems),
              size: Size(widget.messageWidth.toDouble(), 60),
              animationDuration: const Duration(milliseconds: 1000),
            ),
          ),
      ],
    );
  }

  Future<void> _resetPlayer() async {
    try {
      // Stop the player and reset to the start
      await _playerController.seekTo(0);
      // await _playerController.stopPlayer();
    } catch (e) {
      print('Error resetting player: $e');
    }
  }

  Future<void> _loadOrExtractWaveformData() async {
    try {
      // Check if pre-extracted waveform data is provided
      if (widget.preExtractedWaveformData != null) {
        setState(() {
          _waveformData = widget.preExtractedWaveformData!;
        });
      } else {
        // Try loading waveform data from local storage
        final storedWaveformData =
            await _localStorageService.loadWaveformData(widget.audioFileUrl);

        if (storedWaveformData != null) {
          // If stored waveform data exists, use it
          setState(() {
            _waveformData = storedWaveformData;
          });
        } else {
          // If no stored or pre-extracted data exists, extract and save it
          _waveformData = await _playerController.extractWaveformData(
            path: widget.audioFileUrl,
            noOfSamples: _numberOfSamples,
          );

          if (_waveformData != null) {
            // Save the extracted waveform data locally
            await _localStorageService.saveWaveformDataLocally(
                _waveformData!, widget.audioFileUrl);

            setState(() {
              _waveformData = _waveformData!;
            });
          } else {
            throw Exception("Waveform data extraction failed");
          }
        }
      }
    } catch (e) {
      print('Error loading or extracting waveform data: $e');
    }
  }

  void _calculateNumberOfSamples() {
    // Adjust the number of samples based on the width
    // Determine the number of samples to fit the widget width
    const double sampleWidth = 6.8;
    _numberOfSamples = (widget.messageWidth / sampleWidth).round();
    if (_numberOfSamples < 1) {
      _numberOfSamples = 1; // Ensure at least one sample
    }
  }

  Future<void> _checkAndDownloadFile() async {
    if (await LocalStorageService().fileExists(widget.audioFileUrl)) {
      setState(() => _isDownloaded = true);
      _initializePlayer();
    } else {
      await _downloadFile();
    }
  }

  Future<void> _downloadFile() async {
    setState(() => _isDownloading = true);

    try {
      await LocalStorageService().downloadFileWithProgress(
        fileUrl: widget.audioFileUrl,
        onProgress: (progress) => setState(() => _downloadProgress = progress),
      );
      setState(() => _isDownloaded = true);
      _initializePlayer();
    } catch (e) {
      // Handle download errors
      print('Error downloading file: $e');
    } finally {
      setState(() => _isDownloading = false);
    }
  }
}
