class ApiConfig {
  ApiConfig._();

  // Base URL - Change this to your Laravel API URL
  // static const String baseUrl = 'https://your-api-domain.com/api';

  // For local development
  static const String baseUrl =
      'http://192.168.100.8:3000/api'; // Android Emulator
  // static const String baseUrl = 'http://localhost:8000/api'; // iOS Simulator

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // API Version
  static const String apiVersion = 'v1';
}

class ApiEndpoints {
  ApiEndpoints._();

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';
  static const String me = '/auth/me';

  // User Endpoints
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile/update';
  static const String changePassword = '/user/change-password';

  // Bid Endpoints
  static const String bids = '/bids';
  static String bidDetails(String id) => '/bids/$id';
  static String updateBid(String id) => '/bids/$id';
  static String deleteBid(String id) => '/bids/$id';
  static const String draftBids = '/bids/drafts';
  static const String pendingBids = '/bids/pending';
  static const String approvedBids = '/bids/approved';

  // Sync Endpoints
  static const String sync = '/sync';
  static const String syncStatus = '/sync/status';
  static const String syncBids = '/sync/bids';

  // Dashboard Endpoints
  static const String dashboard = '/dashboard';
  static const String dashboardStats = '/dashboard/stats';
  static const String recentBids = '/dashboard/recent-bids';
}
