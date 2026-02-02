import 'dart:io';
import 'package:awesome_dio_interceptor/awesome_dio_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:co.injazathr.injazathr/data/remote/dio_client/auth_interceptor.dart';

class DioClient {
  static DioClient? _instance;
  late Dio dio;
  bool _interceptorsAdded = false;

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.acceptHeader: "application/json"
        },
      ),
    );
  }

  factory DioClient() {
    _instance ??= DioClient._internal();
    _instance!._ensureInterceptors();
    return _instance!;
  }

  void _ensureInterceptors() {
    if (!_interceptorsAdded) {
      // Add auth interceptor for token management
      dio.interceptors.add(AuthInterceptor(dio));

      // Add logging interceptor in debug mode
      dio.interceptors.add(
        AwesomeDioInterceptor(
          logResponseHeaders: true,
          logRequestHeaders: true,
          logRequestTimeout: false,
          logger: debugPrint,
        ),
      );

      _interceptorsAdded = true;
    }
  }

  Future<Response> get(
      String url, Map<String, dynamic> headers, Map<String, dynamic> query) {
    return dio.get(url,
        options: Options(headers: headers), queryParameters: query);
  }

  Future<Response> post(String url, Map<String, dynamic> data,
      Map<String, dynamic> query, Map<String, dynamic> headers) {
    return dio.post(url,
        data: data, queryParameters: query, options: Options(headers: headers));
  }

  Future<Response> postForImageUpload(String url, FormData data, Map<String, dynamic> headers) {
    return dio.post(url,
        data: data,
        options: Options(
          headers: headers,
          contentType: Headers.multipartFormDataContentType,
        ));
  }

  Future<Response> delete(String url, Map<String, dynamic> headers, Map<String, dynamic> query) {
    return dio.delete(url,
        options: Options(headers: headers), queryParameters: query);
  }

  Future<Response> put(String url, Map<String, dynamic> headers, Map<String, dynamic> data) {
    return dio.put(url,
        data: data, options: Options(headers: headers));
  }
}
