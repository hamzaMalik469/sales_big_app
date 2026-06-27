import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../../config/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/helpers.dart';
import '../../../models/bid_item_model.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';

class AddItemDialog extends StatefulWidget {
  final BidItemModel? item;
  final bool isEditing;

  const AddItemDialog({super.key, this.item, this.isEditing = false});

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();

  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _discountController = TextEditingController();
  final _taxController = TextEditingController();
  final _notesController = TextEditingController();

  // Live calculation values
  double _subtotal = 0;
  double _discountAmount = 0;
  double _taxAmount = 0;
  double _total = 0;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _descriptionController.text = widget.item!.description;
      _quantityController.text = widget.item!.quantity.toString();
      _unitPriceController.text = widget.item!.unitPrice.toStringAsFixed(2);
      _discountController.text = widget.item!.discountPercent.toString();
      _taxController.text = widget.item!.taxPercent.toString();
      _notesController.text = widget.item!.notes ?? '';
    } else {
      _quantityController.text = '1';
      _discountController.text = '0';
      _taxController.text = '0';
    }
    _calculateTotal();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _discountController.dispose();
    _taxController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final unitPrice = double.tryParse(_unitPriceController.text) ?? 0;
    final discountPercent = double.tryParse(_discountController.text) ?? 0;
    final taxPercent = double.tryParse(_taxController.text) ?? 0;

    setState(() {
      _subtotal = quantity * unitPrice;
      _discountAmount = _subtotal * (discountPercent / 100);
      final taxableAmount = _subtotal - _discountAmount;
      _taxAmount = taxableAmount * (taxPercent / 100);
      _total = taxableAmount + _taxAmount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),

            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),

                      // Description
                      CustomTextField(
                        controller: _descriptionController,
                        label: 'Item Description *',
                        hint: 'Enter item or service description',
                        prefixIcon: Iconsax.box,
                        textCapitalization: TextCapitalization.sentences,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Description is required';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16.h),

                      // Quantity & Unit Price Row
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _quantityController,
                              label: 'Quantity *',
                              hint: '1',
                              prefixIcon: Iconsax.hashtag,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (_) => _calculateTotal(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                final qty = int.tryParse(value);
                                if (qty == null || qty <= 0) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            flex: 2,
                            child: CustomTextField(
                              controller: _unitPriceController,
                              label: 'Unit Price *',
                              hint: '0.00',
                              prefixIcon: Iconsax.dollar_circle,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [CurrencyInputFormatter()],
                              onChanged: (_) => _calculateTotal(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                final price = double.tryParse(value);
                                if (price == null || price < 0) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      // Discount & Tax Row
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _discountController,
                              label: 'Discount %',
                              hint: '0',
                              prefixIcon: Iconsax.discount_shape,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [PercentageInputFormatter()],
                              onChanged: (_) => _calculateTotal(),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: CustomTextField(
                              controller: _taxController,
                              label: 'Tax %',
                              hint: '0',
                              prefixIcon: Iconsax.receipt,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [PercentageInputFormatter()],
                              onChanged: (_) => _calculateTotal(),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      // Notes
                      CustomTextField(
                        controller: _notesController,
                        label: 'Item Notes',
                        hint: 'Optional notes for this item',
                        prefixIcon: Iconsax.note,
                        maxLines: 2,
                      ),

                      SizedBox(height: 24.h),

                      // Calculation Preview
                      _buildCalculationPreview(),

                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Buttons
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              widget.isEditing ? Iconsax.edit : Iconsax.add_circle,
              size: 24.w,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isEditing ? 'Edit Item' : 'Add New Item',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  widget.isEditing
                      ? 'Update item details'
                      : 'Add item to your bid',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.grey200,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 20.w, color: AppColors.grey600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationPreview() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildCalcRow('Subtotal', _subtotal),
          if (_discountAmount > 0) ...[
            SizedBox(height: 8.h),
            _buildCalcRow('Discount', -_discountAmount, isNegative: true),
          ],
          if (_taxAmount > 0) ...[
            SizedBox(height: 8.h),
            _buildCalcRow('Tax', _taxAmount),
          ],
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Divider(color: AppColors.border),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                Helpers.formatCurrency(_total),
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

  Widget _buildCalcRow(String label, double value, {bool isNegative = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
        Text(
          '${isNegative ? '-' : ''}${Helpers.formatCurrency(value.abs())}',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: isNegative ? AppColors.error : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Expanded(
          //   child: CustomButton(

          //     text: 'Cancel',
          //     type: ButtonType.outlined,
          //     onPressed: () => Navigator.pop(context),
          //   ),
          // ),
          // SizedBox(width: 10.w),
          Expanded(
            child: CustomButton(
              text: widget.isEditing ? 'Update Item' : 'Add Item',
              icon: widget.isEditing ? Iconsax.tick_circle : Iconsax.add,
              onPressed: _saveItem,
            ),
          ),
        ],
      ),
    );
  }

  void _saveItem() {
    if (_formKey.currentState?.validate() ?? false) {
      final item = BidItemModel(
        id: widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        description: _descriptionController.text.trim(),
        quantity: int.tryParse(_quantityController.text) ?? 1,
        unitPrice: double.tryParse(_unitPriceController.text) ?? 0,
        discountPercent: double.tryParse(_discountController.text) ?? 0,
        taxPercent: double.tryParse(_taxController.text) ?? 0,
        notes: _notesController.text.isEmpty
            ? null
            : _notesController.text.trim(),
      );

      Navigator.pop(context, item);
    }
  }
}
