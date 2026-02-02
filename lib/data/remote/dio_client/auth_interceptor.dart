import 'dart:async';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:co.injazathr.injazathr/data/local/preferences.dart';
import 'package:co.injazathr.injazathr/view/login_screen/login_screen.dart';
import 'package:co.injazathr.injazathr/utils/api_helper.dart';

/// Interceptor that handles automatic token refresh on 401 errors.
///
/// When a request fails with 401 Unauthorized, this interceptor will:
/// 1. Attempt to refresh the token using the stored refresh token
/// 2. Retry the original request with the new token
/// 3. Navigate to login screen if refresh fails
class AuthInterceptor extends Interceptor {
  final Dio dio;
  final Preferences _preferences = Preferences();

  bool _isRefreshing = false;
  final List<_RetryRequest> _pendingRequests = [];

  AuthInterceptor(this.dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip adding auth header for refresh token and login endpoints
    final isAuthEndpoint = options.path.contains('/api/login') ||
        options.path.contains('/api/refresh-token') ||
        options.path.contains('/api/company-login-method');

    if (!isAuthEndpoint) {
      final token = await _preferences.getToken();
      if (token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Check if error is 401 Unauthorized
    if (err.response?.statusCode == 401 || _isUnauthorizedError(err.response?.data)) {
      // Skip refresh for login and refresh-token endpoints
      if (err.requestOptions.path.contains('/api/login') ||
          err.requestOptions.path.contains('/api/refresh-token')) {
        return handler.next(err);
      }

      // Try to refresh token
      final refreshed = await _handleTokenRefresh(err.requestOptions, handler);
      if (refreshed) {
        return; // Request was retried successfully
      }
    }

    handler.next(err);
  }

  /// Check if the response indicates an unauthorized error (code 401)
  bool _isUnauthorizedError(dynamic data) {
    if (data == null) return false;
    if (data is Map<String, dynamic>) {
      return data['code'] == 401 || data['error'] == true && data['message']?.toString().toLowerCase().contains('unauthorized') == true;
    }
    return false;
  }

  Future<bool> _handleTokenRefresh(
    RequestOptions options,
    ErrorInterceptorHandler handler,
  ) async {
    // If already refreshing, queue this request
    if (_isRefreshing) {
      final completer = Completer<Response>();
      _pendingRequests.add(_RetryRequest(options, completer, handler));
      try {
        final response = await completer.future;
        handler.resolve(response);
        return true;
      } catch (e) {
        return false;
      }
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _preferences.getRefreshToken();

      if (refreshToken.isEmpty) {
        _navigateToLogin();
        return false;
      }

      final workspaceUrl = await _preferences.getWorkspaceUrl();
      final refreshUrl = '$workspaceUrl/api/refresh-token';

      // Create a new Dio instance for refresh to avoid interceptor loop
      final refreshDio = Dio(BaseOptions(
        validateStatus: (status) => status != null && status < 500,
        contentType: 'application/json',
      ));

      // Add locale to query params
      final locale = ApiHelper.instance.getCurrentLocale();

      final requestBody = {
        'refresh_token': refreshToken,
      };

      Response response;
      try {
        response = await refreshDio.post(
          '$refreshUrl?locale=$locale',
          data: requestBody,
          options: Options(
            headers: {
              'Accept': 'application/json',
              'Accept-Language': locale,
            },
          ),
        );
      } on DioException {
        _navigateToLogin();
        return false;
      }

      final data = response.data;

      // Check if refresh was successful
      if (data != null && data['error'] == false && data['code'] == 100) {
        final newToken = data['token'] as String?;
        final newRefreshToken = data['refresh_token'] as String?;
        final expiresAt = data['expires_at'] as String?;

        if (newToken != null && newToken.isNotEmpty) {
          // Save new tokens
          await _preferences.saveToken(newToken);
          if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
            await _preferences.saveRefreshToken(newRefreshToken);
          }
          if (expiresAt != null && expiresAt.isNotEmpty) {
            await _preferences.saveTokenExpiresAt(expiresAt);
          }

          // Retry the original request with new token
          options.headers['Authorization'] = 'Bearer $newToken';

          try {
            final retryResponse = await dio.fetch(options);
            handler.resolve(retryResponse);

            // Retry all pending requests
            _retryPendingRequests(newToken);

            return true;
          } catch (e) {
            return false;
          }
        }
      }

      // Refresh failed, navigate to login
      _navigateToLogin();
      return false;

    } catch (e) {
      _navigateToLogin();
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  void _retryPendingRequests(String newToken) async {
    for (final request in _pendingRequests) {
      request.options.headers['Authorization'] = 'Bearer $newToken';
      try {
        final response = await dio.fetch(request.options);
        request.completer.complete(response);
      } catch (e) {
        request.completer.completeError(e);
      }
    }
    _pendingRequests.clear();
  }

  void _navigateToLogin() async {
    // Clear tokens
    await _preferences.clearLoginSession();

    // Clear pending requests
    for (final request in _pendingRequests) {
      request.completer.completeError(
        DioException(
          requestOptions: request.options,
          error: 'Session expired. Please login again.',
        ),
      );
    }
    _pendingRequests.clear();

    // Navigate to login screen
    Get.offAll(() => LoginScreen());
  }
}

class _RetryRequest {
  final RequestOptions options;
  final Completer<Response> completer;
  final ErrorInterceptorHandler handler;

  _RetryRequest(this.options, this.completer, this.handler);
}
