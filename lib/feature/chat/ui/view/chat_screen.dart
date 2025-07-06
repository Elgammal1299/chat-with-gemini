// import 'package:chat_gemini_app/core/utils/app_colors.dart';
// import 'package:chat_gemini_app/feature/chat/ui/view/widget/custom_chat_list_view.dart';
// import 'package:chat_gemini_app/feature/chat/ui/view/widget/custom_text_field.dart';
// import 'package:chat_gemini_app/feature/chat/ui/view_model/chat_cubit/chat_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class ChatScreen extends StatefulWidget {
//   const ChatScreen({super.key});

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   late final TextEditingController _messageController;
//   late final ScrollController _scrollController;
//   @override
//   void initState() {
//     super.initState();
//     BlocProvider.of<ChatCubit>(context).startChatSession();
//     _messageController = TextEditingController();
//     _scrollController = ScrollController();
//   }

//   @override
//   void dispose() {
//     _messageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _scrollDown() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: Duration(microseconds: 700),
//         curve: Curves.easeInOut,
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.chatBackground,
//       appBar: AppBar(title: const Text('Chat Screen')),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//           child: Column(
//             children: [
//               Expanded(
//                 child: CustomChatListView(scrollController: _scrollController),
//               ),
//               SizedBox(height: 24.0),

//               CustomTextField(
//                 messageController: _messageController,
//                 scrollDown: _scrollDown,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:chat_gemini_app/core/router/app_routes.dart';
import 'package:chat_gemini_app/core/utils/app_colors.dart';
import 'package:chat_gemini_app/feature/chat/ui/view/widget/custom_chat_list_view.dart';
import 'package:chat_gemini_app/feature/chat/ui/view/widget/custom_text_field.dart';
import 'package:chat_gemini_app/feature/chat/ui/view_model/chat_cubit/chat_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final TextEditingController _messageController;
  late final ScrollController _scrollController;
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ChatCubit>(context).startChatSession();

    _messageController = TextEditingController();
    _scrollController = ScrollController();
    _titleController = TextEditingController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(microseconds: 700),
        curve: Curves.easeInOut,
      );
    });
  }

  void _showSaveDialog() {
    final cubit = context.read<ChatCubit>();
    if (cubit.chatMessages.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No messages to save')));
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Save Conversation'),
            content: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Conversation Title',
                hintText: 'Enter a title for this conversation',
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_titleController.text.trim().isNotEmpty) {
                    cubit.saveConversation(_titleController.text.trim());
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.homeRoute,
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.chatBackground,
      appBar: AppBar(
        title: const Text('Chat with Gemini'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await context.read<ChatCubit>().resetState();
            Navigator.pop(context);
          },
        ),
        actions: [
          BlocBuilder<ChatCubit, ChatState>(
            buildWhen:
                (previous, current) =>
                    current is ChatSuccess && current.messages.isNotEmpty,

            builder: (context, state) {
              if (state is ChatSuccess && state.messages.isNotEmpty) {
                return IconButton(
                  onPressed: _showSaveDialog,
                  icon: const Icon(Icons.save),
                  tooltip: 'Save Conversation',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            children: [
              Expanded(
                child: CustomChatListView(scrollController: _scrollController),
              ),
              SizedBox(height: 24.0),
              CustomTextField(
                messageController: _messageController,
                scrollDown: _scrollDown,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
