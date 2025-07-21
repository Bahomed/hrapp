// Original DioClient (unchanged)
import 'dart:io';
import 'package:awesome_dio_interceptor/awesome_dio_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class DioClient {
  var dio = Dio(
    BaseOptions(
      headers: {
        HttpHeaders.contentTypeHeader: "application/json",
        HttpHeaders.acceptHeader: "application/json"
      },
    ),
  );

  Future<Response> get(
      String url, Map<String, dynamic> headers, Map<String, dynamic> query) {
    dio.interceptors.add(
      AwesomeDioInterceptor(logResponseHeaders: true,
          logRequestHeaders: true,
          logRequestTimeout: false,
          logger: debugPrint),
    );
    return dio.get(url,
        options: Options(headers: headers), queryParameters: query);
  }

  Future<Response> post(String url, Map<String, dynamic> data,
      Map<String, dynamic> query, Map<String, dynamic> headers) {
    dio.interceptors.add(
      AwesomeDioInterceptor(logResponseHeaders: true,
          logRequestHeaders: true,
          logRequestTimeout: false,
          logger: debugPrint),
    );
    return dio.post(url,
        data: data, queryParameters: query, options: Options(headers: headers));
  }

  Future<Response> postForImageUpload(String url, FormData data, Map<String, dynamic> headers) {
    dio.interceptors.add(
      AwesomeDioInterceptor(
          logResponseHeaders: true,
          logRequestHeaders: true,
          logRequestTimeout: false,
          logger: debugPrint
      ),
    );
    return dio.post(url,
        data: data, options: Options(headers: headers));
  }

  Future<Response> delete(String url, Map<String, dynamic> headers, Map<String, dynamic> query) {
    dio.interceptors.add(
      AwesomeDioInterceptor(logResponseHeaders: true,
          logRequestHeaders: true,
          logRequestTimeout: false,
          logger: debugPrint),
    );
    return dio.delete(url,
        options: Options(headers: headers), queryParameters: query);
  }

  Future<Response> put(String url, Map<String, dynamic> headers, Map<String, dynamic> data) {
    dio.interceptors.add(
      AwesomeDioInterceptor(logResponseHeaders: true,
          logRequestHeaders: true,
          logRequestTimeout: false,
          logger: debugPrint),
    );
    return dio.put(url,
        data: data, options: Options(headers: headers));
  }
}