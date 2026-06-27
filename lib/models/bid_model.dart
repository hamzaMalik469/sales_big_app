import 'package:hive/hive.dart';

import 'bid_item_model.dart';

part 'bid_model.g.dart';

/// Bid Status Enum
enum BidStatus {
  draft,
  pending,
  approved,
  rejected;

  String get displayName {
    switch (this) {
      case BidStatus.draft:
        return 'Draft';
      case BidStatus.pending:
        return 'Pending';
      case BidStatus.approved:
        return 'Approved';
      case BidStatus.rejected:
        return 'Rejected';
    }
  }

  static BidStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'draft':
        return BidStatus.draft;
      case 'pending':
        return BidStatus.pending;
      case 'approved':
        return BidStatus.approved;
      case 'rejected':
        return BidStatus.rejected;
      default:
        return BidStatus.draft;
    }
  }
}

@HiveType(typeId: 1)
class BidModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String clientName;

  @HiveField(2)
  final String projectName;

  @HiveField(3)
  final String? projectType;

  @HiveField(4)
  final String? clientEmail;

  @HiveField(5)
  final String? clientPhone;

  @HiveField(6)
  final String? clientAddress;

  @HiveField(7)
  final String? notes;

  @HiveField(8)
  final List<BidItemModel> items;

  @HiveField(9)
  final String status;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final DateTime? updatedAt;

  @HiveField(12)
  final DateTime? submittedAt;

  @HiveField(13)
  final DateTime? approvedAt;

  @HiveField(14)
  final String? approvedBy;

  @HiveField(15)
  final String? rejectionReason;

  @HiveField(16)
  final bool isSynced;

  @HiveField(17)
  final String? userId;

  @HiveField(18)
  final String? serverBidId;

  BidModel({
    required this.id,
    required this.clientName,
    required this.projectName,
    this.projectType,
    this.clientEmail,
    this.clientPhone,
    this.clientAddress,
    this.notes,
    required this.items,
    this.status = 'draft',
    required this.createdAt,
    this.updatedAt,
    this.submittedAt,
    this.approvedAt,
    this.approvedBy,
    this.rejectionReason,
    this.isSynced = false,
    this.userId,
    this.serverBidId,
  });

  // ==================== CALCULATIONS ====================

  /// Total Subtotal (sum of all item subtotals)
  double get subtotal {
    if (items.isEmpty) return 0.0;
    return items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  /// Total Discount Amount
  double get totalDiscount {
    if (items.isEmpty) return 0.0;
    return items.fold(0.0, (sum, item) => sum + item.discountAmount);
  }

  /// Total Tax Amount
  double get totalTax {
    if (items.isEmpty) return 0.0;
    return items.fold(0.0, (sum, item) => sum + item.taxAmount);
  }

  /// Grand Total
  double get grandTotal {
    if (items.isEmpty) return 0.0;
    return items.fold(0.0, (sum, item) => sum + item.total);
  }

  /// Average Discount Percentage
  double get averageDiscountPercent {
    if (items.isEmpty) return 0.0;
    return items.fold(0.0, (sum, item) => sum + item.discountPercent) /
        items.length;
  }

  /// Average Tax Percentage
  double get averageTaxPercent {
    if (items.isEmpty) return 0.0;
    return items.fold(0.0, (sum, item) => sum + item.taxPercent) / items.length;
  }

  /// Profit Margin (example calculation - customize as needed)
  double get profitMargin {
    if (subtotal == 0) return 0.0;
    // Assuming 30% cost base - adjust according to your business logic
    final costBase = subtotal * 0.7;
    return ((grandTotal - costBase) / grandTotal) * 100;
  }

  /// Total Items Count
  int get totalItemsCount => items.length;

  /// Total Quantity
  int get totalQuantity {
    if (items.isEmpty) return 0;
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  // ==================== STATUS HELPERS ====================

  BidStatus get bidStatus => BidStatus.fromString(status);

  bool get isDraft => bidStatus == BidStatus.draft;
  bool get isPending => bidStatus == BidStatus.pending;
  bool get isApproved => bidStatus == BidStatus.approved;
  bool get isRejected => bidStatus == BidStatus.rejected;

  /// Can be edited (draft or pending)
  bool get canEdit => isDraft || isPending;

  /// Can be deleted (only drafts)
  bool get canDelete => isDraft;

  /// Can be submitted (draft with items)
  bool get canSubmit => isDraft && items.isNotEmpty;

  // ==================== FACTORY METHODS ====================

  /// Create empty bid
  factory BidModel.empty() {
    return BidModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clientName: '',
      projectName: '',
      items: [],
      createdAt: DateTime.now(),
    );
  }

  /// Create new bid with basic info
  factory BidModel.create({
    required String clientName,
    required String projectName,
    String? projectType,
    String? clientEmail,
    String? clientPhone,
    String? clientAddress,
    String? notes,
    List<BidItemModel>? items,
    String? userId,
  }) {
    return BidModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clientName: clientName,
      projectName: projectName,
      projectType: projectType,
      clientEmail: clientEmail,
      clientPhone: clientPhone,
      clientAddress: clientAddress,
      notes: notes,
      items: items ?? [],
      status: 'draft',
      createdAt: DateTime.now(),
      isSynced: false,
      userId: userId,
    );
  }

  /// From JSON
  factory BidModel.fromJson(Map<String, dynamic> json) {
    return BidModel(
      id:
          json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      clientName: json['client_name'] ?? json['clientName'] ?? '',
      projectName: json['project_name'] ?? json['projectName'] ?? '',
      projectType: json['project_type'] ?? json['projectType'],
      clientEmail: json['client_email'] ?? json['clientEmail'],
      clientPhone: json['client_phone'] ?? json['clientPhone'],
      clientAddress: json['client_address'] ?? json['clientAddress'],
      notes: json['notes'],
      items: _parseItems(json['items']),
      status: json['status'] ?? 'draft',
      createdAt:
          _parseDateTime(json['created_at'] ?? json['createdAt']) ??
          DateTime.now(),
      updatedAt: _parseDateTime(json['updated_at'] ?? json['updatedAt']),
      submittedAt: _parseDateTime(json['submitted_at'] ?? json['submittedAt']),
      approvedAt: _parseDateTime(json['approved_at'] ?? json['approvedAt']),
      approvedBy: json['approved_by'] ?? json['approvedBy'],
      rejectionReason: json['rejection_reason'] ?? json['rejectionReason'],
      isSynced: json['is_synced'] ?? json['isSynced'] ?? true,
      userId: json['user_id']?.toString() ?? json['userId']?.toString(),
      serverBidId:
          json['server_bid_id']?.toString() ?? json['serverBidId']?.toString(),
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_name': clientName,
      'project_name': projectName,
      'project_type': projectType,
      'client_email': clientEmail,
      'client_phone': clientPhone,
      'client_address': clientAddress,
      'notes': notes,
      'items': items.map((item) => item.toJson()).toList(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'submitted_at': submittedAt?.toIso8601String(),
      'approved_at': approvedAt?.toIso8601String(),
      'approved_by': approvedBy,
      'rejection_reason': rejectionReason,
      'is_synced': isSynced,
      'user_id': userId,
      'server_bid_id': serverBidId,
      // Calculated fields
      'subtotal': subtotal,
      'total_discount': totalDiscount,
      'total_tax': totalTax,
      'grand_total': grandTotal,
      'total_items': totalItemsCount,
    };
  }

  /// Copy With
  BidModel copyWith({
    String? id,
    String? clientName,
    String? projectName,
    String? projectType,
    String? clientEmail,
    String? clientPhone,
    String? clientAddress,
    String? notes,
    List<BidItemModel>? items,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? submittedAt,
    DateTime? approvedAt,
    String? approvedBy,
    String? rejectionReason,
    bool? isSynced,
    String? userId,
    String? serverBidId,
  }) {
    return BidModel(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      projectName: projectName ?? this.projectName,
      projectType: projectType ?? this.projectType,
      clientEmail: clientEmail ?? this.clientEmail,
      clientPhone: clientPhone ?? this.clientPhone,
      clientAddress: clientAddress ?? this.clientAddress,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      submittedAt: submittedAt ?? this.submittedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      isSynced: isSynced ?? this.isSynced,
      userId: userId ?? this.userId,
      serverBidId: serverBidId ?? this.serverBidId,
    );
  }

  // ==================== HELPERS ====================

  static List<BidItemModel> _parseItems(dynamic itemsJson) {
    if (itemsJson == null) return [];
    if (itemsJson is List) {
      return itemsJson
          .map((item) => BidItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// Validate bid
  bool get isValid {
    return clientName.isNotEmpty &&
        projectName.isNotEmpty &&
        items.isNotEmpty &&
        items.every((item) => item.isValid);
  }

  /// Get validation errors
  List<String> get validationErrors {
    final errors = <String>[];
    if (clientName.isEmpty) errors.add('Client name is required');
    if (projectName.isEmpty) errors.add('Project name is required');
    if (items.isEmpty) errors.add('At least one item is required');
    for (var i = 0; i < items.length; i++) {
      final itemErrors = items[i].validationErrors;
      for (final error in itemErrors) {
        errors.add('Item ${i + 1}: $error');
      }
    }
    return errors;
  }

  /// Get summary text
  String get summaryText {
    return '$totalItemsCount items • \$${grandTotal.toStringAsFixed(2)}';
  }

  @override
  String toString() {
    return 'BidModel(id: $id, client: $clientName, project: $projectName, status: $status, total: $grandTotal)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BidModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
