/// Generic API Response Wrapper
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final Map<String, dynamic>? errors;
  final PaginationMeta? meta;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
    this.meta,
  });

  /// Create success response
  factory ApiResponse.success({
    T? data,
    String? message,
    PaginationMeta? meta,
  }) {
    return ApiResponse(success: true, data: data, message: message, meta: meta);
  }

  /// Create error response
  factory ApiResponse.error({String? message, Map<String, dynamic>? errors}) {
    return ApiResponse(success: false, message: message, errors: errors);
  }

  /// Parse from JSON with a data parser
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? dataParser,
  ) {
    return ApiResponse(
      success: json['success'] ?? json['status'] == 'success' ?? true,
      message: json['message'],
      data: dataParser != null && json['data'] != null
          ? dataParser(json['data'])
          : json['data'] as T?,
      errors: json['errors'],
      meta: json['meta'] != null ? PaginationMeta.fromJson(json['meta']) : null,
    );
  }

  /// Check if has data
  bool get hasData => data != null;

  /// Check if has errors
  bool get hasErrors => errors != null && errors!.isNotEmpty;

  /// Get first error message
  String? get firstError {
    if (errors == null || errors!.isEmpty) return null;
    final firstKey = errors!.keys.first;
    final firstValue = errors![firstKey];
    if (firstValue is List && firstValue.isNotEmpty) {
      return firstValue.first.toString();
    }
    return firstValue?.toString();
  }

  /// Get all error messages as list
  List<String> get errorList {
    if (errors == null) return [];
    final errorMessages = <String>[];
    errors!.forEach((key, value) {
      if (value is List) {
        errorMessages.addAll(value.map((e) => e.toString()));
      } else {
        errorMessages.add(value.toString());
      }
    });
    return errorMessages;
  }
}

/// Pagination Meta Data
class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int from;
  final int to;

  PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.from,
    required this.to,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 20,
      total: json['total'] ?? 0,
      from: json['from'] ?? 0,
      to: json['to'] ?? 0,
    );
  }

  /// Check if has more pages
  bool get hasMorePages => currentPage < lastPage;

  /// Check if is first page
  bool get isFirstPage => currentPage == 1;

  /// Check if is last page
  bool get isLastPage => currentPage == lastPage;

  /// Get next page number
  int get nextPage => hasMorePages ? currentPage + 1 : currentPage;

  /// Get previous page number
  int get previousPage => currentPage > 1 ? currentPage - 1 : 1;
}

/// Login Response
class LoginResponse {
  final String token;
  final String? refreshToken;
  final UserData user;
  final DateTime? expiresAt;

  LoginResponse({
    required this.token,
    this.refreshToken,
    required this.user,
    this.expiresAt,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? json['access_token'] ?? '',
      refreshToken: json['refresh_token'],
      user: UserData.fromJson(json['user'] ?? {}),
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'])
          : null,
    );
  }
}

/// User Data for Auth Response
class UserData {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String role;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.role = 'salesperson',
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      avatar: json['avatar'],
      role: json['role'] ?? 'salesperson',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'role': role,
    };
  }
}

// NOTE: DashboardStats is now defined in dashboard_state.dart
// Import from there: import '../screens/dashboard/dashboard_state.dart';
