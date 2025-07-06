import 'dart:io';
import 'package:chat_gemini_app/core/model/conversation_hive_model.dart';
import 'package:chat_gemini_app/core/model/message_hive_model.dart';
import 'package:chat_gemini_app/core/service/hive_service.dart';
import 'package:chat_gemini_app/core/service/native_services.dart';
import 'package:chat_gemini_app/core/utils/app_constant.dart';
import 'package:chat_gemini_app/feature/chat/data/model/conversation_model.dart';
import 'package:chat_gemini_app/feature/chat/data/model/message_model.dart';
import 'package:chat_gemini_app/feature/chat/data/repo/chat_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this._chatRepo) : super(ChatInitial()) {
    _initServices();
  }

  final ChatRepo _chatRepo;
  List<MessageModel> chatMessages = [];
  List<ConversationModel> conversations = [];
  final NativeServices nativeServices = NativeServices();
  File? selectedImage;
  String? currentConversationId;

  late final HiveService<ConversationHiveModel> _conversationService;
  late final HiveService<MessageHiveModel> _messageService;

  Future<void> _initServices() async {
    try {
      print('Initializing Hive services...');
      _conversationService = HiveService.instanceFor<ConversationHiveModel>(
        AppConstant.openBoxConversations,
      );
      _messageService = HiveService.instanceFor<MessageHiveModel>(
        AppConstant.openBoxMessages,
      );

      print('Opening conversation box...');
      await _conversationService.init();
      print('Opening message box...');
      await _messageService.init();

      // Wait a bit to ensure boxes are fully initialized
      await Future.delayed(const Duration(milliseconds: 100));

      print('Loading conversations...');
      await loadConversations();
      print('Services initialized successfully');
    } catch (e) {
      print('Error initializing services: $e');
      emit(ChatError('Failed to initialize services: $e'));
    }
  }

  Future<void> loadConversations() async {
    print('📂 Loading conversations...');
    emit(ChatLoading());
    try {
      // Check if services are initialized
      if (!_conversationService.isBoxOpen()) {
        print('📂 Conversation service not open, initializing...');
        await _conversationService.init();
      }

      final conversationHiveModels = await _conversationService.getAll();
      print('📂 Found ${conversationHiveModels.length} conversations in Hive');

      conversations = conversationHiveModels.map((e) => e.toModel()).toList();
      conversations.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      print('📂 Loaded ${conversations.length} conversations');
      print('📂 Emitting ConversationsLoaded state');
      emit(ConversationsLoaded(conversations));
      print('📂 ConversationsLoaded state emitted');
    } catch (e) {
      print('📂 Error loading conversations: $e');
      conversations = [];
      emit(ConversationsLoaded(conversations));
    }
  }

  Future<void> loadConversation(String conversationId) async {
    emit(ChatLoading());
    try {
      // Check if the conversation exists in our loaded conversations
      final conversationExists = conversations.any(
        (conv) => conv.id == conversationId,
      );
      if (!conversationExists) {
        emit(ChatError('Conversation not found'));
        return;
      }

      final messageHiveModels = await _messageService.getAll();

      final conversationMessages =
          messageHiveModels
              .where((msg) => msg.conversationId == conversationId)
              .map((e) => e.toModel())
              .toList();

      // Set the current conversation ID and messages
      currentConversationId = conversationId;
      chatMessages = conversationMessages;
      selectedImage = null; // Clear any selected image

      // Emit success state with messages (even if empty)
      emit(ChatSuccess(chatMessages));
    } catch (e) {
      emit(ChatError('Failed to load conversation: $e'));
    }
  }

  Future<void> createNewConversation() async {
    // Clear current conversation state
    currentConversationId = DateTime.now().millisecondsSinceEpoch.toString();
    chatMessages = [];
    selectedImage = null;
    // Emit initial state to show "Start chatting!"
    emit(ChatInitial());
    emit(ChatSuccess(chatMessages));
  }

  bool hasUnsavedConversation() {
    return currentConversationId != null && chatMessages.isNotEmpty;
  }

  void continueUnsavedConversation() {
    if (hasUnsavedConversation()) {
      emit(ChatSuccess(chatMessages));
    } else {
      createNewConversation();
    }
  }

  void clearUnsavedConversation() {
    currentConversationId = null;
    chatMessages = [];
    selectedImage = null;
    emit(ChatSuccess(chatMessages));
  }

  Future<void> resetState() async {
    print('🔄 resetState called');
    currentConversationId = null;
    chatMessages = [];
    selectedImage = null;
    print('🔄 Cleared current conversation state');
    // Don't clear conversations, just reload them
    await loadConversations();
    print('🔄 Conversations reloaded');
  }

  Future<void> saveConversation(String title) async {
    if (chatMessages.isEmpty) return;

    emit(ChatLoading());
    try {
      // Check if conversation already exists
      final existingConversation = conversations.firstWhere(
        (conv) => conv.id == currentConversationId,
        orElse:
            () => ConversationModel(
              id: '',
              title: '',
              lastMessagepreview: '',
              createdAt: DateTime.now(),
              isUser: false,
            ),
      );

      final conversation = ConversationModel(
        id: currentConversationId!,
        title: title,
        lastMessagepreview: chatMessages.last.content,
        createdAt:
            existingConversation.id.isEmpty
                ? DateTime.now()
                : existingConversation.createdAt,
        isUser: false,
      );

      final conversationHiveModel = ConversationHiveModel.fromModel(
        conversation,
      );

      // Use the conversation ID as the key
      await _conversationService.addItem(
        conversation.id,
        conversationHiveModel,
      );

      // Save all messages for this conversation
      if (existingConversation.id.isEmpty) {
        for (final message in chatMessages) {
          final messageHiveModel = MessageHiveModel.fromModel(message);
          // Use the message ID as the key
          await _messageService.addItem(message.id, messageHiveModel);
        }
      }

      await loadConversations();
      // Emit success state after saving
      emit(ChatSuccess(chatMessages));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    print('🔥 deleteConversation method called with ID: $conversationId');
    print('Starting deletion of conversation: $conversationId');

    try {
      // Check if the conversation exists
      final conversationExists = conversations.any(
        (conv) => conv.id == conversationId,
      );

      print('Conversation exists: $conversationExists');

      if (!conversationExists) {
        throw Exception('Conversation not found');
      }

      // Delete conversation from Hive
      print('Deleting conversation from Hive...');
      await _conversationService.deleteItem(conversationId);
      print('Conversation deleted from Hive');

      // Delete associated messages
      final messageHiveModels = await _messageService.getAll();
      final messagesToDelete =
          messageHiveModels
              .where((msg) => msg.conversationId == conversationId)
              .toList();

      print('Found ${messagesToDelete.length} messages to delete');

      // Delete messages in batches to avoid blocking
      for (final message in messagesToDelete) {
        try {
          await _messageService.deleteItem(message.id);
          print('Deleted message: ${message.id}');
        } catch (e) {
          // Log error but continue with other messages
          print('Failed to delete message ${message.id}: $e');
        }
      }

      // Clear current conversation if it's the one being deleted
      if (currentConversationId == conversationId) {
        print('Clearing current conversation state');
        currentConversationId = null;
        chatMessages = [];
        selectedImage = null;
      }

      // Reload conversations list
      print('Reloading conversations...');
      await loadConversations();

      print('Deletion completed successfully');
    } catch (e) {
      print('Error during deletion: $e');
      rethrow; // Re-throw the error to be handled by the UI
    }
  }

  Future<void> deleteAllConversations() async {
    emit(ChatLoading());
    try {
      // Clear all conversations
      await _conversationService.clearBox();

      // Clear all messages
      await _messageService.clearBox();

      // Clear current state
      currentConversationId = null;
      chatMessages = [];
      selectedImage = null;

      // Reload conversations list
      await loadConversations();

      // Emit success state
      emit(ConversationsLoaded(conversations));
    } catch (e) {
      emit(ChatError('Failed to delete all conversations: $e'));
    }
  }

  void startChatSession() {
    _chatRepo.startChatSession();
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    print('📤 sendMessage called');
    print('📤 Message: $message');
    print('📤 Selected image: ${selectedImage?.path ?? 'null'}');

    emit(SendingMessage());
    try {
      // Create conversation if it doesn't exist
      currentConversationId ??=
          DateTime.now().millisecondsSinceEpoch.toString();

      print(
        '📤 Calling _chatRepo.sentMessage with image: ${selectedImage?.path ?? 'null'}',
      );
      final response = await _chatRepo.sentMessage(message, selectedImage);
      print('📤 Received response from chat repo: ${response ?? 'null'}');

      // Add user message only after successful API call
      final userMessage = MessageModel(
        id: DateTime.now().toString(),
        content: message,
        timestamp: DateTime.now(),
        isUser: true,
        conversationId: currentConversationId,
        image: selectedImage,
      );

      chatMessages.add(userMessage);
      final messageHiveModel = MessageHiveModel.fromModel(userMessage);
      await _messageService.addItem(userMessage.id, messageHiveModel);
      emit(ChatSuccess(chatMessages));

      final aiMessage = MessageModel(
        id: DateTime.now().toString(),
        content: response ?? 'No response from Gemini',
        timestamp: DateTime.now(),
        isUser: false,
        conversationId: currentConversationId,
      );

      print('📤 Adding AI message to chat');
      chatMessages.add(aiMessage);
      final aiMessageHiveModel = MessageHiveModel.fromModel(aiMessage);
      await _messageService.addItem(aiMessage.id, aiMessageHiveModel);
      print('📤 Emitting MessageSent state');
      emit(MessageSent());
      print('📤 Emitting ChatSuccess state');
      emit(ChatSuccess(chatMessages));

      // Clear selected image after sending
      selectedImage = null;
      print('📤 Cleared selected image');
      emit(ImageRemoved());
      print('📤 Emitted ImageRemoved state');
    } catch (e) {
      print('📤 Error in sendMessage: $e');
      // Clear selected image even on error
      selectedImage = null;
      print('📤 Cleared selected image due to error');
      emit(ImageRemoved());
      print('📤 Emitted ImageRemoved state due to error');
      emit(SendingMessageError(e.toString()));
    }
  }

  Future<void> pickImageFromCamera() async {
    print('📷 pickImageFromCamera called');
    final imagePath = await nativeServices.pickImage(ImageSource.camera);
    print('📷 Camera result: ${imagePath?.path ?? 'null'}');
    if (imagePath != null) {
      selectedImage = imagePath;
      print('📷 Selected image from camera: ${selectedImage?.path}');
      emit(ImagePicker(imagePath));
    }
  }

  Future<void> pickImageFromGallery() async {
    print('📷 pickImageFromGallery called');
    final imagePath = await nativeServices.pickImage(ImageSource.gallery);
    print('📷 Gallery result: ${imagePath?.path ?? 'null'}');
    if (imagePath != null) {
      selectedImage = imagePath;
      print('📷 Selected image from gallery: ${selectedImage?.path}');
      emit(ImagePicker(imagePath));
    }
  }

  void removeImage() {
    print('📷 removeImage called');
    selectedImage = null;
    emit(ImageRemoved());
  }

  bool isCurrentConversationDeleted() {
    if (currentConversationId == null) return false;
    return !conversations.any((conv) => conv.id == currentConversationId);
  }

  void clearCurrentConversation() {
    currentConversationId = null;
    chatMessages = [];
    selectedImage = null;
    emit(ChatInitial());
  }

  void debugHiveStatus() {
    print('=== Hive Service Status ===');
    print('Conversation service open: ${_conversationService.isBoxOpen()}');
    print('Conversation box size: ${_conversationService.getBoxSize()}');
    print('Message service open: ${_messageService.isBoxOpen()}');
    print('Message box size: ${_messageService.getBoxSize()}');
    print('Current conversations count: ${conversations.length}');
    print('Current conversation ID: $currentConversationId');
    print('Current messages count: ${chatMessages.length}');
    print('==========================');
  }

  // Manual database access methods for debugging
  Future<List<String>> getAllConversationIds() async {
    try {
      final conversationHiveModels = await _conversationService.getAll();
      return conversationHiveModels.map((e) => e.id).toList();
    } catch (e) {
      print('Error getting conversation IDs: $e');
      return [];
    }
  }

  Future<void> forceDeleteConversationById(String conversationId) async {
    print('🔥 Force deleting conversation: $conversationId');
    try {
      // Delete conversation directly
      await _conversationService.deleteItem(conversationId);
      print('Conversation deleted from Hive');

      // Delete all messages for this conversation
      final messageHiveModels = await _messageService.getAll();
      final messagesToDelete =
          messageHiveModels
              .where((msg) => msg.conversationId == conversationId)
              .toList();

      print('Found ${messagesToDelete.length} messages to delete');
      for (final message in messagesToDelete) {
        await _messageService.deleteItem(message.id);
        print('Deleted message: ${message.id}');
      }

      // Reload conversations
      await loadConversations();
      print('Force deletion completed');
    } catch (e) {
      print('Error in force deletion: $e');
      rethrow;
    }
  }

  Future<void> clearAllData() async {
    print('🔥 Clearing all data...');
    try {
      await _conversationService.clearBox();
      await _messageService.clearBox();

      // Clear current state
      currentConversationId = null;
      chatMessages = [];
      selectedImage = null;
      conversations = [];

      print('All data cleared successfully');
    } catch (e) {
      print('Error clearing all data: $e');
      rethrow;
    }
  }

  // Debug method to test image processing
  Future<void> debugTestImageProcessing() async {
    print('🔍 Debug: Testing image processing');
    print('🔍 Selected image: ${selectedImage?.path ?? 'null'}');

    if (selectedImage != null) {
      try {
        final bytes = await selectedImage!.readAsBytes();
        print('🔍 Image bytes: ${bytes.length} bytes');
        print('🔍 Image path: ${selectedImage!.path}');
        print('🔍 Image exists: ${await selectedImage!.exists()}');

        // Test MIME type detection
        String mimeType =
            selectedImage!.path.endsWith('.png') ? 'image/png' : 'image/jpeg';
        print('🔍 MIME type: $mimeType');

        print('🔍 Image processing test completed successfully');
      } catch (e) {
        print('🔍 Error testing image processing: $e');
      }
    } else {
      print('🔍 No image selected for testing');
    }
  }
}


  // Future<void> pickImage() async {
  //   try {
  //     final imagePath = await nativeServices.pickImage();
  //     if (imagePath != null) {
  //       chatMessages.add(
  //         MessageModel(
  //           id: DateTime.now().toString(),
  //           content: imagePath ,
  //           timestamp: DateTime.now(),
  //           isUser: true,
  //           conversationId: 'default_conversation_id',
  //         ),
  //       );
  //       emit(ChatSuccess(chatMessages));
  //     }
  //   } catch (e) {
  //     emit(SendingMessageError(e.toString()));
  //   }
  // }
    // Future<void> sentPrompt(String prompt) async {
  //   emit(SendingMessage());
  //   try {
  //     final response = await _chatRepo.chatWithGemini(prompt);
  //     emit(MessageSent());
  //     emit(ChatSuccess(chatMessages));
  //   } catch (e) {
  //     emit(SendingMessageError(e.toString()));
  //   }
  // }