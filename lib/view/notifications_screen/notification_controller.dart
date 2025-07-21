import 'package:injazat_hr_app/model/birthdaymodel.dart';
import 'package:injazat_hr_app/model/noticemodel.dart';
import 'package:injazat_hr_app/repository/noticerepository.dart';
import 'package:injazat_hr_app/utils/alertbox.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NotificatiionController extends GetxController {
  final repositiory = NoticeRepository();
  final noticelsit = <NoticeModel>[].obs;
  final birthdaylist=<BirthdayModel>[].obs;
  final controller = ScrollController();

  @override
  void onInit() {
    controller.addListener(loadmore);
    getAllNotice();
    super.onInit();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void loadmore() {
    if (controller.position.pixels == controller.position.maxScrollExtent) {
      getAllNotice();
    }
  }

  Future<String> getAllNotice() async {
    try {
      var response = await repositiory.getAllNotice();
      final notice = <NoticeModel>[];
      final birthday=<BirthdayModel>[];
      for (var data in response.data.notice) {
        notice.add(NoticeModel(data.title, data.description, "${DateFormat("yyyy/MM/dd").format(data.startDate)} - ${DateFormat("yyyy/MM/dd").format(data.endDate)}"));
      }
      for(var data in response.data.birthday){
        birthday.add(BirthdayModel(data.name, data.date));
      }
      birthdaylist.value=birthday;
      noticelsit.value = notice;
      return "loaded";
    } catch (e) {
      showAlert(e.toString());
      return "failed";
    }
  }
}
