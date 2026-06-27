import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sales_bid_app/models/api_response.dart';

import '../../core/di/service_locator.dart';
import '../../models/bid_model.dart';
import '../../services/bid_service.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/loading_widget.dart';
import 'create_bid_cubit.dart';
import 'create_bid_screen.dart'; // Reuse UI

class EditBidScreen extends StatelessWidget {
  final String bidId;

  const EditBidScreen({super.key, required this.bidId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiResponse<BidModel>>(
      future: sl<BidService>().getBidById(bidId), // Fetch bid first
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: LoadingWidget());
        }

        if (snapshot.hasError || !snapshot.data!.success) {
          return Scaffold(
            appBar: AppBar(title: const Text('Edit Bid')),
            body: CustomErrorWidget.general(
              message: 'Failed to load bid for editing',
              onRetry: () {
                // Trigger rebuild
                (context as Element).markNeedsBuild();
              },
            ),
          );
        }

        final bid = snapshot.data!.data!;

        return BlocProvider(
          create: (_) =>
              sl<CreateBidCubit>()
                ..initializeWithBid(bid), // Need to add this method
          child: const CreateBidView(), // Reuse the view
        );
      },
    );
  }
}
