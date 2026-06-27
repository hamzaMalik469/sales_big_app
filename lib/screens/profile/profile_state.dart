import '../../models/user_model.dart';

enum ProfileStatus { initial, loading, success, error }

class ProfileState {
  final ProfileStatus status;
  final UserModel? user;
  final String? errorMessage;
  final String? successMessage;
  final bool isEditing;

  // Change Password Fields
  final bool isChangingPassword;
  final String? passwordError;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.errorMessage,
    this.successMessage,
    this.isEditing = false,
    this.isChangingPassword = false,
    this.passwordError,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    UserModel? user,
    String? errorMessage,
    String? successMessage,
    bool? isEditing,
    bool? isChangingPassword,
    String? passwordError,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isEditing: isEditing ?? this.isEditing,
      isChangingPassword: isChangingPassword ?? this.isChangingPassword,
      passwordError: passwordError,
    );
  }

  bool get isLoading => status == ProfileStatus.loading;
}
