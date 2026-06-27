import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/local_storage.dart';
import '../../services/auth_service.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final AuthService _authService;
  final LocalStorageHelper _localStorage;

  ProfileCubit({
    required AuthService authService,
    required LocalStorageHelper localStorage,
  }) : _authService = authService,
       _localStorage = localStorage,
       super(const ProfileState()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading));

    try {
      // First, get cached user
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        emit(state.copyWith(status: ProfileStatus.success, user: currentUser));
      }

      // Then fetch latest from API
      final response = await _authService.getProfile();

      if (response.success && response.data != null) {
        emit(
          state.copyWith(status: ProfileStatus.success, user: response.data),
        );
      } else {
        // Only show error if we don't have cached data
        if (currentUser == null) {
          emit(
            state.copyWith(
              status: ProfileStatus.error,
              errorMessage: response.message,
            ),
          );
        }
      }
    } catch (e) {
      if (state.user == null) {
        emit(
          state.copyWith(
            status: ProfileStatus.error,
            errorMessage: 'Failed to load profile',
          ),
        );
      }
    }
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
  }) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    try {
      final response = await _authService.updateProfile(
        name: name,
        phone: phone,
      );

      if (response.success && response.data != null) {
        emit(
          state.copyWith(
            status: ProfileStatus.success,
            user: response.data,
            successMessage: 'Profile updated successfully',
            isEditing: false,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: ProfileStatus.error,
            errorMessage: response.message ?? 'Failed to update profile',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          errorMessage: 'An unexpected error occurred',
        ),
      );
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword != confirmPassword) {
      emit(state.copyWith(passwordError: 'Passwords do not match'));
      return;
    }

    emit(state.copyWith(status: ProfileStatus.loading, passwordError: null));

    try {
      final response = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (response.success) {
        emit(
          state.copyWith(
            status: ProfileStatus.success,
            successMessage: 'Password changed successfully',
            isChangingPassword: false,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: ProfileStatus.error,
            errorMessage: response.message ?? 'Failed to change password',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          errorMessage: 'An unexpected error occurred',
        ),
      );
    }
  }

  void toggleEditMode() {
    emit(state.copyWith(isEditing: !state.isEditing));
  }

  void toggleChangePassword() {
    emit(state.copyWith(isChangingPassword: !state.isChangingPassword));
  }

  Future<void> logout() async {
    await _authService.logout();
    // Navigation is handled in UI listener
  }
}
