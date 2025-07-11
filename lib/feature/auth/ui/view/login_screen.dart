import 'package:chat_gemini_app/feature/auth/ui/view/widget/custom_clip_path.dart';
import 'package:chat_gemini_app/feature/auth/ui/view/widget/custom_login_form_field.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const CustomClipPath(title: "Login"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: CustomLoginFormField(),
            ),
          ],
        ),
      ),
    );
  }
}
