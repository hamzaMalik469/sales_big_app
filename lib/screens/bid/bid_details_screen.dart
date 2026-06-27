import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../config/app_colors.dart';
import '../../config/routes.dart';
import '../../core/di/service_locator.dart';
import '../../core/utils/helpers.dart';
import '../../models/bid_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/status_chip.dart';
import 'bid_details_cubit.dart';
import 'bid_details_state.dart';

class BidDetailsScreen extends StatelessWidget {
  final String bidId;

  const BidDetailsScreen({super.key, required this.bidId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BidDetailsCubit>()..loadBid(bidId),
      child: const BidDetailsView(),
    );
  }
}

class BidDetailsView extends StatelessWidget {
  const BidDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BidDetailsCubit, BidDetailsState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          if (state.successMessage!.contains('deleted')) {
            Navigator.pop(context); // Go back after delete
            showSuccessSnackBar(context, state.successMessage!);
          } else {
            showSuccessSnackBar(context, state.successMessage!);
          }
        }

        if (state.errorMessage != null) {
          showErrorSnackBar(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(body: LoadingWidget());
        }

        if (state.hasError || state.bid == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Details')),
            body: CustomErrorWidget.general(
              message: state.errorMessage ?? 'Bid not found',
              onRetry: () => context.read<BidDetailsCubit>().loadBid(
                '',
              ), // ID is in closure
            ),
          );
        }

        final bid = state.bid!;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(context, bid),
          body: Column(
            children: [
              OfflineBanner(isOffline: state.isOffline),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card
                      _buildHeaderCard(bid),
                      SizedBox(height: 20.h),

                      // Items List
                      _buildItemsSection(bid),
                      SizedBox(height: 20.h),

                      // Financials
                      _buildFinancialSection(bid),

                      // Notes
                      if (bid.notes != null && bid.notes!.isNotEmpty) ...[
                        SizedBox(height: 20.h),
                        _buildNotesSection(bid),
                      ],

                      SizedBox(height: 100.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomSheet: _buildBottomBar(context, bid),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, BidModel bid) {
    return AppBar(
      title: const Text('Bid Details'),
      centerTitle: true,
      backgroundColor: AppColors.surface,
      elevation: 0,
      actions: [
        if (bid.canEdit)
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.editBid,
                arguments: {'bidId': bid.id},
              ).then((_) => context.read<BidDetailsCubit>().loadBid(bid.id));
            },
            icon: const Icon(Iconsax.edit),
          ),
        if (bid.canDelete)
          IconButton(
            onPressed: () => _confirmDelete(context),
            icon: const Icon(Iconsax.trash, color: AppColors.error),
          ),
      ],
    );
  }

  Widget _buildHeaderCard(BidModel bid) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusChip(status: bid.status),
              Text(
                Helpers.formatDate(bid.createdAt),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            bid.projectName,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Iconsax.building,
                size: 16.w,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 8.w),
              Text(
                bid.clientName,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (bid.projectType != null) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(
                  Iconsax.category,
                  size: 16.w,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 8.w),
                Text(
                  bid.projectType!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemsSection(BidModel bid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Items (${bid.totalItemsCount})',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: bid.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey600,
                        ),
                      ),
                    ),
                    title: Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      '${item.quantity} x ${Helpers.formatCurrency(item.unitPrice)}',
                      style: TextStyle(fontSize: 12.sp),
                    ),
                    trailing: Text(
                      Helpers.formatCurrency(item.total),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  if (index < bid.items.length - 1)
                    Divider(height: 1, color: AppColors.border),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialSection(BidModel bid) {
    return Container(
      padding: EdgeInsets.all(20.w),
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
      child: Column(
        children: [
          _buildFinancialRow('Subtotal', bid.subtotal),
          SizedBox(height: 8.h),
          _buildFinancialRow('Discount', -bid.totalDiscount),
          SizedBox(height: 8.h),
          _buildFinancialRow('Tax', bid.totalTax),
          Divider(color: Colors.white.withOpacity(0.3), height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grand Total',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                Helpers.formatCurrency(bid.grandTotal),
                style: TextStyle(
                  fontSize: 24.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        Text(
          Helpers.formatCurrency(value),
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(BidModel bid) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.note, size: 18.w, color: AppColors.textSecondary),
              SizedBox(width: 8.w),
              Text(
                'Notes',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            bid.notes!,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildBottomBar(BuildContext context, BidModel bid) {
    if (!bid.canSubmit) return null;

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
          text: 'Submit Bid',
          onPressed: () => _confirmSubmit(context),
          icon: Iconsax.tick_circle,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await CustomDialog.showDeleteConfirmation(
      context: context,
    );
    if (confirmed == true && context.mounted) {
      context.read<BidDetailsCubit>().deleteBid();
    }
  }

  Future<void> _confirmSubmit(BuildContext context) async {
    final confirmed = await CustomDialog.showConfirmation(
      context: context,
      title: 'Submit Bid?',
      message: 'Once submitted, you cannot edit this bid until it is reviewed.',
      confirmText: 'Submit',
    );

    if (confirmed == true && context.mounted) {
      context.read<BidDetailsCubit>().submitBid();
    }
  }
}
