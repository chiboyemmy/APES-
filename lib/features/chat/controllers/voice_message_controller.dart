import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:get/get.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../data/repositories/chat/chat_repository.dart';
import '../../../data/services/cloud_storage/audio_service.dart';
import '../../../utils/constants/enums.dart';
import '../models/message_model.dart';
import 'chat_controller.dart';

class VoiceMessageController extends GetxController {
  Timer? _timer;
  RxBool isPause = false.obs;
  RxInt recordingTime = 0.obs;
  RxBool isRecording = false.obs;
  RecorderController recorderController = RecorderController();
  final CloudAudioStorageService _cloudAudioStorageService = CloudAudioStorageService();

  @override
  void onInit() {
    super.onInit();
    initRecorder();
  }

  Future<void> initRecorder() async {
    try {
      await recorderController.checkPermission();
      recorderController.androidEncoder = AndroidEncoder.aac;
      recorderController.androidOutputFormat = AndroidOutputFormat.aac_adts;
      recorderController.iosEncoder = IosEncoder.kAudioFormatMPEG4AAC;
    } catch (e) {
      // Handle permission errors
      Get.snackbar('Permission Error', 'Failed to get microphone permissions.');
    }
  }

  // Start recording
  Future<void> startRecording() async {
    try {
      await recorderController.record();
      isRecording.value = true;
      isPause.value = false;

      // Start timer to track recording time
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        recordingTime.value++;
      });
    } catch (e) {
      Get.snackbar('Recording Error', 'Failed to start recording.');
    }
  }

  // Pause recording
  Future<void> pauseRecording() async {
    try {
      await recorderController.pause();
      _timer?.cancel();

      isRecording.value = true;
      isPause.value = true;
    } catch (e) {
      Get.snackbar('Pause Error', 'Failed to pause recording.');
    }
  }

  // Stop recording and save audio
  Future<void> stopRecording() async {
    try {
      final chatId = ChatController.instance.currentChat.value.id;
      final senderId = AuthenticationRepository.instance.getUserID;
      if (chatId.isNotEmpty && senderId.isNotEmpty) {
        // Stop the recording and get the local file path
        final path = await recorderController.stop();
        // Stop recording UI updates
        _timer?.cancel();

        if (path != null && path.isNotEmpty) {
          final size = await File(path).length();
          final waveForm = recorderController.waveData;
          final duration = recorderController.recordedDuration;

          // 1. Generate a temporary unique ID using UUID
          String tempId = UniqueKey().toString();

          // 1. Create a new audio message with 'sending' status
          MessageModel newAudioMessage = MessageModel(
            id: tempId,
            senderId: senderId,
            content: path,
            size: size,
            audioDuration: duration,
            audioWaveData: waveForm,
            timestamp: DateTime.now(),
            status: ChatMessageStatus.sending,
            type: MessageType.audio,
          );

          // Add the message to the ChatController's messages list immediately
          ChatController.instance.messages.insert(0, newAudioMessage);

          // Update Chat Last Message
          ChatController.instance.updateChatLastMessage(newAudioMessage);

          // 2. Upload the audio file to storage and get the download URL
          String audioUrl = await _cloudAudioStorageService.saveAudio(chatId, senderId, path);

          // 3. Update the message with the audio URL and set status to 'sent'
          newAudioMessage.content = audioUrl; // Replace the local path with the URL

          // 4. Save the message in Firestore (with the audio URL and updated status)
          final messageId = await ChatRepository.instance.sendMessage(chatId, newAudioMessage);

          // 7. Update the message ID locally once it's saved in Firestore
          if (messageId.isNotEmpty) {
            newAudioMessage.id = messageId;

            // 8. Find the index of the message in the local list using the temporary ID
            int messageIndex = ChatController.instance.messages.indexWhere((msg) => msg.id == tempId);

            if (messageIndex != -1) {
              // Update the message in the list with the new ID
              ChatController.instance.messages[messageIndex] = newAudioMessage;
            }
          }
        }
      }
    } catch (e) {
      Get.snackbar('Stop Error', 'Failed to stop recording.');
    } finally {
      isPause.value = false;
      recordingTime.value = 0;
    }
  }

  // Cancel recording
  Future<void> cancelRecording() async {
    try {
      await stopRecording(); // Optionally pass empty chatId and senderId for canceling
    } catch (e) {
      Get.snackbar('Cancel Error', 'Failed to cancel recording.');
    } finally {
      isRecording.value = false;
      isPause.value = false;
      recordingTime.value = 0;
    }
  }
}
