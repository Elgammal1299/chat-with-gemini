import 'package:chat_gemini_app/core/router/app_routes.dart';
import 'package:chat_gemini_app/core/utils/app_colors.dart';
import 'package:chat_gemini_app/core/widget/custom_elevated_button.dart';
import 'package:chat_gemini_app/core/widget/custom_text_form.dart';
import 'package:chat_gemini_app/feature/auth/ui/view/widget/custom_switch_auth_mode.dart';
import 'package:chat_gemini_app/feature/auth/ui/view_model/auth_cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomRegesterFormField extends StatefulWidget {
  const CustomRegesterFormField({super.key});

  @override
  State<CustomRegesterFormField> createState() =>
      _CustomRegesterFormFieldState();
}

class _CustomRegesterFormFieldState extends State<CustomRegesterFormField> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // final TextEditingController _nameController = TextEditingController();
  // final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: BlocConsumer<AuthCubit, AuthState>(
        listenWhen:
            (previous, current) =>
                current is AuthRegesterLoading ||
                current is AuthRegesterError ||
                current is AuthRegesterSuccess,
        listener: (context, state) {
          if (state is AuthRegesterLoading) {
            showDialog(
              context: context,
              barrierDismissible: false, // يمنع الإغلاق بالضغط خارج الديالوج
              builder: (context) {
                return const Center(child: CircularProgressIndicator());
              },
            );
          } else if (state is AuthRegesterSuccess) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.homeRoute,
              (route) => false,
            );
          } else if (state is AuthRegesterError) {
            Navigator.pop(context);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
          }
        },
        buildWhen: (previous, current) => current is AuthRegesterLoading,
        builder: (context, state) {
          return Column(
            children: [
              CustomTextForm(
                controller: _emailController,
                hintText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              const SizedBox(height: 12),
              CustomTextForm(
                hintText: 'Name',
                prefixIcon: const Icon(Icons.person),
              ),
              const SizedBox(height: 12),
              CustomTextForm(
                hintText: 'Phone Number',
                prefixIcon: const Icon(Icons.phone),
              ),
              const SizedBox(height: 12),
              CustomTextForm(
                isObscureText: true,
                controller: _passwordController,
                hintText: 'Password',
                prefixIcon: const Icon(Icons.visibility_off),
              ),
              const SizedBox(height: 20),

              // الزر أو اللودينج
              CustomElevatedButton(
                text: 'Register',
                borderColor: AppColors.timeTextColor,
                textStyle: TextStyle(
                  color: AppColors.inputBackground,
                  fontSize: 20,
                ),
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    context.read<AuthCubit>().register(
                      _emailController.text,
                      _passwordController.text,
                    );
                  }
                },
              ),

              const SizedBox(height: 16),
              CustomSwitchAuthMode(
                onToggle: () {
                  Navigator.pushNamed(context, AppRoutes.loginRoute);
                },
                title: 'تسجيل الدخول',
              ),
            ],
          );
        },
      ),
    );
  }
}
