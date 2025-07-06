import 'package:chat_gemini_app/core/DI/setup_get_it.dart';
import 'package:chat_gemini_app/chat_app.dart';
import 'package:chat_gemini_app/core/model/conversation_hive_model.dart';
import 'package:chat_gemini_app/core/model/message_hive_model.dart';
import 'package:chat_gemini_app/feature/chat/ui/view_model/chat_cubit/chat_cubit.dart';
import 'package:chat_gemini_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();

  Hive.registerAdapter(ConversationHiveModelAdapter());
  Hive.registerAdapter(MessageHiveModelAdapter());

  await setupGetIt();

  runApp(
    BlocProvider(
      create: (context) => getIt<ChatCubit>(),
      child: const ChatApp(),
    ),
  );
}
