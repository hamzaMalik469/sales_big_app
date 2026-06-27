import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../config/app_colors.dart';
import '../../core/di/service_locator.dart';
import '../../core/utils/helpers.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_widget.dart';
import 'profile_cubit.dart';
import 'profile_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileCubit>(), // Ensure Factory is registered in DI
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Password controllers
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          showSuccessSnackBar(context, state.successMessage!);
        }
        if (state.errorMessage != null) {
          showErrorSnackBar(context, state.errorMessage!);
        }

        // Populate controllers when user loads
        if (state.user != null && !state.isEditing) {
          _nameController.text = state.user!.name;
          _phoneController.text = state.user!.phone ?? '';
        }
      },
      builder: (context, state) {
        if (state.user == null && state.isLoading) {
          return const Scaffold(body: LoadingWidget());
        }

        final user = state.user;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('My Profile'),
            centerTitle: true,
            backgroundColor: AppColors.surface,
            elevation: 0,
            actions: [
              if (!state.isEditing && !state.isChangingPassword)
                IconButton(
                  onPressed: () =>
                      context.read<ProfileCubit>().toggleEditMode(),
                  icon: const Icon(Iconsax.edit),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                // Avatar Section
                _buildAvatarSection(user?.initials ?? 'U'),

                SizedBox(height: 32.h),

                // Form Section
                if (state.isChangingPassword)
                  _buildPasswordForm(context, state)
                else
                  _buildProfileForm(context, state, user?.email ?? ''),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomBar(context, state),
        );
      },
    );
  }

  Widget _buildAvatarSection(String initials) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(
                Iconsax.camera,
                size: 18.w,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm(
    BuildContext context,
    ProfileState state,
    String email,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: _nameController,
          label: 'Full Name',
          prefixIcon: Iconsax.user,
          enabled: state.isEditing,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: _phoneController,
          label: 'Phone Number',
          prefixIcon: Iconsax.call,
          keyboardType: TextInputType.phone,
          enabled: state.isEditing,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          initialValue: email,
          label: 'Email Address',
          prefixIcon: Iconsax.sms,
          enabled: false, // Email usually cannot be changed easily
          fillColor: AppColors.grey100,
        ),

        if (!state.isEditing) ...[
          SizedBox(height: 32.h),
          ListTile(
            onTap: () => context.read<ProfileCubit>().toggleChangePassword(),
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Iconsax.lock, color: AppColors.primary, size: 20.w),
            ),
            title: Text(
              'Change Password',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            trailing: Icon(
              Iconsax.arrow_right_3,
              size: 18.w,
              color: AppColors.grey400,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPasswordForm(BuildContext context, ProfileState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Change Password',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 20.h),
        CustomTextField(
          controller: _currentPassController,
          label: 'Current Password',
          prefixIcon: Iconsax.lock,
          isPassword: true,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: _newPassController,
          label: 'New Password',
          prefixIcon: Iconsax.lock,
          isPassword: true,
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: _confirmPassController,
          label: 'Confirm New Password',
          prefixIcon: Iconsax.lock,
          isPassword: true,
          errorText: state.passwordError,
        ),
      ],
    );
  }

  Widget? _buildBottomBar(BuildContext context, ProfileState state) {
    if (!state.isEditing && !state.isChangingPassword) return null;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Cancel',
                type: ButtonType.outlined,
                onPressed: () {
                  if (state.isChangingPassword) {
                    context.read<ProfileCubit>().toggleChangePassword();
                    _currentPassController.clear();
                    _newPassController.clear();
                    _confirmPassController.clear();
                  } else {
                    context.read<ProfileCubit>().toggleEditMode();
                    // Reset fields
                    if (state.user != null) {
                      _nameController.text = state.user!.name;
                      _phoneController.text = state.user!.phone ?? '';
                    }
                  }
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: CustomButton(
                text: 'Save Changes',
                isLoading: state.isLoading,
                onPressed: () {
                  if (state.isChangingPassword) {
                    context.read<ProfileCubit>().changePassword(
                      currentPassword: _currentPassController.text,
                      newPassword: _newPassController.text,
                      confirmPassword: _confirmPassController.text,
                    );
                  } else {
                    context.read<ProfileCubit>().updateProfile(
                      name: _nameController.text,
                      phone: _phoneController.text,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
