import 'package:chat_gemini_app/feature/chat/data/model/conversation_model.dart';
import 'package:chat_gemini_app/feature/chat/data/model/message_model.dart';

class ChatStateManager {
  String? _currentConversationId;
  List<MessageModel> _chatMessages = [];

  String? get currentConversationId => _currentConversationId;
  List<MessageModel> get chatMessages => _chatMessages;

  bool get hasCurrentConversation => _currentConversationId != null;
  bool get hasMessages => _chatMessages.isNotEmpty;

  void createNewConversation() {
    _currentConversationId = DateTime.now().millisecondsSinceEpoch.toString();
    _chatMessages = [];
    print('🆕 Created new conversation: $_currentConversationId');
  }

  void setCurrentConversation(String conversationId) {
    _currentConversationId = conversationId;
    print('🔄 Set current conversation: $_currentConversationId');
  }

  void clearCurrentConversation() {
    _currentConversationId = null;
    _chatMessages = [];
    print('🗑️ Cleared current conversation');
  }

  void setMessages(List<MessageModel> messages) {
    _chatMessages = messages;
    print('💬 Set ${_chatMessages.length} messages');
  }

  void addMessage(MessageModel message) {
    _chatMessages.add(message);
    print('➕ Added message: ${message.id}');
  }

  void clearMessages() {
    _chatMessages = [];
    print('🗑️ Cleared messages');
  }

  bool hasUnsavedConversation() {
    return _currentConversationId != null && _chatMessages.isNotEmpty;
  }

  bool isCurrentConversationDeleted(List<ConversationModel> conversations) {
    if (_currentConversationId == null) return false;
    return !conversations.any((conv) => conv.id == _currentConversationId);
  }

  void resetState() {
    _currentConversationId = null;
    _chatMessages = [];
    print('🔄 Reset chat state');
  }
}
