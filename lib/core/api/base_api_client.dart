import 'dart:async';

import 'package:fixa/core/api/header_interceptor.dart';
import 'package:fixa/core/api/multi_env.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

abstract class BaseApiClient<T> {
  BaseApiClient({
    required this.dio,
    required this.appPreferenceService,
  }) {
    dio
      ..options.baseUrl = MultiEnv().apiUrl
      ..options.connectTimeout = const Duration(seconds: 15)
      ..options.receiveTimeout = const Duration(seconds: 30)
      ..options.sendTimeout = const Duration(seconds: 30)
      ..options.headers = {'Content-Type': 'application/json; charset=UTF-8'};

    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: false,
          requestBody: false,
          responseBody: false,
        ),
      );
    }

    dio.interceptors.add(
      HeaderInterceptor(
        appPreferenceService: appPreferenceService,
      ),
    );
  }

  final Dio dio;
  final dynamic appPreferenceService;

  Future<T> get({
    required String endpoint,
    Options? options,
    Map<String, dynamic>? params,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await dio.get(
        endpoint,
        queryParameters: params,
        options: options,
        data: data,
      );
      return response.data;
    } on DioException catch (_) {
      rethrow;
    }
  }

  Future<T> post({
    required String endpoint,
    dynamic data,
    Options? options,
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await dio.post(
        endpoint,
        data: data,
        options: options,
        queryParameters: params,
      );
      return response.data;
    } on DioException catch (_) {
      rethrow;
    }
  }

  Future<T> put({
    required String endpoint,
    dynamic data,
    Options? options,
    Map<String, dynamic>? params,
    Function(int, int)? onSendProgress,
  }) async {
    try {
      final response = await dio.put(
        endpoint,
        data: data,
        options: options,
        queryParameters: params,
        onSendProgress: onSendProgress,
      );
      return response.data;
    } on DioException catch (_) {
      rethrow;
    }
  }

  Future<T> patch({
    required String endpoint,
    dynamic data,
    Options? options,
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await dio.patch(
        endpoint,
        data: data,
        options: options,
        queryParameters: params,
      );
      return response.data;
    } on DioException catch (_) {
      rethrow;
    }
  }

  Future<T> delete({
    required String endpoint,
    dynamic data,
    Options? options,
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await dio.delete(
        endpoint,
        data: data,
        options: options,
        queryParameters: params,
      );
      return response.data;
    } on DioException catch (_) {
      rethrow;
    }
  }
}
