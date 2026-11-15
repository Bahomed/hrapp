import 'dart:convert';

import 'package:dio/dio.dart';

/// Single place that decides whether a server answer is a failure and pulls
/// out the message / field errors. Handles every shape the API returns:
///
///  * HTTP 4xx / 5xx
///  * `{ "error": true, "message": ... }`            (old endpoints)
///  * `{ "success": false, "message": ... }`         (old endpoints)
///  * `{ "status": false | "error", "message": ... }` (new /api/my/...)
///  * `{ "message": ..., "errors": { field: [..] } }` (422 form errors)
class ApiResult {
  final bool ok;
  final int? statusCode;
  final String message;
  final Map<String, List<String>> fieldErrors;
  final dynamic data;

  const ApiResult({
    required this.ok,
    this.statusCode,
    this.message = '',
    this.fieldErrors = const {},
    this.data,
  });

  /// Raw JSON body as a map (empty map when the body is not an object).
  Map<String, dynamic> get json =>
      data is Map ? Map<String, dynamic>.from(data as Map) : <String, dynamic>{};

  /// First field error for [field], or null.
  String? errorFor(String field) {
    final list = fieldErrors[field];
    return (list == null || list.isEmpty) ? null : list.first;
  }

  /// The message to show the user: the server message, else the first field
  /// error, else [fallback].
  String displayMessage([String fallback = 'Something went wrong']) {
    if (message.isNotEmpty) return message;
    for (final l in fieldErrors.values) {
      if (l.isNotEmpty) return l.first;
    }
    return fallback;
  }

  /// Every field error joined by newlines (or the message when there are none).
  String allErrors([String fallback = 'Something went wrong']) {
    final lines = <String>[for (final l in fieldErrors.values) ...l];
    if (lines.isEmpty) return displayMessage(fallback);
    return lines.join('\n');
  }

  static dynamic _decode(dynamic body) {
    if (body is String && body.isNotEmpty) {
      try {
        return jsonDecode(body);
      } catch (_) {}
    }
    return body;
  }

  /// True when the body (or the status code) says the call failed.
  static bool isFailure(int? statusCode, dynamic body) {
    if (statusCode != null && statusCode >= 400) return true;
    body = _decode(body);
    if (body is Map) {
      if (body['error'] == true) return true;
      if (body['success'] == false) return true;
      final s = body['status'];
      if (s == false || s == 'error' || s == 'failed' || s == 'fail') return true;
    }
    return false;
  }

  static Map<String, List<String>> _parseErrors(dynamic raw) {
    final out = <String, List<String>>{};
    if (raw is Map) {
      raw.forEach((k, v) {
        if (v is List) {
          out[k.toString()] = v.map((e) => e.toString()).toList();
        } else if (v != null) {
          out[k.toString()] = [v.toString()];
        }
      });
    }
    return out;
  }

  /// Build from a completed Dio [Response] (any status code).
  factory ApiResult.fromResponse(Response? response) {
    final body = _decode(response?.data);
    final code = response?.statusCode;
    String msg = '';
    Map<String, List<String>> errs = const {};
    if (body is Map) {
      msg = (body['message'] ?? body['validation_message'] ?? '').toString();
      errs = _parseErrors(body['errors']);
    }
    return ApiResult(
      ok: !isFailure(code, body),
      statusCode: code,
      message: msg,
      fieldErrors: errs,
      data: body,
    );
  }

  /// Build from a [DioException] (network error or non-2xx answer).
  factory ApiResult.fromException(DioException e) {
    if (e.response != null) {
      final r = ApiResult.fromResponse(e.response);
      return ApiResult(
        ok: false,
        statusCode: r.statusCode,
        message: r.message,
        fieldErrors: r.fieldErrors,
        data: r.data,
      );
    }
    String msg;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        msg = 'No response from server. Try again later';
        break;
      case DioExceptionType.connectionError:
        msg = 'Please check your internet connection';
        break;
      case DioExceptionType.receiveTimeout:
        msg = 'Server did not send any response. Try again later.';
        break;
      default:
        msg = 'Something went wrong, Try again';
    }
    return ApiResult(ok: false, message: msg);
  }

  /// Run a Dio call and always come back with an [ApiResult] (never throws).
  static Future<ApiResult> guard(Future<Response> Function() call) async {
    try {
      return ApiResult.fromResponse(await call());
    } on DioException catch (e) {
      return ApiResult.fromException(e);
    } catch (e) {
      return ApiResult(ok: false, message: e.toString());
    }
  }
}
