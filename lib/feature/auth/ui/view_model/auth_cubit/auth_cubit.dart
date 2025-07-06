import 'package:chat_gemini_app/core/service/fire_base_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._auth) : super(AuthInitial());
  final FireBaseServices _auth;
  Future<void> login(String email, String password) async {
    emit(AuthLoginLoading());
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      emit(AuthLoginSuccess(userCredential.user!));
    } on FirebaseAuthException catch (e) {
      // ده اللي بيمسك خطأ like: invalid-email, weak-password, etc.
      emit(AuthLoginrError(e.message ?? 'حدث خطأ غير متوقع'));
    } catch (e) {
      emit(AuthLoginrError(e.toString()));
    }
  }

  Future<void> register(String email, String password) async {
    emit(AuthRegesterLoading());
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      emit(AuthRegesterSuccess(userCredential.user!));
    } on FirebaseAuthException catch (e) {
      // ده اللي بيمسك خطأ like: invalid-email, weak-password, etc.
      emit(AuthRegesterError(e.message ?? 'حدث خطأ غير متوقع'));
    } catch (e) {
      emit(AuthRegesterError(e.toString()));
    }
  }
}
