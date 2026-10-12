import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'package:fixa/core/network/api_constants.dart';
import 'package:fixa/core/network/app_error.dart';
import 'package:fixa/core/storage/app_preference_service.dart';

const String _authTokenStorageKey = 'auth_token';

class ApiClient {
  ApiClient({Dio? dio, AppPreferenceService? appPreferenceService})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConstants.baseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
              headers: const {'Content-Type': 'application/json'},
            ),
          ),
      _appPreferenceService = appPreferenceService {
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: false,
        responseHeader: false,
        responseBody: true,
        error: true,
        compact: true,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final accessToken = _appPreferenceService
              ?.getValue<String>(_authTokenStorageKey)
              ?.trim();

          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = accessToken.startsWith('Bearer ')
                ? accessToken
                : 'Bearer $accessToken';
          }

          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  final AppPreferenceService? _appPreferenceService;

  void _syncBaseUrl() {
    if (_dio.options.baseUrl != ApiConstants.baseUrl) {
      _dio.options.baseUrl = ApiConstants.baseUrl;
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      _syncBaseUrl();
      final response = await _dio.post<Map<String, dynamic>>(path, data: data);
      return response.data ?? <String, dynamic>{};
    } on DioException catch (error) {
      throw AppError(_resolveMessage(error));
    } catch (_) {
      throw const AppError('Something went wrong. Please try again.');
    }
  }

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required FormData data,
  }) async {
    try {
      _syncBaseUrl();
      final response = await _dio.post<Map<String, dynamic>>(path, data: data);
      return response.data ?? <String, dynamic>{};
    } on DioException catch (error) {
      throw AppError(_resolveMessage(error));
    } catch (_) {
      throw const AppError('Something went wrong. Please try again.');
    }
  }

  Future<Map<String, dynamic>> postFlexible(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      _syncBaseUrl();
      final response = await _dio.post<String>(
        path,
        data: data,
        options: Options(responseType: ResponseType.plain),
      );
      final raw = response.data?.trim() ?? '';
      if (raw.isEmpty) {
        return <String, dynamic>{
          'success': true,
          'message': 'Request completed successfully.',
        };
      }

      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) return decoded;
      } on FormatException {
        // A successful endpoint may return plain text instead of JSON.
      }

      return <String, dynamic>{'success': true, 'message': raw};
    } on DioException catch (error) {
      throw AppError(_resolveMessage(error));
    } catch (_) {
      throw const AppError('Something went wrong. Please try again.');
    }
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      _syncBaseUrl();
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      return response.data ?? <String, dynamic>{};
    } on DioException catch (error) {
      throw AppError(_resolveMessage(error));
    } catch (_) {
      throw const AppError('Something went wrong. Please try again.');
    }
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      _syncBaseUrl();
      final response = await _dio.delete<Map<String, dynamic>>(
        path,
        data: data,
      );
      return response.data ?? <String, dynamic>{};
    } on DioException catch (error) {
      throw AppError(_resolveMessage(error));
    } catch (_) {
      throw const AppError('Something went wrong. Please try again.');
    }
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      _syncBaseUrl();
      final response = await _dio.put<Map<String, dynamic>>(path, data: data);
      return response.data ?? <String, dynamic>{};
    } on DioException catch (error) {
      throw AppError(_resolveMessage(error));
    } catch (_) {
      throw const AppError('Something went wrong. Please try again.');
    }
  }

  Future<Map<String, dynamic>> putMultipart(
    String path, {
    required FormData data,
  }) async {
    try {
      _syncBaseUrl();
      final response = await _dio.put<Map<String, dynamic>>(path, data: data);
      return response.data ?? <String, dynamic>{};
    } on DioException catch (error) {
      throw AppError(_resolveMessage(error));
    } catch (_) {
      throw const AppError('Something went wrong. Please try again.');
    }
  }

  String _resolveMessage(DioException error) {
    final responseData = error.response?.data;

    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'];

      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Request timed out. Please try again.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'No internet connection. Please try again.';
    }

    return 'Something went wrong. Please try again.';
  }
}
