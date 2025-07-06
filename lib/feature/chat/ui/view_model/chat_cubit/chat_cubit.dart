// import 'dart:io';
// import 'package:chat_gemini_app/core/model/conversation_hive_model.dart';
// import 'package:chat_gemini_app/core/model/message_hive_model.dart';
// import 'package:chat_gemini_app/core/service/hive_service.dart';
// import 'package:chat_gemini_app/core/service/native_services.dart';
// import 'package:chat_gemini_app/core/utils/app_constant.dart';
// import 'package:chat_gemini_app/feature/chat/data/model/conversation_model.dart';
// import 'package:chat_gemini_app/feature/chat/data/model/message_model.dart';
// import 'package:chat_gemini_app/feature/chat/data/repo/chat_repo.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:image_picker/image_picker.dart';
// part 'chat_state.dart';

// class ChatCubit extends Cubit<ChatState> {
//   ChatCubit(this._chatRepo) : super(ChatInitial()) {
//     _initServices();
//   }
//   final ChatRepo _chatRepo;
//   List<MessageModel> chatMessages = [];
//   final NativeServices nativeServices = NativeServices();
//   File? selectedImage;
//   late final HiveService<ConversationHiveModel> _conversationService;
//   late final HiveService<MessageHiveModel> _messageService;
//   List<ConversationModel> conversations = [];
//   String? currentConversationId;
//   void startChatSession() {
//     _chatRepo.startChatSession();
//   }

//   //هنا بنفتح الصناديق بتاعت hive اللى هنخزن فيها المحادثات والرسائل
//   //ولما نفتح هنعمل تحميل لكل المحادثات loadConversations
//   Future<void> _initServices() async {
//     try {
//       _conversationService = HiveService.instanceFor<ConversationHiveModel>(
//         AppConstant.openBoxConversations,
//       );
//       _messageService = HiveService.instanceFor<MessageHiveModel>(
//         AppConstant.openBoxMessages,
//       );
//       await _conversationService.init();
//       await _messageService.init();
//       await loadConversations();
//     } catch (e) {
//       emit(ChatError('Failed to initialize services: $e'));
//     }
//   }

//   //هنا بنعمل تحميل لكل المحادثات اللى موجودة فى hive
//   //وبنرتبها على حسب تاريخ اللى اتعمل الاول
//   Future<void> loadConversations() async {
//     emit(ChatLoading());
//     try {
//       final conversationHiveModels = await _conversationService.getAll();
//       conversations = conversationHiveModels.map((e) => e.toModel()).toList();
//       conversations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
//       emit(ConversationsLoaded(conversations));
//     } catch (e) {
//       conversations = [];
//       emit(ConversationsLoaded(conversations));
//     }
//   }

// Future<void> loadConversation(String conversationId) async {
//   emit(ChatLoading());
//   try {
//     // Check if the conversation exists in our loaded conversations
//     final conversationExists = conversations.any(
//       (conv) => conv.id == conversationId,
//     );
//     if (!conversationExists) {
//       emit(ChatError('Conversation not found'));
//       return;
//     }

//     final messageHiveModels = await _messageService.getAll();

//     final conversationMessages =
//         messageHiveModels
//             .where((msg) => msg.conversationId == conversationId)
//             .map((e) => e.toModel())
//             .toList();

//     // Set the current conversation ID and messages
//     currentConversationId = conversationId;
//     chatMessages = conversationMessages;

//     emit(ChatSuccess(chatMessages));
//   } catch (e) {
//     emit(ChatError('Failed to load conversation: $e'));
//   }
// }

//   Future<void> createNewConversation() async {
//     currentConversationId = DateTime.now().millisecondsSinceEpoch.toString();
//     chatMessages = [];
//     emit(ChatSuccess(chatMessages));
//   }

//   bool hasUnsavedConversation() {
//     return currentConversationId != null && chatMessages.isNotEmpty;
//   }

//   void continueUnsavedConversation() {
//     if (hasUnsavedConversation()) {
//       emit(ChatSuccess(chatMessages));
//     } else {
//       createNewConversation();
//     }
//   }

//   void clearUnsavedConversation() {
//     currentConversationId = null;
//     chatMessages = [];
//     emit(ChatSuccess(chatMessages));
//   }

//   Future<void> resetState() async {
//     currentConversationId = null;
//     chatMessages = [];
//     selectedImage = null;
//     // Don't clear conversations, just reload them
//     await loadConversations();
//   }

//   Future<void> saveConversation(String title) async {
//     if (chatMessages.isEmpty) return;

//     try {
//       // Check if conversation already exists
//       final existingConversation = conversations.firstWhere(
//         (conv) => conv.id == currentConversationId,
//         orElse:
//             () => ConversationModel(
//               id: '',
//               title: '',
//               lastMessagepreview: '',
//               createdAt: DateTime.now(),
//               isUser: false,
//             ),
//       );

//       final conversation = ConversationModel(
//         id: currentConversationId!,
//         title: title,
//         lastMessagepreview: chatMessages.last.content,
//         createdAt:
//             existingConversation.id.isEmpty
//                 ? DateTime.now()
//                 : existingConversation.createdAt,
//         isUser: false,
//       );

//       final conversationHiveModel = ConversationHiveModel.fromModel(
//         conversation,
//       );

//       if (existingConversation.id.isEmpty) {
//         // New conversation - add it
//         await _conversationService.addItem(conversationHiveModel);

//         // Save all messages for this conversation
//         for (final message in chatMessages) {
//           final messageHiveModel = MessageHiveModel.fromModel(message);
//           await _messageService.addItem(messageHiveModel);
//         }
//       } else {
//         // Existing conversation - update it by removing and re-adding
//         final allConversations = await _conversationService.getAll();
//         final index = allConversations.indexWhere(
//           (c) => c.id == currentConversationId,
//         );
//         if (index != -1) {
//           await _conversationService.deleteItemAt(index);
//           await _conversationService.addItem(conversationHiveModel);
//         }
//       }

//       await loadConversations();
//     } catch (e) {
//       emit(ChatError(e.toString()));
//     }
//   }

// Future<void> deleteConversation(String conversationId) async {
//   try {
//     // Delete conversation
//     final conversationIndex = conversations.indexWhere(
//       (c) => c.id == conversationId,
//     );
//     if (conversationIndex != -1) {
//       await _conversationService.deleteItemAt(conversationIndex);
//     }

//     // Delete associated messages
//     final messageHiveModels = await _messageService.getAll();
//     final messagesToDelete =
//         messageHiveModels
//             .where((msg) => msg.conversationId == conversationId)
//             .toList();

//     for (final message in messagesToDelete) {
//       final index = messageHiveModels.indexOf(message);
//       if (index != -1) {
//         await _messageService.deleteItemAt(index);
//       }
//     }

//     await loadConversations();
//   } catch (e) {
//     emit(ChatError(e.toString()));
//   }
// }

//   Future<void> sendMessage(String message) async {
//     emit(SendingMessage());
//     try {
//       // Create conversation if it doesn't exist
//       currentConversationId ??=
//           DateTime.now().millisecondsSinceEpoch.toString();

//       final userMessage = MessageModel(
//         id: DateTime.now().toString(),
//         content: message,
//         timestamp: DateTime.now(),
//         isUser: true,
//         conversationId: currentConversationId,
//         image: selectedImage,
//       );

//       chatMessages.add(userMessage);
//       emit(ChatSuccess(chatMessages));

//       final response = await _chatRepo.sentMessage(message, selectedImage);

//       final aiMessage = MessageModel(
//         id: DateTime.now().toString(),
//         content: response ?? 'No response from Gemini',
//         timestamp: DateTime.now(),
//         isUser: false,
//         conversationId: currentConversationId,
//       );

//       chatMessages.add(aiMessage);
//       emit(MessageSent());
//       emit(ChatSuccess(chatMessages));

//       // Clear selected image after sending
//       selectedImage = null;
//     } catch (e) {
//       emit(SendingMessageError(e.toString()));
//     }
//   }

//   Future<void> pickImageFromCamera() async {
//     final imagePath = await nativeServices.pickImage(ImageSource.camera);
//     if (imagePath != null) {
//       selectedImage = imagePath;
//       emit(ImagePicker(imagePath));
//     }
//   }

//   Future<void> pickImageFromGallery() async {
//     final imagePath = await nativeServices.pickImage(ImageSource.gallery);
//     if (imagePath != null) {
//       selectedImage = imagePath;
//       emit(ImagePicker(imagePath));
//     }
//   }

//   void removeImage() {
//     selectedImage = null;
//     emit(ImageRemoved());
//   }
// }

// // Future<void> sendMessage(String message) async {
// //     emit(SendingMessage());
// //     try {
// //       chatMessages.add(
// //         MessageModel(
// //           id: DateTime.now().toString(),
// //           content: message,
// //           timestamp: DateTime.now(),
// //           isUser: true,
// //           conversationId: 'default_conversation_id',
// //           image: selectedImage,
// //         ),
// //       );
// //       //to update the UI with the user's message
// //       emit(ChatSuccess(chatMessages));
// //       final response = await _chatRepo.sentMessage(message, selectedImage);
// //       chatMessages.add(
// //         MessageModel(
// //           id: DateTime.now().toString(),
// //           content: response ?? 'No response from Gemini',
// //           timestamp: DateTime.now(),
// //           isUser: false,
// //           conversationId: 'default_conversation_id',
// //         ),
// //       );
// //       emit(MessageSent());
// //       emit(ChatSuccess(chatMessages));
// //     } catch (e) {
// //       emit(SendingMessageError(e.toString()));
// //     }
// //   }

//   // Future<void> pickImage() async {
//   //   try {
//   //     final imagePath = await nativeServices.pickImage();
//   //     if (imagePath != null) {
//   //       chatMessages.add(
//   //         MessageModel(
//   //           id: DateTime.now().toString(),
//   //           content: imagePath ,
//   //           timestamp: DateTime.now(),
//   //           isUser: true,
//   //           conversationId: 'default_conversation_id',
//   //         ),
//   //       );
//   //       emit(ChatSuccess(chatMessages));
//   //     }
//   //   } catch (e) {
//   //     emit(SendingMessageError(e.toString()));
//   //   }
//   // }
//     // Future<void> sentPrompt(String prompt) async {
//   //   emit(SendingMessage());
//   //   try {
//   //     final response = await _chatRepo.chatWithGemini(prompt);
//   //     emit(MessageSent());
//   //     emit(ChatSuccess(chatMessages));
//   //   } catch (e) {
//   //     emit(SendingMessageError(e.toString()));
//   //   }
//   // }

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
      _conversationService = HiveService.instanceFor<ConversationHiveModel>(
        AppConstant.openBoxConversations,
      );
      _messageService = HiveService.instanceFor<MessageHiveModel>(
        AppConstant.openBoxMessages,
      );
      await _conversationService.init();
      await _messageService.init();
      await loadConversations();
    } catch (e) {
      emit(ChatError('Failed to initialize services: $e'));
    }
  }

  Future<void> loadConversations() async {
    emit(ChatLoading());
    try {
      final conversationHiveModels = await _conversationService.getAll();
      conversations = conversationHiveModels.map((e) => e.toModel()).toList();
      conversations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(ConversationsLoaded(conversations));
    } catch (e) {
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

      emit(ChatSuccess(chatMessages));
    } catch (e) {
      emit(ChatError('Failed to load conversation: $e'));
    }
  }
  // Future<void> loadConversation(String conversationId) async {
  //   emit(ChatLoading());
  //   try {
  //     // Check if the conversation exists in our loaded conversations
  //     final conversationExists = conversations.any(
  //       (conv) => conv.id == conversationId,
  //     );
  //     if (!conversationExists) {
  //       emit(ChatError('Conversation not found'));
  //       return;
  //     }

  //     final messageHiveModels = await _messageService.getAll();

  //     final conversationMessages =
  //         messageHiveModels
  //             .where((msg) => msg.conversationId == conversationId)
  //             .map((e) => e.toModel())
  //             .toList();

  //     // Set the current conversation ID and messages
  //     currentConversationId = conversationId;
  //     chatMessages = conversationMessages;

  //     emit(ChatSuccess(chatMessages));
  //   } catch (e) {
  //     emit(ChatError('Failed to load conversation: $e'));
  //   }
  // }

  Future<void> createNewConversation() async {
    currentConversationId = DateTime.now().millisecondsSinceEpoch.toString();
    chatMessages = [];
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
    emit(ChatSuccess(chatMessages));
  }

  Future<void> resetState() async {
    currentConversationId = null;
    chatMessages = [];
    selectedImage = null;
    emit(ChatInitial());
  }
  // Future<void> resetState() async {
  //   currentConversationId = null;
  //   chatMessages = [];
  //   selectedImage = null;
  //   // Don't clear conversations, just reload them
  //   await loadConversations();
  // }

  Future<void> saveConversation(String title) async {
    if (chatMessages.isEmpty) return;

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
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      // Delete conversation
      final conversationIndex = conversations.indexWhere(
        (c) => c.id == conversationId,
      );
      if (conversationIndex != -1) {
        // Delete conversation by its ID (key)
        await _conversationService.deleteItem(conversationId);
      }

      // Delete associated messages
      final messageHiveModels = await _messageService.getAll();
      final messagesToDelete =
          messageHiveModels
              .where((msg) => msg.conversationId == conversationId)
              .toList();

      for (final message in messagesToDelete) {
        // Delete message by its ID (key)
        await _messageService.deleteItem(message.id);
      }

      await loadConversations();
      emit(ConversationsLoaded(conversations));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void startChatSession() {
    _chatRepo.startChatSession();
  }

  Future<void> sendMessage(String message) async {
    emit(SendingMessage());
    try {
      // Create conversation if it doesn't exist
      currentConversationId ??=
          DateTime.now().millisecondsSinceEpoch.toString();

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

      final response = await _chatRepo.sentMessage(message, selectedImage);

      final aiMessage = MessageModel(
        id: DateTime.now().toString(),
        content: response ?? 'No response from Gemini',
        timestamp: DateTime.now(),
        isUser: false,
        conversationId: currentConversationId,
      );

      chatMessages.add(aiMessage);
      final aiMessageHiveModel = MessageHiveModel.fromModel(aiMessage);
      await _messageService.addItem(aiMessage.id, aiMessageHiveModel);
      emit(MessageSent());
      emit(ChatSuccess(chatMessages));

      // Clear selected image after sending
      selectedImage = null;
    } catch (e) {
      emit(SendingMessageError(e.toString()));
    }
  }

  Future<void> pickImageFromCamera() async {
    final imagePath = await nativeServices.pickImage(ImageSource.camera);
    if (imagePath != null) {
      selectedImage = imagePath;
      emit(ImagePicker(imagePath));
    }
  }

  Future<void> pickImageFromGallery() async {
    final imagePath = await nativeServices.pickImage(ImageSource.gallery);
    if (imagePath != null) {
      selectedImage = imagePath;
      emit(ImagePicker(imagePath));
    }
  }

  void removeImage() {
    selectedImage = null;
    emit(ImageRemoved());
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