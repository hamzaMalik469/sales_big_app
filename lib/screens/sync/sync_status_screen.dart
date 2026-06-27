import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';

import '../../config/app_colors.dart';
import '../../core/di/service_locator.dart';
import '../../core/utils/helpers.dart';
import '../../services/sync_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/offline_banner.dart';
import 'sync_cubit.dart';
import 'sync_state.dart';

class SyncStatusScreen extends StatelessWidget {
  const SyncStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SyncCubit>(),
      child: const SyncStatusView(),
    );
  }
}

class SyncStatusView extends StatelessWidget {
  const SyncStatusView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncCubit, SyncScreenState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Sync Status'),
            centerTitle: true,
            backgroundColor: AppColors.surface,
            elevation: 0,
          ),
          body: Column(
            children: [
              // Connection Status
              ConnectionStatusWidget(
                isConnected: state.isConnected,
                onCheckConnection: () {},
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Status Icon
                      _buildStatusIcon(state.status),

                      SizedBox(height: 32.h),

                      // Status Title
                      Text(
                        _getStatusTitle(state.status),
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      SizedBox(height: 12.h),

                      // Status Message
                      Text(
                        state.status.message ?? _getStatusMessage(state.status),
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 48.h),

                      // Progress Stats
                      if (state.status.totalItems > 0)
                        _buildProgressStats(state.status),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(context, state),
        );
      },
    );
  }

  Widget _buildStatusIcon(SyncStatus status) {
    IconData icon;
    Color color;
    bool isAnimating = false;

    switch (status.state) {
      case SyncState.idle:
        icon = Iconsax.cloud;
        color = AppColors.primary;
        break;
      case SyncState.syncing:
        icon = Iconsax.refresh;
        color = AppColors.info;
        isAnimating = true;
        break;
      case SyncState.success:
        icon = Iconsax.tick_circle;
        color = AppColors.success;
        break;
      case SyncState.error:
        icon = Iconsax.warning_2;
        color = AppColors.error;
        break;
    }

    Widget iconWidget = Container(
      width: 120.w,
      height: 120.w,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.2), width: 2),
      ),
      child: Icon(icon, size: 56.w, color: color),
    );

    if (isAnimating) {
      return iconWidget
          .animate(onPlay: (controller) => controller.repeat())
          .rotate(duration: 2.seconds);
    }

    return iconWidget.animate().scale(
      begin: const Offset(0.8, 0.8),
      curve: Curves.elasticOut,
      duration: 600.ms,
    );
  }

  Widget _buildProgressStats(SyncStatus status) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStatRow('Total Items', status.totalItems.toString()),
          Divider(height: 24.h, color: AppColors.border),
          _buildStatRow(
            'Synced',
            status.syncedItems.toString(),
            color: AppColors.success,
          ),
          SizedBox(height: 12.h),
          _buildStatRow(
            'Failed',
            status.failedItems.toString(),
            color: AppColors.error,
          ),
          SizedBox(height: 12.h),
          _buildStatRow(
            'Pending',
            status.pendingItems.toString(),
            color: AppColors.warning,
          ),

          if (status.isSyncing) ...[
            SizedBox(height: 20.h),
            LinearProgressIndicator(
              value: status.progress,
              backgroundColor: AppColors.grey100,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              minHeight: 6.h,
              borderRadius: BorderRadius.circular(3.r),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, SyncScreenState state) {
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
        child: CustomButton(
          text: state.status.isSyncing ? 'Syncing...' : 'Sync Now',
          icon: state.status.isSyncing ? null : Iconsax.refresh,
          isLoading: state.status.isSyncing,
          isDisabled: !state.isConnected,
          onPressed: () => context.read<SyncCubit>().startSync(),
        ),
      ),
    );
  }

  String _getStatusTitle(SyncStatus status) {
    switch (status.state) {
      case SyncState.idle:
        return status.pendingItems > 0 ? 'Pending Sync' : 'Up to Date';
      case SyncState.syncing:
        return 'Syncing Data...';
      case SyncState.success:
        return 'Sync Complete';
      case SyncState.error:
        return 'Sync Error';
    }
  }

  String _getStatusMessage(SyncStatus status) {
    switch (status.state) {
      case SyncState.idle:
        return status.pendingItems > 0
            ? 'You have items waiting to be synced.'
            : 'All your data is synchronized with the server.';
      case SyncState.syncing:
        return 'Please wait while we upload your changes.';
      case SyncState.success:
        return 'Your data has been successfully updated.';
      case SyncState.error:
        return 'Some items failed to sync. Please try again.';
    }
  }
}
