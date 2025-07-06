// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ConversationModel {
  final String id;
  final String title;
  final String lastMessagepreview;
  final DateTime createdAt;
  final bool isUser;

  ConversationModel({
    required this.id,
    required this.title,
    required this.lastMessagepreview,
    required this.createdAt,
    required this.isUser,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'lastMessagepreview': lastMessagepreview,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isUser': isUser,
    };
  }

  factory ConversationModel.fromMap(Map<String, dynamic> map) {
    return ConversationModel(
      id: map['id'] as String,
      title: map['title'] as String,
      lastMessagepreview: map['lastMessagepreview'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      isUser: map['isUser'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory ConversationModel.fromJson(String source) =>
      ConversationModel.fromMap(json.decode(source) as Map<String, dynamic>);

  ConversationModel copyWith({
    String? id,
    String? title,
    String? lastMessagepreview,
    DateTime? createdAt,
    bool? isUser,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      lastMessagepreview: lastMessagepreview ?? this.lastMessagepreview,
      createdAt: createdAt ?? this.createdAt,
      isUser: isUser ?? this.isUser,
    );
  }
}
