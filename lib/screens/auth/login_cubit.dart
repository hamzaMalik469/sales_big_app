import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/validators.dart';
import '../../services/auth_service.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthService _authService;

  LoginCubit({required AuthService authService})
    : _authService = authService,
      super(const LoginState());

  /// Update email field
  void emailChanged(String value) {
    String? error;
    if (value.isNotEmpty) {
      error = Validators.email(value);
    }
    emit(state.copyWith(email: value, emailError: error, errorMessage: null));
  }

  /// Update password field
  void passwordChanged(String value) {
    String? error;
    if (value.isNotEmpty && value.length < 6) {
      error = 'Password must be at least 6 characters';
    }
    emit(
      state.copyWith(password: value, passwordError: error, errorMessage: null),
    );
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  /// Toggle remember me
  void toggleRememberMe() {
    emit(state.copyWith(rememberMe: !state.rememberMe));
  }

  /// Validate form
  bool _validateForm() {
    final emailError = Validators.email(state.email);
    final passwordError = state.password.length < 6
        ? 'Password must be at least 6 characters'
        : null;

    if (emailError != null || passwordError != null) {
      emit(
        state.copyWith(emailError: emailError, passwordError: passwordError),
      );
      return false;
    }

    return true;
  }

  /// Submit login
  Future<void> login() async {
    // Validate
    if (!_validateForm()) return;

    emit(state.copyWith(status: LoginStatus.loading, errorMessage: null));

    try {
      final response = await _authService.login(
        email: state.email.trim(),
        password: state.password,
      );

      if (response.success) {
        emit(state.copyWith(status: LoginStatus.success));
      } else {
        emit(
          state.copyWith(
            status: LoginStatus.failure,
            errorMessage: response.message ?? 'Login failed. Please try again.',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'An unexpected error occurred. Please try again.',
        ),
      );
    }
  }

  /// Clear error
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  /// Reset state
  void reset() {
    emit(const LoginState());
  }
}
