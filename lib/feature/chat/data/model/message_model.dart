// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

class MessageModel {
  final String id;
  final String content;
  final DateTime timestamp;
  final bool isUser;
  final String? conversationId;
  final File? image;

  MessageModel({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.isUser,
    required this.conversationId,
    this.image,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isUser': isUser,
      'conversationId': conversationId,
      'image': image,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] as String,
      content: map['content'] as String,
      image: map['image'] as File,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      isUser: map['isUser'] as bool,
      conversationId:
          map['conversationId'] != null
              ? map['conversationId'] as String
              : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory MessageModel.fromJson(String source) =>
      MessageModel.fromMap(json.decode(source) as Map<String, dynamic>);

  MessageModel copyWith({
    String? id,
    String? content,
    DateTime? timestamp,
    bool? isUser,
    String? conversationId,
    File? image,
  }) {
    return MessageModel(
      id: id ?? this.id,
      content: content ?? this.content,
      image: image ?? this.image,
      timestamp: timestamp ?? this.timestamp,
      isUser: isUser ?? this.isUser,
      conversationId: conversationId ?? this.conversationId,
    );
  }
}
