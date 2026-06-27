import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sales_bid_app/models/bid_model.dart';

import '../../models/bid_item_model.dart';
import '../../services/bid_service.dart';
import '../../services/connectivity_service.dart';
import 'create_bid_state.dart';

class CreateBidCubit extends Cubit<CreateBidState> {
  final BidService _bidService;
  final ConnectivityService _connectivityService;

  CreateBidCubit({
    required BidService bidService,
    required ConnectivityService connectivityService,
  }) : _bidService = bidService,
       _connectivityService = connectivityService,
       super(const CreateBidState()) {
    _initConnectivity();
  }

  void _initConnectivity() {
    emit(state.copyWith(isOffline: !_connectivityService.isConnected));

    _connectivityService.statusStream.listen((status) {
      emit(state.copyWith(isOffline: status == ConnectionStatus.offline));
    });
  }

  // ==================== NAVIGATION ====================

  void goToStep(CreateBidStep step) {
    emit(state.copyWith(currentStep: step, errorMessage: null));
  }

  void nextStep() {
    final currentIndex = state.currentStepIndex;
    if (currentIndex < state.totalSteps - 1) {
      final nextStep = CreateBidStep.values[currentIndex + 1];

      // Validate before proceeding
      if (_canProceedToStep(nextStep)) {
        emit(state.copyWith(currentStep: nextStep, errorMessage: null));
      }
    }
  }

  void previousStep() {
    final currentIndex = state.currentStepIndex;
    if (currentIndex > 0) {
      final prevStep = CreateBidStep.values[currentIndex - 1];
      emit(state.copyWith(currentStep: prevStep, errorMessage: null));
    }
  }

  bool _canProceedToStep(CreateBidStep step) {
    switch (step) {
      case CreateBidStep.basicInfo:
        return true;
      case CreateBidStep.addItems:
        return _validateBasicInfo();
      case CreateBidStep.calculation:
        if (!_validateBasicInfo()) return false;
        if (!state.hasItems) {
          emit(state.copyWith(errorMessage: 'Please add at least one item'));
          return false;
        }
        return true;
      case CreateBidStep.review:
        if (!_validateBasicInfo()) return false;
        if (!state.hasItems) {
          emit(state.copyWith(errorMessage: 'Please add at least one item'));
          return false;
        }
        return true;
    }
  }

  // ==================== STEP 1: BASIC INFO ====================

  void updateClientName(String value) {
    String? error;
    if (value.isNotEmpty && value.length < 2) {
      error = 'Client name must be at least 2 characters';
    }
    emit(
      state.copyWith(
        clientName: value,
        clientNameError: error,
        errorMessage: null,
      ),
    );
  }

  void updateProjectName(String value) {
    String? error;
    if (value.isNotEmpty && value.length < 2) {
      error = 'Project name must be at least 2 characters';
    }
    emit(
      state.copyWith(
        projectName: value,
        projectNameError: error,
        errorMessage: null,
      ),
    );
  }

  void updateProjectType(String? value) {
    emit(state.copyWith(projectType: value));
  }

  void updateClientEmail(String value) {
    emit(state.copyWith(clientEmail: value.isEmpty ? null : value));
  }

  void updateClientPhone(String value) {
    emit(state.copyWith(clientPhone: value.isEmpty ? null : value));
  }

  void updateClientAddress(String value) {
    emit(state.copyWith(clientAddress: value.isEmpty ? null : value));
  }

  void updateNotes(String value) {
    emit(state.copyWith(notes: value.isEmpty ? null : value));
  }

  bool _validateBasicInfo() {
    bool isValid = true;
    String? clientNameError;
    String? projectNameError;

    if (state.clientName.isEmpty) {
      clientNameError = 'Client name is required';
      isValid = false;
    } else if (state.clientName.length < 2) {
      clientNameError = 'Client name must be at least 2 characters';
      isValid = false;
    }

    if (state.projectName.isEmpty) {
      projectNameError = 'Project name is required';
      isValid = false;
    } else if (state.projectName.length < 2) {
      projectNameError = 'Project name must be at least 2 characters';
      isValid = false;
    }

    emit(
      state.copyWith(
        clientNameError: clientNameError,
        projectNameError: projectNameError,
      ),
    );

    return isValid;
  }

  // ==================== STEP 2: ITEMS ====================

  void addItem(BidItemModel item) {
    final updatedItems = [...state.items, item];
    emit(state.copyWith(items: updatedItems, errorMessage: null));
  }

  void updateItem(int index, BidItemModel item) {
    if (index < 0 || index >= state.items.length) return;

    final updatedItems = List<BidItemModel>.from(state.items);
    updatedItems[index] = item;
    emit(state.copyWith(items: updatedItems, editingItemIndex: null));
  }

  void removeItem(int index) {
    if (index < 0 || index >= state.items.length) return;

    final updatedItems = List<BidItemModel>.from(state.items);
    updatedItems.removeAt(index);
    emit(state.copyWith(items: updatedItems));
  }

  void setEditingItem(int? index) {
    emit(state.copyWith(editingItemIndex: index));
  }

  void duplicateItem(int index) {
    if (index < 0 || index >= state.items.length) return;

    final itemToDuplicate = state.items[index];
    final duplicatedItem = itemToDuplicate.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );

    final updatedItems = List<BidItemModel>.from(state.items);
    updatedItems.insert(index + 1, duplicatedItem);
    emit(state.copyWith(items: updatedItems));
  }

  void reorderItems(int oldIndex, int newIndex) {
    final updatedItems = List<BidItemModel>.from(state.items);
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = updatedItems.removeAt(oldIndex);
    updatedItems.insert(newIndex, item);
    emit(state.copyWith(items: updatedItems));
  }

  // ==================== SUBMIT ====================

  Future<void> submitBid() async {
    if (!state.canSubmit) return;

    emit(state.copyWith(status: CreateBidStatus.loading, errorMessage: null));

    try {
      final bid = state.toBidModel();
      final updatedBid = bid.copyWith(status: 'pending');

      final response = await _bidService.createBid(updatedBid);

      if (response.success) {
        emit(
          state.copyWith(
            status: CreateBidStatus.success,
            successMessage: state.isOffline
                ? 'Bid saved offline. Will sync when connected.'
                : 'Bid submitted successfully!',
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: CreateBidStatus.error,
            errorMessage: response.message ?? 'Failed to submit bid',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: CreateBidStatus.error,
          errorMessage: 'An unexpected error occurred',
        ),
      );
    }
  }

  Future<void> saveDraft() async {
    if (!state.isBasicInfoValid) {
      _validateBasicInfo();
      return;
    }

    emit(state.copyWith(status: CreateBidStatus.loading, errorMessage: null));

    try {
      final bid = state.toBidModel();

      final response = await _bidService.createBid(bid);

      if (response.success) {
        emit(
          state.copyWith(
            status: CreateBidStatus.success,
            successMessage: 'Draft saved successfully!',
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: CreateBidStatus.error,
            errorMessage: response.message ?? 'Failed to save draft',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: CreateBidStatus.error,
          errorMessage: 'An unexpected error occurred',
        ),
      );
    }
  }

  // Add to CreateBidCubit class
  void initializeWithBid(BidModel bid) {
    emit(
      state.copyWith(
        clientName: bid.clientName,
        projectName: bid.projectName,
        projectType: bid.projectType,
        clientEmail: bid.clientEmail,
        clientPhone: bid.clientPhone,
        clientAddress: bid.clientAddress,
        notes: bid.notes,
        items: bid.items,
      ),
    );
  }

  // ==================== RESET ====================

  void reset() {
    emit(const CreateBidState());
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
