import '../../models/bid_model.dart';
import '../../models/bid_item_model.dart';

enum CreateBidStatus { initial, loading, success, error }

enum CreateBidStep { basicInfo, addItems, calculation, review }

class CreateBidState {
  // Status
  final CreateBidStatus status;
  final CreateBidStep currentStep;
  final String? errorMessage;
  final String? successMessage;
  final bool isOffline;

  // Step 1: Basic Info
  final String clientName;
  final String projectName;
  final String? projectType;
  final String? clientEmail;
  final String? clientPhone;
  final String? clientAddress;
  final String? notes;

  // Step 2: Items
  final List<BidItemModel> items;
  final int? editingItemIndex;

  // Validation Errors
  final String? clientNameError;
  final String? projectNameError;

  const CreateBidState({
    this.status = CreateBidStatus.initial,
    this.currentStep = CreateBidStep.basicInfo,
    this.errorMessage,
    this.successMessage,
    this.isOffline = false,
    // Basic Info
    this.clientName = '',
    this.projectName = '',
    this.projectType,
    this.clientEmail,
    this.clientPhone,
    this.clientAddress,
    this.notes,
    // Items
    this.items = const [],
    this.editingItemIndex,
    // Validation
    this.clientNameError,
    this.projectNameError,
  });

  CreateBidState copyWith({
    CreateBidStatus? status,
    CreateBidStep? currentStep,
    String? errorMessage,
    String? successMessage,
    bool? isOffline,
    String? clientName,
    String? projectName,
    String? projectType,
    String? clientEmail,
    String? clientPhone,
    String? clientAddress,
    String? notes,
    List<BidItemModel>? items,
    int? editingItemIndex,
    String? clientNameError,
    String? projectNameError,
  }) {
    return CreateBidState(
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      errorMessage: errorMessage,
      successMessage: successMessage,
      isOffline: isOffline ?? this.isOffline,
      clientName: clientName ?? this.clientName,
      projectName: projectName ?? this.projectName,
      projectType: projectType ?? this.projectType,
      clientEmail: clientEmail ?? this.clientEmail,
      clientPhone: clientPhone ?? this.clientPhone,
      clientAddress: clientAddress ?? this.clientAddress,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      editingItemIndex: editingItemIndex,
      clientNameError: clientNameError,
      projectNameError: projectNameError,
    );
  }

  // ==================== GETTERS ====================

  bool get isLoading => status == CreateBidStatus.loading;
  bool get isSuccess => status == CreateBidStatus.success;
  bool get hasError => status == CreateBidStatus.error;

  // Step Index
  int get currentStepIndex => CreateBidStep.values.indexOf(currentStep);
  int get totalSteps => CreateBidStep.values.length;
  bool get isFirstStep => currentStep == CreateBidStep.basicInfo;
  bool get isLastStep => currentStep == CreateBidStep.review;

  // Validation
  bool get isBasicInfoValid =>
      clientName.isNotEmpty &&
      projectName.isNotEmpty &&
      clientNameError == null &&
      projectNameError == null;

  bool get hasItems => items.isNotEmpty;

  bool get canProceedToItems => isBasicInfoValid;
  bool get canProceedToCalculation => isBasicInfoValid && hasItems;
  bool get canProceedToReview => isBasicInfoValid && hasItems;
  bool get canSubmit => isBasicInfoValid && hasItems && !isLoading;

  // ==================== CALCULATIONS ====================

  double get subtotal {
    if (items.isEmpty) return 0.0;
    return items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  double get totalDiscount {
    if (items.isEmpty) return 0.0;
    return items.fold(0.0, (sum, item) => sum + item.discountAmount);
  }

  double get totalTax {
    if (items.isEmpty) return 0.0;
    return items.fold(0.0, (sum, item) => sum + item.taxAmount);
  }

  double get grandTotal {
    if (items.isEmpty) return 0.0;
    return items.fold(0.0, (sum, item) => sum + item.total);
  }

  int get totalQuantity {
    if (items.isEmpty) return 0;
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get averageDiscountPercent {
    if (items.isEmpty) return 0.0;
    return items.fold(0.0, (sum, item) => sum + item.discountPercent) /
        items.length;
  }

  double get averageTaxPercent {
    if (items.isEmpty) return 0.0;
    return items.fold(0.0, (sum, item) => sum + item.taxPercent) / items.length;
  }

  // ==================== CREATE BID MODEL ====================

  BidModel toBidModel({String? id, String? userId}) {
    return BidModel(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      clientName: clientName,
      projectName: projectName,
      projectType: projectType,
      clientEmail: clientEmail,
      clientPhone: clientPhone,
      clientAddress: clientAddress,
      notes: notes,
      items: items,
      status: 'draft',
      createdAt: DateTime.now(),
      isSynced: false,
      userId: userId,
    );
  }
}

// Project Type Options
class ProjectTypes {
  static const List<String> types = [
    'New Installation',
    'Upgrade',
    'Maintenance',
    'Consulting',
    'Support',
    'Training',
    'Custom Development',
    'Other',
  ];
}
