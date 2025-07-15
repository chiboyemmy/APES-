import 'dart:io';

import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:get/get.dart';
import 'package:uuid/v4.dart';

import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../data/repositories/chat/chat_repository.dart';
import '../../../data/repositories/user/user_repository.dart';
import '../../../data/services/cloud_storage/firebase_storage_service.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/popups/loaders.dart';
import '../../personalization/controllers/user_controller.dart';
import '../../personalization/models/user_model.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../models/participant_model.dart';

class ChatController extends GetxController {
  static ChatController get instance => Get.find();
  final ChatRepository _chatRepository = Get.put(ChatRepository());

  // Observables
  var chats = <ChatModel>[].obs;
  var messages = <MessageModel>[].obs;
  var isLoading = true.obs;
  var isEditing = false.obs;
  var isSendingAttachment = false.obs;
  var currentChatId = ''.obs;
  var currentChat = ChatModel.empty().obs;
  var admin = UserModel.empty().obs;

  Future<void> fetchSupportChat() async {
    try {
      isLoading.value = true;
      chats.clear();
      final userId = AuthenticationRepository.instance.getUserID;
      await fetchChatsByType(userId, ChatType.support);
      await fetchAdmin();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUserChats() async {
    // Get Current User ID
    final userId = AuthenticationRepository.instance.getUserID;

    // Get Ride Chat
    await fetchChatsByType(userId, ChatType.support);
  }

  Future<ChatModel> getChatsForSpecificRide(String rideId, String driverId) async {
    // get chat list
    await fetchUserChats();

    // Now proceed to find the chat
    final chat = chats.firstWhereOrNull(
      (chat) =>
          chat.referenceId == rideId &&
          chat.participants.any((part) => part.userId == AuthenticationRepository.instance.getUserID) &&
          chat.participants.any((part) => part.userId == driverId),
    );

    if (chat != null) {
      return chat;
    } else {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: 'Unable to find chat');
      return ChatModel.empty();
    }
  }

  // Fetch messages for a specific chat
  Future<void> fetchMessages() async {
    try {
      isLoading.value = true;
      // Fetch Chat if empty
      if (currentChat.value.id.isEmpty) {
        final chat = await _chatRepository.getChatById(currentChatId.value);
        currentChat.value = chat;
      }

      // Fetch Message
      if (currentChat.value.id.isNotEmpty) {
        _chatRepository.listenToMessages(currentChatId.value).listen(
          (newMessages) {
            messages.assignAll(newMessages);
            markMessagesAsSeen(); // Mark messages as seen
          },
        );
      } else {
        messages.value = [];
      }
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: 'Unable to fetch messages');
    } finally {
      isLoading.value = false;
    }
  }

  // Method to mark messages as seen
  void markMessagesAsSeen() async {
    final currentUserId = UserController.instance.user.value.id; // Replace with the actual user ID
    await _chatRepository.markMessagesAsSeen(currentChatId.value, currentUserId);
  }

  // Create a new chat or fetch the existing one
  Future<void> createChat({required ParticipantModel receiver, required ChatType chatType, String? referenceId}) async {
    try {
      isLoading.value = true;
      List<ParticipantModel> participants = [
        ParticipantModel(
          userId: UserController.instance.user.value.id,
          name: UserController.instance.user.value.fullName,
          profileImageURL: UserController.instance.user.value.profilePicture,
        ),
        receiver,
      ];

      final chat = ChatModel(
        id: '',
        participants: participants,
        lastMessageTime: DateTime.now(),
        chatType: chatType,
        participantIds: participants.map((p) => p.userId).toList(),
        referenceId: referenceId ?? '',
      );

      ChatModel? receivedChat = await _chatRepository.createChat(chat);
      if (receivedChat != null) currentChat.value = receivedChat;
      if (receivedChat != null) chats.add(receivedChat);
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch chats based on type (e.g., ride, support)
  Future<void> fetchChatsByType(String currentUserId, ChatType chatType) async {
    try {
      isLoading.value = true;
      List<ChatModel> typedChats = await _chatRepository.getChatsByType(currentUserId, chatType);
      chats.assignAll(typedChats);
    } finally {
      isLoading.value = false;
    }
  }

  // Mark the chat as read
  Future<void> markChatAsRead(String chatId) async {
    await _chatRepository.markChatAsRead(chatId);
  }

  // Send a text message
  Future<void> sendTextMessage(String content) async {
    _sendMessage(content, MessageType.text);
  }

  // Send an image message
  Future<void> sendImageMessage(File imagePath) async {
    try {
      isSendingAttachment.value = true;
      // Close the Bottom Sheet
      Get.back();

      // Upload image to Firebase Storage
      final url = await TFirebaseStorageService.instance.uploadImageFile('Chats/${currentChatId.value}', imagePath, const UuidV4().generate());
      await _sendMessage(url, MessageType.image);
    } catch (e) {
      TLoaders.warningSnackBar(title: 'Oh Snap', message: 'Unable to send message. Please try again.');
    } finally {
      isSendingAttachment.value = false;
    }
  }

  // Generic function to send a message of any type
  Future<void> _sendMessage(String content, MessageType messageType) async {
    // 1. Create a new audio message with 'sending' status
    MessageModel newMessage = MessageModel(
      id: '',
      senderId: AuthenticationRepository.instance.getUserID,
      content: content,
      timestamp: DateTime.now(),
      status: ChatMessageStatus.sent,
      type: messageType,
    );

    // Add message locally so it appears instantly
    messages.insert(0, newMessage);

    // Update Chat Last Message
    updateChatLastMessage(newMessage);

    isEditing.value = false;
    try {
      // Send the message to Firestore with 'sending' status
      final messageId = await _chatRepository.sendMessage(currentChat.value.id, newMessage);

      // 7. Update the message ID locally once it's saved in Firestore
      if (messageId.isNotEmpty) {
        newMessage.id = messageId;

        // 8. Find the index of the message in the local list using the temporary ID
        int messageIndex = ChatController.instance.messages.indexWhere((msg) => msg.id == messageId);

        if (messageIndex != -1) {
          // Update the message in the list with the new ID
          ChatController.instance.messages[messageIndex] = newMessage;
        }

        // 5. Update the last message in the selected chat
        final updatedChat = ChatController.instance.chats.firstWhere(
              (chat) => chat.id == currentChat.value.id,
          orElse: () => ChatModel.empty(),
        );

        updatedChat.lastMessage = newMessage.content;
        updatedChat.lastMessageType = messageType;
        updatedChat.lastMessageTime = DateTime.now();
        updatedChat.lastMessageStatus = ChatMessageStatus.sent;
        updatedChat.lastMessageSenderId = AuthenticationRepository.instance.getUserID;

        // Update the selected chat in the chat list
        int chatIndex = ChatController.instance.chats.indexWhere((chat) => chat.id == updatedChat.id);
        if (chatIndex != -1) {
          ChatController.instance.chats[chatIndex] = updatedChat;
        }
      }

      refresh();
    } catch (e) {
      messages[0].status = ChatMessageStatus.failed;
      TLoaders.warningSnackBar(title: 'Oh Snap', message: 'Unable to send message. Please try again.');
    }
  }

  void updateChatLastMessage(MessageModel message) {
    currentChat.value.lastMessage = message.content;
    currentChat.value.lastMessageType = message.type;
    currentChat.value.lastMessageStatus = message.status;
    currentChat.value.lastMessageTime = message.timestamp;
    currentChat.value.lastMessageSenderId = message.senderId;
  }

  // Method to get Admin
  Future<void> fetchAdmin() async {
    admin.value = await UserRepository.instance.fetchAdmin("admin");
  }
}
