import 'dart:convert';

import 'package:dio/dio.dart';

String exceptionHandler(DioException e) {
  if (e.type == DioExceptionType.badResponse) {
    try {
      var error = e.response?.data is Map ? e.response!.data : json.decode(e.response.toString());
      // Return the first field validation error if present
      if (error['errors'] != null && error['errors'] is Map) {
        final errors = error['errors'] as Map;
        if (errors.isNotEmpty) {
          final firstField = errors.values.first;
          if (firstField is List && firstField.isNotEmpty) {
            return firstField.first.toString();
          }
        }
      }
      return error['message'] ?? "Something went wrong";
    } catch (e) {
      return "Something went wrong";
    }
  } else if (e.type == DioExceptionType.connectionTimeout) {
    return "No response from server. Try again later";
  } else if (e.type == DioExceptionType.connectionError) {
    return "Please check your internet connection";
  } else if (e.type == DioExceptionType.receiveTimeout) {
    return "Server did not send any response. Try again later.";
  } else {
    return "Something went wrong, Try again";
  }
}
