import 'package:chat_gemini_app/core/utils/app_colors.dart';
import 'package:chat_gemini_app/feature/chat/ui/view_model/chat_cubit/chat_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomIconButtonSend extends StatelessWidget {
  const CustomIconButtonSend({
    super.key,
    required TextEditingController messageController,
    required this.scrollDown,
  }) : _messageController = messageController;

  final TextEditingController _messageController;
  final VoidCallback? scrollDown;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatCubit, ChatState>(
      bloc: BlocProvider.of<ChatCubit>(context),
      listenWhen:
          (previous, current) =>
              current is SendingMessageError || current is ChatSuccess,

      buildWhen:
          (previous, current) =>
              current is SendingMessage ||
              current is MessageSent ||
              current is SendingMessageError,
      builder: (context, state) {
        if (state is SendingMessage) {
          return const CircularProgressIndicator();
        }
        return IconButton(
          color: AppColors.sendButtonColor,
          iconSize: 32,
          icon: const Icon(Icons.send),
          onPressed: () {
            if (_messageController.text.trim().isNotEmpty) {
              BlocProvider.of<ChatCubit>(
                context,
              ).sendMessage(_messageController.text);
              BlocProvider.of<ChatCubit>(context).removeImage();
              _messageController.clear();
              scrollDown!();
            }
          },
        );
      },
      listener: (BuildContext context, ChatState state) {
        if (state is SendingMessageError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is ChatSuccess) {
          scrollDown!();
        }
      },
    );
  }
}
