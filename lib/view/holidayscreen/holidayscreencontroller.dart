import 'package:co.injazathr.injazathr/data/remote/response/holiday_response.dart';
import 'package:co.injazathr.injazathr/repository/holidayrepository.dart';
import 'package:co.injazathr.injazathr/utils/language_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../utils/alertbox.dart';

class HolidayScreenController extends GetxController {
  final repositiory = HolidayRepository();
  final filteredholidaylist = <HolidayItem>[].obs;

  final controller = ScrollController();

  final selectedFilter = 'upcoming'.obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;

  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void onInit() {
    controller.addListener(_onScroll);
    getAllholiday();
    ever(LanguageService.instance.currentLanguage, (_) => getAllholiday());
    super.onInit();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (controller.position.pixels >= controller.position.maxScrollExtent - 200) {
      loadMore();
    }
  }

  Future<void> getAllholiday() async {
    try {
      isLoading.value = true;
      _currentPage = 1;
      _hasMore = true;
      filteredholidaylist.clear();

      final response = await repositiory.getAllNotice(
        page: _currentPage,
        filter: selectedFilter.value,
      );
      _hasMore = response.data.pagination.hasMore;
      filteredholidaylist.addAll(response.data.items);
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
      final response = await repositiory.getAllNotice(
        page: _currentPage,
        filter: selectedFilter.value,
      );
      _hasMore = response.data.pagination.hasMore;
      filteredholidaylist.addAll(response.data.items);
    } catch (e) {
      _currentPage--;
      showAlert(e.toString());
    } finally {
      isLoadingMore.value = false;
    }
  }

  void filterByType(String filterType) {
    selectedFilter.value = filterType;
    getAllholiday();
  }

  Future<void> refreshHolidays() async {
    await getAllholiday();
  }
}
