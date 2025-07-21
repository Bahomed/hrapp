import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import 'customborderradius.dart';
import '../services/theme_service.dart';

enum AlertType { warning, success, error, others, password, url }

void showLottieDialog(
    String title, String desc, AlertType type, String lottiePath) {
  final themeService = ThemeService.instance;
  Get.dialog(
    barrierDismissible: false,
    AlertDialog(
      backgroundColor: themeService.getCardColor(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: themeService.getTextPrimaryColor(),
        ),
      ),
      content: SizedBox(
        height: 140,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(lottiePath, repeat: false, width: 100, height: 100),
            Text(
              desc,
              style: TextStyle(
                fontWeight: FontWeight.normal, 
                fontSize: 15,
                color: themeService.getTextPrimaryColor(),
              ),
            )
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              backgroundColor: type == AlertType.success
                  ? themeService.getSuccessColor()
                  : type == AlertType.warning
                      ? themeService.getWarningColor()
                      : themeService.getErrorColor()),
          child: Container(
            width: double.infinity,
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Text(
                "Okay",
                style: TextStyle(color: themeService.getSilver()),
              ),
            ),
          ),
          onPressed: () {
            Get.back();
            Get.back();
          },
        ),
      ],
    ),
  );
}

void showAlertDialog(String title, String desc) {
  final themeService = ThemeService.instance;
  Get.dialog(
    barrierDismissible: false,
    AlertDialog(
      backgroundColor: themeService.getCardColor(),
      shape: RoundedRectangleBorder(borderRadius: borderRadius()),
      elevation: 0,
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: themeService.getTextPrimaryColor(),
        ),
      ),
      content: SizedBox(
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning,
              color: themeService.getWarningColor(),
              size: 80,
            ),
            Text(
              desc,
              style: TextStyle(
                fontWeight: FontWeight.normal, 
                fontSize: 15,
                color: themeService.getTextPrimaryColor(),
              ),
            )
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: borderRadius()),
            backgroundColor: themeService.getPrimaryColor(),
          ),
          child: Container(
            width: double.infinity,
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Text(
                "Okay",
                style: TextStyle(color: themeService.getSilver()),
              ),
            ),
          ),
          onPressed: () {
            Get.back();
          },
        ),
      ],
    ),
  );
}

Icon alertIconType(AlertType type) {
  final themeService = ThemeService.instance;
  const size = 60.0;
  switch (type) {
    case AlertType.success:
      {
        return Icon(
          Icons.check_circle,
          color: themeService.getSuccessColor(),
          size: size,
        );
      }
    case AlertType.warning:
      {
        return Icon(
          Icons.warning,
          color: themeService.getWarningColor(),
          size: size,
        );
      }
    case AlertType.error:
      {
        return Icon(
          Icons.error,
          color: themeService.getErrorColor(),
          size: size,
        );
      }
    case AlertType.password:
      {
        return Icon(
          Icons.key,
          color: themeService.getTextSecondaryColor(),
          size: size,
        );
      }
    case AlertType.url:
      {
        return Icon(
          Icons.link,
          color: themeService.getTextSecondaryColor(),
          size: size,
        );
      }
    default:
      {
        return Icon(
          Icons.question_mark,
          color: themeService.getTextSecondaryColor(),
          size: size,
        );
      }
  }
}

void customLoader() {
  final themeService = ThemeService.instance;
  Get.dialog(
    barrierDismissible: false,
    Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          color: themeService.getCardColor(),
          width: 150,
          height: 150,
          padding: const EdgeInsets.all(40),
          child: CircularProgressIndicator(
            backgroundColor: themeService.getTextSecondaryColor().withOpacity(0.3),
            color: themeService.getPrimaryColor(),
            strokeWidth: 5,
            strokeAlign: CircularProgressIndicator.strokeAlignCenter,
          ),
        ),
      ),
    ),
  );
}

showAlert(String message) {
  final themeService = ThemeService.instance;
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: themeService.isDarkMode ? themeService.getDarkBlack() : themeService.getTextPrimaryColor(),
      textColor: themeService.isDarkMode ? themeService.getSilver() : themeService.getSilver(),
      fontSize: 14.0);
}

void customDilogBox(
    IconData icon, String title, String desc, VoidCallback confirmBtn) {
  final themeService = ThemeService.instance;
  Get.dialog(
    barrierDismissible: false,
    AlertDialog(
      backgroundColor: themeService.getCardColor(),
      shape: RoundedRectangleBorder(borderRadius: borderRadius()),
      elevation: 0,
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: themeService.getTextPrimaryColor(),
        ),
      ),
      content: SizedBox(
        height: 125,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: themeService.getPrimaryColor(),
              size: 100,
            ),
            Text(
              desc,
              style: TextStyle(
                fontWeight: FontWeight.normal, 
                fontSize: 15,
                color: themeService.getTextPrimaryColor(),
              ),
            )
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      actionsOverflowButtonSpacing: 10,
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: borderRadius()),
              backgroundColor: themeService.getPrimaryColor()),
          onPressed: confirmBtn,
          child: Container(
            width: double.infinity,
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Text(
                "Okay",
                style: TextStyle(color: themeService.getSilver()),
              ),
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: borderRadius()),
              backgroundColor: themeService.getPrimaryColor().withOpacity(0.7)),
          child: Container(
            width: double.infinity,
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Text(
                "Cancel",
                style: TextStyle(color: themeService.getSilver()),
              ),
            ),
          ),
          onPressed: () {
            Get.back();
          },
        ),
      ],
    ),
  );
}

void customDilogBoxForAttendance(String title, String image) {
  final themeService = ThemeService.instance;
  Get.dialog(
    barrierDismissible: false,
    AlertDialog(
      backgroundColor: themeService.getCardColor(),
      shape: RoundedRectangleBorder(borderRadius: borderRadius()),
      elevation: 0,
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: themeService.getTextPrimaryColor(),
        ),
      ),
      content: SizedBox(
        height: 125,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
                child: ClipRRect(
              borderRadius: borderRadius(),
              child: Image.network(
                image,
                fit: BoxFit.cover,
                width: 120,
                height: 120,
              ),
            )),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      actionsOverflowButtonSpacing: 10,
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: borderRadius()),
              backgroundColor: themeService.getPrimaryColor().withOpacity(0.7)),
          child: Container(
            width: double.infinity,
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Text(
                "Cancel",
                style: TextStyle(color: themeService.getSilver()),
              ),
            ),
          ),
          onPressed: () {
            Get.back();
          },
        ),
      ],
    ),
  );
}

void dilogBoxForFaceId(int count, IconData icon, String title, String desc,
    VoidCallback confirmBtn, VoidCallback deleteBtn) {
  final themeService = ThemeService.instance;
  Get.dialog(
    barrierDismissible: false,
    AlertDialog(
      backgroundColor: themeService.getCardColor(),
      shape: RoundedRectangleBorder(borderRadius: borderRadius()),
      elevation: 0,
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: themeService.getTextPrimaryColor(),
        ),
      ),
      content: SizedBox(
        height: 155,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: themeService.getPrimaryColor(),
              size: 100,
            ),
            Text(
              desc,
              style: TextStyle(
                fontWeight: FontWeight.normal, 
                fontSize: 15,
                color: themeService.getTextPrimaryColor(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top:5),
              child: Text(
                "Total: $count",
                style: TextStyle(
                  fontWeight: FontWeight.normal, 
                  fontSize: 18,
                  color: themeService.getTextPrimaryColor(),
                ),
              ),
            )
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      actionsOverflowButtonSpacing: 10,
      contentPadding: EdgeInsets.zero,
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: borderRadius()),
              backgroundColor: themeService.getPrimaryColor()),
          onPressed: confirmBtn,
          child: Container(
            width: double.infinity,
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Text(
                "Save FaceId",
                style: TextStyle(color: themeService.getSilver()),
              ),
            ),
          ),
        ),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: borderRadius()),
                backgroundColor: themeService.getPrimaryColor()),
            onPressed: deleteBtn,
            child: Container(
              width: double.infinity,
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: Text(
                  "Delete FaceId",
                  style: TextStyle(color: themeService.getSilver()),
                ),
              ),
            )),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: borderRadius()),
              backgroundColor: themeService.getPrimaryColor().withOpacity(0.7)),
          child: Container(
            width: double.infinity,
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Text(
                "Cancel",
                style: TextStyle(color: themeService.getSilver()),
              ),
            ),
          ),
          onPressed: () {
            Get.back();
          },
        ),
      ],
    ),
  );
}
