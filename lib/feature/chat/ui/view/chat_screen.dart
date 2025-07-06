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
      // Add a small delay to ensure the ListView is properly built
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients &&
            _scrollController.position.maxScrollExtent > 0) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOut,
          );
        }
      });
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
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Save Conversation'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Conversation Title',
                    hintText: 'Enter a title for this conversation',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                BlocBuilder<ChatCubit, ChatState>(
                  buildWhen: (previous, current) => current is ChatLoading,
                  builder: (context, state) {
                    if (state is ChatLoading) {
                      return const Row(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 16),
                          Text('Saving...'),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              BlocBuilder<ChatCubit, ChatState>(
                buildWhen: (previous, current) => current is ChatLoading,
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed:
                        state is ChatLoading
                            ? null
                            : () {
                              if (_titleController.text.trim().isNotEmpty) {
                                cubit.saveConversation(
                                  _titleController.text.trim(),
                                );
                                // Don't close dialog immediately, let the loading state handle it
                              }
                            },
                    child: const Text('Save'),
                  );
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatCubit, ChatState>(
      listenWhen:
          (previous, current) =>
              current is ChatSuccess ||
              current is ChatError ||
              current is ConversationsLoaded,
      listener: (context, state) {
        if (state is ChatSuccess) {
          // Check if we're in a save operation context
          if (_titleController.text.isNotEmpty) {
            Navigator.pop(context); // Close dialog
            Navigator.pop(context); // Go back to home screen
            _titleController.clear();
          }
        } else if (state is ChatError) {
          // Show error and close dialog
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
          Navigator.pop(context); // Close dialog
          _titleController.clear();
        } else if (state is ConversationsLoaded) {
          // Check if current conversation was deleted
          final cubit = context.read<ChatCubit>();
          if (cubit.isCurrentConversationDeleted()) {
            cubit.clearCurrentConversation();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('This conversation has been deleted'),
              ),
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.chatBackground,
        appBar: AppBar(
          title: const Text('Chat with Gemini'),
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              print('🔙 Back button pressed in chat screen');
              // Handle chat screen back navigation properly
              final cubit = context.read<ChatCubit>();
              await cubit.handleChatScreenBack();
              Navigator.pop(context);
              print('🔙 Navigated back to home screen');
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
            IconButton(
              onPressed: () {
                context.read<ChatCubit>().debugTestImageProcessing();
              },
              icon: const Icon(Icons.image),
              tooltip: 'Test Image Processing',
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Column(
              children: [
                Expanded(
                  child: CustomChatListView(
                    scrollController: _scrollController,
                  ),
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
      ),
    );
  }
}
