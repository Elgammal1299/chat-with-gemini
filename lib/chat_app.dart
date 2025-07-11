import 'package:chat_gemini_app/core/router/app_router.dart';
import 'package:chat_gemini_app/core/router/app_routes.dart';
import 'package:flutter/material.dart';

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat Gemini',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: AppRoutes.splachRoute,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
