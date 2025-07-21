import 'package:injazat_hr_app/utils/backgrounddecoration.dart';
import 'package:injazat_hr_app/view/holidayscreen/holidayscreencontroller.dart';
import 'package:injazat_hr_app/view/holidayscreen/widget/customtabbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HolidayScreen extends StatelessWidget {
  const HolidayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HolidayScreenController());
    return Container(
      decoration: backgroundDecoration(context),
      child: const Scaffold(
        body:CustomTabBar()
      ),
    );
  }
}
