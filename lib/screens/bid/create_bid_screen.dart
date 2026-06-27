import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../config/app_colors.dart';
import '../../config/routes.dart';
import '../../core/di/service_locator.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_dialog.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/offline_banner.dart';
import 'create_bid_cubit.dart';
import 'create_bid_state.dart';
import 'widgets/step_indicator.dart';
import 'widgets/step_basic_info.dart';
import 'widgets/step_add_items.dart';
import 'widgets/step_calculation.dart';
import 'widgets/step_review.dart';

class CreateBidScreen extends StatelessWidget {
  const CreateBidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CreateBidCubit>(),
      child: const CreateBidView(),
    );
  }
}

class CreateBidView extends StatelessWidget {
  const CreateBidView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateBidCubit, CreateBidState>(
      listener: (context, state) {
        if (state.isSuccess) {
          CustomDialog.showSuccess(
            context: context,
            title: 'Success!',
            message: state.successMessage ?? 'Bid created successfully!',
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.dashboard,
                (route) => false,
              );
            },
          );
        }

        if (state.hasError && state.errorMessage != null) {
          showErrorSnackBar(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () => _onWillPop(context, state),
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: _buildAppBar(context, state),
            body: Column(
              children: [
                // Offline Banner
                OfflineBanner(isOffline: state.isOffline),

                // Step Indicator
                StepIndicator(
                  currentStep: state.currentStep,
                  onStepTap: (step) {
                    context.read<CreateBidCubit>().goToStep(step);
                  },
                ),

                // Step Content
                Expanded(child: _buildStepContent(state)),

                // Bottom Navigation
                _buildBottomNavigation(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, CreateBidState state) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: IconButton(
        onPressed: () async {
          final shouldPop = await _onWillPop(context, state);
          if (shouldPop && context.mounted) {
            Navigator.pop(context);
          }
        },
        icon: Icon(
          Iconsax.arrow_left,
          color: AppColors.textPrimary,
          size: 24.w,
        ),
      ),
      title: Text(
        'Create New Bid',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
      actions: [
        if (state.currentStep != CreateBidStep.basicInfo)
          TextButton(
            onPressed: state.isLoading
                ? null
                : () => context.read<CreateBidCubit>().saveDraft(),
            child: Text(
              'Save Draft',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: state.isLoading ? AppColors.grey400 : AppColors.primary,
              ),
            ),
          ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildStepContent(CreateBidState state) {
    switch (state.currentStep) {
      case CreateBidStep.basicInfo:
        return const StepBasicInfo();
      case CreateBidStep.addItems:
        return const StepAddItems();
      case CreateBidStep.calculation:
        return const StepCalculation();
      case CreateBidStep.review:
        return const StepReview();
    }
  }

  Widget _buildBottomNavigation(BuildContext context, CreateBidState state) {
    final cubit = context.read<CreateBidCubit>();

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
      child: SafeArea(
        child: Row(
          children: [
            // Back Button
            if (!state.isFirstStep)
              Expanded(
                flex: 2,
                child: CustomButton(
                  text: 'Back',
                  type: ButtonType.outlined,
                  icon: Iconsax.arrow_left_2,
                  onPressed: state.isLoading ? null : cubit.previousStep,
                ),
              ),

            if (!state.isFirstStep) SizedBox(width: 12.w),

            // Next/Submit Button
            Expanded(
              flex: state.isFirstStep ? 1 : 2,
              child: CustomButton(
                text: _getNextButtonText(state),
                icon: _getNextButtonIcon(state),
                isLoading: state.isLoading,
                onPressed: state.isLoading
                    ? null
                    : () {
                        if (state.isLastStep) {
                          cubit.submitBid();
                        } else {
                          cubit.nextStep();
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getNextButtonText(CreateBidState state) {
    switch (state.currentStep) {
      case CreateBidStep.basicInfo:
        return 'Add Items';
      case CreateBidStep.addItems:
        return 'Calculate';
      case CreateBidStep.calculation:
        return 'Review';
      case CreateBidStep.review:
        return 'Submit Bid';
    }
  }

  IconData _getNextButtonIcon(CreateBidState state) {
    switch (state.currentStep) {
      case CreateBidStep.basicInfo:
        return Iconsax.arrow_right_3;
      case CreateBidStep.addItems:
        return Iconsax.calculator;
      case CreateBidStep.calculation:
        return Iconsax.document_text;
      case CreateBidStep.review:
        return Iconsax.tick_circle;
    }
  }

  Future<bool> _onWillPop(BuildContext context, CreateBidState state) async {
    // If form has data, show confirmation
    if (state.clientName.isNotEmpty ||
        state.projectName.isNotEmpty ||
        state.items.isNotEmpty) {
      final shouldDiscard = await CustomDialog.showConfirmation(
        context: context,
        title: 'Discard Changes?',
        message:
            'You have unsaved changes. Are you sure you want to discard them?',
        confirmText: 'Discard',
        cancelText: 'Keep Editing',
        isDanger: true,
      );
      return shouldDiscard ?? false;
    }
    return true;
  }
}
