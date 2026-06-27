import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../../config/app_colors.dart';
import '../../../config/constants.dart';
import '../../../config/routes.dart';
import '../../../models/user_model.dart';
import '../../../widgets/custom_dialog.dart';

class AppDrawer extends StatelessWidget {
  final UserModel? user;
  final int pendingSyncCount;
  final bool isOffline;
  final VoidCallback? onSyncTap;

  const AppDrawer({
    super.key,
    this.user,
    this.pendingSyncCount = 0,
    this.isOffline = false,
    this.onSyncTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24.r)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            Divider(height: 1, color: AppColors.border),

            // Menu Items
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Column(
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Iconsax.home_2,
                      title: 'Dashboard',
                      isSelected: true,
                      onTap: () => Navigator.pop(context),
                    ),

                    _buildMenuItem(
                      context,
                      icon: Iconsax.add_square,
                      title: 'Create New Bid',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.createBid);
                      },
                    ),

                    _buildMenuItem(
                      context,
                      icon: Iconsax.document_text,
                      title: 'My Bids',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.bidList);
                      },
                    ),

                    SizedBox(height: 8.h),
                    Divider(
                      height: 1,
                      color: AppColors.border,
                      indent: 20.w,
                      endIndent: 20.w,
                    ),
                    SizedBox(height: 8.h),

                    _buildMenuItem(
                      context,
                      icon: Iconsax.cloud,
                      title: 'Offline Entries',
                      badge: pendingSyncCount > 0
                          ? pendingSyncCount.toString()
                          : null,
                      badgeColor: AppColors.warning,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.offlineEntries);
                      },
                    ),

                    _buildMenuItem(
                      context,
                      icon: Iconsax.refresh,
                      title: 'Sync Status',
                      subtitle: isOffline ? 'Offline' : 'Online',
                      subtitleColor: isOffline
                          ? AppColors.warning
                          : AppColors.success,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.syncStatus);
                      },
                    ),

                    SizedBox(height: 8.h),
                    Divider(
                      height: 1,
                      color: AppColors.border,
                      indent: 20.w,
                      endIndent: 20.w,
                    ),
                    SizedBox(height: 8.h),

                    _buildMenuItem(
                      context,
                      icon: Iconsax.user,
                      title: 'Profile',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.profile);
                      },
                    ),

                    _buildMenuItem(
                      context,
                      icon: Iconsax.setting_2,
                      title: 'Settings',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRoutes.setting);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                user?.initials ?? 'U',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ),
          ),

          SizedBox(width: 14.w),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'User',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  user?.email ?? 'email@example.com',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    user?.role.toUpperCase() ?? 'SALESPERSON',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Edit Profile Button
          IconButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.profile);
            },
            icon: Icon(Iconsax.edit, size: 20.w, color: AppColors.grey500),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Color? subtitleColor,
    String? badge,
    Color? badgeColor,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
      child: Material(
        color: isSelected
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22.w,
                  color: isSelected ? AppColors.primary : AppColors.grey600,
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: subtitleColor ?? AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor ?? AppColors.primary,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          // Sync Button
          if (pendingSyncCount > 0)
            Container(
              margin: EdgeInsets.only(bottom: 16.h),
              child: Material(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(12.r),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    onSyncTap?.call();
                  },
                  borderRadius: BorderRadius.circular(12.r),
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Iconsax.cloud_add,
                            size: 18.w,
                            color: AppColors.warning,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$pendingSyncCount items pending',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.warningDark,
                                ),
                              ),
                              Text(
                                'Tap to sync now',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Iconsax.refresh,
                          size: 18.w,
                          color: AppColors.warning,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Logout Button
          Material(
            color: AppColors.errorLight,
            borderRadius: BorderRadius.circular(12.r),
            child: InkWell(
              onTap: () => _handleLogout(context),
              borderRadius: BorderRadius.circular(12.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.logout, size: 20.w, color: AppColors.error),
                    SizedBox(width: 10.w),
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Version
          Text(
            'Version ${AppConstants.appVersion}',
            style: TextStyle(fontSize: 11.sp, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await CustomDialog.showLogoutConfirmation(context);

    if (shouldLogout == true && context.mounted) {
      Navigator.pop(context); // Close drawer
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }
}
