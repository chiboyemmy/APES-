import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/images/t_circular_image.dart';
import '../../../../routes/routes.dart';
import '../../../../utils/constants/enums.dart';
import '../../../personalization/controllers/user_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../models/chat_model.dart';
import '../../models/participant_model.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatController chatController = Get.put(ChatController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatController.fetchSupportChat();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [

          // Check if there is support chat exist
          Obx(() => chatController.chats.isEmpty ? IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final receiver = ParticipantModel(userId: chatController.admin.value.id, name: chatController.admin.value.fullName, profileImageURL: chatController.admin.value.profilePicture);
              await chatController.createChat(receiver: receiver, chatType: ChatType.support,);
            },
          ): const SizedBox.shrink())
        ],
      ),
      body: Obx(() {
        if (chatController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (chatController.chats.isEmpty) {
          return const Center(child: Text('No chats available'));
        } else {
          return ListView.builder(
            itemCount: chatController.chats.length,
            itemBuilder: (context, index) {
              ChatModel chat = chatController.chats[index];
              ParticipantModel otherParticipant =
                  chat.participants.where((user) => user.userId != UserController.instance.user.value.id).firstOrNull  ??
                      ParticipantModel(userId: '', name: '', profileImageURL: '');

              return ListTile(
                leading: otherParticipant.profileImageURL.isNotEmpty
                    ? TCircularImage(
                        image: otherParticipant.profileImageURL,
                        isNetworkImage: true,
                        padding: 0,
                        width: 40,
                        height: 40,
                      )
                    : CircleAvatar(child: Text(otherParticipant.name[0])),
                title: Text(
                  otherParticipant.name.isNotEmpty
                      ? otherParticipant.name
                      : chat.chatType == ChatType.support
                          ? 'Support'
                          : 'Driver',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                subtitle: Text(
                  chat.lastMessageType == MessageType.text
                      ? chat.lastMessage.isNotEmpty
                          ? chat.lastMessage
                          : 'No recent message'
                      : chat.lastMessageType == MessageType.audio
                          ? 'Audio Message'
                          : chat.lastMessageType == MessageType.image
                              ? 'Image'
                              : '',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                trailing: Text(
                  TimeOfDay.fromDateTime(chat.lastMessageTime).format(context),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                onTap: () {
                  // Navigate to the chat screen
                  Get.toNamed(TRoutes.chat, parameters: {'id': chat.id});
                },
              );
            },
          );
        }
      }),
    );
  }
}
