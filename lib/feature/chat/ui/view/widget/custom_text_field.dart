import 'package:chat_gemini_app/core/utils/app_colors.dart';
import 'package:chat_gemini_app/feature/chat/ui/view/widget/custom_icon_button_send.dart';
import 'package:chat_gemini_app/feature/chat/ui/view_model/chat_cubit/chat_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required TextEditingController messageController,
    required this.scrollDown,
  }) : _messageController = messageController;
  final VoidCallback? scrollDown;
  final TextEditingController _messageController;

  @override
  Widget build(BuildContext context) {
    void showOptions() {
      showCupertinoModalPopup(
        context: context,
        builder: (_) {
          return CupertinoActionSheet(
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  BlocProvider.of<ChatCubit>(context).pickImageFromGallery();
                },
                child: Text('Pick from Gallery'),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  BlocProvider.of<ChatCubit>(context).pickImageFromCamera();
                },
                child: Text('Take a Photo'),
              ),
            ],
            // cancelButton: CupertinoActionSheetAction(
            //   onPressed: () => Navigator.pop(context),
            //   child: Text('Cancel'),
            // ),
          );
        },
      );
    }

    final size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<ChatCubit, ChatState>(
          buildWhen:
              (previous, current) =>
                  current is ImagePicker || current is ImageRemoved,
          builder: (context, state) {
            if (state is ImagePicker) {
              return Container(
                height: 200,
                width: size.width - 90,
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Image.file(
                          state.imagePath,
                          fit: BoxFit.cover,
                          width: size.width - 90,
                          height: 200,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: InkWell(
                            onTap: () {
                              BlocProvider.of<ChatCubit>(context).removeImage();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        SizedBox(height: 8.0),
        Row(
          children: [
            Expanded(
              child: TextField(
                minLines: 1,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                controller: _messageController,

                onSubmitted: (message) {
                  if (message.trim().isNotEmpty) {
                    BlocProvider.of<ChatCubit>(
                      context,
                    ).sendMessage(_messageController.text);
                    _messageController.clear();
                    scrollDown?.call();
                  }
                },
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () {
                      showOptions();
                    },
                    icon: Icon(Icons.attachment),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  filled: true,
                  fillColor: AppColors.inputBackground,
                  hintText: 'Type your message here...',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: .5, color: Colors.white),
                    borderRadius: BorderRadius.all(Radius.circular(16.0)),
                  ),
                ),
              ),
            ),

            SizedBox(width: 8.0),
            CustomIconButtonSend(
              messageController: _messageController,
              scrollDown: scrollDown,
            ),
          ],
        ),
      ],
    );
  }
}
