import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../../config/app_colors.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../widgets/custom_dropdown.dart';
import '../create_bid_cubit.dart';
import '../create_bid_state.dart';

class StepBasicInfo extends StatefulWidget {
  const StepBasicInfo({super.key});

  @override
  State<StepBasicInfo> createState() => _StepBasicInfoState();
}

class _StepBasicInfoState extends State<StepBasicInfo> {
  final _clientNameController = TextEditingController();
  final _projectNameController = TextEditingController();
  final _clientEmailController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _clientAddressController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initControllers();
    });
  }

  void _initControllers() {
    final state = context.read<CreateBidCubit>().state;
    _clientNameController.text = state.clientName;
    _projectNameController.text = state.projectName;
    _clientEmailController.text = state.clientEmail ?? '';
    _clientPhoneController.text = state.clientPhone ?? '';
    _clientAddressController.text = state.clientAddress ?? '';
    _notesController.text = state.notes ?? '';
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _projectNameController.dispose();
    _clientEmailController.dispose();
    _clientPhoneController.dispose();
    _clientAddressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateBidCubit, CreateBidState>(
      builder: (context, state) {
        final cubit = context.read<CreateBidCubit>();

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header - Client Info
              _buildSectionHeader(
                icon: Iconsax.building,
                title: 'Client Information',
                subtitle: 'Enter client details',
              ),

              SizedBox(height: 20.h),

              // Client Name *
              CustomTextField(
                controller: _clientNameController,
                label: 'Client Name *',
                hint: 'Enter client or company name',
                prefixIcon: Iconsax.user,
                errorText: state.clientNameError,
                textCapitalization: TextCapitalization.words,
                onChanged: cubit.updateClientName,
              ),

              SizedBox(height: 16.h),

              // Project Name *
              CustomTextField(
                controller: _projectNameController,
                label: 'Project Name *',
                hint: 'Enter project name',
                prefixIcon: Iconsax.folder,
                errorText: state.projectNameError,
                textCapitalization: TextCapitalization.words,
                onChanged: cubit.updateProjectName,
              ),

              SizedBox(height: 16.h),

              // Project Type
              CustomDropdown<String>(
                label: 'Project Type',
                hint: 'Select project type',
                prefixIcon: Iconsax.category,
                value: state.projectType,
                items: ProjectTypes.types.map((type) {
                  return DropdownItem(value: type, label: type);
                }).toList(),
                onChanged: cubit.updateProjectType,
              ),

              SizedBox(height: 32.h),

              // Section Header - Contact Details
              _buildSectionHeader(
                icon: Iconsax.call,
                title: 'Contact Details',
                subtitle: 'Optional contact information',
              ),

              SizedBox(height: 20.h),

              // Client Email
              CustomTextField(
                controller: _clientEmailController,
                label: 'Client Email',
                hint: 'Enter client email address',
                prefixIcon: Iconsax.sms,
                keyboardType: TextInputType.emailAddress,
                onChanged: cubit.updateClientEmail,
              ),

              SizedBox(height: 16.h),

              // Client Phone
              CustomTextField(
                controller: _clientPhoneController,
                label: 'Client Phone',
                hint: 'Enter phone number',
                prefixIcon: Iconsax.call,
                keyboardType: TextInputType.phone,
                onChanged: cubit.updateClientPhone,
              ),

              SizedBox(height: 16.h),

              // Client Address
              CustomTextField(
                controller: _clientAddressController,
                label: 'Client Address',
                hint: 'Enter client address',
                prefixIcon: Iconsax.location,
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
                onChanged: cubit.updateClientAddress,
              ),

              SizedBox(height: 32.h),

              // Section Header - Notes
              _buildSectionHeader(
                icon: Iconsax.note,
                title: 'Additional Notes',
                subtitle: 'Any special requirements',
              ),

              SizedBox(height: 20.h),

              // Notes
              CustomTextField(
                controller: _notesController,
                hint: 'Enter any additional notes or special requirements...',
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                onChanged: cubit.updateNotes,
              ),

              SizedBox(height: 100.h), // Space for bottom button
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, size: 22.w, color: AppColors.primary),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}
