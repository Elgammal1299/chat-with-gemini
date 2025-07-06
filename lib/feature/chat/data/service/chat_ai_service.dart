import 'dart:io';
import 'package:chat_gemini_app/feature/chat/data/repo/chat_repo.dart';

class ChatAIService {
  final ChatRepo _chatRepo;

  ChatAIService(this._chatRepo);

  void startChatSession() {
    _chatRepo.startChatSession();
    print('🤖 Chat session started');
  }

  Future<String?> sendMessage(String message, [File? image]) async {
    if (message.trim().isEmpty) return null;

    print('📤 sendMessage called');
    print('📤 Message: $message');
    print('📤 Selected image: ${image?.path ?? 'null'}');

    try {
      final response = await _chatRepo.sentMessage(message, image);
      print('📤 Received response from chat repo: ${response ?? 'null'}');
      return response;
    } catch (e) {
      print('📤 Error in sendMessage: $e');
      rethrow;
    }
  }
}
