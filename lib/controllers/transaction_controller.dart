import 'package:get/get.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class TransactionController extends GetxController {
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final errorMessage = ''.obs;
  final alltransactionlist = TransactionModel().obs;

  // Keeps the existing model unchanged; entries come from its parsed list.
  final transactions = <dynamic>[].obs;
  final TransactionApi _api = TransactionApi();
  final int itemsPerPage = 20;
  int currentPage = 0;
  int _generation = 0;
  Map<String, String> _activeFilters = {};

  Future<void> fetchTransactionData() async {
    final generation = ++_generation;
    isLoading.value = true;
    isLoadingMore.value = false;
    hasMore.value = true;
    errorMessage.value = '';
    currentPage = 0;
    transactions.clear();
    alltransactionlist.value = TransactionModel();
    try {
      _activeFilters = _api.captureFilters();
      final result = await _api.fetchTransactionPage(
        1,
        itemsPerPage: itemsPerPage,
        filters: Map<String, String>.from(_activeFilters),
      );
      if (generation != _generation) return;
      alltransactionlist.value = result.model;
      transactions.assignAll(
        result.model.data?.resellerBalanceTransactions ?? [],
      );
      currentPage = 1;
      hasMore.value = result.hasMore;
    } catch (_) {
      if (generation == _generation) {
        errorMessage.value = 'Unable to load transactions. Tap to retry.';
      }
    } finally {
      if (generation == _generation) isLoading.value = false;
    }
  }

  Future<void> loadMoreTransactions() async {
    if (isLoading.value ||
        isLoadingMore.value ||
        !hasMore.value ||
        currentPage == 0)
      return;
    final generation = _generation;
    final nextPage = currentPage + 1;
    isLoadingMore.value = true;
    errorMessage.value = '';
    try {
      final result = await _api.fetchTransactionPage(
        nextPage,
        itemsPerPage: itemsPerPage,
        filters: Map<String, String>.from(_activeFilters),
      );
      if (generation != _generation) return;
      transactions.addAll(result.model.data?.resellerBalanceTransactions ?? []);
      currentPage = nextPage;
      hasMore.value = result.hasMore;
    } catch (_) {
      if (generation == _generation) {
        errorMessage.value = 'Unable to load transactions. Tap to retry.';
      }
    } finally {
      if (generation == _generation) isLoadingMore.value = false;
    }
  }

  @override
  void onClose() {
    ++_generation;
    super.onClose();
  }
}
