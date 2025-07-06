import 'package:chat_gemini_app/core/service/chat_service.dart';
import 'package:chat_gemini_app/core/service/fire_base_services.dart';
import 'package:chat_gemini_app/feature/auth/ui/view_model/auth_cubit/auth_cubit.dart';
import 'package:chat_gemini_app/feature/chat/data/repo/chat_repo.dart';
import 'package:chat_gemini_app/feature/chat/data/service/chat_ai_service.dart';
import 'package:chat_gemini_app/feature/chat/ui/view_model/chat_cubit/chat_cubit.dart';
import 'package:get_it/get_it.dart';

/// This is the dependency injection file for the app.
final getIt = GetIt.instance;

Future<void> setupGetIt() async {
  // Dio Instance
  // Dio dio = await DioFactory.getDio();

  // ✅ Register ChatService
  getIt.registerLazySingleton<ChatService>(() => ChatService());

  // ✅ Register ChatRepo
  getIt.registerLazySingleton<ChatRepo>(() => ChatRepo(getIt<ChatService>()));

  // ✅ Register ChatAIService
  getIt.registerLazySingleton<ChatAIService>(
    () => ChatAIService(getIt<ChatRepo>()),
  );

  // ✅ Register ChatCubit
  getIt.registerLazySingleton<ChatCubit>(
    () => ChatCubit(getIt<ChatAIService>()),
  );

  // ✅ Register FireBaseServices
  getIt.registerLazySingleton<FireBaseServices>(() => FireBaseServices());

  // ✅ Register AuthCubit
  getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt<FireBaseServices>()));
}
