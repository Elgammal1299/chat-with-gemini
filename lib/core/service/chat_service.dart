import 'dart:io';

import 'package:chat_gemini_app/core/utils/app_constant.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatService {
  final model = GenerativeModel(
    model: 'gemini-1.5-flash-latest',
    apiKey: AppConstant.apiKey,
  );
  late ChatSession _chatSession;

  // Future<String?> sentPrompt(String prompt) async {
  //   final content = [Content.text(prompt)];
  //   final response = await model.generateContent(content);

  //   return response.text;
  // }

  void startChatSession() {
    _chatSession = model.startChat();
  }

  Future<String?> sentMessage(String message, [File? image]) async {
    late final Content content;
    if (image != null) {
      String mimeType =
          image.path.endsWith('.png') ? 'image/png' : 'image/jpeg';
      final bytes = await image.readAsBytes();
      content = Content.multi([TextPart(message), DataPart(mimeType, bytes)]);
    } else {
      content = Content.text(message);
    }
    final response = await _chatSession.sendMessage(content);
    return response.text;
  }
}
