import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/bid_model.dart';

/// Google Sheets Service
/// Note: In a production app, you should use the backend to handle
/// Google Sheets API calls for security reasons.
/// This is a simplified version for demonstration.
class GoogleSheetsService {
  // Your Google Sheets API credentials
  static const String _spreadsheetId = 'YOUR_SPREADSHEET_ID';
  static const String _apiKey = 'YOUR_API_KEY'; // For read-only operations
  
  // For write operations, you'll need OAuth or Service Account
  // This should be handled by your Laravel backend for security
  
  /// Sheet names
  static const String _bidsSheet = 'Bids';
  static const String _itemsSheet = 'BidItems';

  /// Append bid data to Google Sheets
  /// Note: In production, call your backend API instead
  Future<bool> appendBidToSheet(BidModel bid) async {
    try {
      // This should call your Laravel backend endpoint
      // which handles the Google Sheets API securely
      
      // Example API call to your backend:
      // final response = await http.post(
      //   Uri.parse('${ApiConfig.baseUrl}/sync/sheets'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({
      //     'action': 'append',
      //     'bid': bid.toJson(),
      //   }),
      // );
      
      // For now, just simulate success
      await Future.delayed(const Duration(milliseconds: 500));
      print('📊 Bid synced to Google Sheets: ${bid.id}');
      return true;
    } catch (e) {
      print('❌ Failed to sync to Google Sheets: $e');
      return false;
    }
  }

  /// Update bid in Google Sheets
  Future<bool> updateBidInSheet(BidModel bid) async {
    try {
      // Call backend to update sheet row
      await Future.delayed(const Duration(milliseconds: 500));
      print('📊 Bid updated in Google Sheets: ${bid.id}');
      return true;
    } catch (e) {
      print('❌ Failed to update in Google Sheets: $e');
      return false;
    }
  }

  /// Delete bid from Google Sheets
  Future<bool> deleteBidFromSheet(String bidId) async {
    try {
      // Call backend to delete sheet row
      await Future.delayed(const Duration(milliseconds: 500));
      print('📊 Bid deleted from Google Sheets: $bidId');
      return true;
    } catch (e) {
      print('❌ Failed to delete from Google Sheets: $e');
      return false;
    }
  }

  /// Format bid data for sheets
  List<dynamic> _formatBidRow(BidModel bid) {
    return [
      bid.id,
      bid.clientName,
      bid.projectName,
      bid.projectType ?? '',
      bid.status,
      bid.totalItemsCount,
      bid.subtotal,
      bid.totalDiscount,
      bid.totalTax,
      bid.grandTotal,
      bid.createdAt.toIso8601String(),
      bid.submittedAt?.toIso8601String() ?? '',
      bid.approvedAt?.toIso8601String() ?? '',
      bid.userId ?? '',
      DateTime.now().toIso8601String(), // Sync timestamp
    ];
  }

  /// Get sheet headers
  List<String> get bidSheetHeaders => [
        'Bid ID',
        'Client Name',
        'Project Name',
        'Project Type',
        'Status',
        'Total Items',
        'Subtotal',
        'Discount',
        'Tax',
        'Grand Total',
        'Created At',
        'Submitted At',
        'Approved At',
        'User ID',
        'Synced At',
      ];
}

/// Google Sheets API Helper
/// This is a placeholder - implement based on your backend
class SheetsApiHelper {
  /// Read data from sheet
  static Future<List<List<dynamic>>> readSheet({
    required String spreadsheetId,
    required String range,
    required String apiKey,
  }) async {
    final url = Uri.parse(
      'https://sheets.googleapis.com/v4/spreadsheets/$spreadsheetId/values/$range?key=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['values'] as List?)?.cast<List<dynamic>>() ?? [];
    }

    throw Exception('Failed to read sheet: ${response.statusCode}');
  }

  /// Write data to sheet (requires OAuth - do this on backend)
  static Future<bool> writeSheet({
    required String spreadsheetId,
    required String range,
    required List<List<dynamic>> values,
    required String accessToken,
  }) async {
    final url = Uri.parse(
      'https://sheets.googleapis.com/v4/spreadsheets/$spreadsheetId/values/$range:append?valueInputOption=USER_ENTERED',
    );

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'values': values,
      }),
    );

    return response.statusCode == 200;
  }
}