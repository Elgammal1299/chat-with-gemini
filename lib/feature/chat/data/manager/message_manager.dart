import 'package:chat_gemini_app/core/model/message_hive_model.dart';
import 'package:chat_gemini_app/core/service/hive_service.dart';
import 'package:chat_gemini_app/core/utils/app_constant.dart';
import 'package:chat_gemini_app/feature/chat/data/model/message_model.dart';

class MessageManager {
  late final HiveService<MessageHiveModel> _messageService;
  List<MessageModel> _messages = [];

  List<MessageModel> get messages => _messages;

  Future<void> initialize() async {
    try {
      print('💬 Initializing MessageManager...');
      _messageService = HiveService.instanceFor<MessageHiveModel>(
        boxName: AppConstant.openBoxMessages,
        enableLogging: true,
      );
      await _messageService.init();
      print('💬 MessageManager initialized successfully');
    } catch (e) {
      print('💬 Error initializing MessageManager: $e');
      rethrow;
    }
  }

  Future<void> loadMessagesForConversation(String conversationId) async {
    print('💬 Loading messages for conversation: $conversationId');
    try {
      if (!_messageService.isOpen) {
        print('💬 Message service not open, initializing...');
        await _messageService.init();
      }

      final messageHiveModels = await _messageService.getAll();
      _messages =
          messageHiveModels
              .where((msg) => msg.conversationId == conversationId)
              .map((e) => e.toModel())
              .toList();

      print(
        '💬 Loaded ${_messages.length} messages for conversation $conversationId',
      );
    } catch (e) {
      print('💬 Error loading messages: $e');
      _messages = [];
    }
  }

  Future<void> addMessage(MessageModel message) async {
    try {
      _messages.add(message);
      final messageHiveModel = MessageHiveModel.fromModel(message);
      await _messageService.put(message.id, messageHiveModel);
      print('💬 Message added successfully: ${message.id}');
    } catch (e) {
      print('💬 Error adding message: $e');
      rethrow;
    }
  }

  Future<void> deleteMessagesForConversation(String conversationId) async {
    print('💬 Deleting messages for conversation: $conversationId');
    try {
      final messageHiveModels = await _messageService.getAll();
      final messagesToDelete =
          messageHiveModels
              .where((msg) => msg.conversationId == conversationId)
              .toList();

      print('💬 Found ${messagesToDelete.length} messages to delete');

      for (final message in messagesToDelete) {
        try {
          await _messageService.delete(message.id);
          print('💬 Deleted message: ${message.id}');
        } catch (e) {
          print('💬 Failed to delete message ${message.id}: $e');
        }
      }

      // Clear local messages if this is the current conversation
      _messages.removeWhere((msg) => msg.conversationId == conversationId);
    } catch (e) {
      print('💬 Error deleting messages: $e');
      rethrow;
    }
  }

  Future<void> deleteAllMessages() async {
    try {
      await _messageService.clear();
      _messages = [];
      print('💬 All messages deleted');
    } catch (e) {
      print('💬 Error deleting all messages: $e');
      rethrow;
    }
  }
}
