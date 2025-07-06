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
    print('🖼️ ChatService.sentMessage called');
    print('🖼️ Message: $message');
    print('🖼️ Image: ${image?.path ?? 'null'}');

    late final Content content;
    if (image != null) {
      print('🖼️ Processing image: ${image.path}');
      String mimeType =
          image.path.endsWith('.png') ? 'image/png' : 'image/jpeg';
      print('🖼️ MIME type: $mimeType');

      final bytes = await image.readAsBytes();
      print('🖼️ Image bytes: ${bytes.length} bytes');

      content = Content.multi([TextPart(message), DataPart(mimeType, bytes)]);
      print('🖼️ Created multi-content with image');
    } else {
      print('🖼️ No image, creating text-only content');
      content = Content.text(message);
    }

    print('🖼️ Sending message to Gemini...');
    try {
      final response = await _chatSession.sendMessage(content);
      print('🖼️ Received response from Gemini');
      print('🖼️ Response text: ${response.text}');
      return response.text;
    } catch (e) {
      print('🖼️ Error from Gemini API: $e');
      rethrow;
    }
  }
}
