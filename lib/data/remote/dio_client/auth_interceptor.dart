import 'dart:async';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:co.injazathr.injazathr/data/local/preferences.dart';
import 'package:co.injazathr.injazathr/view/login_screen/login_screen.dart';
import 'package:co.injazathr.injazathr/utils/api_helper.dart';

/// Shared in-flight refresh so concurrent callers (splash, resume, interceptor)
/// never fire two `refresh-token` calls with the same (single-use) token.
Future<bool>? _refreshInFlight;

Future<bool> _doRefresh(Preferences preferences) {
  return _refreshInFlight ??=
      _refreshNow(preferences).whenComplete(() => _refreshInFlight = null);
}

/// Calls `POST refresh-token` with form field `refresh_token`.
/// This is the ONLY request that ever carries the refresh token.
/// Server answers `{ "error": false, "token", "refresh_token", "expires_at" }`.
Future<bool> _refreshNow(Preferences preferences) async {
  final refreshToken = await preferences.getRefreshToken();
  if (refreshToken.isEmpty) return false;

  final workspaceUrl = await preferences.getWorkspaceUrl();
  if (workspaceUrl.isEmpty) return false;

  final locale = ApiHelper.instance.getCurrentLocale();
  final refreshUrl = '$workspaceUrl/api/refresh-token?locale=$locale';

  // Plain Dio: no AuthInterceptor, so no `Authorization` header is added.
  final refreshDio = Dio(BaseOptions(
    validateStatus: (status) => status != null && status < 500,
  ));

  try {
    final response = await refreshDio.post(
      refreshUrl,
      data: FormData.fromMap({'refresh_token': refreshToken}),
      options: Options(
        headers: {'Accept': 'application/json', 'Accept-Language': locale},
        contentType: Headers.multipartFormDataContentType,
      ),
    );

    final data = response.data;
    if (response.statusCode == 200 && data is Map && data['error'] != true) {
      final newToken = data['token']?.toString();
      final newRefreshToken = data['refresh_token']?.toString();
      final expiresAt = data['expires_at']?.toString();
      if (newToken != null && newToken.isNotEmpty) {
        await preferences.saveToken(newToken);
        if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
          await preferences.saveRefreshToken(newRefreshToken);
        }
        if (expiresAt != null && expiresAt.isNotEmpty) {
          await preferences.saveTokenExpiresAt(expiresAt);
        }
        return true;
      }
    }
  } catch (_) {}
  return false;
}

/// Adds `Authorization: Bearer <login token>` to every call and, when a call
/// answers 401, refreshes the token once and repeats the failed call once.
/// If the refresh fails the user is logged out.
class AuthInterceptor extends Interceptor {
  final Dio dio;
  final Preferences _preferences = Preferences();

  static const _retriedKey = '_auth_retried';
  static bool _loggingOut = false;

  AuthInterceptor(this.dio);

  /// Callable from outside the interceptor (e.g. splash) to refresh a token
  /// without needing an active Dio instance.
  static Future<bool> refreshTokenOnce(Preferences preferences) =>
      _doRefresh(preferences);

  static bool _isAuthEndpoint(String path) =>
      path.contains('/api/login') ||
      path.contains('/api/refresh-token') ||
      path.contains('/api/company-login-method');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (_isAuthEndpoint(options.path)) {
      // Never send any token on login / refresh endpoints.
      options.headers.remove('Authorization');
    } else {
      // Always (re)set from storage: guarantees only the login token is sent,
      // even if a caller passed a stale header.
      final token = await _preferences.getToken();
      if (token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      } else {
        options.headers.remove('Authorization');
      }
    }
    options.headers['Accept'] ??= 'application/json';
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    // Some old endpoints answer HTTP 200 with `{ "error": true, "code": 401 }`.
    if (_isUnauthorizedBody(response.data) &&
        !_isAuthEndpoint(response.requestOptions.path) &&
        response.requestOptions.extra[_retriedKey] != true) {
      try {
        final retried = await _refreshAndRetry(response.requestOptions);
        if (retried != null) return handler.resolve(retried);
      } on DioException catch (e) {
        return handler.reject(e, true);
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isUnauthorized = err.response?.statusCode == 401 ||
        _isUnauthorizedBody(err.response?.data);
    if (isUnauthorized &&
        !_isAuthEndpoint(err.requestOptions.path) &&
        err.requestOptions.extra[_retriedKey] != true) {
      try {
        final retried = await _refreshAndRetry(err.requestOptions);
        if (retried != null) return handler.resolve(retried);
      } on DioException catch (e) {
        return handler.next(e);
      }
    }
    handler.next(err);
  }

  bool _isUnauthorizedBody(dynamic data) {
    if (data is! Map) return false;
    if (data['code'] == 401 || data['statusCode'] == 401) return true;
    if (data['error'] == true) {
      final msg = data['message']?.toString().toLowerCase() ?? '';
      return msg.contains('unauthorized') ||
          msg.contains('unauthenticated') ||
          msg.contains('token has expired') ||
          msg.contains('refresh token');
    }
    return false;
  }

  /// Refreshes the token (shared between concurrent callers) and repeats
  /// [options] once. Returns null when the refresh failed (user logged out).
  /// A failing repeat is rethrown as its [DioException].
  Future<Response?> _refreshAndRetry(RequestOptions options) async {
    final refreshed = await _doRefresh(_preferences);
    if (!refreshed) {
      await _logout();
      return null;
    }
    final newToken = await _preferences.getToken();
    options.headers['Authorization'] = 'Bearer $newToken';
    options.extra[_retriedKey] = true;
    return await dio.fetch(options);
  }

  Future<void> _logout() async {
    if (_loggingOut) return;
    _loggingOut = true;
    try {
      await _preferences.clearLoginSession();
      Get.offAll(() => LoginScreen());
    } finally {
      _loggingOut = false;
    }
  }
}
