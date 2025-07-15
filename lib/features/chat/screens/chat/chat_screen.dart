import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:t_utils/common/widgets/containers/t_container.dart';

import '../../../../common/widgets/audio/audio_player.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../personalization/controllers/user_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../controllers/voice_message_controller.dart';
import '../../models/chat_model.dart';
import 'widgets/audio_widget.dart';

class ChatScreen extends StatelessWidget {
  final ChatController chatController = Get.put(ChatController());
  final TextEditingController _textController = TextEditingController();
  final VoiceMessageController audioController = Get.put(VoiceMessageController());

  ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    chatController.currentChat.value = Get.arguments ?? ChatModel.empty();
    chatController.currentChatId.value = Get.parameters['id'] ?? '';
    final sender = UserController.instance.user.value;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatController.fetchMessages();
    });


    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Obx(() {
        if (chatController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else {
          // Map messages to the format required by flutter_chat_ui
          List<types.Message> messages = chatController.messages.map((message) {
            // Check the message type and map it to the appropriate flutter_chat_ui message type
            switch (message.type) {
              case types.MessageType.text:
                return types.TextMessage(
                  id: message.id,
                  showStatus: true,
                  text: message.content,
                  type: types.MessageType.text,
                  author: types.User(id: message.senderId),
                  createdAt: message.timestamp.millisecondsSinceEpoch,
                  status: mapMessageStatus(message.status),
                );
              case types.MessageType.audio:
                return types.AudioMessage(
                  id: message.id,
                  showStatus: true,
                  uri: message.content,
                  // Assuming content contains the audio file URL/path
                  size: message.size ?? 10,
                  // Replace with actual audio file size if needed
                  duration: message.audioDuration ?? const Duration(seconds: 5),
                  // Replace with actual duration if available
                  waveForm: message.audioWaveData,
                  name: 'Audio',
                  // Replace with actual name if needed
                  type: types.MessageType.audio,
                  author: types.User(id: message.senderId),
                  createdAt: message.timestamp.millisecondsSinceEpoch,
                  status: mapMessageStatus(message.status),
                );
              case types.MessageType.image:
                return types.ImageMessage(
                  id: message.id,
                  showStatus: true,
                  uri: message.content,
                  // Assuming content contains the image URL/path
                  name: 'Image',
                  // You can set the name if needed
                  size: 10,
                  // Replace with the actual image file size if needed
                  type: types.MessageType.image,
                  author: types.User(id: message.senderId),
                  createdAt: message.timestamp.millisecondsSinceEpoch,
                  status: mapMessageStatus(message.status),
                );
              case types.MessageType.custom:
                throw UnimplementedError();
              case types.MessageType.file:
                throw UnimplementedError();
              case types.MessageType.system:
                throw UnimplementedError();
              case types.MessageType.unsupported:
                throw UnimplementedError();
              case types.MessageType.video:
                throw UnimplementedError();
            }
          }).toList();

          return Stack(
            children: [
              Positioned.fill(
                child: Chat(
                  messages: messages,
                  onSendPressed: (partialText) {},
                  user: types.User(id: sender.id, imageUrl: sender.profilePicture, role: types.Role.user, firstName: sender.firstName, lastName: sender.lastName),
                  showUserNames: true,
                  showUserAvatars: true,
                  usePreviewData: true,
                  customBottomWidget: _buildCustomInputToolbar(context),
                  textMessageOptions: const TextMessageOptions(isTextSelectable: true),
                  audioMessageBuilder: (types.AudioMessage message, {required int messageWidth}) {
                    return TAudioPlayer(audioUrl: message.uri);
                  },
                ),
              ),
            ],
          );
        }
      }),
    );
  }

  Widget _buildCustomInputToolbar(context) {
    return TContainer(
      margin: const EdgeInsets.all(TSizes.defaultSpace / 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      backgroundColor: const Color(0xff1d1c21),
      child: Column(
        children: [
          if (audioController.isRecording.value) VoiceMessageRecorder(),
          Row(
            children: [
              /// Attachments OR Trash
              // if (audioController.isRecording.value)
              //   IconButton(
              //     icon: const Icon(Iconsax.trash, color: Colors.red),
              //     onPressed: () => audioController.cancelRecording(),
              //   ),
              // if (!audioController.isRecording.value)
              //   if (chatController.isSendingAttachment.value)
              //     const CircularProgressIndicator(color: Colors.white, strokeWidth: 1)
              //   else
              //     IconButton(
              //       icon: const Icon(Iconsax.attach_circle, color: Colors.grey),
              //       onPressed: _handleAttachmentPressed, // Handle attachment logic
              //     ),

              /// TextField OR Recorder Bar
              if (audioController.isRecording.value)
                Expanded(
                  child: Center(
                    child: audioController.isPause.value
                        ? IconButton(onPressed: () => audioController.startRecording(), icon: const Icon(Iconsax.play))
                        : IconButton(onPressed: () => audioController.pauseRecording(), icon: const Icon(Iconsax.pause)),
                  ),
                ),
              if (!audioController.isRecording.value)
                Expanded(
                  child: TextFormField(
                    controller: _textController,
                    textInputAction: chatController.isEditing.value ? TextInputAction.send : TextInputAction.done,

                    // Text editing controller
                    style: Theme.of(context).textTheme.bodyLarge!.apply(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      fillColor: const Color(0xff1d1c21),
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      errorBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                    ),
                    onChanged: (value) => value.isEmpty ? chatController.isEditing.value = false : chatController.isEditing.value = true,
                    onFieldSubmitted: (value) {
                      // Send the message when the user presses enter
                      chatController.sendTextMessage(value);
                      _textController.clear();
                    },
                  ),
                ),

              /// Send Icon

             // if (chatController.isEditing.value || audioController.isRecording.value)
              if (chatController.isEditing.value && _textController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Iconsax.send_1, color: Colors.blue),
                  onPressed: () {
                    if (_textController.text.isNotEmpty) {
                      chatController.sendTextMessage(_textController.text);
                      _textController.clear();
                    }
                    if (audioController.isRecording.value) {
                      audioController.stopRecording();
                      audioController.isRecording.value = false;
                    }
                  },
                ),

              /// Mic Recording
              // if (!chatController.isEditing.value && !audioController.isRecording.value)
              //   GestureDetector(
              //     onTapDown: (_) => audioController.startRecording(),
              //     child: const Icon(Iconsax.microphone_2, color: Colors.grey),
              //   ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: Get.context!,
      builder: (BuildContext context) => SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              runAlignment: WrapAlignment.start,
              spacing: TSizes.spaceBtwItems,
              children: [
                GestureDetector(
                  onTap: () async {
                    // Handle picking an image from the camera
                    final pickedImage = await ImagePicker().pickImage(source: ImageSource.camera);
                    if (pickedImage != null) {
                      File? croppedImage = await _cropImage(File(pickedImage.path));
                      if (croppedImage != null) {
                        chatController.sendImageMessage(croppedImage);
                      }
                    }
                  },
                  child: TContainer(
                    backgroundColor: TColors.dark,
                    child: Column(
                      children: [
                        const Icon(Iconsax.camera, color: Colors.grey),
                        const Gap(TSizes.spaceBtwItems / 2),
                        Text('Camera', style: Theme.of(context).textTheme.labelLarge!.apply(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    // Handle picking an image from the camera
                    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
                    if (pickedImage != null) {
                      File? croppedImage = await _cropImage(File(pickedImage.path));
                      if (croppedImage != null) {
                        chatController.sendImageMessage(croppedImage);
                      }
                    }
                  },
                  child: TContainer(
                    backgroundColor: TColors.dark,
                    child: Column(
                      children: [
                        const Icon(Iconsax.image, color: Colors.grey),
                        const Gap(TSizes.spaceBtwItems / 2),
                        Text('Gallery', style: Theme.of(context).textTheme.labelLarge!.apply(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Gap(TSizes.defaultSpace),
          ],
        ),
      ),
    );
  }

  Future<File?> _cropImage(File imageFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
          ],
        ),
        IOSUiSettings(
          title: 'Cropper',
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
          ],
        ),
      ],
    );

    return croppedFile != null ? File(croppedFile.path) : null;
  }

  // Mapping ChatMessageStatus to types.Status
  types.Status mapMessageStatus(ChatMessageStatus messageStatus) {
    switch (messageStatus) {
      case ChatMessageStatus.failed:
        return types.Status.error;
      case ChatMessageStatus.read:
        return types.Status.seen;
      case ChatMessageStatus.delivered:
        return types.Status.delivered;
      case ChatMessageStatus.sent:
        return types.Status.sent;
      case ChatMessageStatus.sending:
        return types.Status.sending;
      }
  }
}
