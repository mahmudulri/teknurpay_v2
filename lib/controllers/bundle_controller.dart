import 'package:get/get.dart';
import 'package:teknurpay/models/bundle_model.dart';
import 'package:teknurpay/services/bundle_service.dart';

class BundleController extends GetxController {
  int initialpage = 1;
  final RxList<Bundle> finalList = <Bundle>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLookupLoading = false.obs;
  final Rx<BundleModel> allbundleslist = BundleModel().obs;

  int _requestId = 0;
  int _loadedPage = 0;
  bool _hasMore = false;
  String? _lookupNumber;

  bool get hasMore => _hasMore;

  // Ignore an old response if the phone number changes during a request.
  void invalidateRequests() {
    _requestId++;
    isLoading.value = false;
    isLookupLoading.value = false;
    _hasMore = false;
  }

  Future<void> fetchallbundles() => _fetchPage(initialpage);

  Future<void> fetchlookupbundles(String phoneNumber, {int pageNo = 1}) async {
    final number = phoneNumber.trim();
    if (number.isEmpty) return;
    await _fetchPage(pageNo, phoneNumber: number);
  }

  Future<void> loadNextPage({String? phoneNumber}) async {
    if (isLoading.value || isLookupLoading.value || !_hasMore) return;
    final number = phoneNumber?.trim();
    // Never append results from another phone number or another API mode.
    if (number != _lookupNumber) return;
    await _fetchPage(_loadedPage + 1, phoneNumber: number);
  }

  Future<void> _fetchPage(int page, {String? phoneNumber}) async {
    final lookup = phoneNumber != null;
    if (page > 1 && (isLoading.value || isLookupLoading.value)) return;
    final request = ++_requestId;
    if (page == 1) {
      _hasMore = false;
      _loadedPage = 0;
      _lookupNumber = phoneNumber;
    }
    isLoading.value = !lookup;
    isLookupLoading.value = lookup;
    try {
      final api = BundlesApi();
      final response = lookup
          ? await api.fetchlookupBundles(phoneNumber!, pageNo: page)
          : await api.fetchBundles(page);
      if (request != _requestId) return;

      final bundles = response.data?.bundles ?? <Bundle>[];
      final totalPages = response.payload?.pagination.totalPages ?? 0;
      allbundleslist.value = response;
      if (page == 1) finalList.clear();

      final existingIds = finalList
          .where((bundle) => bundle.id != null)
          .map((bundle) => bundle.id.toString())
          .toSet();
      int added = 0;
      for (final bundle in bundles) {
        if (bundle.id == null || existingIds.add(bundle.id.toString())) {
          finalList.add(bundle);
          added++;
        }
      }

      _loadedPage = page;
      initialpage = page;
      // Prefer backend pagination metadata. Without it, probe until empty.
      // Repeated pages stop here if the server ignores the page parameter.
      _hasMore =
          bundles.isNotEmpty &&
          added > 0 &&
          (totalPages <= 0 || page < totalPages);
      print(
        'Bundles: page=$page, pages=$totalPages, '
        'received=${bundles.length}, total=${finalList.length}, lookup=$lookup',
      );
    } catch (e) {
      if (request != _requestId) return;
      if (page == 1) finalList.clear();
      // Commit a page only after success, so the failed page can be retried.
      initialpage = _loadedPage > 0 ? _loadedPage : 1;
      print('Bundle API error (page $page): $e');
    } finally {
      if (request == _requestId) {
        isLoading.value = false;
        isLookupLoading.value = false;
      }
    }
  }

  void resetBundles() {
    invalidateRequests();
    initialpage = 1;
    _loadedPage = 0;
    _lookupNumber = null;
    finalList.clear();
    allbundleslist.value = BundleModel();
  }
}
