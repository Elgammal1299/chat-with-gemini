// import 'package:hive/hive.dart';

// part 'conversation_hive_model.g.dart';

// @HiveType(typeId: 0)
// class ConversationHiveModel extends HiveObject {
//   @HiveField(0)
//   final String id;

//   @HiveField(1)
//   final String title;

//   @HiveField(2)
//   final String lastMessagepreview;

//   @HiveField(3)
//   final DateTime createdAt;

//   ConversationHiveModel({
//     required this.id,
//     required this.title,
//     required this.lastMessagepreview,
//     required this.createdAt,
//   });
// }
import 'package:chat_gemini_app/feature/chat/data/model/conversation_model.dart';
import 'package:hive/hive.dart';

part 'conversation_hive_model.g.dart';

@HiveType(typeId: 0)
class ConversationHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String lastMessagepreview;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final bool isUser;

  ConversationHiveModel({
    required this.id,
    required this.title,
    required this.lastMessagepreview,
    required this.createdAt,
    required this.isUser,
  });

  // ⬅️ تحويل إلى الموديل العادي
  ConversationModel toModel() {
    return ConversationModel(
      id: id,
      title: title,
      lastMessagepreview: lastMessagepreview,
      createdAt: createdAt,
      isUser: isUser,
    );
  }

  // ➡️ تحويل من الموديل العادي
  factory ConversationHiveModel.fromModel(ConversationModel model) {
    return ConversationHiveModel(
      id: model.id,
      title: model.title,
      lastMessagepreview: model.lastMessagepreview,
      createdAt: model.createdAt,
      isUser: model.isUser,
    );
  }
}
