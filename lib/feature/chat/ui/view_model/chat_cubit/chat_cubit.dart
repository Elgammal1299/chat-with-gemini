import 'dart:io';
import 'package:chat_gemini_app/feature/chat/data/manager/chat_state_manager.dart';
import 'package:chat_gemini_app/feature/chat/data/manager/conversation_manager.dart';
import 'package:chat_gemini_app/feature/chat/data/manager/image_manager.dart';
import 'package:chat_gemini_app/feature/chat/data/manager/message_manager.dart';
import 'package:chat_gemini_app/feature/chat/data/model/conversation_model.dart';
import 'package:chat_gemini_app/feature/chat/data/model/message_model.dart';
import 'package:chat_gemini_app/feature/chat/data/service/chat_ai_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this._chatRepo) : super(ChatInitial()) {
    _initServices();
  }

  final ChatAIService _chatRepo;

  // Managers
  late final ConversationManager _conversationManager;
  late final MessageManager _messageManager;
  late final ImageManager _imageManager;
  late final ChatStateManager _stateManager;

  // Getters for backward compatibility
  List<MessageModel> get chatMessages => _stateManager.chatMessages;
  List<ConversationModel> get conversations =>
      _conversationManager.conversations;
  File? get selectedImage => _imageManager.selectedImage;
  String? get currentConversationId => _stateManager.currentConversationId;

  Future<void> _initServices() async {
    try {
      print('🚀 Initializing ChatCubit services...');

      // Initialize managers
      _conversationManager = ConversationManager();
      _messageManager = MessageManager();
      _imageManager = ImageManager();
      _stateManager = ChatStateManager();

      // Initialize services
      await _conversationManager.initialize();
      await _messageManager.initialize();

      // Wait a bit to ensure boxes are fully initialized
      await Future.delayed(const Duration(milliseconds: 100));

      print('🚀 ChatCubit services initialized successfully');
    } catch (e) {
      print('🚀 Error initializing ChatCubit services: $e');
      emit(ChatError('Failed to initialize services: $e'));
    }
  }

  // Conversation Management
  Future<void> loadConversations() async {
    print('📂 Loading conversations...');
    emit(ChatLoading());
    try {
      await _conversationManager.loadConversations();
      emit(ConversationsLoaded(_conversationManager.conversations));
    } catch (e) {
      print('📂 Error loading conversations: $e');
      emit(ConversationsLoaded([]));
    }
  }

  Future<void> loadConversation(String conversationId) async {
    emit(ChatLoading());
    try {
      if (!_conversationManager.conversationExists(conversationId)) {
        emit(ChatError('Conversation not found'));
        return;
      }

      await _messageManager.loadMessagesForConversation(conversationId);
      _stateManager.setCurrentConversation(conversationId);
      _stateManager.setMessages(_messageManager.messages);
      _imageManager.clearImage();

      emit(ChatSuccess(_stateManager.chatMessages));
    } catch (e) {
      emit(ChatError('Failed to load conversation: $e'));
    }
  }

  Future<void> createNewConversation() async {
    _stateManager.createNewConversation();
    _imageManager.clearImage();
    emit(ChatInitial());
    emit(ChatSuccess(_stateManager.chatMessages));
  }

  Future<void> saveConversation(String title) async {
    if (_stateManager.chatMessages.isEmpty) return;

    emit(ChatLoading());
    try {
      final existingConversation = _conversationManager.getConversationById(
        _stateManager.currentConversationId!,
      );

      final conversation = ConversationModel(
        id: _stateManager.currentConversationId!,
        title: title,
        lastMessagepreview: _stateManager.chatMessages.last.content,
        createdAt: existingConversation?.createdAt ?? DateTime.now(),
        isUser: false,
      );

      await _conversationManager.saveConversation(conversation);

      // Save all messages for this conversation if it's new
      if (existingConversation == null) {
        for (final message in _stateManager.chatMessages) {
          await _messageManager.addMessage(message);
        }
      }

      await loadConversations();
      emit(ChatSuccess(_stateManager.chatMessages));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    print('🔥 Deleting conversation: $conversationId');
    try {
      await _conversationManager.deleteConversation(conversationId);
      await _messageManager.deleteMessagesForConversation(conversationId);

      // Clear current conversation if it's the one being deleted
      if (_stateManager.currentConversationId == conversationId) {
        _stateManager.clearCurrentConversation();
        _imageManager.clearImage();
      }

      await loadConversations();
    } catch (e) {
      print('🔥 Error during deletion: $e');
      rethrow;
    }
  }

  Future<void> deleteAllConversations() async {
    emit(ChatLoading());
    try {
      await _conversationManager.deleteAllConversations();
      await _messageManager.deleteAllMessages();
      _stateManager.resetState();
      _imageManager.clearImage();
      await loadConversations();
      emit(ConversationsLoaded(_conversationManager.conversations));
    } catch (e) {
      emit(ChatError('Failed to delete all conversations: $e'));
    }
  }

  // Message Management
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    emit(SendingMessage());
    try {
      // Create conversation if it doesn't exist
      if (!_stateManager.hasCurrentConversation) {
        _stateManager.createNewConversation();
      }

      final response = await _chatRepo.sendMessage(
        message,
        _imageManager.selectedImage,
      );

      // Add user message
      final userMessage = MessageModel(
        id: DateTime.now().toString(),
        content: message,
        timestamp: DateTime.now(),
        isUser: true,
        conversationId: _stateManager.currentConversationId,
        image: _imageManager.selectedImage,
      );

      _stateManager.addMessage(userMessage);
      await _messageManager.addMessage(userMessage);
      emit(ChatSuccess(_stateManager.chatMessages));

      // Add AI message
      final aiMessage = MessageModel(
        id: DateTime.now().toString(),
        content: response ?? 'No response from Gemini',
        timestamp: DateTime.now(),
        isUser: false,
        conversationId: _stateManager.currentConversationId,
      );

      _stateManager.addMessage(aiMessage);
      await _messageManager.addMessage(aiMessage);
      emit(MessageSent());
      emit(ChatSuccess(_stateManager.chatMessages));

      // Clear selected image after sending
      _imageManager.clearImage();
      emit(ImageRemoved());
    } catch (e) {
      print('📤 Error in sendMessage: $e');
      _imageManager.clearImage();
      emit(ImageRemoved());
      emit(SendingMessageError(e.toString()));
    }
  }

  // Image Management
  Future<void> pickImageFromCamera() async {
    final image = await _imageManager.pickImageFromCamera();
    if (image != null) {
      emit(ImagePicker(image));
    }
  }

  Future<void> pickImageFromGallery() async {
    final image = await _imageManager.pickImageFromGallery();
    if (image != null) {
      emit(ImagePicker(image));
    }
  }

  void removeImage() {
    _imageManager.removeImage();
    emit(ImageRemoved());
  }

  // State Management
  void startChatSession() {
    _chatRepo.startChatSession();
  }

  bool hasUnsavedConversation() {
    return _stateManager.hasUnsavedConversation();
  }

  void continueUnsavedConversation() {
    if (_stateManager.hasUnsavedConversation()) {
      emit(ChatSuccess(_stateManager.chatMessages));
    } else {
      createNewConversation();
    }
  }

  void clearUnsavedConversation() {
    _stateManager.clearCurrentConversation();
    _imageManager.clearImage();
    emit(ChatSuccess(_stateManager.chatMessages));
  }

  Future<void> resetState() async {
    print('🔄 resetState called');
    _stateManager.resetState();
    _imageManager.clearImage();
    await loadConversations();
    print('🔄 State reset completed');
  }

  bool isCurrentConversationDeleted() {
    return _stateManager.isCurrentConversationDeleted(
      _conversationManager.conversations,
    );
  }

  void clearCurrentConversation() {
    _stateManager.clearCurrentConversation();
    _imageManager.clearImage();
    emit(ChatInitial());
  }

  // Debug method for image processing
  Future<void> debugTestImageProcessing() async {
    await _imageManager.debugTestImageProcessing();
  }
}
