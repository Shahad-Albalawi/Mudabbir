import 'package:dio/dio.dart';
import 'package:mudabbir/domain/models/expense_transaction.dart';
import 'package:mudabbir/data/network/api_exception.dart';
import 'package:mudabbir/presentation/server_challenges/utils/dio_client.dart';

/// REST client for expense transactions.
class ExpenseApiService {
  final DioClient _dioClient;

  ExpenseApiService(this._dioClient);

  Future<List<ExpenseTransaction>> getExpenses() async {
    try {
      final response = await _dioClient.dio.get('/expenses');
      if (response.data['success'] == true) {
        final data = response.data['data'] as List<dynamic>;
        return data
            .map((json) => ExpenseTransaction.fromMap(
                  Map<String, dynamic>.from(json as Map),
                ))
            .toList();
      }
      throw ApiException(message: 'Failed to load expenses');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<ExpenseTransaction> createExpense(Map<String, dynamic> payload) async {
    try {
      final response = await _dioClient.dio.post('/expenses', data: payload);
      if (response.data['success'] == true) {
        return ExpenseTransaction.fromMap(
          Map<String, dynamic>.from(response.data['data'] as Map),
        );
      }
      throw ApiException(message: 'Failed to create expense');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<ExpenseTransaction> updateExpense(
    int id,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dioClient.dio.put('/expenses/$id', data: payload);
      final body = response.data;
      if (response.statusCode == 409 && body is Map<String, dynamic>) {
        throw ApiException(
          message: body['message'] as String? ?? 'Sync conflict',
          statusCode: 409,
          conflictData: body['data'],
        );
      }
      if (body is Map && body['success'] == true) {
        return ExpenseTransaction.fromMap(
          Map<String, dynamic>.from(body['data'] as Map),
        );
      }
      throw ApiException(message: 'Failed to update expense');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      final response = await _dioClient.dio.delete('/expenses/$id');
      if (response.data['success'] == true) return;
      throw ApiException(message: 'Failed to delete expense');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
