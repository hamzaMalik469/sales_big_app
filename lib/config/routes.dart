import 'package:flutter/material.dart';

import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/bid/create_bid_screen.dart';
import '../screens/bid/bid_list_screen.dart';
import '../screens/bid/bid_details_screen.dart';
import '../screens/bid/edit_bid_screen.dart';
import '../screens/bid/calculation_preview_screen.dart';
import '../screens/bid/bid_review_screen.dart';
import '../screens/offline/offline_entries_screen.dart';
import '../screens/sync/sync_status_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/settings_screen.dart';

class AppRoutes {
  AppRoutes._();

  // Route Names
  static const String splash = '/';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String createBid = '/create-bid';
  static const String bidList = '/bids';
  static const String bidDetails = '/bid-details';
  static const String editBid = '/edit-bid';
  static const String calculationPreview = '/calculation-preview';
  static const String bidReview = '/bid-review';
  static const String offlineEntries = '/offline-entries';
  static const String syncStatus = '/sync-status';
  static const String profile = '/profile';
  static const String setting = '/settings';

  // Route Generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashScreen(), settings);

      case login:
        return _buildRoute(const LoginScreen(), settings);

      case forgotPassword:
        return _buildRoute(const ForgotPasswordScreen(), settings);

      case dashboard:
        return _buildRoute(const DashboardScreen(), settings);

      case createBid:
        return _buildRoute(const CreateBidScreen(), settings);

      case bidList:
        return _buildRoute(const BidListScreen(), settings);

      case bidDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        final bidId = args?['bidId'] as String? ?? '';
        return _buildRoute(BidDetailsScreen(bidId: bidId), settings);

      case editBid:
        final args = settings.arguments as Map<String, dynamic>?;
        final bidId = args?['bidId'] as String? ?? '';
        return _buildRoute(EditBidScreen(bidId: bidId), settings);

      case calculationPreview:
        return _buildRoute(const CalculationPreviewScreen(), settings);

      case bidReview:
        return _buildRoute(const BidReviewScreen(), settings);

      case offlineEntries:
        return _buildRoute(const OfflineEntriesScreen(), settings);

      case syncStatus:
        return _buildRoute(const SyncStatusScreen(), settings);

      case profile:
        return _buildRoute(const ProfileScreen(), settings);

      case setting:
        return _buildRoute(const SettingsScreen(), settings);

      default:
        return _buildRoute(const _NotFoundScreen(), settings);
    }
  }

  // Route Builder with Slide Transition
  static PageRoute<dynamic> _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  // Fade Route
  static PageRoute<dynamic> fadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

// 404 Not Found Screen
class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('404', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.dashboard),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
