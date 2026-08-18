import 'package:dio/dio.dart';
import 'package:mudabbir/data/network/api_exception.dart';
import 'package:mudabbir/data/network/dio_client.dart';

/// Server-side aggregates from `/api/statistics` and `/api/dashboard`.
class AnalyticsApiService {
  AnalyticsApiService(this._dioClient);

  final DioClient _dioClient;

  Future<Map<String, dynamic>> getStatistics() async {
    return _fetch('/statistics');
  }

  Future<Map<String, dynamic>> getStatisticsForPeriod({
    required String period,
    String? from,
    String? to,
  }) async {
    return _fetch(
      '/statistics',
      queryParameters: {
        if (from != null) 'from': from,
        if (to != null) 'to': to,
        if (from == null && to == null) 'period': period,
      },
    );
  }

  Future<Map<String, dynamic>> getDashboard() async {
    return _fetch('/dashboard');
  }

  Future<Map<String, dynamic>> _fetch(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dioClient.dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      final body = response.data;
      if (body == null || body['success'] != true) {
        throw ApiException(message: 'Failed to load $path');
      }
      final data = body['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      throw ApiException(message: 'Unexpected $path response');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

/// Maps Laravel statistics payload into [StatisticsState] fields.
class ApiStatisticsMapper {
  static Map<String, double> doubleMap(dynamic raw) {
    if (raw is! Map) return const {};
    return raw.map(
      (key, value) => MapEntry(
        key.toString(),
        (value as num).toDouble(),
      ),
    );
  }

  static ({
    double totalIncome,
    double totalExpense,
    double currentBalance,
    Map<String, double> expenseByCategory,
    Map<String, double> incomeByCategory,
    Map<String, double> goalsProgress,
    Map<String, double> budgetsProgress,
  }) fromApi(Map<String, dynamic> data) {
    return (
      totalIncome: (data['total_income'] as num?)?.toDouble() ?? 0,
      totalExpense: (data['total_expense'] as num?)?.toDouble() ?? 0,
      currentBalance: (data['current_balance'] as num?)?.toDouble() ?? 0,
      expenseByCategory: doubleMap(data['expense_by_category']),
      incomeByCategory: doubleMap(data['income_by_category']),
      goalsProgress: doubleMap(data['goals_progress']),
      budgetsProgress: doubleMap(data['budgets_progress']),
    );
  }
}
