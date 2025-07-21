import 'package:injazat_hr_app/model/holidaymodel.dart';
import 'package:injazat_hr_app/repository/holidayrepository.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../utils/alertbox.dart';

class HolidayScreenController extends GetxController {
  final repositiory = HolidayRepository();
  final upcomingholidaylist = <HolidayModel>[].obs;
  final pastholidaylist = <HolidayModel>[].obs;

  final controller = ScrollController();

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
      var response = await repositiory.getAllNotice();

      final upcomingholiday = <HolidayModel>[];
      final pastHoliday = <HolidayModel>[];

      for (var data in response.data) {
        if (data.date.isAfter(DateTime(DateTime.now().year,
                DateTime.now().month, DateTime.now().day)) ||
            data.date.isAtSameMomentAs(DateTime(DateTime.now().year,
                DateTime.now().month, DateTime.now().day))) {
          upcomingholiday.add(HolidayModel(data.title, data.date));
        } else {
          pastHoliday.add(HolidayModel(data.title, data.date));
        }
      }

      upcomingholidaylist.value = upcomingholiday;
      pastholidaylist.value = pastHoliday.reversed.toList();
      return "loaded";
    } catch (e) {
      // Get.back();
      showAlert(e.toString());
      return "failed";
    }
  }
}
