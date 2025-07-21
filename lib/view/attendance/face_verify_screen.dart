import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'face_verify_controller.dart';

class FaceVerifyScreen extends StatelessWidget {
  const FaceVerifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FaceVerifyController());
    
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).appBarTheme.foregroundColor ?? Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Face Verification",
          style: TextStyle(color: Theme.of(context).appBarTheme.foregroundColor ?? Colors.white),
        ),
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.dark 
          ? Theme.of(context).scaffoldBackgroundColor 
          : Colors.black,
      body: SafeArea(
        child: Obx(() => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status Icon/Animation
              SizedBox(
                width: 200,
                height: 200,
                child: _buildStatusWidget(controller.verificationState.value),
              ),
              
              const SizedBox(height: 30),
              
              // Status Message
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  controller.statusMessage.value,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Theme.of(context).textTheme.bodyLarge?.color 
                        : Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Sub message based on state
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  _getSubMessage(controller.verificationState.value),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Retry button for failed state
              if (controller.verificationState.value == VerificationState.failed)
                ElevatedButton(
                  onPressed: () {
                    controller.getImageFromCamera();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BCD4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        )),
      ),
    );
  }

  Widget _buildStatusWidget(VerificationState state) {
    switch (state) {
      case VerificationState.scanning:
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF00BCD4), width: 3),
          ),
          child: const Icon(
            Icons.face,
            size: 100,
            color: Color(0xFF00BCD4),
          ),
        );
      
      case VerificationState.processing:
        return const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00BCD4)),
          strokeWidth: 4,
        );
      
      case VerificationState.success:
        return Lottie.asset(
          'assets/raw/confirm.json',
          repeat: false,
        );
      
      case VerificationState.failed:
        return Lottie.asset(
          'assets/raw/error.json',
          repeat: true,
        );
      
      default:
        return const SizedBox.shrink();
    }
  }

  String _getSubMessage(VerificationState state) {
    switch (state) {
      case VerificationState.scanning:
        return "Hold still and look directly at the camera";
      
      case VerificationState.processing:
        return "Processing face verification and location data";
      
      case VerificationState.success:
        return "Attendance recorded with location verification";
      
      case VerificationState.failed:
        return "Verification failed. Please try again or register your Face ID";
      
      default:
        return "";
    }
  }
}