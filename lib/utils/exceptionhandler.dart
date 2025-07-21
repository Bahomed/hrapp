import 'dart:convert';

import 'package:dio/dio.dart';

String exceptionHandler(DioException e) {
  if (e.type == DioExceptionType.badResponse) {
    try {
      var error = json.decode(e.response.toString());
      return error['message'];
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
