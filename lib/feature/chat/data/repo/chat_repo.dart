import 'dart:io';

import 'package:chat_gemini_app/core/service/chat_service.dart';

class ChatRepo {
  final ChatService _chatWithAIService;
  ChatRepo(this._chatWithAIService);
  // Future<String?> chatWithGemini(String prompt) async {
  //   return await _chatWithAIService.sentPrompt(prompt);
  // }

  void startChatSession() {
    _chatWithAIService.startChatSession();
  }

  Future<String?> sentMessage(String message, [File? image]) async {
    return await _chatWithAIService.sentMessage(message, image);
  }
}
