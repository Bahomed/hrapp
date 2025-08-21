import 'package:com.injazatsoftware.injazathr/data/remote/response/holiday_response.dart';
import 'package:com.injazatsoftware.injazathr/repository/holidayrepository.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../utils/alertbox.dart';

class HolidayScreenController extends GetxController {
  final repositiory = HolidayRepository();
  final upcomingholidaylist = <Datum>[].obs;
  final pastholidaylist = <Datum>[].obs;
  final allholidaylist = <Datum>[].obs;
  final filteredholidaylist = <Datum>[].obs;

  final controller = ScrollController();
  
  // Filter state
  final selectedFilter = 'upcoming'.obs; // 'upcoming', 'past'
  final isLoading = false.obs;

  @override
  void onInit() {
    controller.addListener(loadmore);
    getAllholiday();

    super.onInit();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void loadmore() {
    if (controller.position.pixels == controller.position.maxScrollExtent) {
      getAllholiday();
    }
  }

  Future<String> getAllholiday() async {
    try {
      isLoading.value = true;
      var response = await repositiory.getAllNotice();

      final upcomingholiday = <Datum>[];
      final pastHoliday = <Datum>[];
      final allholiday = <Datum>[];

      for (var data in response.data) {
        allholiday.add(data);
        
        if (data.date.isAfter(DateTime(DateTime.now().year,
                DateTime.now().month, DateTime.now().day)) ||
            data.date.isAtSameMomentAs(DateTime(DateTime.now().year,
                DateTime.now().month, DateTime.now().day))) {
          upcomingholiday.add(data);
        } else {
          pastHoliday.add(data);
        }
      }

      upcomingholidaylist.value = upcomingholiday;
      pastholidaylist.value = pastHoliday.reversed.toList();
      allholidaylist.value = allholiday;
      
      // Apply current filter
      _applyFilter();
      
      isLoading.value = false;
      return "loaded";
    } catch (e) {
      isLoading.value = false;
      showAlert(e.toString());
      return "failed";
    }
  }
  
  void filterByType(String filterType) {
    selectedFilter.value = filterType;
    _applyFilter();
  }
  
  void _applyFilter() {
    switch (selectedFilter.value) {
      case 'upcoming':
        filteredholidaylist.value = upcomingholidaylist.toList();
        break;
      case 'past':
        filteredholidaylist.value = pastholidaylist.toList();
        break;
    }
  }
  
  Future<void> refreshHolidays() async {
    await getAllholiday();
  }
}
