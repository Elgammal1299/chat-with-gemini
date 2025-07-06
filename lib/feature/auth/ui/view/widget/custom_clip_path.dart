
import 'package:chat_gemini_app/core/helper/auth_clip.dart' show TsClip1;
import 'package:chat_gemini_app/core/utils/app_colors.dart';
import 'package:flutter/material.dart';

class CustomClipPath extends StatelessWidget {
  const CustomClipPath({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: TsClip1(),
      child: Container(
        padding: const EdgeInsets.only(bottom: 38),
        alignment: Alignment.center,
        width: double.infinity,
        height: 150,
        color: AppColors.primaryColor,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
