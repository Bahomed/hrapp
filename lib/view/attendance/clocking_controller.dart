import 'package:get/get.dart';
import 'package:injazat_hr_app/data/local/preferences.dart';
import 'package:injazat_hr_app/view/scan/AutoRecognitionScreen.dart';
import 'package:injazat_hr_app/view/scan/AutoRegisterScreen.dart';

class ClockingController extends GetxController {
  final Preferences preferences = Preferences();

  var isLoading = false.obs;
  var hasEmbedding = false.obs;
  var currentUserId = 0.obs;
  var userName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    isLoading.value = true;
    
    try {
      // Get current user data
      final userData = await preferences.getUserData();
      if (userData != null && userData.id != null) {
        currentUserId.value = userData.id!;
        userName.value = userData.employeeName ?? '';
        
        // Check if user has embedding registered
        await _checkEmbeddingStatus();
      }
    } catch (e) {
      print('Error initializing user: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _checkEmbeddingStatus() async {
    try {
      hasEmbedding.value = await preferences.userFaceExists();

      print(await preferences.getFaceUserName());
    } catch (e) {
      print('Error checking embedding status: $e');
      hasEmbedding.value = false;
    }
  }

  /// Navigate to scan screen to register face recognition
  Future<void> navigateToScanScreen() async {
    final result = await Get.to(
      () => const AutoRegisterScreen(),
      arguments: {
        'userId': currentUserId.value,
        'username': userName.value,
      },
    );
    // Refresh embedding status when returning from scan screen
    await refreshEmbeddingStatus();
  }

  /// Refresh embedding status after returning from scan screen
  Future<void> refreshEmbeddingStatus() async {
    await _checkEmbeddingStatus();
  }

  /// Check if user can clock in (has embedding registered)
  bool canClockIn() {
    return hasEmbedding.value;
  }

  /// Get embedding message for user
  String getEmbeddingMessage() {
    if (isLoading.value) {
      return 'Checking embedding status...';
    }
    
    if (hasEmbedding.value) {
      return 'Face recognition ready - Ready to clock in';
    } else {
      return 'Face recognition not set up - Please register to clock in';
    }
  }

  /// Navigate to face recognition screen for clock-in
  Future<dynamic> verifyFaceForClockIn({
    String attendanceType = 'clock_in',
    Map<String, dynamic>? locationData,
  }) async {
    if (!canClockIn()) {
      return false; // No embedding registered
    }

    final result = await Get.to(
      () => AutoRecognitionScreen(
        attendanceType: attendanceType,
        locationData: locationData,
      ),
      arguments: {
        'userId': currentUserId.value,
        'username': userName.value,
        'attendanceType': attendanceType,
        'locationData': locationData,
      },
    );

    return result; // Return the full result map or false/null
  }
}