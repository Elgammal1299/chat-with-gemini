import 'package:chat_gemini_app/feature/chat/ui/view/widget/chat_message_item.dart';
import 'package:chat_gemini_app/feature/chat/ui/view_model/chat_cubit/chat_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomChatListView extends StatelessWidget {
  const CustomChatListView({super.key, required this.scrollController});
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      buildWhen:
          (previous, current) =>
              current is ChatSuccess ||
              current is ChatError ||
              current is ChatLoading ||
              current is ChatInitial,
      builder: (context, state) {
        if (state is ChatSuccess) {
          final messages = state.messages;
          if (messages.isEmpty) {
            return const Center(child: Text('Start chatting!'));
          }
          return ListView.separated(
            controller: scrollController,
            separatorBuilder: (context, index) => SizedBox(height: 8.0),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return ChatMessageItem(messageModel: message);
            },
          );
        } else if (state is ChatError) {
          return Center(child: Text(state.error));
        } else if (state is ChatLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ChatInitial) {
          return const Center(child: Text('Start chatting!'));
        }
        return const Center(child: Text('Start chatting!'));
      },
    );
  }
}
