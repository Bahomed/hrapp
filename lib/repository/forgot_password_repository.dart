import 'package:co.injazathr.injazathr/data/local/preferences.dart';
import 'package:co.injazathr.injazathr/data/remote/dio_client/dio_client.dart';
import 'package:co.injazathr.injazathr/data/remote/response/otp_response.dart';
import 'package:co.injazathr.injazathr/data/remote/response/reset_password_response.dart';
import 'package:co.injazathr.injazathr/utils/exceptionhandler.dart';
import 'package:co.injazathr.injazathr/utils/api_helper.dart';
import 'package:dio/dio.dart';

class ForgotPasswordRepository {
  final DioClient dioClient = DioClient();
  final Preferences preferences = Preferences();

  /// Send OTP to mobile number for password reset
  Future<OtpResponse?> sendOtp(String mobileNo) async {
    try {
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final sendOtpUrl = '$workspaceUrl/api/send-otp';

      Map<String, dynamic> data = {
        'mobile_no': mobileNo,
      };
      data = ApiHelper.instance.addLocaleToData(data);

      var response = await dioClient.post(
        sendOtpUrl,
        data,
        {},
        {},
      );

      if (response.data != null) {
        return OtpResponse.fromJson(response.data);
      } else {
        throw Exception("No data received from server");
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        try {
          var errorResponse = OtpResponse.fromJson(e.response!.data);
          return errorResponse;
        } catch (parseError) {
          throw exceptionHandler(e);
        }
      } else {
        throw exceptionHandler(e);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Verify OTP for password reset
  Future<OtpResponse?> verifyOtp(String mobileNo, String otp) async {
    try {
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final verifyOtpUrl = '$workspaceUrl/api/verify-otp';

      Map<String, dynamic> data = {
        'mobile_no': mobileNo,
        'otp': otp,
      };
      data = ApiHelper.instance.addLocaleToData(data);

      var response = await dioClient.post(
        verifyOtpUrl,
        data,
        {},
        {},
      );

      if (response.data != null) {
        return OtpResponse.fromJson(response.data);
      } else {
        throw Exception("No data received from server");
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        try {
          var errorResponse = OtpResponse.fromJson(e.response!.data);
          return errorResponse;
        } catch (parseError) {
          throw exceptionHandler(e);
        }
      } else {
        throw exceptionHandler(e);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Reset password with OTP verification
  Future<ResetPasswordResponse?> resetPassword(
      String mobileNo, String otp, String newPassword) async {
    try {
      final workspaceUrl = await preferences.getWorkspaceUrl();
      final resetPasswordUrl = '$workspaceUrl/api/reset-password';

      Map<String, dynamic> data = {
        'mobile_no': mobileNo,
        'otp': otp,
        'password': newPassword,
        'password_confirmation': newPassword,
      };
      data = ApiHelper.instance.addLocaleToData(data);

      var response = await dioClient.post(
        resetPasswordUrl,
        data,
        {},
        {},
      );

      if (response.data != null) {
        return ResetPasswordResponse.fromJson(response.data);
      } else {
        throw Exception("No data received from server");
      }
    } on DioException catch (e) {
      if (e.response?.data != null) {
        try {
          var errorResponse = ResetPasswordResponse.fromJson(e.response!.data);
          return errorResponse;
        } catch (parseError) {
          throw exceptionHandler(e);
        }
      } else {
        throw exceptionHandler(e);
      }
    } catch (e) {
      rethrow;
    }
  }
}