import 'package:hive/hive.dart';

part 'bid_item_model.g.dart';

@HiveType(typeId: 2)
class BidItemModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final int quantity;

  @HiveField(3)
  final double unitPrice;

  @HiveField(4)
  final double discountPercent;

  @HiveField(5)
  final double taxPercent;

  @HiveField(6)
  final String? notes;

  @HiveField(7)
  final String? unit;

  BidItemModel({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.discountPercent = 0.0,
    this.taxPercent = 0.0,
    this.notes,
    this.unit,
  });

  // ==================== CALCULATIONS ====================

  /// Subtotal = Quantity × Unit Price
  double get subtotal => quantity * unitPrice;

  /// Discount Amount = Subtotal × (Discount % / 100)
  double get discountAmount => subtotal * (discountPercent / 100);

  /// Taxable Amount = Subtotal - Discount
  double get taxableAmount => subtotal - discountAmount;

  /// Tax Amount = Taxable Amount × (Tax % / 100)
  double get taxAmount => taxableAmount * (taxPercent / 100);

  /// Total = Taxable Amount + Tax Amount
  double get total => taxableAmount + taxAmount;

  // ==================== FACTORY METHODS ====================

  /// Create empty item
  factory BidItemModel.empty() {
    return BidItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description: '',
      quantity: 1,
      unitPrice: 0.0,
    );
  }

  /// From JSON
  factory BidItemModel.fromJson(Map<String, dynamic> json) {
    return BidItemModel(
      id:
          json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      description: json['description'] ?? '',
      quantity: _parseToInt(json['quantity']),
      unitPrice: _parseToDouble(json['unit_price']),
      discountPercent: _parseToDouble(json['discount_percent']),
      taxPercent: _parseToDouble(json['tax_percent']),
      notes: json['notes'],
      unit: json['unit'],
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'quantity': quantity,
      'unit_price': unitPrice,
      'discount_percent': discountPercent,
      'tax_percent': taxPercent,
      'notes': notes,
      'unit': unit,
      // Calculated fields for API
      'subtotal': subtotal,
      'discount_amount': discountAmount,
      'tax_amount': taxAmount,
      'total': total,
    };
  }

  /// Copy With
  BidItemModel copyWith({
    String? id,
    String? description,
    int? quantity,
    double? unitPrice,
    double? discountPercent,
    double? taxPercent,
    String? notes,
    String? unit,
  }) {
    return BidItemModel(
      id: id ?? this.id,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discountPercent: discountPercent ?? this.discountPercent,
      taxPercent: taxPercent ?? this.taxPercent,
      notes: notes ?? this.notes,
      unit: unit ?? this.unit,
    );
  }

  // ==================== HELPERS ====================

  static int _parseToInt(dynamic value) {
    if (value == null) return 1;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 1;
    return 1;
  }

  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Validate item
  bool get isValid {
    return description.isNotEmpty && quantity > 0 && unitPrice >= 0;
  }

  /// Get validation errors
  List<String> get validationErrors {
    final errors = <String>[];
    if (description.isEmpty) errors.add('Description is required');
    if (quantity <= 0) errors.add('Quantity must be greater than 0');
    if (unitPrice < 0) errors.add('Unit price cannot be negative');
    if (discountPercent < 0 || discountPercent > 100) {
      errors.add('Discount must be between 0 and 100');
    }
    if (taxPercent < 0 || taxPercent > 100) {
      errors.add('Tax must be between 0 and 100');
    }
    return errors;
  }

  @override
  String toString() {
    return 'BidItemModel(id: $id, description: $description, qty: $quantity, price: $unitPrice, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BidItemModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
