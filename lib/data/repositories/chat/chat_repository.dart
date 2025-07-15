import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../features/chat/models/chat_model.dart';
import '../../../features/chat/models/message_model.dart';
import '../../../utils/constants/enums.dart';

/// Repository class for vehicle-related operations.
class ChatRepository extends GetxService {
  static ChatRepository get instance => Get.find();
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // Fetch all chats where the current user is a participant
  Future<List<ChatModel>> fetchUserChats(String currentUserId) async {
    final querySnapshot = await db.collection('Chats').where('participantIds', arrayContains: currentUserId).get();
    final chats = querySnapshot.docs.map((doc) => ChatModel.fromFirestore(doc)).toList();
    return chats;
  }

  // Fetch all messages for a specific chat, ordered by timestamp
  Future<List<MessageModel>> fetchMessages(String chatId) async {
    final querySnapshot = await db.collection('Chats').doc(chatId).collection('messages').orderBy('timestamp', descending: true).get();

    final messages = querySnapshot.docs.map((doc) => MessageModel.fromFirestore(doc)).toList();
    return messages;
  }

  // Fetch messages with real-time updates
  Stream<List<MessageModel>> listenToMessages(String chatId) {
    return db
        .collection('Chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true) // Ensure correct order
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => MessageModel.fromFirestore(doc)).toList());
  }

  // Update the status of messages to 'seen'
  Future<void> markMessagesAsSeen(String chatId, String currentUserId) async {
    final messagesRef = db.collection('Chats').doc(chatId).collection('messages');

    final messagesSnapshot = await messagesRef
        .where('senderId', isNotEqualTo: currentUserId)
        .where('status', isEqualTo: 'sent')
        .where('status', isEqualTo: 'delivered')
        .get();

    final batch = db.batch();
    for (final doc in messagesSnapshot.docs) {
      batch.update(doc.reference, {'status': 'seen'});
    }

    await batch.commit();
  }

  // Create a new chat between participants if not exists
  Future<ChatModel?> createChat(ChatModel chat) async {
    try {
      final existingChats = await db
          .collection('Chats')
          .where('participants', arrayContainsAny: [chat.participants[0].userId, chat.participants[1].userId])
          .where('chatType', isEqualTo: chat.chatType.name)
          .get();

      if (existingChats.docs.isNotEmpty) {
        // Return the existing chatId if it exists
        return ChatModel.fromFirestore(existingChats.docs.first);
      } else {
        // Create a new chat
        final result = await db.collection('Chats').add(chat.toFirestore());
        db.collection('Chats').doc(result.id).update({"id": result.id});
        chat.id = result.id;


        return chat;
      }
    } catch (e) {
      return null;
    }
  }

  // Send a new message to a specific chat
  Future<String> sendMessage(String chatId, MessageModel message) async {
    try {
      final result = await db.collection('Chats').doc(chatId).collection('messages').add(message.toMap());

      // Update the last message details in the chat
      await db.collection('Chats').doc(chatId).update({
        'lastMessage': message.content,
        'lastMessageType': message.type.name,
        'lastMessageTime': message.timestamp,
        'lastMessageSenderId': message.senderId,
      });

      return result.id;
    } catch (e) {
      rethrow;
    }
  }

  // Utility method for fetching chat by chat type (e.g., ride or support)
  Future<List<ChatModel>> getChatsByType(String currentUserId, ChatType chatType) async {
    final querySnapshot =
        await db.collection('Chats').where('participantIds', arrayContains: currentUserId).where('chatType', isEqualTo: chatType.name).get();

    return querySnapshot.docs.map((doc) => ChatModel.fromFirestore(doc)).toList();
  }

  // Utility method for fetching chat by chat type (e.g., ride or support)
  Future<ChatModel> getChatById(String chatId) async {
    final querySnapshot = await db.collection('Chats').doc(chatId).get();

    return ChatModel.fromFirestore(querySnapshot);
  }

  // Mark chat as read or seen
  Future<void> markChatAsRead(String chatId) async {
    try {
      await db.collection('Chats').doc(chatId).update({'isRead': true});
    } catch (e) {
      rethrow;
    }
  }
}
