import 'package:chat_gemini_app/feature/auth/ui/view/widget/custom_clip_path.dart';
import 'package:chat_gemini_app/feature/auth/ui/view/widget/custom_regester_form_field.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const CustomClipPath(title: "Register"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: CustomRegesterFormField(),
            ),
          ],
        ),
      ),
    );
  }
}
