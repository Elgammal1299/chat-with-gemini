import 'package:chat_gemini_app/core/model/conversation_hive_model.dart';
import 'package:chat_gemini_app/core/service/hive_service.dart';
import 'package:chat_gemini_app/core/utils/app_constant.dart';
import 'package:chat_gemini_app/feature/chat/data/model/conversation_model.dart';

class ConversationManager {
  late final HiveService<ConversationHiveModel> _conversationService;
  List<ConversationModel> _conversations = [];

  List<ConversationModel> get conversations => _conversations;

  Future<void> initialize() async {
    try {
      print('📂 Initializing ConversationManager...');
      _conversationService = HiveService.instanceFor<ConversationHiveModel>(
        boxName: AppConstant.openBoxConversations,
        enableLogging: true,
      );
      await _conversationService.init();
      await loadConversations();
      print('📂 ConversationManager initialized successfully');
    } catch (e) {
      print('📂 Error initializing ConversationManager: $e');
      rethrow;
    }
  }

  Future<void> loadConversations() async {
    print('📂 Loading conversations...');
    try {
      if (!_conversationService.isOpen) {
        print('📂 Conversation service not open, initializing...');
        await _conversationService.init();
      }

      final conversationHiveModels = await _conversationService.getAll();
      print('📂 Found ${conversationHiveModels.length} conversations in Hive');

      _conversations = conversationHiveModels.map((e) => e.toModel()).toList();
      _conversations.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      print('📂 Loaded ${_conversations.length} conversations');
    } catch (e) {
      print('📂 Error loading conversations: $e');
      _conversations = [];
    }
  }

  Future<void> saveConversation(ConversationModel conversation) async {
    try {
      final conversationHiveModel = ConversationHiveModel.fromModel(
        conversation,
      );
      await _conversationService.put(conversation.id, conversationHiveModel);
      await loadConversations();
    } catch (e) {
      print('📂 Error saving conversation: $e');
      rethrow;
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    print('🔥 Deleting conversation: $conversationId');
    try {
      final conversationExists = _conversations.any(
        (conv) => conv.id == conversationId,
      );

      if (!conversationExists) {
        throw Exception('Conversation not found');
      }

      await _conversationService.delete(conversationId);
      await loadConversations();
      print('🔥 Conversation deleted successfully');
    } catch (e) {
      print('🔥 Error deleting conversation: $e');
      rethrow;
    }
  }

  Future<void> deleteAllConversations() async {
    try {
      await _conversationService.clear();
      _conversations = [];
      print('🔥 All conversations deleted');
    } catch (e) {
      print('🔥 Error deleting all conversations: $e');
      rethrow;
    }
  }

  bool conversationExists(String conversationId) {
    return _conversations.any((conv) => conv.id == conversationId);
  }

  ConversationModel? getConversationById(String conversationId) {
    try {
      return _conversations.firstWhere((conv) => conv.id == conversationId);
    } catch (e) {
      return null;
    }
  }
}
