// lib/core/network/mock_data.dart

class MockData {
  static final Map<String, dynamic> userProfile = {
    "success": true,
    "data": {
      "id": "1",
      "name": "John Salesman",
      "email": "john@example.com",
      "phone": "123-456-7890",
      "role": "salesperson",
      "avatar": null,
      "created_at": DateTime.now().toIso8601String(),
    },
  };

  static final Map<String, dynamic> loginSuccess = {
    "success": true,
    "message": "Login successful",
    "data": {
      "token": "fake_jwt_token_12345",
      "refresh_token": "fake_refresh_token_67890",
      "user": userProfile['data'],
      "expires_at": DateTime.now()
          .add(const Duration(days: 7))
          .toIso8601String(),
    },
  };

  static final Map<String, dynamic> bidList = {
    "success": true,
    "data": [
      {
        "id": "101",
        "client_name": "Acme Corp",
        "project_name": "Office Renovation",
        "status": "pending",
        "subtotal": 5000.0,
        "total_discount": 0.0,
        "total_tax": 500.0,
        "grand_total": 5500.0,
        "created_at": DateTime.now()
            .subtract(const Duration(days: 2))
            .toIso8601String(),
        "is_synced": true,
        "items": [],
      },
      {
        "id": "102",
        "client_name": "TechStart Inc",
        "project_name": "Server Setup",
        "status": "approved",
        "subtotal": 12000.0,
        "total_discount": 1000.0,
        "total_tax": 1100.0,
        "grand_total": 12100.0,
        "created_at": DateTime.now()
            .subtract(const Duration(days: 5))
            .toIso8601String(),
        "is_synced": true,
        "items": [],
      },
    ],
    "meta": {"current_page": 1, "last_page": 1, "total": 2, "per_page": 20},
  };
}
