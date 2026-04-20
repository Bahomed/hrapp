import 'package:co.injazathr.injazathr/data/remote/response/asset_response.dart';
import 'package:co.injazathr.injazathr/repository/assetrepository.dart';
import 'package:co.injazathr.injazathr/utils/language_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../utils/alertbox.dart';

class AssetScreenController extends GetxController {
  final repository = AssetRepository();
  final scrollController = ScrollController();

  final assetList = <AssetAssignmentItem>[].obs;
  final summary = Rxn<AssetSummary>();
  final selectedFilter = 'assigned'.obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isSummaryLoading = false.obs;

  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void onInit() {
    scrollController.addListener(_onScroll);
    loadSummary();
    loadAssets();
    ever(LanguageService.instance.currentLanguage, (_) => loadAssets());
    super.onInit();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      loadMore();
    }
  }

  Future<void> loadSummary() async {
    try {
      isSummaryLoading.value = true;
      final response = await repository.getMyAssetsSummary();
      summary.value = response.data;
    } catch (_) {
    } finally {
      isSummaryLoading.value = false;
    }
  }

  Future<void> loadAssets() async {
    try {
      isLoading.value = true;
      _currentPage = 1;
      _hasMore = true;
      assetList.clear();

      final response = await repository.getMyAssets(
        page: _currentPage,
        status: selectedFilter.value,
      );
      _hasMore = response.data.pagination.hasMore;
      assetList.addAll(response.data.items);
    } catch (e) {
      showAlert(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !_hasMore) return;
    try {
      isLoadingMore.value = true;
      _currentPage++;
      final response = await repository.getMyAssets(
        page: _currentPage,
        status: selectedFilter.value,
      );
      _hasMore = response.data.pagination.hasMore;
      assetList.addAll(response.data.items);
    } catch (e) {
      _currentPage--;
      showAlert(e.toString());
    } finally {
      isLoadingMore.value = false;
    }
  }

  void filterByStatus(String status) {
    selectedFilter.value = status;
    loadAssets();
  }

  @override
  Future<void> refresh() async {
    await loadSummary();
    await loadAssets();
  }
}
