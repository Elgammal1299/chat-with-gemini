import 'package:chat_gemini_app/core/utils/app_colors.dart';
import 'package:chat_gemini_app/feature/chat/data/model/conversation_model.dart';
import 'package:chat_gemini_app/feature/chat/ui/view_model/chat_cubit/chat_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load conversations when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatCubit>().loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.chatBackground,
      appBar: AppBar(
        title: const Text(
          'Chat with Gemini',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showClearAllDialog(context),
            icon: const Icon(Icons.delete, color: Colors.white),
            tooltip: 'Clear All Data',
          ),
        ],
      ),
      body: BlocBuilder<ChatCubit, ChatState>(
        buildWhen: (previous, current) {
          print(
            '🏠 Home BlocBuilder buildWhen - Previous: $previous, Current: $current',
          );
          // Only rebuild for states that affect the home screen
          return current is ConversationsLoaded ||
              current is ChatError ||
              (current is ChatLoading && previous is! ChatLoading);
        },
        builder: (context, state) {
          print('🏠 Home BlocBuilder builder called with state: $state');
          if (state is ChatLoading) {
            print('🏠 Showing loading indicator');
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ConversationsLoaded) {
            print('🏠 Showing conversations: ${state.conversations.length}');
            return _buildHomeContent(context, state.conversations);
          }

          if (state is ChatError) {
            print('🏠 Showing error: ${state.error}');
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
          print('🏠 Showing default loading');
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
                Icon(Icons.chat_bubble_outline, size: 24),
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
      color: AppColors.otherMessageColor,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
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
              maxLines: 1,
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
            switch (value) {
              case 'open':
                _openConversation(context, conversation);
                break;
              case 'delete':
                _deleteConversation(context, conversation.id);
                break;
              case 'debug':
                _showConversationDebugInfo(context, conversation);
                break;
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'open',
                  child: Row(
                    children: [
                      Icon(Icons.open_in_new, size: 20),
                      SizedBox(width: 8),
                      Text('Open'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
        ),
        onTap: () => _openConversation(context, conversation),
      ),
    );
  }

  void _startNewChat(BuildContext context) {
    print('🆕 Start new chat button pressed');
    final cubit = context.read<ChatCubit>();
    cubit.createNewConversation();
    Navigator.pushNamed(context, '/chat');
  }

  void _openConversation(BuildContext context, ConversationModel conversation) {
    print('📂 Opening conversation: ${conversation.id}');
    final cubit = context.read<ChatCubit>();
    cubit.loadConversation(conversation.id);
    Navigator.pushNamed(context, '/chat');
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _deleteConversation(BuildContext context, String conversationId) {
    print('🗑️ Delete conversation called with ID: $conversationId');

    // Show confirmation dialog first
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Delete Conversation'),
            content: const Text(
              'Are you sure you want to delete this conversation? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  print('🗑️ Delete button pressed, starting deletion...');
                  Navigator.pop(dialogContext); // Close confirmation dialog

                  // Show loading dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder:
                        (loadingContext) => AlertDialog(
                          title: const Text('Deleting Conversation'),
                          content: const Row(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(width: 16),
                              Text('Please wait...'),
                            ],
                          ),
                        ),
                  );

                  try {
                    await context.read<ChatCubit>().deleteConversation(
                      conversationId,
                    );
                    Navigator.pop(context); // Close loading dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Conversation deleted successfully'),
                      ),
                    );
                  } catch (e) {
                    Navigator.pop(context); // Close loading dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting conversation: $e'),
                      ),
                    );
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear All Data'),
            content: const Text(
              'Are you sure you want to clear all conversations? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  print(
                    '🗑️ Clear all data button pressed, starting deletion...',
                  );
                  Navigator.pop(context); // Close confirmation dialog

                  // Show loading dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder:
                        (loadingContext) => AlertDialog(
                          title: const Text('Deleting all conversations'),
                          content: const Row(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(width: 16),
                              Text('Please wait...'),
                            ],
                          ),
                        ),
                  );

                  try {
                    await context.read<ChatCubit>().deleteAllConversations();
                    Navigator.pop(context); // Close loading dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('All conversations deleted successfully'),
                      ),
                    );
                  } catch (e) {
                    Navigator.pop(context); // Close loading dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting conversations: $e'),
                      ),
                    );
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Clear All Data'),
              ),
            ],
          ),
    );
  }

  void _showConversationDebugInfo(
    BuildContext context,
    ConversationModel conversation,
  ) {
    final cubit = context.read<ChatCubit>();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Conversation Debug Info'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('ID: ${conversation.id}'),
                  const SizedBox(height: 8),
                  Text('Title: ${conversation.title}'),
                  const SizedBox(height: 8),
                  Text('Last Message: ${conversation.lastMessagepreview}'),
                  const SizedBox(height: 8),
                  Text('Created: ${conversation.createdAt}'),
                  const SizedBox(height: 8),
                  Text('Is User: ${conversation.isUser}'),
                  const SizedBox(height: 16),
                  const Text(
                    'Actions:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      try {
                        await cubit.deleteConversation(conversation.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Conversation deleted successfully'),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Force Delete This Conversation'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}
