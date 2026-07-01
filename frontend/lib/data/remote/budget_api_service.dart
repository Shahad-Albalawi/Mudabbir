import 'package:dio/dio.dart';
import 'package:mudabbir/domain/models/budget_record.dart';
import 'package:mudabbir/data/network/api_exception.dart';
import 'package:mudabbir/data/network/dio_client.dart';

/// REST client for monthly budgets.
class BudgetApiService {
  final DioClient _dioClient;

  BudgetApiService(this._dioClient);

  Future<List<BudgetRecord>> getBudgets() async {
    try {
      final response = await _dioClient.dio.get('/budgets');
      if (response.data['success'] == true) {
        final data = response.data['data'] as List<dynamic>;
        return data
            .map(
              (json) => BudgetRecord.fromMap(
                Map<String, dynamic>.from(json as Map),
              ),
            )
            .toList();
      }
      throw ApiException(message: 'Failed to load budgets');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<BudgetRecord> createBudget(Map<String, dynamic> payload) async {
    try {
      final response = await _dioClient.dio.post('/budgets', data: payload);
      if (response.data['success'] == true) {
        return BudgetRecord.fromMap(
          Map<String, dynamic>.from(response.data['data'] as Map),
        );
      }
      throw ApiException(message: 'Failed to create budget');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<BudgetRecord> updateBudget(int id, Map<String, dynamic> payload) async {
    try {
      final response = await _dioClient.dio.put('/budgets/$id', data: payload);
      final body = response.data;
      if (response.statusCode == 409 && body is Map<String, dynamic>) {
        throw ApiException(
          message: body['message'] as String? ?? 'Sync conflict',
          statusCode: 409,
          conflictData: body['data'],
        );
      }
      if (body is Map && body['success'] == true) {
        return BudgetRecord.fromMap(
          Map<String, dynamic>.from(body['data'] as Map),
        );
      }
      throw ApiException(message: 'Failed to update budget');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteBudget(int id) async {
    try {
      final response = await _dioClient.dio.delete('/budgets/$id');
      if (response.data['success'] == true) return;
      throw ApiException(message: 'Failed to delete budget');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
