import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';

import '../../../utils/constants/enums.dart';
import 'message_model.dart';
import 'participant_model.dart';

class ChatModel {
  String id;
  List<ParticipantModel> participants; // List of ParticipantModel instances
  String lastMessage;
  MessageType lastMessageType;
  DateTime lastMessageTime;
  ChatMessageStatus lastMessageStatus;
  bool isGroupChat;
  String lastMessageSenderId;
  ChatType chatType;
  List<String> participantIds; // List of participant userIds for querying
  String referenceId;

  ChatModel({
    required this.id,
    required this.participants,
    required this.participantIds, // New field
    this.lastMessageType = MessageType.text,
    this.lastMessage = '',
    this.lastMessageStatus = ChatMessageStatus.failed,
    required this.lastMessageTime,
    this.isGroupChat = false,
    this.lastMessageSenderId = '',
    required this.chatType,
    required this.referenceId,
  });

  // Convert Chat model to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'participants': participants.map((p) => p.toFirestore()).toList(),
      'participantIds': participantIds, // Save the list of userIds
      'lastMessageType': lastMessageType.name,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'isGroupChat': isGroupChat,
      'lastMessageStatus': lastMessageStatus.name,
      'lastMessageSenderId': lastMessageSenderId,
      'chatType': chatType.name,
      'referenceId': referenceId,
    };
  }

  factory ChatModel.empty() => ChatModel(id: '', participants: [], participantIds: [], lastMessageTime: DateTime.now(), chatType: ChatType.support, referenceId: '');

  // Convert Firestore document to Chat model
  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return ChatModel(
      id: doc.id,
      participants: (data.containsKey('participants')
          ? (data['participants'] as List).map((participantData) => ParticipantModel.fromFirestore(participantData)).toList()
          : []),
      participantIds: List<String>.from(data['participantIds']), // Fetch userIds
      lastMessage: data.containsKey('lastMessage') ? data['lastMessage'] : '',
      lastMessageType: data.containsKey('lastMessageType') ? MessageModel.messageTypeFromString(data['lastMessageType']) : MessageType.text,
      lastMessageTime: data.containsKey('lastMessageTime') ? data['lastMessageTime'].toDate() : DateTime.now(),
      lastMessageStatus: data.containsKey('lastMessageStatus') ? messageStatusFromString(data['lastMessageStatus']) : ChatMessageStatus.failed,
      isGroupChat: data.containsKey('isGroupChat') ? data['isGroupChat'] : false,
      lastMessageSenderId: data.containsKey('lastMessageSenderId') ? data['lastMessageSenderId'] : '',
      chatType: data.containsKey('chatType') ? chatTypeFromString(data['chatType']) : ChatType.support, // Default to 'ride'
      referenceId: data.containsKey('referenceId') ? data['referenceId'] : '',
    );
  }
}

ChatMessageStatus messageStatusFromString(String messageStatus) {
  switch (messageStatus) {
    case 'read':
      return ChatMessageStatus.read;
    case 'delivered':
      return ChatMessageStatus.delivered;
    case 'sent':
      return ChatMessageStatus.sent;
    case 'failed':
      return ChatMessageStatus.failed;
    default:
      return ChatMessageStatus.failed;
  }
}

ChatType chatTypeFromString(String chatType) {
  switch (chatType) {
    case 'support':
      return ChatType.support;
    default:
      return ChatType.support; // Default
  }
}
