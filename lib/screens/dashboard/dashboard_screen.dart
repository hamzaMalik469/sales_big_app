import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../config/app_colors.dart';
import '../../config/routes.dart';
import '../../core/di/service_locator.dart';
import '../../services/auth_service.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/offline_banner.dart';
import 'dashboard_cubit.dart';
import 'dashboard_state.dart';
import 'widgets/app_drawer.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/stats_section.dart';
import 'widgets/quick_actions.dart';
import 'widgets/recent_bids_section.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DashboardCubit>()..loadDashboard(),
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthService _authService = sl<AuthService>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardCubit, DashboardState>(
      listener: (context, state) {
        if (state.hasError && state.errorMessage != null) {
          showErrorSnackBar(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.background,
          drawer: AppDrawer(
            user: _authService.currentUser,
            pendingSyncCount: state.stats.unsyncedCount,
            isOffline: state.isOffline,
            onSyncTap: () => context.read<DashboardCubit>().syncData(),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Offline Banner
                OfflineBanner(
                  isOffline: state.isOffline,
                  onRetry: () => context.read<DashboardCubit>().refresh(),
                ),

                // Main Content
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => context.read<DashboardCubit>().refresh(),
                    color: AppColors.primary,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      slivers: [
                        // App Bar
                        _buildAppBar(context, state),

                        // Content
                        SliverToBoxAdapter(
                          child: _buildContent(context, state),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: _buildFAB(context),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, DashboardState state) {
    return SliverAppBar(
      floating: true,
      snap: true,
      elevation: 0,
      backgroundColor: AppColors.background,
      surfaceTintColor: AppColors.background,
      toolbarHeight: 80.h,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: EdgeInsets.only(top: 16.h),
          child: DashboardHeader(
            greeting: state.greeting,
            user: _authService.currentUser,
            isOffline: state.isOffline,
            notificationCount: 0,
            onProfileTap: () => _scaffoldKey.currentState?.openDrawer(),
            onNotificationTap: () {
              showInfoSnackBar(context, 'Notifications coming soon!');
            },
          ),
        ),
      ),
      actions: [
        // Menu Button
        Padding(
          padding: EdgeInsets.only(right: 8.w),
          child: IconButton(
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            icon: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Iconsax.menu_1,
                size: 20.w,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, DashboardState state) {
    if (state.isLoading && state.recentBids.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 100.h),
        child: const LoadingWidget(),
      );
    }

    if (state.hasError && state.recentBids.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 50.h),
        child: CustomErrorWidget.general(
          message: state.errorMessage,
          onRetry: () => context.read<DashboardCubit>().loadDashboard(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.h),

        // Stats Section
        StatsSection(
          stats: state.stats,
          isLoading: state.isLoading,
          onTotalTap: () => _navigateToBids(context, null),
          onPendingTap: () => _navigateToBids(context, 'pending'),
          onApprovedTap: () => _navigateToBids(context, 'approved'),
          onDraftTap: () => _navigateToBids(context, 'draft'),
        ),

        SizedBox(height: 28.h),

        // Quick Actions
        QuickActions(
          unsyncedCount: state.stats.unsyncedCount,
          onSyncTap: () => context.read<DashboardCubit>().syncData(),
        ),

        SizedBox(height: 28.h),

        // Recent Bids
        RecentBidsSection(
          bids: state.recentBids,
          isLoading: state.isLoading,
          onViewAllTap: () => _navigateToBids(context, null),
        ),

        SizedBox(height: 100.h), // Space for FAB
      ],
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.pushNamed(context, AppRoutes.createBid),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 4,
      icon: Icon(Iconsax.add, size: 22.w),
      label: Text(
        'New Bid',
        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _navigateToBids(BuildContext context, String? status) {
    Navigator.pushNamed(
      context,
      AppRoutes.bidList,
      arguments: {'status': status},
    );
  }
}
