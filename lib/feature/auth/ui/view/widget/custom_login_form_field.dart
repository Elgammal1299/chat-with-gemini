import 'package:chat_gemini_app/core/utils/app_colors.dart';
import 'package:chat_gemini_app/core/widget/custom_elevated_button.dart';
import 'package:chat_gemini_app/core/widget/custom_text_form.dart';
import 'package:chat_gemini_app/feature/auth/ui/view/widget/custom_switch_auth_mode.dart';
import 'package:flutter/material.dart';

class CustomLoginFormField extends StatefulWidget {
  const CustomLoginFormField({super.key});

  @override
  State<CustomLoginFormField> createState() => _CustomLoginFormFieldState();
}

class _CustomLoginFormFieldState extends State<CustomLoginFormField> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextForm(
            hintText: 'Email',
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          const SizedBox(height: 12),
          CustomTextForm(
            isObscureText: true,

            hintText: 'Password',
            prefixIcon: const Icon(Icons.visibility_off),
          ),
          const SizedBox(height: 20),
          CustomElevatedButton(
            text: 'Login',
            borderColor: AppColors.timeTextColor,
            textStyle: TextStyle(
              color: AppColors.inputBackground,
              fontSize: 20,
            ),
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                // login logic
              }
            },
          ),
          const SizedBox(height: 16),
          CustomSwitchAuthMode(
            onToggle: () {
              Navigator.pop(context);
            },
            title: 'إنشاء حساب',
          ),
        ],
      ),
    );
  }
}
