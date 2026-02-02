import 'dart:convert';
import 'dart:typed_data';

import 'package:get_storage/get_storage.dart';
import 'package:co.injazathr.injazathr/data/remote/response/login_response.dart' as login_response;

class Preferences {
  final datacount = GetStorage();

  // Core keys
  final companyName = 'COMPANYNAME';
  final address = 'ADDRESS';
  final companyImage = 'COMPANYIMAGE';
  final token = 'TOKEN';
  final refreshToken = 'REFRESH_TOKEN';
  final tokenExpiresAt = 'TOKEN_EXPIRES_AT';
  final apppassword = 'APPPASSWORD';
  final checkPassword = 'CHECKPASSWORD';
  final workspaceName = 'WORKSPACENAME';
  final workspaceUrl = 'WORKSPACEURL';

  // User data keys
  final userData = 'USER_DATA';
  final notifications = 'NOTIFICATIONS';

  // ==================== USER DATA ====================

  Future<void> saveUserData(login_response.Data userData) async {
    await datacount.write(this.userData, userData.toJson());
  }

  Future<login_response.Data?> getUserData() async {
    final data = datacount.read(this.userData);
    if (data != null) {
      return login_response.Data.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  Future<int?> getUserId() async => (await getUserData())?.id;

  Future<String> getUserName() async => (await getUserData())?.employeeName ?? '';

  Future<String> getUserEmail() async => (await getUserData())?.email ?? '';

  Future<String> getUserMobile() async => (await getUserData())?.mobileNo ?? '';

  Future<String> getUserEmployeeNo() async => (await getUserData())?.employeeNo ?? '';

  Future<String> getUserIqamaNo() async => (await getUserData())?.iqamaNo ?? '';

  Future<String> getUserImage() async => (await getUserData())?.image ?? '';

  Future<String> getUserGender() async => (await getUserData())?.gender ?? '';

  Future<String> getUserPosition() async => (await getUserData())?.position ?? '';

  Future<String> getUserDepartment() async => (await getUserData())?.department ?? '';

  Future<String> getUserSection() async => (await getUserData())?.section ?? '';

  Future<String> getUserNationality() async => (await getUserData())?.nationality ?? '';

  Future<String> getUserPreferredLang() async => (await getUserData())?.preferredLang ?? '';

  Future<bool> isManager() async => (await getUserData())?.manager ?? false;

  // ==================== COMPANY DATA ====================

  Future<void> saveCompanyName(String value) async => datacount.write(companyName, value);

  Future<String> getCompanyName() async => datacount.read(companyName) ?? '';

  Future<void> saveAddress(String value) async => datacount.write(address, value);

  Future<String> getAddress() async => datacount.read(address) ?? '';

  Future<void> saveCompanyImage(String value) async => datacount.write(companyImage, value);

  Future<String> getCompanyImage() async => datacount.read(companyImage) ?? '';

  // ==================== AUTH ====================

  Future<void> saveToken(String value) async => datacount.write(token, value);

  Future<String> getToken() async => datacount.read(token) ?? '';

  Future<void> saveRefreshToken(String value) async => datacount.write(refreshToken, value);

  Future<String> getRefreshToken() async => datacount.read(refreshToken) ?? '';

  Future<void> saveTokenExpiresAt(String value) async => datacount.write(tokenExpiresAt, value);

  Future<String> getTokenExpiresAt() async => datacount.read(tokenExpiresAt) ?? '';

  Future<bool> isTokenExpired() async {
    final expiresAt = await getTokenExpiresAt();
    if (expiresAt.isEmpty) return false;
    try {
      final expiryDate = DateTime.parse(expiresAt);
      // Consider token expired 1 minute before actual expiry for safety
      return DateTime.now().isAfter(expiryDate.subtract(const Duration(minutes: 1)));
    } catch (e) {
      return false;
    }
  }

  Future<void> saveAppPassword(String value) async => datacount.write(apppassword, value);

  Future<String> getAppPassword() async => datacount.read(apppassword) ?? '';

  Future<void> saveCheckPassword(bool value) async => datacount.write(checkPassword, value);

  Future<bool> getCheckPassword() async => datacount.read(checkPassword) ?? false;

  // ==================== WORKSPACE ====================

  Future<void> saveWorkspaceName(String value) async => datacount.write(workspaceName, value);

  Future<String> getWorkspaceName() async => datacount.read(workspaceName) ?? '';

  Future<void> saveWorkspaceUrl(String value) async => datacount.write(workspaceUrl, value);

  Future<String> getWorkspaceUrl() async => datacount.read(workspaceUrl) ?? '';

  // ==================== CLEAR ====================

  Future<void> clearToken() async {
    await datacount.remove(token);
    await datacount.remove(refreshToken);
    await datacount.remove(tokenExpiresAt);
    await datacount.remove(apppassword);
    await datacount.remove(checkPassword);
  }

  Future<void> clearUserData() async => datacount.remove(userData);

  Future<void> clearWorkspace() async {
    await datacount.remove(workspaceName);
    await datacount.remove(workspaceUrl);
  }

  Future<void> clearAll() async => datacount.erase();

  // ==================== UTILITY ====================

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    final user = await getUserData();
    return token.isNotEmpty && user != null;
  }

  Future<String> getUserDisplayName() async {
    final user = await getUserData();
    if (user != null) {
      return user.employeeName?.isNotEmpty == true
          ? user.employeeName!
          : user.email ?? 'User';
    }
    return 'User';
  }

  Future<void> saveLoginSession(
    login_response.Data userData,
    String token, {
    String? refreshToken,
    String? expiresAt,
  }) async {
    await saveUserData(userData);
    await saveToken(token);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await saveRefreshToken(refreshToken);
    }
    if (expiresAt != null && expiresAt.isNotEmpty) {
      await saveTokenExpiresAt(expiresAt);
    }
  }

  Future<void> clearLoginSession() async {
    // Clear only user session data, preserve workspace and other core settings
    await clearUserData();
    await clearToken();
  }

  Future<void> clearUserSessionOnly() async {
    // Clear only user-specific session data, preserve everything else
    await datacount.remove(userData);
    await datacount.remove(token);
    await datacount.remove(apppassword);
    await datacount.remove(checkPassword);
  }

  Future<void> clearAllAppData() async {
    // Clear user-specific data but preserve workspace settings
    await clearUserData();
    await clearToken();
    // Don't clear workspace - it should persist across login/logout cycles
    // await clearWorkspace(); // Commented out to preserve workspace
    
    // Clear only user-specific data, not workspace or other core settings
    await _clearUserSpecificData();
  }

  Future<void> _clearUserSpecificData() async {
    // Clear only user-specific keys, preserve workspace and other core settings
    final workspaceNameValue = await getWorkspaceName();
    final workspaceUrlValue = await getWorkspaceUrl();
    final companyNameValue = await getCompanyName();
    final companyAddressValue = await getAddress();
    final companyImageValue = await getCompanyImage();
    
    // Clear all data
    await datacount.erase();
    
    // Restore workspace and company data
    if (workspaceNameValue.isNotEmpty) {
      await saveWorkspaceName(workspaceNameValue);
    }
    if (workspaceUrlValue.isNotEmpty) {
      await saveWorkspaceUrl(workspaceUrlValue);
    }
    if (companyNameValue.isNotEmpty) {
      await saveCompanyName(companyNameValue);
    }
    if (companyAddressValue.isNotEmpty) {
      await saveAddress(companyAddressValue);
    }
    if (companyImageValue.isNotEmpty) {
      await saveCompanyImage(companyImageValue);
    }
  }

  // ==================== FACE RECOGNITION ====================

  Future<login_response.FaceData?> getFaceData() async {
    final userData = await getUserData();
    return userData?.faceData;
  }

  Future<int?> getFaceId() async {
    final faceData = await getFaceData();
    return faceData?.id;
  }

  Future<String?> getFaceUserName() async {
    final faceData = await getFaceData();
    return faceData?.name;
  }

  Future<String?> getFaceUserEmbedding() async {
    final faceData = await getFaceData();
    return faceData?.embeddings;
  }

  Future<Uint8List?> getFaceUserImage() async {
    final faceData = await getFaceData();
    if (faceData?.faceImageBase64 == null) return null;
    return base64Decode(faceData!.faceImageBase64!);
  }

  Future<bool> userFaceExists() async {
    final faceData = await getFaceData();
    return faceData != null && faceData.embeddings != null && faceData.embeddings!.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getFaceUser() async {
    final faceData = await getFaceData();
    if (faceData == null || faceData.embeddings == null || faceData.faceImageBase64 == null) return null;

    return {
      'name': faceData.name ?? '',
      'embedding': faceData.embeddings!,
      'image': base64Decode(faceData.faceImageBase64!),
    };
  }

  // ==================== NOTIFICATIONS ====================

  Future<void> saveNotifications(List<Map<String, dynamic>> notificationsList) async {
    await datacount.write(notifications, notificationsList);
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final data = datacount.read(notifications);
    if (data != null && data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  Future<void> clearNotifications() async {
    await datacount.remove(notifications);
  }
}
