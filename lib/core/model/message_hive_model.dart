// import 'package:hive/hive.dart';

// part 'message_hive_model.g.dart';

// @HiveType(typeId: 1)
// class MessageHiveModel extends HiveObject {
//   @HiveField(0)
//   final String id;

//   @HiveField(1)
//   final String content;

//   @HiveField(2)
//   final DateTime timestamp;

//   @HiveField(3)
//   final bool isUser;

//   @HiveField(4)
//   final String? conversationId;

//   @HiveField(5)
//   final String? imagePath;

//   MessageHiveModel({
//     required this.id,
//     required this.content,
//     required this.timestamp,
//     required this.isUser,
//     this.conversationId,
//     this.imagePath,
//   });

// }
import 'package:chat_gemini_app/feature/chat/data/model/message_model.dart';
import 'package:hive/hive.dart';
import 'dart:io';

part 'message_hive_model.g.dart';

@HiveType(typeId: 1)
class MessageHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final bool isUser;

  @HiveField(4)
  final String? conversationId;

  @HiveField(5)
  final String? imagePath;

  MessageHiveModel({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.isUser,
    this.conversationId,
    this.imagePath,
  });

  // ⬅️ تحويل إلى الموديل العادي
  MessageModel toModel() {
    return MessageModel(
      id: id,
      content: content,
      timestamp: timestamp,
      isUser: isUser,
      conversationId: conversationId,
      image: imagePath != null ? File(imagePath!) : null,
    );
  }

  // ➡️ تحويل من الموديل العادي
  factory MessageHiveModel.fromModel(MessageModel model) {
    return MessageHiveModel(
      id: model.id,
      content: model.content,
      timestamp: model.timestamp,
      isUser: model.isUser,
      conversationId: model.conversationId,
      imagePath: model.image?.path,
    );
  }
}
