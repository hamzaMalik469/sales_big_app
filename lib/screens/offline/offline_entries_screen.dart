import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../config/app_colors.dart';
import '../../config/routes.dart';
import '../../core/di/service_locator.dart';
import '../../core/utils/helpers.dart';
import '../../widgets/bid_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_widget.dart';
import 'offline_cubit.dart';
import 'offline_state.dart';

class OfflineEntriesScreen extends StatelessWidget {
  const OfflineEntriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OfflineCubit>()..loadOfflineEntries(),
      child: const OfflineEntriesView(),
    );
  }
}

class OfflineEntriesView extends StatelessWidget {
  const OfflineEntriesView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OfflineCubit, OfflineState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          showSuccessSnackBar(context, state.successMessage!);
        }
        if (state.errorMessage != null) {
          showErrorSnackBar(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Offline Entries'),
            centerTitle: true,
            backgroundColor: AppColors.surface,
            actions: [
              if (!state.isEmpty)
                IconButton(
                  onPressed: () =>
                      context.read<OfflineCubit>().loadOfflineEntries(),
                  icon: const Icon(Iconsax.refresh),
                ),
            ],
          ),
          body: Column(
            children: [
              // Info Banner
              if (!state.isEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  color: AppColors.warningLight,
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.info_circle,
                        color: AppColors.warning,
                        size: 20.w,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'These items are saved locally and waiting to be synced to the server.',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.warningDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // List
              Expanded(child: _buildContent(context, state)),
            ],
          ),
          bottomNavigationBar: !state.isEmpty
              ? _buildSyncButton(context, state)
              : null,
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, OfflineState state) {
    if (state.isLoading) {
      return const LoadingWidget();
    }

    if (state.isEmpty) {
      return EmptyState.offline(
        onRefresh: () => context.read<OfflineCubit>().loadOfflineEntries(),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: state.offlineBids.length,
      itemBuilder: (context, index) {
        final bid = state.offlineBids[index];
        return Dismissible(
          key: Key(bid.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20.w),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(Iconsax.trash, color: Colors.white, size: 24.w),
          ),
          confirmDismiss: (_) async {
            return await CustomDialog.showDeleteConfirmation(
              context: context,
              itemName: 'this offline entry',
            );
          },
          onDismissed: (_) {
            context.read<OfflineCubit>().deleteEntry(bid.id);
          },
          child: BidCard(
            bid: bid,
            showSyncStatus: true,
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.bidDetails,
                arguments: {'bidId': bid.id},
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSyncButton(BuildContext context, OfflineState state) {
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
          text: 'Sync All Now',
          icon: Iconsax.cloud_add,
          isLoading: state.isSyncing,
          onPressed: () => context.read<OfflineCubit>().syncAll(),
        ),
      ),
    );
  }
}
