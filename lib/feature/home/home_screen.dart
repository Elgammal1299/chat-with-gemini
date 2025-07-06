import 'package:chat_gemini_app/core/DI/setup_get_it.dart';
import 'package:chat_gemini_app/core/router/app_routes.dart';
import 'package:chat_gemini_app/core/utils/app_colors.dart';
import 'package:chat_gemini_app/feature/chat/data/model/conversation_model.dart';
import 'package:chat_gemini_app/feature/chat/ui/view/chat_screen.dart';
import 'package:chat_gemini_app/feature/chat/ui/view_model/chat_cubit/chat_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<ChatCubit>()..loadConversations(),
      child: const HomeScreenView(),
    );
  }
}

class HomeScreenView extends StatelessWidget {
  const HomeScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chat with Gemini',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
      ),
      body: BlocBuilder<ChatCubit, ChatState>(
        buildWhen:
            (previous, current) =>
                current is ConversationsLoaded || current is ChatError,
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ConversationsLoaded) {
            return _buildHomeContent(context, state.conversations);
          }

          if (state is ChatError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.error}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ChatCubit>().loadConversations();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Default state - show loading
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildHomeContent(
    BuildContext context,
    List<ConversationModel> conversations,
  ) {
    return Column(
      children: [
        // Start New Chat Button
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => _startNewChat(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, size: 24),
                SizedBox(width: 8),
                Text(
                  'Start New Chat',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),

        // Divider
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: const Divider(thickness: 1),
        ),

        // Past Conversations
        Expanded(
          child:
              conversations.isEmpty
                  ? _buildEmptyState()
                  : _buildConversationsList(context, conversations),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your first chat with Gemini!',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsList(
    BuildContext context,
    List<ConversationModel> conversations,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return _buildConversationTile(context, conversation);
      },
    );
  }

  Widget _buildConversationTile(
    BuildContext context,
    ConversationModel conversation,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryColor,
          child: Icon(Icons.chat_outlined, color: Colors.white, size: 20),
        ),
        title: Text(
          conversation.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              conversation.lastMessagepreview,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(conversation.createdAt),
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              _deleteConversation(context, conversation.id);
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
        ),
        onTap: () => _openConversation(context, conversation.id),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(date);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  void _startNewChat(BuildContext context) {
    final cubit = context.read<ChatCubit>();

    // Check if there's an unsaved conversation
    if (cubit.hasUnsavedConversation()) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Unsaved Conversation'),
              content: const Text(
                'You have an unsaved conversation. Would you like to continue it or start a new one?',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    cubit.continueUnsavedConversation();
                    Navigator.pushNamed(context, AppRoutes.chatRoute);
                  },
                  child: const Text('Continue'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    cubit.createNewConversation();
                    Navigator.pushNamed(context, AppRoutes.chatRoute);
                  },
                  child: const Text('New Chat'),
                ),
              ],
            ),
      );
    } else {
      cubit.createNewConversation();
      Navigator.pushNamed(context, AppRoutes.chatRoute);
    }
  }

  void _openConversation(BuildContext context, String conversationId) {
    final cubit = context.read<ChatCubit>();
    cubit.loadConversation(conversationId).then((_) {
      Navigator.pushNamed(context, AppRoutes.chatRoute);
    });
  }

  void _deleteConversation(BuildContext context, String conversationId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Conversation'),
            content: const Text(
              'Are you sure you want to delete this conversation? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  context.read<ChatCubit>().deleteConversation(conversationId);
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
