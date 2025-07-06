part of 'chat_cubit.dart';

sealed class ChatState {}

final class ChatInitial extends ChatState {}

final class ChatLoading extends ChatState {}

final class ChatSuccess extends ChatState {
  final List<MessageModel> messages;

  ChatSuccess(this.messages);
}

final class ChatError extends ChatState {
  final String error;

  ChatError(this.error);
}

final class SendingMessage extends ChatState {}

final class SendingMessageError extends ChatState {
  final String error;

  SendingMessageError(this.error);
}

final class MessageSent extends ChatState {}

final class ImageRemoved extends ChatState {}

final class ImagePicker extends ChatState {
  final File imagePath;

  ImagePicker(this.imagePath);
}

final class ConversationsLoaded extends ChatState {
  final List<ConversationModel> conversations;

  ConversationsLoaded(this.conversations);
}
