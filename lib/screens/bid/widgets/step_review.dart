import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../../config/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../create_bid_cubit.dart';
import '../create_bid_state.dart';

class StepReview extends StatelessWidget {
  const StepReview({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateBidCubit, CreateBidState>(
      builder: (context, state) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Success Header
              _buildHeader(state),

              SizedBox(height: 24.h),

              // Client Info Card
              _buildInfoCard(
                title: 'Client Information',
                icon: Iconsax.building,
                items: [
                  _InfoItem('Client Name', state.clientName),
                  _InfoItem('Project Name', state.projectName),
                  if (state.projectType != null)
                    _InfoItem('Project Type', state.projectType!),
                  if (state.clientEmail != null)
                    _InfoItem('Email', state.clientEmail!),
                  if (state.clientPhone != null)
                    _InfoItem('Phone', state.clientPhone!),
                  if (state.clientAddress != null)
                    _InfoItem('Address', state.clientAddress!),
                ],
              ),

              SizedBox(height: 16.h),

              // Items Summary Card
              _buildItemsSummaryCard(state),

              SizedBox(height: 16.h),

              // Financial Summary Card
              _buildFinancialCard(state),

              // Notes Card
              if (state.notes != null && state.notes!.isNotEmpty) ...[
                SizedBox(height: 16.h),
                _buildNotesCard(state),
              ],

              SizedBox(height: 24.h),

              // Offline Warning
              if (state.isOffline) _buildOfflineWarning(),

              SizedBox(height: 100.h), // Space for bottom buttons
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(CreateBidState state) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: AppColors.successGradient,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              Iconsax.document_text,
              size: 28.w,
              color: AppColors.white,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ready to Submit',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Review your bid details below',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<_InfoItem> items,
  }) {
    return Container(
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
              Icon(icon, size: 20.w, color: AppColors.primary),
              SizedBox(width: 10.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...items.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100.w,
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.value,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSummaryCard(CreateBidState state) {
    return Container(
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
              Icon(Iconsax.box, size: 20.w, color: AppColors.primary),
              SizedBox(width: 10.w),
              Text(
                'Items Summary',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${state.items.length} items',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...state.items
              .take(3)
              .map(
                (item) => Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.description,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        Helpers.formatCurrency(item.total),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          if (state.items.length > 3)
            Text(
              '+${state.items.length - 3} more items',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFinancialCard(CreateBidState state) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildFinancialRow('Subtotal', state.subtotal),
          SizedBox(height: 8.h),
          _buildFinancialRow(
            'Discount',
            -state.totalDiscount,
            isNegative: true,
          ),
          SizedBox(height: 8.h),
          _buildFinancialRow('Tax', state.totalTax),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Divider(color: AppColors.primary.withOpacity(0.2)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grand Total',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                Helpers.formatCurrency(state.grandTotal),
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(
    String label,
    double value, {
    bool isNegative = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
        Text(
          '${isNegative && value != 0 ? '-' : ''}${Helpers.formatCurrency(value.abs())}',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: isNegative && value != 0
                ? AppColors.success
                : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildNotesCard(CreateBidState state) {
    return Container(
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
              Icon(Iconsax.note, size: 20.w, color: AppColors.primary),
              SizedBox(width: 10.w),
              Text(
                'Notes',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            state.notes!,
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

  Widget _buildOfflineWarning() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Iconsax.wifi_square, size: 24.w, color: AppColors.warning),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You\'re Offline',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warningDark,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Bid will be saved locally and synced when online.',
                  style: TextStyle(fontSize: 12.sp, color: AppColors.warning),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;

  _InfoItem(this.label, this.value);
}
