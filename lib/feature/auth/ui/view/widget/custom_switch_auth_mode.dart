import 'package:chat_gemini_app/core/utils/app_colors.dart';
import 'package:flutter/material.dart';

class CustomSwitchAuthMode extends StatelessWidget {
  const CustomSwitchAuthMode({
    super.key,
    required this.onToggle,
    required this.title,
  });
  final void Function() onToggle;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {
            onToggle();
          },
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          'هل لديك حساب بالفعل؟ ',
          style: TextStyle(
            fontSize: 20,
            color: AppColors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
