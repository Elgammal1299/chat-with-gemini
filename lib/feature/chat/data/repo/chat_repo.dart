import 'dart:io';

import 'package:chat_gemini_app/core/service/chat_service.dart';

class ChatRepo {
  final ChatService _chatWithAIService;
  ChatRepo(this._chatWithAIService);

  void startChatSession() {
    _chatWithAIService.startChatSession();
  }

  Future<String?> sentMessage(String message, [File? image]) async {
    return await _chatWithAIService.sentMessage(message, image);
  }
}
