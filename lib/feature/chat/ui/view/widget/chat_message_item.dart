import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chat_gemini_app/core/utils/app_colors.dart';
import 'package:chat_gemini_app/feature/chat/data/model/message_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatMessageItem extends StatelessWidget {
  final MessageModel messageModel;
  const ChatMessageItem({super.key, required this.messageModel});

  @override
  Widget build(BuildContext context) {
    final messageTime =
        messageModel.timestamp.day == DateTime.now().day &&
                messageModel.timestamp.month == DateTime.now().month &&
                messageModel.timestamp.year == DateTime.now().year
            ? DateFormat('hh:mm a').format(messageModel.timestamp.toLocal())
            : DateFormat(
              'dd/MM/yyyy hh:mm a',
            ).format(messageModel.timestamp.toLocal());
    return Align(
      alignment:
          messageModel.isUser ? Alignment.centerLeft : Alignment.centerRight,
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 100,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (messageModel.isUser)
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue[200],
                child: const Icon(Icons.person, color: Colors.white),
              ),
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(12.0),

                    topRight: const Radius.circular(12.0),

                    bottomRight:
                        messageModel.isUser
                            ? const Radius.circular(12.0)
                            : const Radius.circular(0.0),
                    bottomLeft:
                        messageModel.isUser
                            ? const Radius.circular(0.0)
                            : const Radius.circular(12.0),
                  ),
                ),
                color:
                    messageModel.isUser
                        ? AppColors.userMessageColor
                        : AppColors.otherMessageColor,
                margin: const EdgeInsets.symmetric(
                  vertical: 4.0,
                  horizontal: 8.0,
                ),

                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      messageModel.isUser
                          ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (messageModel.image != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.file(
                                      messageModel.image!,
                                      height: 175,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              Text(
                                messageModel.content,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: AppColors.messageTextColor,
                                ),
                              ),
                            ],
                          )
                          : AnimatedTextKit(
                            repeatForever: false,
                            totalRepeatCount: 1,
                            animatedTexts: [
                              TyperAnimatedText(
                                messageModel.content,
                                textStyle: TextStyle(
                                  fontSize: 16.0,
                                  color: AppColors.messageTextColor,
                                ),
                                speed: const Duration(milliseconds: 50),
                              ),
                            ],
                          ),
                      const SizedBox(height: 4.0),
                      Text(
                        messageTime.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.timeTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
