import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../../config/app_colors.dart';
import '../../../core/utils/helpers.dart';
import '../../../models/bid_item_model.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_dialog.dart';
import '../../../widgets/empty_state.dart';
import '../create_bid_cubit.dart';
import '../create_bid_state.dart';
import 'add_item_dialog.dart';

class StepAddItems extends StatelessWidget {
  const StepAddItems({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateBidCubit, CreateBidState>(
      builder: (context, state) {
        return Column(
          children: [
            // Header with Add Button
            _buildHeader(context, state),

            // Items List
            Expanded(
              child: state.items.isEmpty
                  ? _buildEmptyState(context)
                  : _buildItemsList(context, state),
            ),

            // Summary Footer
            if (state.items.isNotEmpty) _buildSummaryFooter(state),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, CreateBidState state) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Iconsax.box, size: 22.w, color: AppColors.primary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bid Items',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${state.items.length} item${state.items.length != 1 ? 's' : ''} added',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // 👇 FIXED: Added width constraint here
          SizedBox(
            width: 90.w, // Define a concrete width
            child: CustomButton(
              text: 'Add',
              icon: Iconsax.add,
              size: ButtonSize.small,
              expanded: true, // Set to true so it fills the SizedBox width
              onPressed: () => _showAddItemDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: EmptyState(
        icon: Iconsax.box,
        title: 'No Items Added',
        message: 'Add items to your bid by tapping the button above.',
        buttonText: 'Add First Item',
        onAction: () => _showAddItemDialog(context),
      ),
    );
  }

  Widget _buildItemsList(BuildContext context, CreateBidState state) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final item = state.items[index];
        return _ItemCard(
          item: item,
          index: index,
          onEdit: () => _showEditItemDialog(context, item, index),
          onDuplicate: () {
            context.read<CreateBidCubit>().duplicateItem(index);
          },
          onDelete: () => _confirmDeleteItem(context, index, item),
        );
      },
    );
  }

  Widget _buildSummaryFooter(CreateBidState state) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${state.items.length} Items',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Subtotal: ${Helpers.formatCurrency(state.subtotal)}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Estimated Total',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                Helpers.formatCurrency(state.grandTotal),
                style: TextStyle(
                  fontSize: 20.sp,
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

  Future<void> _showAddItemDialog(BuildContext context) async {
    final result = await showDialog<BidItemModel>(
      context: context,
      builder: (_) => const AddItemDialog(),
    );

    if (result != null && context.mounted) {
      context.read<CreateBidCubit>().addItem(result);
    }
  }

  Future<void> _showEditItemDialog(
    BuildContext context,
    BidItemModel item,
    int index,
  ) async {
    final result = await showDialog<BidItemModel>(
      context: context,
      builder: (_) => AddItemDialog(item: item, isEditing: true),
    );

    if (result != null && context.mounted) {
      context.read<CreateBidCubit>().updateItem(index, result);
    }
  }

  Future<void> _confirmDeleteItem(
    BuildContext context,
    int index,
    BidItemModel item,
  ) async {
    final confirmed = await CustomDialog.showDeleteConfirmation(
      context: context,
      itemName: item.description,
    );

    if (confirmed == true && context.mounted) {
      context.read<CreateBidCubit>().removeItem(index);
    }
  }
}

// Item Card Widget
class _ItemCard extends StatelessWidget {
  final BidItemModel item;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  const _ItemCard({
    required this.item,
    required this.index,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item Number
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),

                    // Item Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.description,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              _buildInfoChip(
                                'Qty: ${item.quantity}',
                                Iconsax.box,
                              ),
                              SizedBox(width: 8.w),
                              _buildInfoChip(
                                Helpers.formatCurrency(item.unitPrice),
                                Iconsax.dollar_circle,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // More Menu
                    PopupMenuButton<String>(
                      icon: Icon(
                        Iconsax.more,
                        size: 20.w,
                        color: AppColors.grey500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.edit,
                                size: 18.w,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 10.w),
                              const Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'duplicate',
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.copy,
                                size: 18.w,
                                color: AppColors.secondary,
                              ),
                              SizedBox(width: 10.w),
                              const Text('Duplicate'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.trash,
                                size: 18.w,
                                color: AppColors.error,
                              ),
                              SizedBox(width: 10.w),
                              const Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit();
                            break;
                          case 'duplicate':
                            onDuplicate();
                            break;
                          case 'delete':
                            onDelete();
                            break;
                        }
                      },
                    ),
                  ],
                ),

                // Divider
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Divider(height: 1, color: AppColors.border),
                ),

                // Footer Row - Calculations
                Row(
                  children: [
                    if (item.discountPercent > 0)
                      _buildFooterChip(
                        '-${item.discountPercent.toStringAsFixed(0)}%',
                        AppColors.success,
                      ),
                    if (item.discountPercent > 0) SizedBox(width: 8.w),
                    if (item.taxPercent > 0)
                      _buildFooterChip(
                        'Tax ${item.taxPercent.toStringAsFixed(0)}%',
                        AppColors.info,
                      ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (item.discountAmount > 0 || item.taxAmount > 0)
                          Text(
                            Helpers.formatCurrency(item.subtotal),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textTertiary,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Text(
                          Helpers.formatCurrency(item.total),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.w, color: AppColors.grey600),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
