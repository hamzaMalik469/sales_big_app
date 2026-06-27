import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../config/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/bid_model.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/status_chip.dart';

class BidReviewScreen extends StatelessWidget {
  const BidReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Extract BidModel from arguments
    final bid = ModalRoute.of(context)?.settings.arguments as BidModel?;

    if (bid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review Bid')),
        body: CustomErrorWidget.general(message: 'No bid data provided'),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bid Review'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Center(child: StatusChip(status: bid.status, isSmall: true)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Client Info
            _buildSection(
              title: 'Client Information',
              icon: Iconsax.building,
              children: [
                _buildInfoRow('Client Name', bid.clientName),
                _buildInfoRow('Project Name', bid.projectName),
                if (bid.projectType != null)
                  _buildInfoRow('Type', bid.projectType!),
                if (bid.clientEmail != null)
                  _buildInfoRow('Email', bid.clientEmail!),
                if (bid.clientPhone != null)
                  _buildInfoRow('Phone', bid.clientPhone!),
              ],
            ),

            SizedBox(height: 20.h),

            // Financials
            _buildSection(
              title: 'Financial Summary',
              icon: Iconsax.money_recive,
              children: [
                _buildInfoRow('Subtotal', Helpers.formatCurrency(bid.subtotal)),
                _buildInfoRow(
                  'Discount',
                  '-${Helpers.formatCurrency(bid.totalDiscount)}',
                  valueColor: AppColors.success,
                ),
                _buildInfoRow(
                  'Tax',
                  Helpers.formatCurrency(bid.totalTax),
                  valueColor: AppColors.warning,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Divider(color: AppColors.border),
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
                      Helpers.formatCurrency(bid.grandTotal),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // Items Summary
            _buildSection(
              title: 'Items (${bid.items.length})',
              icon: Iconsax.box,
              children: bid.items
                  .map(
                    (item) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.description,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            Helpers.formatCurrency(item.total),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),

            if (bid.notes != null && bid.notes!.isNotEmpty) ...[
              SizedBox(height: 20.h),
              _buildSection(
                title: 'Notes',
                icon: Iconsax.note,
                children: [
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
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
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
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
