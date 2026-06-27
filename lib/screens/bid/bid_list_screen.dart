import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../config/app_colors.dart';
import '../../config/routes.dart';
import '../../core/di/service_locator.dart';
import '../../widgets/bid_card.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/status_chip.dart';
import 'bid_list_cubit.dart';
import 'bid_list_state.dart';

class BidListScreen extends StatelessWidget {
  const BidListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BidListCubit>()..loadBids(),
      child: const BidListView(),
    );
  }
}

class BidListView extends StatefulWidget {
  const BidListView({super.key});

  @override
  State<BidListView> createState() => _BidListViewState();
}

class _BidListViewState extends State<BidListView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: BlocBuilder<BidListCubit, BidListState>(
        builder: (context, state) {
          return Column(
            children: [
              // Offline Banner
              OfflineBanner(isOffline: state.isOffline),

              // Search & Filter
              _buildSearchFilter(context, state),

              // Bid List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => context.read<BidListCubit>().refresh(),
                  color: AppColors.primary,
                  child: _buildListContent(context, state),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.createBid),
        backgroundColor: AppColors.primary,
        child: const Icon(Iconsax.add, color: Colors.white),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('My Bids'),
      centerTitle: true,
      backgroundColor: AppColors.surface,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: () {}, // Sort options could go here
          icon: const Icon(Iconsax.sort),
        ),
      ],
    );
  }

  Widget _buildSearchFilter(BuildContext context, BidListState state) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: SearchTextField(
              controller: _searchController,
              hint: 'Search client, project...',
              onChanged: (value) => context.read<BidListCubit>().search(value),
            ),
          ),

          // Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: BidFilter.values.map((filter) {
                final isSelected = state.currentFilter == filter;
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: FilterChip(
                    label: Text(_getFilterLabel(filter)),
                    selected: isSelected,
                    onSelected: (_) {
                      context.read<BidListCubit>().setFilter(filter);
                    },
                    backgroundColor: AppColors.grey50,
                    selectedColor: AppColors.primary.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListContent(BuildContext context, BidListState state) {
    if (state.isLoading && state.bids.isEmpty) {
      return const LoadingList();
    }

    if (state.hasError && state.bids.isEmpty) {
      return CustomErrorWidget.general(
        message: state.errorMessage,
        onRetry: () => context.read<BidListCubit>().loadBids(),
      );
    }

    if (state.filteredBids.isEmpty) {
      if (state.searchQuery.isNotEmpty) {
        return EmptyState.search(
          searchTerm: state.searchQuery,
          onClear: () {
            _searchController.clear();
            context.read<BidListCubit>().search('');
          },
        );
      }
      return EmptyState.bids(
        onCreateBid: () => Navigator.pushNamed(context, AppRoutes.createBid),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(top: 8.h, bottom: 80.h),
      itemCount: state.filteredBids.length,
      itemBuilder: (context, index) {
        final bid = state.filteredBids[index];
        return BidCard(
          bid: bid,
          onTap: () => Navigator.pushNamed(
            context,
            AppRoutes.bidDetails,
            arguments: {'bidId': bid.id},
          ),
        );
      },
    );
  }

  String _getFilterLabel(BidFilter filter) {
    switch (filter) {
      case BidFilter.all:
        return 'All';
      case BidFilter.pending:
        return 'Pending';
      case BidFilter.approved:
        return 'Approved';
      case BidFilter.draft:
        return 'Drafts';
      case BidFilter.rejected:
        return 'Rejected';
    }
  }
}
