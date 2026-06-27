import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../config/app_colors.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../core/di/service_locator.dart';
import '../../services/auth_service.dart';
import '../../services/bid_service.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/error_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('General'),
            _buildTile(
              title: 'Notifications',
              icon: Iconsax.notification,
              trailing: Switch(
                value: _notificationsEnabled,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setState(() => _notificationsEnabled = val);
                  showInfoSnackBar(
                    context,
                    val ? 'Notifications Enabled' : 'Notifications Disabled',
                  );
                },
              ),
            ),
            _buildTile(
              title: 'Dark Mode',
              icon: Iconsax.moon,
              trailing: Switch(
                value: _darkMode,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setState(() => _darkMode = val);
                  showInfoSnackBar(context, 'Theme switching coming soon!');
                },
              ),
            ),

            SizedBox(height: 24.h),

            _buildSectionHeader('Data & Storage'),
            _buildTile(
              title: 'Sync Status',
              icon: Iconsax.refresh,
              onTap: () => Navigator.pushNamed(context, AppRoutes.syncStatus),
            ),
            _buildTile(
              title: 'Clear Local Data',
              icon: Iconsax.trash,
              iconColor: AppColors.error,
              textColor: AppColors.error,
              onTap: () => _handleClearData(context),
            ),

            SizedBox(height: 24.h),

            _buildSectionHeader('About'),
            _buildTile(
              title: 'Privacy Policy',
              icon: Iconsax.shield_tick,
              onTap: () {},
            ),
            _buildTile(
              title: 'Terms of Service',
              icon: Iconsax.document_text,
              onTap: () {},
            ),
            _buildTile(
              title: 'App Version',
              icon: Iconsax.info_circle,
              trailing: Text(
                'v${AppConstants.appVersion}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            SizedBox(height: 32.h),

            // Logout Button
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: ElevatedButton.icon(
                onPressed: () => _handleLogout(context),
                icon: const Icon(Iconsax.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error.withOpacity(0.1),
                  foregroundColor: AppColors.error,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, left: 4.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildTile({
    required String title,
    required IconData icon,
    VoidCallback? onTap,
    Widget? trailing,
    Color? iconColor,
    Color? textColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.primary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, size: 20.w, color: iconColor ?? AppColors.primary),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
            color: textColor ?? AppColors.textPrimary,
          ),
        ),
        trailing:
            trailing ??
            (onTap != null
                ? Icon(
                    Iconsax.arrow_right_3,
                    size: 18.w,
                    color: AppColors.grey400,
                  )
                : null),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await CustomDialog.showLogoutConfirmation(context);

    if (shouldLogout == true && context.mounted) {
      await sl<AuthService>().logout();
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  Future<void> _handleClearData(BuildContext context) async {
    final confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: 'Clear Local Data?',
      message:
          'This will remove all locally saved bids that haven\'t been synced. This action cannot be undone.',
      confirmText: 'Clear Data',
      isDanger: true,
    );

    if (confirmed == true && context.mounted) {
      await sl<BidService>().clearAllLocalBids();
      showSuccessSnackBar(context, 'Local data cleared');
    }
  }
}
