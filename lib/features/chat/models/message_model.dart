import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';

import '../../../utils/constants/enums.dart';

class MessageModel {
  String id;
  String senderId;
  String content;
  DateTime timestamp;
  ChatMessageStatus status;
  MessageType type;
  String? mediaUrl; // URL for voice/image media
  String? replyToMessageId; // If this is a reply
  String? replyToMessageContent; // Content of the message being replied to
  MessageType? replyToMessageType; // Type of the message being replied to
  int? size; // Size of the audio file in bytes
  Duration? audioDuration; // Duration of the audio file
  List<double>? audioWaveData; // Audio wave data for visualization

  MessageModel({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.status,
    required this.type,
    this.mediaUrl,
    this.replyToMessageId,
    this.replyToMessageContent,
    this.replyToMessageType,
    this.size,
    this.audioDuration,
    this.audioWaveData,
  });

  // Convert Firestore data to MessageModel
  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      senderId: data['senderId'],
      content: data['content'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      status: messageStatusFromString(data['status']),
      type: messageTypeFromString(data['type']),
      mediaUrl: data['mediaUrl'],
      replyToMessageId: data['replyToMessageId'],
      replyToMessageContent: data['replyToMessageContent'],
      replyToMessageType: data.containsKey('replyToMessageType') ? messageTypeFromString(data['replyToMessageType'] ?? MessageType.text.name) : MessageType.text,
      size: data['size'], // Add this line
      audioDuration: data['audioDuration'] != null ? Duration(milliseconds: data['audioDuration']) : null, // Add this line
      audioWaveData: data['audioWaveData'] != null ? List<double>.from(data['audioWaveData']) : null, // Add this line
    );
  }

  // Convert MessageModel to Firestore format
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status.name,
      'type': type.name,
      'mediaUrl': mediaUrl,
      'replyToMessageId': replyToMessageId,
      'replyToMessageContent': replyToMessageContent,
      'replyToMessageType': replyToMessageType?.name,
      'size': size, // Add this line
      'audioDuration': audioDuration?.inMilliseconds, // Add this line
      'audioWaveData': audioWaveData, // Add this line
    };
  }

  // Helper function to convert string to MessageStatus
  static ChatMessageStatus messageStatusFromString(String status) {
    switch (status) {
      case 'read':
        return ChatMessageStatus.read;
      case 'delivered':
        return ChatMessageStatus.delivered;
      case 'sent':
        return ChatMessageStatus.sent;
      case 'failed':
        return ChatMessageStatus.failed;
      case 'sending':
        return ChatMessageStatus.sending;
      default:
        return ChatMessageStatus.failed;
    }
  }

  // Helper function to convert string to MessageType
  static MessageType messageTypeFromString(String type) {
    switch (type) {
      case 'text':
        return MessageType.text;
      case 'audio':
        return MessageType.audio;
      case 'image':
        return MessageType.image;
      default:
        return MessageType.text;
    }
  }
}


