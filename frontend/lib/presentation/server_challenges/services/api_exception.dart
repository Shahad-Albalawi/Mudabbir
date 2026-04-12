import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mudabbir/presentation/resources/network_messages.dart';
import 'package:mudabbir/presentation/server_challenges/services/api_exception_localizations.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic errors;

  ApiException({required this.message, this.statusCode, this.errors});

  String get userMessage => ApiExceptionLocalizations.display(message);

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Connection timed out. Check your internet and try again.',
          statusCode: null,
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);

      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request was cancelled.',
          statusCode: null,
        );

      case DioExceptionType.connectionError:
        return ApiException(
          message:
              'Unable to reach the finance server. Check internet or try again later.',
          statusCode: null,
        );

      case DioExceptionType.badCertificate:
        return ApiException(
          message: 'Security certificate error. Please try again later.',
          statusCode: null,
        );

      case DioExceptionType.unknown:
        final err = error.error;
        if (err is SocketException) {
          return ApiException(
            message:
                'Unable to reach the finance server. Check internet or try again later.',
            statusCode: null,
          );
        }
        return ApiException(
          message: 'Something went wrong. Please try again.',
          statusCode: null,
        );
    }
  }

  static ApiException _handleBadResponse(Response? response) {
    if (response == null) {
      return ApiException(
        message: 'Something went wrong. Please try again.',
        statusCode: null,
      );
    }

    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    if (data is Map<String, dynamic>) {
      final message = data['message'] as String?;
      final errors = data['errors'];

      if (errors != null) {
        return ApiException(
          message: message ?? 'Invalid input. Please correct and try again.',
          statusCode: statusCode,
          errors: errors,
        );
      }

      if (message != null) {
        return ApiException(message: message, statusCode: statusCode);
      }
    }

    switch (statusCode) {
      case 400:
        return ApiException(
          message: 'Bad request. Please check your input.',
          statusCode: statusCode,
        );
      case 401:
        return ApiException(
          message: 'Please sign in again.',
          statusCode: statusCode,
        );
      case 403:
        return ApiException(message: 'Access denied.', statusCode: statusCode);
      case 404:
        return ApiException(
          message: 'Resource not found.',
          statusCode: statusCode,
        );
      case 422:
        return ApiException(
          message: 'Invalid input. Please correct and try again.',
          statusCode: statusCode,
        );
      case 500:
        return ApiException(
          message: 'The server had an error. Please try again later.',
          statusCode: statusCode,
        );
      case 503:
      case 530:
        return ApiException(
          message:
              'The finance server is temporarily unavailable. Please try again later.',
          statusCode: statusCode,
        );
      default:
        return ApiException(
          message: 'Something went wrong. Please try again.',
          statusCode: statusCode,
        );
    }
  }

  String getValidationMessage() {
    if (errors == null) return userMessage;

    if (errors is Map<String, dynamic>) {
      final firstError = errors.values.first;
      if (firstError is List && firstError.isNotEmpty) {
        return NetworkUserMessages.serverPolish(
          firstError.first.toString(),
          statusCode ?? 422,
        );
      }
    }

    return userMessage;
  }

  @override
  String toString() => message;
}
