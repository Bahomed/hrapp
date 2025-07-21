import 'package:injazat_hr_app/view/attendancescreen/attendancecontroller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AttendanceController());
    
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).appBarTheme.foregroundColor),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Face Recognition Debug",
          style: TextStyle(color: Theme.of(context).appBarTheme.foregroundColor),
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Status Icon
              Obx(() {
                IconData icon;
                Color color;
                switch (controller.status.value) {
                  case 0:
                    icon = Icons.face_outlined;
                    color = Colors.blue;
                    break;
                  case 1:
                    icon = Icons.check_circle;
                    color = Colors.green;
                    break;
                  case 2:
                    icon = Icons.error;
                    color = Colors.red;
                    break;
                  default:
                    icon = Icons.face_outlined;
                    color = Colors.blue;
                }
                
                return Icon(
                  icon,
                  size: 80,
                  color: color,
                );
              }),
              
              const SizedBox(height: 20),
              
              // Status Text
              Obx(() => Text(
                controller.status.value == 0 
                    ? "Processing..."
                    : controller.person.value,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              )),
              
              const SizedBox(height: 20),
              
              // Debug Information
              Obx(() => Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Debug Info:",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      controller.debugMessage.value.isEmpty 
                          ? "No debug info available"
                          : controller.debugMessage.value,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              )),
              
              const SizedBox(height: 20),
              
              // Loading indicator when processing
              Obx(() => controller.status.value == 0
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    )
                  : const SizedBox.shrink()),
              
              const SizedBox(height: 20),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Retry button
                  ElevatedButton(
                    onPressed: () {
                      controller.status.value = 0;
                      controller.person.value = "";
                      controller.debugMessage.value = "";
                      controller.getImageFromCamera();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Try Again"),
                  ),
                  
                  // Clear debug button
                  ElevatedButton(
                    onPressed: () {
                      controller.debugMessage.value = "";
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Clear Debug"),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Instructions
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Builder(
                  builder: (context) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Troubleshooting Tips:",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "• Check console/logcat for detailed error messages\n"
                        "• Ensure camera permissions are granted\n"
                        "• Make sure ML model files are in assets\n"
                        "• Verify face database has registered users\n"
                        "• Check internet connection for API calls",
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}