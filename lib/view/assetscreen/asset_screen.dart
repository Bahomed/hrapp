import 'package:co.injazathr.injazathr/services/theme_service.dart';
import 'package:co.injazathr.injazathr/utils/translation_helper.dart';
import 'package:co.injazathr.injazathr/view/assetscreen/assetscreen_controller.dart';
import 'package:co.injazathr.injazathr/view/assetscreen/widget/asset_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AssetScreen extends StatelessWidget {
  const AssetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AssetScreenController());
    final themeService = ThemeService.instance;

    return Scaffold(
      backgroundColor: themeService.getPageBackgroundColor(),
      appBar: AppBar(
        backgroundColor: themeService.getSurfaceColor(),
        elevation: 0,
        title: Text(
          tr('my_assets'),
          style: TextStyle(
            color: themeService.getTextPrimaryColor(),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: themeService.getTextPrimaryColor()),
          onPressed: () => Get.back(),
        ),
      ),
      body: const AssetListWidget(),
    );
  }
}
