import 'package:chat_gemini_app/core/DI/setup_get_it.dart';
import 'package:chat_gemini_app/core/router/app_routes.dart';
import 'package:chat_gemini_app/feature/auth/ui/view/register_screen.dart';
import 'package:chat_gemini_app/feature/auth/ui/view/login_screen.dart';
import 'package:chat_gemini_app/feature/auth/ui/view_model/auth_cubit/auth_cubit.dart';
import 'package:chat_gemini_app/feature/chat/ui/view/chat_screen.dart';
import 'package:chat_gemini_app/feature/chat/ui/view_model/chat_cubit/chat_cubit.dart';
import 'package:chat_gemini_app/feature/home/home_screen.dart';
import 'package:chat_gemini_app/feature/splah_screen/splah_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppRouter {
  static Route? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splachRoute:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case AppRoutes.homeRoute:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case AppRoutes.regesterRoute:
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create: (context) => getIt<AuthCubit>(),
                child: RegisterScreen(),
              ),
        );
      case AppRoutes.loginRoute:
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider(
                create: (context) => getIt<AuthCubit>(),
                child: LoginScreen(),
              ),
        );
      case AppRoutes.chatRoute:
        return MaterialPageRoute(
          builder:
              (_) => BlocProvider.value(
                value: getIt<ChatCubit>(),
                child: const ChatScreen(),
              ),
        );
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(body: Center(child: Text('لا يوجد بيانات '))),
        );
    }
  }
}
